-- ============================================================
-- Book Clurb — seed data (current state as of Sept 2026)
-- Run ONCE in the Supabase SQL Editor, after schema.sql.
-- (Running it twice would duplicate books — members and ratings
-- are protected by unique constraints, books are not.)
--
-- Note: 4.2s were rounded to 4.0 and 4.25 to 4.5 to fit the
-- half-star system.
-- ============================================================

-- ---------- Members (18) ----------

insert into members (name) values
  ('Dan'),
  ('Matt'),
  ('Ben'),
  ('Chris'),
  ('Daniel K'),
  ('Dru'),
  ('Evan'),
  ('Jacques'),
  ('Javaun'),
  ('Joel'),
  ('Josue'),
  ('Miguel'),
  ('Nigel'),
  ('Paul'),
  ('Peter'),
  ('Philip'),
  ('Robby'),
  ('Thibaut')
on conflict (name) do nothing;

-- ---------- Books (7) ----------
-- Cover URLs use Open Library's ISBN endpoint; any that miss just
-- show the site's placeholder and can be swapped via admin.html.
-- "John of John" is too new for a reliable ISBN — cover left blank.

insert into books (title, author, month_read, goodreads_url, cover_url) values
  ('The Lilac People', 'Milo Todd', '2026-04-01',
    'https://www.goodreads.com/search?q=The+Lilac+People+Milo+Todd',
    'https://covers.openlibrary.org/b/isbn/9781640096585-M.jpg'),
  ('A Psalm for the Wild-Built', 'Becky Chambers', '2026-05-01',
    'https://www.goodreads.com/search?q=A+Psalm+for+the+Wild-Built+Becky+Chambers',
    'https://covers.openlibrary.org/b/isbn/9781250236210-M.jpg'),
  ('Season of the Witch', 'David Talbot', '2026-06-01',
    'https://www.goodreads.com/search?q=Season+of+the+Witch+David+Talbot',
    'https://covers.openlibrary.org/b/isbn/9781439108246-M.jpg'),
  ('John of John', 'Douglas Stuart', '2026-07-01',
    'https://www.goodreads.com/search?q=John+of+John+Douglas+Stuart',
    null),
  ('China Mountain Zhang', 'Maureen F. McHugh', '2026-08-01',
    'https://www.goodreads.com/search?q=China+Mountain+Zhang+Maureen+McHugh',
    'https://covers.openlibrary.org/b/isbn/9780765328113-M.jpg'),
  ('Martyr!', 'Kaveh Akbar', '2026-09-01',
    'https://www.goodreads.com/search?q=Martyr+Kaveh+Akbar',
    'https://covers.openlibrary.org/b/isbn/9780593537619-M.jpg'),
  ('The Song of Achilles', 'Madeline Miller', '2026-10-01',
    'https://www.goodreads.com/search?q=The+Song+of+Achilles+Madeline+Miller',
    'https://covers.openlibrary.org/b/isbn/9780062060624-M.jpg');

-- ---------- Ratings ----------

insert into ratings (book_id, member_id, stars)
select b.id, m.id, v.stars
from (values
  -- The Lilac People
  ('The Lilac People', 'Dan',   5.0),
  ('The Lilac People', 'Josue', 4.0),
  ('The Lilac People', 'Matt',  4.0),
  ('The Lilac People', 'Joel',  4.0),
  -- A Psalm for the Wild-Built
  ('A Psalm for the Wild-Built', 'Josue', 4.0),  -- was 4.2
  ('A Psalm for the Wild-Built', 'Joel',  3.5),
  ('A Psalm for the Wild-Built', 'Robby', 3.5),
  ('A Psalm for the Wild-Built', 'Dan',   4.0),  -- was 4.2
  ('A Psalm for the Wild-Built', 'Matt',  4.0),
  -- Season of the Witch
  ('Season of the Witch', 'Robby',   3.0),
  ('Season of the Witch', 'Dan',     2.5),
  ('Season of the Witch', 'Josue',   3.0),
  ('Season of the Witch', 'Jacques', 3.0),
  ('Season of the Witch', 'Matt',    2.5),
  -- John of John
  ('John of John', 'Joel', 4.0),
  ('John of John', 'Matt', 4.0),
  ('John of John', 'Dan',  5.0),
  -- China Mountain Zhang
  ('China Mountain Zhang', 'Jacques', 3.0),
  ('China Mountain Zhang', 'Joel',    4.5),  -- was 4.25
  ('China Mountain Zhang', 'Robby',   3.5),
  ('China Mountain Zhang', 'Dan',     4.5)
  -- Martyr! (Sept) and The Song of Achilles (Oct): no ratings yet
) as v(title, member, stars)
join books   b on b.title = v.title
join members m on m.name  = v.member
on conflict (book_id, member_id) do nothing;

-- ---------- sanity check ----------
-- Expect: 18 members, 7 books, 21 ratings
select
  (select count(*) from members) as members,
  (select count(*) from books)   as books,
  (select count(*) from ratings) as ratings;
