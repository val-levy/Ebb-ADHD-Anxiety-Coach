-- Chat history, one row per message. No chat UI yet; the table is ready for it.
create table chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  body text not null check (char_length(body) between 1 and 20000),
  created_at timestamptz not null default now()
);

create index chat_messages_user_time on chat_messages (user_id, created_at);

alter table chat_messages enable row level security;

create policy "own rows" on chat_messages for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
