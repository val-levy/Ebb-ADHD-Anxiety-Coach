-- Brain dump text, one row per user (upserted as they type).
create table notes (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  body text not null default '' check (char_length(body) <= 20000),
  updated_at timestamptz not null default now()
);

alter table notes enable row level security;

create policy "own rows" on notes for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
