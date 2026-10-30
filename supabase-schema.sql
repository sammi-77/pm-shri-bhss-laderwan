-- Run in the Supabase SQL Editor. Create an administrator in Authentication first,
-- then set app_metadata.role = 'admin' for that account using a trusted server-side
-- admin tool. Never expose the service role key in this website.
create table if not exists public.site_content (
  section text primary key check (section in ('notices','staff','students','alumni','datesheets','gallery')),
  items jsonb not null default '[]'::jsonb check (jsonb_typeof(items) = 'array'),
  updated_at timestamptz not null default now()
);
create table if not exists public.complaints (
  id uuid primary key default gen_random_uuid(),
  class smallint not null check (class between 9 and 12),
  name text check (name is null or length(name) <= 100),
  subject text not null check (length(subject) between 1 and 140),
  message text not null check (length(message) between 10 and 3000),
  created_at timestamptz not null default now()
);
alter table public.site_content enable row level security;
alter table public.complaints enable row level security;
drop policy if exists "Public can read published school content" on public.site_content;
create policy "Public can read published school content" on public.site_content for select to anon, authenticated using (true);
drop policy if exists "Admins manage school content" on public.site_content;
create policy "Admins manage school content" on public.site_content for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
drop policy if exists "Anyone can submit a complaint" on public.complaints;
create policy "Anyone can submit a complaint" on public.complaints for insert to anon, authenticated with check (true);
drop policy if exists "Admins read complaints" on public.complaints;
create policy "Admins read complaints" on public.complaints for select to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
revoke all on public.site_content from anon, authenticated;
grant select on public.site_content to anon, authenticated;
grant insert, update, delete on public.site_content to authenticated;
revoke all on public.complaints from anon, authenticated;
grant insert on public.complaints to anon, authenticated;
grant select on public.complaints to authenticated;
