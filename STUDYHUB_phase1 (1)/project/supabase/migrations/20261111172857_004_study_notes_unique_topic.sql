/*
# Add unique constraint on study_notes.topic_id

## Summary
Each topic should have exactly one current study note. Add a unique constraint
on study_notes.topic_id so upserts (ON CONFLICT) work for content seeding.

## Changes
- ALTER TABLE public.study_topics ADD CONSTRAINT study_notes_topic_id_key UNIQUE (topic_id)
*/
do $$ begin
  if not exists (
    select 1 from pg_constraint where conname = 'study_notes_topic_id_key'
      and conrelid = 'public.study_notes'::regclass
  ) then
    alter table public.study_notes add constraint study_notes_topic_id_key unique (topic_id);
  end if;
end $$;
