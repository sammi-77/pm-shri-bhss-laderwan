-- Admission requests contain student and guardian contact details.
-- Visitors can submit requests but cannot read or modify any request.
-- Only authenticated users with app_metadata.role = 'admin' can read/update them.
create table if not exists public.admission_applications (
  id uuid primary key default gen_random_uuid(),
  student_name text not null check (length(student_name) between 2 and 100),
  class_applying smallint not null check (class_applying between 9 and 12),
  guardian_name text not null check (length(guardian_name) between 2 and 100),
  guardian_phone text not null check (
    length(guardian_phone) between 7 and 24
    and length(regexp_replace(guardian_phone, '[^0-9]', '', 'g')) between 7 and 15
  ),
  previous_school text check (previous_school is null or length(previous_school) <= 120),
  message text check (message is null or length(message) <= 600),
  status text not null default 'new' check (status in ('new', 'reviewed')),
  created_at timestamptz not null default now()
);

alter table public.admission_applications enable row level security;

drop policy if exists "Anyone can submit an admission request" on public.admission_applications;
create policy "Anyone can submit an admission request"
  on public.admission_applications for insert to anon, authenticated
  with check (true);

drop policy if exists "Admins read admission requests" on public.admission_applications;
create policy "Admins read admission requests"
  on public.admission_applications for select to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins update admission request status" on public.admission_applications;
create policy "Admins update admission request status"
  on public.admission_applications for update to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

revoke all on public.admission_applications from public, anon, authenticated;
grant insert (student_name, class_applying, guardian_name, guardian_phone, previous_school, message)
  on public.admission_applications to anon, authenticated;
grant select, update on public.admission_applications to authenticated;

