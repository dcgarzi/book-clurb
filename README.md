# 📚 Book Club Ratings

A static site (GitHub Pages) backed by Supabase. Members browse past books and everyone's star ratings; only the admin (you) can write.

## Architecture

```
GitHub Pages (static)                    Supabase
┌─────────────────────┐                 ┌──────────────────────────┐
│ index.html (public) │──anon key──────▶│ RLS: SELECT for everyone │
│ admin.html (you)    │──email+password▶│ RLS: writes only for     │
│ config.js           │                 │      authenticated users │
└─────────────────────┘                 │ (signups disabled → the  │
                                        │  only auth user is you)  │
                                        └──────────────────────────┘
```

**Why no member logins:** members never write, and all names/ratings are visible to everyone by design (leaderboard style) — so the public page needs no auth at all. Security lives entirely in Postgres Row Level Security: the anon key can only `SELECT`. Only you hold the keys, via `admin.html`.

**Placeholder mode:** until `config.js` exists with real Supabase values, `index.html` automatically renders built-in placeholder data (12 books, 12 members, ~65% participation) with a banner saying so — open the file in a browser to evaluate the design. Once `config.js` is filled in, it switches to live data; the mock block can then be deleted or left alone.

**Schema** (see `schema.sql`):

| table   | columns                                                        |
|---------|----------------------------------------------------------------|
| members | id, name (unique), is_active                                   |
| books   | id, title, author, cover_url, goodreads_url, month_read (date) |
| ratings | id, book_id, member_id, stars (0.5–5.0 in half steps), unique (book_id, member_id) |

## Setup (one time, ~10 minutes)

### 1. Supabase

1. Create a project at [supabase.com](https://supabase.com) (free tier is plenty for this scale).
2. **SQL Editor** → paste the contents of `schema.sql` → Run.
3. **Authentication → Sign In / Up**: turn **off** "Allow new users to sign up". This is what makes "authenticated = admin" safe.
4. **Authentication → Users → Add user**: create yourself with your email + a strong password (use "Auto confirm user"). This is your admin login.
5. **Project Settings → API**: copy the Project URL and the `anon` `public` key.

### 2. This repo

1. Copy `config.example.js` → `config.js` and paste in the URL and anon key. (The anon key is public by design — committing it is fine.)
2. Push to a GitHub repo.
3. Repo **Settings → Pages** → Source: "Deploy from a branch" → `main`, `/ (root)` → Save.
4. Site appears at `https://<you>.github.io/<repo>/`. The admin page is at `.../admin.html`.

### 3. (Recommended) Lock auth to your domain

In Supabase **Authentication → URL Configuration**, set the Site URL to your GitHub Pages URL.

## Day-to-day (monthly)

1. Open `admin.html`, sign in.
2. **Add a book**: title, author, month, Goodreads link, cover URL.
   - Easy covers: `https://covers.openlibrary.org/b/isbn/<ISBN>-M.jpg`
   - Or right-click → "Copy image address" on the Goodreads cover.
3. **Ratings**: pick the book, click stars next to each member. Saves instantly; ✕ clears. Clicking your current star again toggles a half star (e.g. 4 → 3.5).
4. **Members**: add once; mark inactive when people drift off (their old ratings stay).

## Credits

The 5-star holographic cell effect adapts the "Holographic card (Pokemon style)" technique from [Effect.Labs' CSS holographic effects tutorial](https://effect-labs.com/en/pages/blog/effet-holographique-css.html) — dark base, color-dodge gradient sweep, fine holo grid — recolored to a celestial pink/blue/lavender palette and set to animate continuously.

## Notes & future ideas

- ~20 members × 12 books/yr is trivially inside Supabase free tier limits.
- The admin page is "hidden" only by URL — that's fine, because without your password it can't write anything. RLS is the real lock.
- Whole-star-only preference? Change the `check` constraint in `schema.sql` and skip the half-star toggle.
- Possible later additions: a "current book" banner, sort/filter by rating, a member leaderboard (most books rated), CSV export.
