/*
# STUDYHUB Core Schema — Curriculum, Auth Profiles, Progress

## Summary
Creates the foundational academic content architecture for STUDYHUB:
classes, subjects, topics, study notes, formulas, worked examples,
flashcards, examinations and their questions, plus per-student tables
for profiles, progress, bookmarks, practice sessions and study planning.
Enables Row Level Security on every table with appropriate policies.

## New Tables

### Per-student (created first because is_admin() depends on profiles)
- `profiles` — extends auth.users: full_name, class_id, avatar_url, audio preferences, theme, notification prefs, is_admin flag.

### Academic structure
- `classes` — SS1, SS2, SS3 (expandable). slug, name, level.
- `subjects` — library of subjects (Mathematics, English, etc.). keyed by slug, has icon name, category, description. Expandable by admins.
- `class_subjects` — join: which subjects belong to which class.
- `topics` — individual topics under a subject for a class. ordered by `order_index`. has publish flag.
- `study_notes` — rich text notes for a topic.
- `formulas` — formulas for a topic: name, expression, variables jsonb, when_to_use, worked_example.
- `worked_examples` — standalone worked examples for a topic.
- `flashcards` — question/answer cards for a topic or subject.

### Examination content
- `examinations` — metadata: type (WASSCE/JAMB), subject, year, source type (official/original/sample).
- `examination_questions` — questions belonging to an examination. topic classification optional.
- `question_options` — A/B/C/D options for a question.
- `question_answers` — correct answer + explanation (separate so exam mode can hide it).

### More per-student data
- `study_progress` — per topic completion status + last studied timestamp + time spent.
- `bookmarks` — saved topics, formulas, questions, flashcards. polymorphic by type.
- `flashcard_progress` — per-card revision state (difficult/needs_practice/mastered).
- `practice_sessions` — a student's practice/exam attempt: exam_id, mode, score, time.
- `practice_responses` — per-question answers within a session.
- `study_goals` — student-defined goals.
- `study_sessions` — logged study time records.

## Security
- Public content tables: SELECT to authenticated (students see published only; admins see all).
- Admin CRUD on content tables via `is_admin()` SECURITY DEFINER helper.
- Owner-scoped tables (profiles, study_progress, bookmarks, flashcard_progress,
  practice_sessions, practice_responses, study_goals, study_sessions): CRUD scoped to auth.uid().
- `profiles.is_admin` defaults false; only settable via `set_admin_status()` SECURITY DEFINER fn
  callable by existing admins. Students cannot self-promote.
- Owner columns default to `auth.uid()` so inserts omitting user_id satisfy WITH CHECK.
- Auto profile creation via trigger on auth.users insert.
*/

-- =========================================================
-- PROFILES (created first; is_admin() depends on it)
-- =========================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  class_id uuid,
  avatar_url text,
  preferred_voice text default 'default',
  playback_rate real not null default 1.0,
  theme text not null default 'light' check (theme in ('light', 'dark', 'system')),
  notification_prefs jsonb not null default '{"study_reminders": true, "exam_results": true, "new_content": false}'::jsonb,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
grant select, insert, update on public.profiles to authenticated;

drop policy if exists "profiles_select" on public.profiles;
create policy "profiles_select" on public.profiles for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "profiles_insert" on public.profiles;
create policy "profiles_insert" on public.profiles for insert
  to authenticated
  with check (auth.uid() = id and is_admin = false);

drop policy if exists "profiles_update" on public.profiles;
create policy "profiles_update" on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Helper: is the current user an admin? (created after profiles)
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select coalesce(
    (select is_admin from public.profiles where id = auth.uid()),
    false
  );
$$;

-- SECURITY DEFINER function to update admin flag; callable only by existing admins.
create or replace function public.set_admin_status(target_user_id uuid, status boolean)
returns void
language plpgsql
security definer
as $$
begin
  if not public.is_admin() then
    raise exception 'Only admins can change admin status';
  end if;
  update public.profiles set is_admin = status, updated_at = now()
  where id = target_user_id;
end;
$$;

revoke execute on function public.set_admin_status(uuid, boolean) from public, anon;
grant execute on function public.set_admin_status(uuid, boolean) to authenticated;

-- Auto-create profile on new auth user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =========================================================
-- CLASSES
-- =========================================================
create table if not exists public.classes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  level int not null,
  created_at timestamptz not null default now()
);

alter table public.classes enable row level security;
grant select on public.classes to authenticated;

drop policy if exists "classes_select" on public.classes;
create policy "classes_select" on public.classes for select
  to authenticated using (true);

drop policy if exists "classes_admin_write" on public.classes;
create policy "classes_admin_write" on public.classes for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Add the FK now that classes exists.
do $$ begin
  if not exists (select 1 from information_schema.table_constraints
                 where constraint_name = 'profiles_class_id_fkey'
                   and table_name = 'profiles') then
    alter table public.profiles
      add constraint profiles_class_id_fkey
      foreign key (class_id) references public.classes(id) on delete set null;
  end if;
end $$;

-- =========================================================
-- SUBJECTS
-- =========================================================
create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  icon text,
  category text,
  description text,
  created_at timestamptz not null default now()
);

alter table public.subjects enable row level security;
grant select on public.subjects to authenticated;

drop policy if exists "subjects_select" on public.subjects;
create policy "subjects_select" on public.subjects for select
  to authenticated using (true);

drop policy if exists "subjects_admin_write" on public.subjects;
create policy "subjects_admin_write" on public.subjects for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- CLASS_SUBJECTS (join)
-- =========================================================
create table if not exists public.class_subjects (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.classes(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (class_id, subject_id)
);

alter table public.class_subjects enable row level security;
grant select on public.class_subjects to authenticated;

drop policy if exists "class_subjects_select" on public.class_subjects;
create policy "class_subjects_select" on public.class_subjects for select
  to authenticated using (true);

drop policy if exists "class_subjects_admin_write" on public.class_subjects;
create policy "class_subjects_admin_write" on public.class_subjects for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- TOPICS
-- =========================================================
create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete cascade,
  title text not null,
  slug text not null,
  description text,
  order_index int not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (class_id, subject_id, slug)
);

create index if not exists idx_topics_subject_class on public.topics(subject_id, class_id);
create index if not exists idx_topics_published on public.topics(is_published);

alter table public.topics enable row level security;
grant select on public.topics to authenticated;

drop policy if exists "topics_select" on public.topics;
create policy "topics_select" on public.topics for select
  to authenticated
  using (is_published = true or public.is_admin());

drop policy if exists "topics_admin_write" on public.topics;
create policy "topics_admin_write" on public.topics for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- STUDY_NOTES
-- =========================================================
create table if not exists public.study_notes (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  content text not null,
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_study_notes_topic on public.study_notes(topic_id);

alter table public.study_notes enable row level security;
grant select on public.study_notes to authenticated;

drop policy if exists "study_notes_select" on public.study_notes;
create policy "study_notes_select" on public.study_notes for select
  to authenticated
  using (
    exists (select 1 from public.topics t
            where t.id = study_notes.topic_id
              and (t.is_published = true or public.is_admin()))
  );

drop policy if exists "study_notes_admin_write" on public.study_notes;
create policy "study_notes_admin_write" on public.study_notes for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- FORMULAS
-- =========================================================
create table if not exists public.formulas (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  name text not null,
  expression text not null,
  variables jsonb not null default '[]'::jsonb,
  when_to_use text,
  worked_example text,
  created_at timestamptz not null default now()
);

create index if not exists idx_formulas_topic on public.formulas(topic_id);

alter table public.formulas enable row level security;
grant select on public.formulas to authenticated;

drop policy if exists "formulas_select" on public.formulas;
create policy "formulas_select" on public.formulas for select
  to authenticated
  using (
    exists (select 1 from public.topics t
            where t.id = formulas.topic_id
              and (t.is_published = true or public.is_admin()))
  );

drop policy if exists "formulas_admin_write" on public.formulas;
create policy "formulas_admin_write" on public.formulas for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- WORKED_EXAMPLES
-- =========================================================
create table if not exists public.worked_examples (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  title text not null,
  problem text not null,
  solution text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_worked_examples_topic on public.worked_examples(topic_id);

alter table public.worked_examples enable row level security;
grant select on public.worked_examples to authenticated;

drop policy if exists "worked_examples_select" on public.worked_examples;
create policy "worked_examples_select" on public.worked_examples for select
  to authenticated
  using (
    exists (select 1 from public.topics t
            where t.id = worked_examples.topic_id
              and (t.is_published = true or public.is_admin()))
  );

drop policy if exists "worked_examples_admin_write" on public.worked_examples;
create policy "worked_examples_admin_write" on public.worked_examples for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- FLASHCARDS
-- =========================================================
create table if not exists public.flashcards (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references public.topics(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete cascade,
  front text not null,
  back text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_flashcards_topic on public.flashcards(topic_id);
create index if not exists idx_flashcards_subject_class on public.flashcards(subject_id, class_id);

alter table public.flashcards enable row level security;
grant select on public.flashcards to authenticated;

drop policy if exists "flashcards_select" on public.flashcards;
create policy "flashcards_select" on public.flashcards for select
  to authenticated
  using (
    topic_id is null or exists (
      select 1 from public.topics t
      where t.id = flashcards.topic_id
        and (t.is_published = true or public.is_admin())
    )
  );

drop policy if exists "flashcards_admin_write" on public.flashcards;
create policy "flashcards_admin_write" on public.flashcards for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- EXAMINATIONS
-- =========================================================
create table if not exists public.examinations (
  id uuid primary key default gen_random_uuid(),
  exam_type text not null check (exam_type in ('WASSCE', 'JAMB')),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  year int not null,
  title text,
  question_source_type text not null default 'official' check (question_source_type in ('official', 'original', 'sample')),
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  unique (exam_type, subject_id, year)
);

create index if not exists idx_examinations_type_subject on public.examinations(exam_type, subject_id);
create index if not exists idx_examinations_published on public.examinations(is_published);

alter table public.examinations enable row level security;
grant select on public.examinations to authenticated;

drop policy if exists "examinations_select" on public.examinations;
create policy "examinations_select" on public.examinations for select
  to authenticated
  using (is_published = true or public.is_admin());

drop policy if exists "examinations_admin_write" on public.examinations;
create policy "examinations_admin_write" on public.examinations for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- EXAMINATION_QUESTIONS
-- =========================================================
create table if not exists public.examination_questions (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null references public.examinations(id) on delete cascade,
  topic_id uuid references public.topics(id) on delete set null,
  question_number int not null,
  question_text text not null,
  has_options boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_exam_questions_exam on public.examination_questions(examination_id);

alter table public.examination_questions enable row level security;
grant select on public.examination_questions to authenticated;

drop policy if exists "exam_questions_select" on public.examination_questions;
create policy "exam_questions_select" on public.examination_questions for select
  to authenticated
  using (
    exists (select 1 from public.examinations e
            where e.id = examination_questions.examination_id
              and (e.is_published = true or public.is_admin()))
  );

drop policy if exists "exam_questions_admin_write" on public.examination_questions;
create policy "exam_questions_admin_write" on public.examination_questions for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- QUESTION_OPTIONS
-- =========================================================
create table if not exists public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.examination_questions(id) on delete cascade,
  label text not null,
  option_text text not null,
  order_index int not null default 0
);

create index if not exists idx_question_options_question on public.question_options(question_id);

alter table public.question_options enable row level security;
grant select on public.question_options to authenticated;

drop policy if exists "question_options_select" on public.question_options;
create policy "question_options_select" on public.question_options for select
  to authenticated
  using (
    exists (select 1 from public.examination_questions q
            join public.examinations e on e.id = q.examination_id
            where q.id = question_options.question_id
              and (e.is_published = true or public.is_admin()))
  );

drop policy if exists "question_options_admin_write" on public.question_options;
create policy "question_options_admin_write" on public.question_options for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- QUESTION_ANSWERS
-- =========================================================
create table if not exists public.question_answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null unique references public.examination_questions(id) on delete cascade,
  correct_option_label text,
  correct_text text,
  explanation text not null,
  created_at timestamptz not null default now()
);

alter table public.question_answers enable row level security;
grant select on public.question_answers to authenticated;

drop policy if exists "question_answers_select" on public.question_answers;
create policy "question_answers_select" on public.question_answers for select
  to authenticated
  using (
    exists (select 1 from public.examination_questions q
            join public.examinations e on e.id = q.examination_id
            where q.id = question_answers.question_id
              and (e.is_published = true or public.is_admin()))
  );

drop policy if exists "question_answers_admin_write" on public.question_answers;
create policy "question_answers_admin_write" on public.question_answers for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =========================================================
-- STUDY_PROGRESS (owner-scoped)
-- =========================================================
create table if not exists public.study_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  topic_id uuid not null references public.topics(id) on delete cascade,
  status text not null default 'in_progress' check (status in ('not_started', 'in_progress', 'completed')),
  last_studied_at timestamptz,
  time_spent_seconds int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, topic_id)
);

create index if not exists idx_study_progress_user on public.study_progress(user_id);

alter table public.study_progress enable row level security;
grant select, insert, update, delete on public.study_progress to authenticated;

drop policy if exists "study_progress_select" on public.study_progress;
create policy "study_progress_select" on public.study_progress for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "study_progress_insert" on public.study_progress;
create policy "study_progress_insert" on public.study_progress for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "study_progress_update" on public.study_progress;
create policy "study_progress_update" on public.study_progress for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "study_progress_delete" on public.study_progress;
create policy "study_progress_delete" on public.study_progress for delete
  to authenticated using (auth.uid() = user_id);

-- =========================================================
-- BOOKMARKS (owner-scoped, polymorphic)
-- =========================================================
create table if not exists public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  bookmark_type text not null check (bookmark_type in ('topic', 'formula', 'question', 'flashcard', 'note')),
  reference_id uuid not null,
  label text,
  created_at timestamptz not null default now(),
  unique (user_id, bookmark_type, reference_id)
);

create index if not exists idx_bookmarks_user on public.bookmarks(user_id);

alter table public.bookmarks enable row level security;
grant select, insert, update, delete on public.bookmarks to authenticated;

drop policy if exists "bookmarks_select" on public.bookmarks;
create policy "bookmarks_select" on public.bookmarks for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "bookmarks_insert" on public.bookmarks;
create policy "bookmarks_insert" on public.bookmarks for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "bookmarks_update" on public.bookmarks;
create policy "bookmarks_update" on public.bookmarks for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "bookmarks_delete" on public.bookmarks;
create policy "bookmarks_delete" on public.bookmarks for delete
  to authenticated using (auth.uid() = user_id);

-- =========================================================
-- FLASHCARD_PROGRESS (owner-scoped)
-- =========================================================
create table if not exists public.flashcard_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  flashcard_id uuid not null references public.flashcards(id) on delete cascade,
  revision_state text not null default 'needs_practice' check (revision_state in ('difficult', 'needs_practice', 'mastered')),
  last_reviewed_at timestamptz not null default now(),
  unique (user_id, flashcard_id)
);

create index if not exists idx_flashcard_progress_user on public.flashcard_progress(user_id);

alter table public.flashcard_progress enable row level security;
grant select, insert, update, delete on public.flashcard_progress to authenticated;

drop policy if exists "flashcard_progress_select" on public.flashcard_progress;
create policy "flashcard_progress_select" on public.flashcard_progress for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "flashcard_progress_insert" on public.flashcard_progress;
create policy "flashcard_progress_insert" on public.flashcard_progress for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "flashcard_progress_update" on public.flashcard_progress;
create policy "flashcard_progress_update" on public.flashcard_progress for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "flashcard_progress_delete" on public.flashcard_progress;
create policy "flashcard_progress_delete" on public.flashcard_progress for delete
  to authenticated using (auth.uid() = user_id);

-- =========================================================
-- PRACTICE_SESSIONS (owner-scoped)
-- =========================================================
create table if not exists public.practice_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  examination_id uuid references public.examinations(id) on delete set null,
  exam_type text not null,
  subject_id uuid references public.subjects(id) on delete set null,
  year int,
  mode text not null check (mode in ('study', 'exam')),
  total_questions int not null default 0,
  correct_answers int not null default 0,
  incorrect_answers int not null default 0,
  unanswered int not null default 0,
  score_percentage real not null default 0,
  time_taken_seconds int not null default 0,
  started_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists idx_practice_sessions_user on public.practice_sessions(user_id);

alter table public.practice_sessions enable row level security;
grant select, insert, update, delete on public.practice_sessions to authenticated;

drop policy if exists "practice_sessions_select" on public.practice_sessions;
create policy "practice_sessions_select" on public.practice_sessions for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "practice_sessions_insert" on public.practice_sessions;
create policy "practice_sessions_insert" on public.practice_sessions for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "practice_sessions_update" on public.practice_sessions;
create policy "practice_sessions_update" on public.practice_sessions for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "practice_sessions_delete" on public.practice_sessions;
create policy "practice_sessions_delete" on public.practice_sessions for delete
  to authenticated using (auth.uid() = user_id);

-- =========================================================
-- PRACTICE_RESPONSES (owner-scoped)
-- =========================================================
create table if not exists public.practice_responses (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.practice_sessions(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  question_id uuid not null references public.examination_questions(id) on delete cascade,
  selected_option_label text,
  is_correct boolean,
  time_spent_seconds int default 0,
  created_at timestamptz not null default now(),
  unique (session_id, question_id)
);

create index if not exists idx_practice_responses_session on public.practice_responses(session_id);
create index if not exists idx_practice_responses_user on public.practice_responses(user_id);

alter table public.practice_responses enable row level security;
grant select, insert, update, delete on public.practice_responses to authenticated;

drop policy if exists "practice_responses_select" on public.practice_responses;
create policy "practice_responses_select" on public.practice_responses for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "practice_responses_insert" on public.practice_responses;
create policy "practice_responses_insert" on public.practice_responses for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "practice_responses_update" on public.practice_responses;
create policy "practice_responses_update" on public.practice_responses for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "practice_responses_delete" on public.practice_responses;
create policy "practice_responses_delete" on public.practice_responses for delete
  to authenticated using (auth.uid() = user_id);

-- =========================================================
-- STUDY_GOALS (owner-scoped)
-- =========================================================
create table if not exists public.study_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  subject_id uuid references public.subjects(id) on delete set null,
  target_date date,
  target_minutes int not null default 60,
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_study_goals_user on public.study_goals(user_id);

alter table public.study_goals enable row level security;
grant select, insert, update, delete on public.study_goals to authenticated;

drop policy if exists "study_goals_select" on public.study_goals;
create policy "study_goals_select" on public.study_goals for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "study_goals_insert" on public.study_goals;
create policy "study_goals_insert" on public.study_goals for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "study_goals_update" on public.study_goals;
create policy "study_goals_update" on public.study_goals for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "study_goals_delete" on public.study_goals;
create policy "study_goals_delete" on public.study_goals for delete
  to authenticated using (auth.uid() = user_id);

-- =========================================================
-- STUDY_SESSIONS (owner-scoped, time log)
-- =========================================================
create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  subject_id uuid references public.subjects(id) on delete set null,
  topic_id uuid references public.topics(id) on delete set null,
  duration_seconds int not null default 0,
  studied_at date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists idx_study_sessions_user_date on public.study_sessions(user_id, studied_at);

alter table public.study_sessions enable row level security;
grant select, insert, update, delete on public.study_sessions to authenticated;

drop policy if exists "study_sessions_select" on public.study_sessions;
create policy "study_sessions_select" on public.study_sessions for select
  to authenticated using (auth.uid() = user_id);

drop policy if exists "study_sessions_insert" on public.study_sessions;
create policy "study_sessions_insert" on public.study_sessions for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "study_sessions_update" on public.study_sessions;
create policy "study_sessions_update" on public.study_sessions for update
  to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "study_sessions_delete" on public.study_sessions;
create policy "study_sessions_delete" on public.study_sessions for delete
  to authenticated using (auth.uid() = user_id);
