// Deletes the signed-in (non-anonymous) caller. Their rows go with them via `on delete cascade`.
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization");
  if (!auth) return new Response("unauthorized", { status: 401 });

  const url = Deno.env.get("SUPABASE_URL")!;
  const asCaller = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
  });
  const { data, error } = await asCaller.auth.getUser();
  if (error || !data.user) return new Response("unauthorized", { status: 401 });
  if (data.user.is_anonymous) return new Response("anonymous users can't delete", { status: 403 });

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { error: delErr } = await admin.auth.admin.deleteUser(data.user.id);
  if (delErr) return new Response(delErr.message, { status: 500 });
  return new Response(null, { status: 200 });
});
