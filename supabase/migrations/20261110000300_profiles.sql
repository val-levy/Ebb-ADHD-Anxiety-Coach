-- Profiles: a row here means "signed in". Anonymous users can't create one.
create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_]{3,20}$'),
  display_name text not null check (char_length(display_name) between 1 and 40),
  bio text check (bio is null or char_length(bio) <= 160),
  animal text not null default 'panda',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy profiles_select_own on public.profiles for select to authenticated
  using (id = (select auth.uid()));
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy profiles_insert_own on public.profiles for insert to authenticated
  with check (id = (select auth.uid())
    and not coalesce(((select auth.jwt())->>'is_anonymous')::boolean, false));

-- Own-row RLS hides other names, so availability goes through a definer function.
create function public.username_available(name text) returns boolean
language sql stable security definer set search_path = '' as $$
  select not exists (select 1 from public.profiles where username = lower(trim(name)));
$$;
revoke execute on function public.username_available(text) from public;
grant execute on function public.username_available(text) to authenticated;

-- Apple refresh tokens, written only by Edge Functions with the service role.
create schema if not exists private;
create table private.apple_tokens (
  user_id uuid primary key references auth.users on delete cascade,
  refresh_token text not null
);
revoke all on schema private from anon, authenticated;
