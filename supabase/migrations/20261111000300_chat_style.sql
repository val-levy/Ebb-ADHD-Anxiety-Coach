-- Optional extra instructions the user adds for the chat's tone and style. Read-only to the model, lowest priority.
create table chat_style (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  body text not null check (char_length(body) <= 500),
  updated_at timestamptz not null default now()
);

alter table chat_style enable row level security;

create policy "own rows" on chat_style for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
