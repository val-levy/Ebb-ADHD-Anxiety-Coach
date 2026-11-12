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

  const messages: any[] = [{ role: "system", content: SYSTEM }, ...history.map((m) => ({ role: m.role, content: m.body })), { role: "user", content: message }];
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
