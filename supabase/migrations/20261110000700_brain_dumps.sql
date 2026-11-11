-- One note per user becomes a history: many brain dumps per user. The "own rows" policy carries over the rename.
alter table notes rename to brain_dumps;
alter table brain_dumps drop constraint notes_pkey;
alter table brain_dumps add column id uuid primary key default gen_random_uuid();
alter table brain_dumps rename column updated_at to created_at;
create index brain_dumps_user_time on brain_dumps (user_id, created_at desc);
