-- Every reset a user does, plus their one-tap rating.
create type reset_kind as enum ('breathe', 'sigh', 'ground', 'body');

create table resets (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  kind       reset_kind not null,
  helped     boolean,                 -- null = skipped rating
  created_at timestamptz not null default now()
);

create index resets_user_time on resets (user_id, created_at desc);

-- RLS: the anon key ships in the app, so this is the only thing keeping users apart.
alter table resets enable row level security;

create policy "own rows" on resets for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
