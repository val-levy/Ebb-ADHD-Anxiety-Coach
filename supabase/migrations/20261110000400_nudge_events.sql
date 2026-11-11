-- Records each check-in offer and its optional response. These labels feed later personalization.
create type nudge_origin as enum ('planned', 'preview', 'signal');
create type nudge_outcome as enum ('shown', 'accepted', 'dismissed', 'snoozed', 'false_alarm');

create table nudge_events (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  origin     nudge_origin not null,
  outcome    nudge_outcome not null default 'shown',
  created_at timestamptz not null default now()
);

create index nudge_events_user_time on nudge_events (user_id, created_at desc);

alter table nudge_events enable row level security;

create policy "own rows" on nudge_events for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
