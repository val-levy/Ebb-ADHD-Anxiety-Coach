begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, email, is_anonymous) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test', false),
  ('00000000-0000-0000-0000-00000000000b', 'b@test', false),
  ('00000000-0000-0000-0000-00000000000c', null, true);

-- constraints (as postgres, bypassing RLS)
select throws_ok($$insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000a','ab','A')$$, '23514', null, 'rejects 2-char name');
select throws_ok($$insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000a','Abc','A')$$, '23514', null, 'rejects uppercase');
select throws_ok($$insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000a','abcdefghijklmnopqrstu','A')$$, '23514', null, 'rejects 21 chars');
select throws_ok($$insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000a','a b','A')$$, '23514', null, 'rejects space');
select throws_ok($$insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000a','abc','')$$, '23514', null, 'rejects empty display name');

-- anonymous user cannot insert
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated","is_anonymous":true}', true);
select throws_ok($$insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000c','anon_user','Anon')$$, '42501', null, 'anonymous insert blocked by RLS');

-- A inserts own row
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated","is_anonymous":false}', true);
insert into public.profiles(id,username,display_name) values ('00000000-0000-0000-0000-00000000000a','taken','A');

-- B cannot see A's row, but availability check works
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated","is_anonymous":false}', true);
select is((select count(*) from public.profiles)::int, 0, 'B cannot select A''s profile');
select is(public.username_available('taken'), false, 'taken name unavailable');
select is(public.username_available('free_name'), true, 'free name available');

select * from finish();
rollback;
