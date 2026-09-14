-- ============================================================
-- Book Club — Supabase schema
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor).
-- Security model:
--   * Everyone (anon key) can READ everything.
--   * Only an authenticated user can WRITE — and since email
--     signups are disabled (see README), the only authenticated
--     user is you, the admin.
-- ============================================================

-- ---------- Tables ----------

create table if not exists members (
  id         uuid primary key default gen_random_uuid(),
  name       text not null unique,
  is_active  boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists books (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  author        text not null,
  cover_url     text,           -- direct image URL (Open Library, Goodreads CDN, etc.)
  goodreads_url text,           -- link target for the title
  month_read    date not null,  -- use the 1st of the month, e.g. 2026-09-01
  created_at    timestamptz not null default now()
);

create table if not exists ratings (
  id         uuid primary key default gen_random_uuid(),
  book_id    uuid not null references books(id)   on delete cascade,
  member_id  uuid not null references members(id) on delete cascade,
  -- 0.5 to 5.0 in half-star steps (use whole numbers if you prefer)
  stars      numeric(2,1) not null
             check (stars >= 0.5 and stars <= 5.0 and (stars * 2) = floor(stars * 2)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (book_id, member_id)   -- one rating per member per book
);

create index if not exists ratings_book_id_idx   on ratings (book_id);
create index if not exists ratings_member_id_idx on ratings (member_id);
create index if not exists books_month_read_idx  on books (month_read desc);

-- ---------- Row Level Security ----------

alter table members enable row level security;
alter table books   enable row level security;
alter table ratings enable row level security;

-- Public, read-only access for the site (anon key)
create policy "public read members" on members for select using (true);
create policy "public read books"   on books   for select using (true);
create policy "public read ratings" on ratings for select using (true);

-- Full write access for authenticated users (only you — signups are disabled)
create policy "admin write members" on members for all
  to authenticated using (true) with check (true);
create policy "admin write books" on books for all
  to authenticated using (true) with check (true);
create policy "admin write ratings" on ratings for all
  to authenticated using (true) with check (true);

-- ---------- updated_at trigger for ratings ----------

create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists ratings_set_updated_at on ratings;
create trigger ratings_set_updated_at
  before update on ratings
  for each row execute function set_updated_at();
