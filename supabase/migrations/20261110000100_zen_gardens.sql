-- One zen garden per user: placed elements + rake strokes, stored as JSON (coordinates normalized 0..1).
create table zen_gardens (
  user_id    uuid primary key default auth.uid() references auth.users on delete cascade,
  items      jsonb not null default '[]',
  strokes    jsonb not null default '[]',
  updated_at timestamptz not null default now()
);

alter table zen_gardens enable row level security;

create policy "own garden" on zen_gardens for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
