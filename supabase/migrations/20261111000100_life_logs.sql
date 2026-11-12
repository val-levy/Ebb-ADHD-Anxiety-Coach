-- Things the user logs about their day: a dose they took, or a stressor they tagged.
-- source says whether it was tapped in manually or parsed from chat (chat parsing comes later).
create table life_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  kind text not null check (kind in ('dose', 'stressor')),
  tag text check (char_length(tag) <= 40),
  source text not null default 'manual' check (source in ('manual', 'chat')),
  created_at timestamptz not null default now()
);

create index life_logs_user_time on life_logs (user_id, created_at);

alter table life_logs enable row level security;

create policy "own rows" on life_logs for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
