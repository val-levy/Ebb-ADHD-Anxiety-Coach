-- Zen garden concept replaced by guided calm sessions (user decision, 2026-11-10).
drop table if exists zen_gardens;

-- One row per guided calm session: which program, intensity before/after (0-10), what helped most.
create table calm_sessions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null default auth.uid() references auth.users on delete cascade,
  program          text not null,
  intensity_before smallint not null check (intensity_before between 0 and 10),
  intensity_after  smallint check (intensity_after between 0 and 10),
  helped_technique text,
  created_at       timestamptz not null default now()
);

create index calm_sessions_user_time on calm_sessions (user_id, created_at desc);

alter table calm_sessions enable row level security;

create policy "own sessions" on calm_sessions for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
