-- What the chat remembers about a person: one short text per user, rewritten (never appended) by the chat function.
create table user_memory (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  body text not null check (char_length(body) <= 1000),
  updated_at timestamptz not null default now()
);

alter table user_memory enable row level security;

create policy "own rows" on user_memory for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
