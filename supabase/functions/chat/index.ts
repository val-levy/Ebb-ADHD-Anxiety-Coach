// The Ebb chat. The signed-in user sends a message; a model (via OpenRouter) replies and may call tools that
// log things for them. Every database call runs AS THE CALLER, so row-level security still applies.
// Secrets: OPENROUTER_API_KEY (required), OPENROUTER_MODEL (optional, defaults below).
import { createClient } from "jsr:@supabase/supabase-js@2";

const MODEL = Deno.env.get("OPENROUTER_MODEL") ?? "meta-llama/llama-3.3-70b-instruct:free";
const STRESSORS = ["Work", "Sleep", "Social", "Health", "Other"];

// Mirrors .claude/docs/wording-and-safety.md. Keep them in sync.
const SYSTEM = `You are Ebb's chat: a warm, calm companion inside a wellness app. Keep replies short (1-3 sentences), kind, never snarky.
Your job: listen, and quietly log what the person tells you by calling tools. Log only what they actually said.
- log_dose: they say they took a dose of their medication. This is a record only.
- log_stressor: they mention something weighing on them. tag must be one of ${STRESSORS.join(", ")}.
- save_brain_dump: they unload a long jumble of thoughts. Save their words as written.
After logging, say so briefly ("Noted.") and carry on the conversation.
Hard rules:
- Never give medication advice: never suggest taking, skipping, changing or retiming a dose, never remind anyone to take medication.
- Never diagnose or name a condition as something Ebb detects, treats, manages or monitors. Never say a problem "is" anxiety, ADHD, panic, etc.
- Never state cause ("X causes Y"). Say "often followed" or "came up".
- Suggestions are options ("want to try a quick reset?"), never orders. No stress numbers.
- If they mention thoughts of harming themselves or being in danger, respond with care and point them to the 988 Suicide & Crisis Lifeline (call or text 988 in the US), and stop there.`;

const TOOLS = [
  { type: "function", function: { name: "log_dose", description: "Record that the user took a dose of their medication.", parameters: { type: "object", properties: {} } } },
  { type: "function", function: { name: "log_stressor", description: "Record something weighing on the user.", parameters: { type: "object", properties: { tag: { type: "string", enum: STRESSORS } }, required: ["tag"] } } },
  { type: "function", function: { name: "save_brain_dump", description: "Save the user's unloaded thoughts, in their own words.", parameters: { type: "object", properties: { body: { type: "string" } }, required: ["body"] } } },
];

const RESET_NAMES: Record<string, string> = { breathe: "paced breathing", sigh: "physiological sigh", ground: "grounding", body: "body break" };
const MEMORY_EVERY = 10;   // rewrite the memory after this many new messages
const SUMMARIZER = `You keep a short memory about one person for their wellness chat. You get the current memory and recent messages.
Rewrite the memory as plain short lines, 800 characters max, replacing (never just appending to) the old one.
Keep only lasting things THEY said: preferred name, what they like or find helpful, recurring worries, how they like to be talked to.
Drop one-off events and anything stale. Never store diagnoses or condition labels, medication details or advice, or guesses. Do not invent.
Reply with the memory text only.`;

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization");
  if (!auth) return json({ error: "unauthorized" }, 401);
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, { global: { headers: { Authorization: auth } } });
  const { data: u, error: uErr } = await db.auth.getUser();
  if (uErr || !u.user) return json({ error: "unauthorized" }, 401);
  if (u.user.is_anonymous) return json({ error: "sign in to chat" }, 403);

  const { message } = await req.json().catch(() => ({}));
  if (typeof message !== "string" || !message.trim() || message.length > 4000) return json({ error: "bad message" }, 400);

  // Last 20 messages are the model's memory. ponytail: no rolling summary yet; add user_memory when 20 isn't enough.
  const { data: past } = await db.from("chat_messages").select("role,body").order("created_at", { ascending: false }).limit(20);
  const history = (past ?? []).reverse();
  await db.from("chat_messages").insert({ role: "user", body: message });

  const { data: mem } = await db.from("user_memory").select("body,updated_at").maybeSingle();
  const system = SYSTEM + (mem?.body ? `\nWhat you remember about this person:\n${mem.body}` : "") + await statsLine(db);

  const messages: any[] = [{ role: "system", content: system }, ...history.map((m) => ({ role: m.role, content: m.body })), { role: "user", content: message }];
  const actions: string[] = [];
  let reply = "";

  for (let round = 0; round < 3; round++) {
    const res = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: { Authorization: `Bearer ${Deno.env.get("OPENROUTER_API_KEY")}`, "Content-Type": "application/json" },
      // data_collection "deny": only route to providers that don't store or train on prompts.
      body: JSON.stringify({ model: MODEL, messages, tools: TOOLS, provider: { data_collection: "deny" } }),
    });
    if (!res.ok) {
      console.error("openrouter", res.status, (await res.text()).slice(0, 300));   // server logs only, never the client
      return json({ error: res.status === 429 ? "busy" : "model unavailable" }, 502);
    }
    const msg = (await res.json()).choices?.[0]?.message;
    if (!msg) return json({ error: "model unavailable" }, 502);
    if (!msg.tool_calls?.length) { reply = msg.content ?? ""; break; }

    messages.push(msg);
    for (const call of msg.tool_calls) {
      const args = (() => { try { return JSON.parse(call.function.arguments || "{}"); } catch { return {}; } })();
      messages.push({ role: "tool", tool_call_id: call.id, content: await runTool(db, call.function.name, args, actions) });
    }
  }
  reply = reply.trim() || "I'm here. Tell me more?";
  await db.from("chat_messages").insert({ role: "assistant", body: reply });
  const job = maybeUpdateMemory(db, mem);
  const rt = (globalThis as any).EdgeRuntime;
  if (rt?.waitUntil) rt.waitUntil(job); else await job;   // don't make the user wait for it
  return json({ reply, actions });
});

/// Runs one tool as the caller. Returns text for the model; records a short label in `actions` when a row was written.
async function runTool(db: ReturnType<typeof createClient>, name: string, args: any, actions: string[]): Promise<string> {
  let error: unknown = null;
  if (name === "log_dose") {
    ({ error } = await db.from("life_logs").insert({ kind: "dose", source: "chat" }));
    if (!error) actions.push("Logged a dose");
  } else if (name === "log_stressor" && STRESSORS.includes(args.tag)) {
    ({ error } = await db.from("life_logs").insert({ kind: "stressor", tag: args.tag, source: "chat" }));
    if (!error) actions.push(`Tagged ${args.tag}`);
  } else if (name === "save_brain_dump" && typeof args.body === "string" && args.body.trim()) {
    ({ error } = await db.from("brain_dumps").insert({ body: args.body.slice(0, 20000) }));
    if (!error) actions.push("Saved a brain dump");
  } else return "error: unknown tool or bad arguments";
  return error ? "error: could not save" : "ok";
}

/// One line of the person's own logged patterns, from tables the app already fills. Costs no stored tokens.
async function statsLine(db: ReturnType<typeof createClient>): Promise<string> {
  const month = new Date(Date.now() - 30 * 86400_000).toISOString();
  const week = new Date(Date.now() - 7 * 86400_000).toISOString();
  const [{ data: resets }, { data: logs }] = await Promise.all([
    db.from("resets").select("kind").eq("helped", true).gte("created_at", month),
    db.from("life_logs").select("tag").eq("kind", "stressor").gte("created_at", week),
  ]);
  const top = (xs: (string | null)[]) => {
    const n: Record<string, number> = {};
    for (const x of xs) if (x) n[x] = (n[x] ?? 0) + 1;
    return Object.entries(n).sort((a, b) => b[1] - a[1])[0]?.[0];
  };
  const best = top((resets ?? []).map((r) => RESET_NAMES[r.kind] ?? null));
  const stress = top((logs ?? []).map((l) => l.tag));
  const parts = [best && `reset that helped most this month: ${best}`, stress && `stressor tagged most this week: ${stress}`].filter(Boolean);
  return parts.length ? `\nTheir own logged patterns (mention only if relevant, never as cause): ${parts.join("; ")}.` : "";
}

/// Every MEMORY_EVERY new messages, rewrite the memory from the old one plus the new messages (capped, so it never grows).
async function maybeUpdateMemory(db: ReturnType<typeof createClient>, mem: { body: string; updated_at: string } | null) {
  try {
    let q = db.from("chat_messages").select("role,body", { count: "exact" }).order("created_at", { ascending: false }).limit(MEMORY_EVERY * 2);
    if (mem) q = q.gt("created_at", mem.updated_at);
    const { data: recent, count } = await q;
    if ((count ?? 0) < MEMORY_EVERY * 2) return;   // a message and its reply are two rows
    const transcript = (recent ?? []).reverse().map((m) => `${m.role}: ${m.body}`).join("\n");
    const res = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: { Authorization: `Bearer ${Deno.env.get("OPENROUTER_API_KEY")}`, "Content-Type": "application/json" },
      body: JSON.stringify({ model: MODEL, provider: { data_collection: "deny" }, messages: [
        { role: "system", content: SUMMARIZER },
        { role: "user", content: `Current memory:\n${mem?.body || "(empty)"}\n\nRecent messages:\n${transcript}` },
      ] }),
    });
    if (!res.ok) return;
    const body = ((await res.json()).choices?.[0]?.message?.content ?? "").trim().slice(0, 900);
    if (body) await db.from("user_memory").upsert({ body, updated_at: new Date().toISOString() });
  } catch (e) { console.error("memory update failed", e); }
}
