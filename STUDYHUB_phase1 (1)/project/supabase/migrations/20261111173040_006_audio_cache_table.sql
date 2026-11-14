/*
# Audio cache table for TTS edge function

## Summary
Stores generated Fish Audio speech as base64 so repeated reads of the same
study note do not re-generate audio (saving API calls and reducing latency).
Keyed by a SHA-256 hash of (text + voice + speed + format).

## New Table
- `audio_cache`
  - id text PK (the SHA-256 cache key)
  - audio_data text (base64-encoded mp3)
  - voice text
  - speed real
  - text_preview text (first 200 chars for admin inspection)
  - created_at timestamptz

## Security
- The table is written and read by the edge function using the service_role key,
  which bypasses RLS. No anon/authenticated grants are given — students never
  touch this table directly; they go through the edge function.
*/

create table if not exists public.audio_cache (
  id text primary key,
  audio_data text not null,
  voice text not null default 'default',
  speed real not null default 1.0,
  text_preview text,
  created_at timestamptz not null default now()
);

alter table public.audio_cache enable row level security;
-- No grants to anon/authenticated: only the service_role (edge function) accesses it.
grant select, insert on public.audio_cache to service_role;

-- Allow admins to view (but not modify) the cache for inspection.
drop policy if exists "audio_cache_admin_select" on public.audio_cache;
create policy "audio_cache_admin_select" on public.audio_cache for select
  to authenticated
  using (public.is_admin());

grant select on public.audio_cache to authenticated;
