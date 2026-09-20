# 📖 The Cultured Peoples of San Francisco Book Clurb

A static site on GitHub Pages where the GitHub repo itself is the database. Members browse books, everyone's star ratings, and recommendations; only the admin (you) can write.

## Architecture (v2 — post-Supabase)

```
GitHub repo
├── index.html    ← public site (reads data.json + published Google Sheet)
├── admin.html    ← writer's desk (writes data.json as commits, via your token)
├── data.json     ← THE DATABASE: members, books, ratings
└── config.js     ← repo coordinates + recommendation links (public-safe)

Recommendations: Google Form → Google Sheet → "Publish to web" CSV → index.html
```

**Why no backend at all:** ~20 readers, one writer, a handful of writes a month. The public site fetches `data.json` from its own host (fast, free, unpausable). Your admin page edits that file through GitHub's Contents API — every save is a commit, so the entire rating history is version-controlled and recoverable. Security model: writes require your GitHub personal access token, which only you hold, entered on admin.html and stored only in your browser. Members can't write anything; there's nothing to hack but GitHub itself.

**Trade-off to know:** after a save, GitHub Pages redeploys, so the public site reflects changes in ~30–60 seconds (the admin page sees them instantly). Fine for a monthly cadence.

## Setup

1. **data.json** — the database file, committed to the repo root. Migrating from Supabase: run `migrate.sql` in the Supabase SQL Editor, copy the single cell it returns, and paste it into a new `data.json` (GitHub → Add file → Create new file).
2. **config.js** — set `GITHUB_OWNER` and `GITHUB_REPO` to this repo's coordinates (see `config.example.js`). Add the three `RECS_*` links when the Google Form exists.
3. **Personal access token** (your admin key): github.com → Settings → Developer settings → Personal access tokens → **Fine-grained tokens** → Generate. Repository access: *Only select repositories* → this repo. Permissions: **Contents: Read and write**. Nothing else. Set a long expiration; when it lapses, generate a new one and sign in again.
4. **GitHub Pages**: repo Settings → Pages → Deploy from branch → `main`, root. Site at `https://<you>.github.io/<repo>/`, admin at `/admin.html`.

## Day-to-day (monthly)

1. Open `/admin.html` — sign in with your token if asked (it's remembered per browser).
2. **Books**: add this month's pick (title, author, month, Goodreads link, cover URL — Open Library covers: `https://covers.openlibrary.org/b/isbn/<ISBN>-M.jpg`). The same panel edits or deletes existing books.
3. **Ratings**: pick the book, click stars (right half = whole, left half = half star, ✕ clears). Changes batch into a commit a moment after you stop clicking — watch for "saved ✓".
4. **Members**: add, rename, or deactivate (deactivating hides them and their ratings from the public site; nothing is deleted).
5. **Recommendations**: edit the Google Sheet directly — it's the admin surface for that tab.

## Recommendations flow

Google Form (members submit) → linked responses Sheet → File → Share → **Publish to web** → that tab as **CSV** → paste the link as `RECS_CSV_URL` in config.js. `RECS_FORM_URL` (form share link) powers the "Recommend a book" button; `RECS_SHEET_URL` (normal sheet URL) gives admin.html its edit links. Anything in the published tab appears on the site within a few minutes — deleting a row is the moderation tool.

## Credits

The 5-star holographic cell effect adapts the "Holographic card (Pokemon style)" technique from [Effect.Labs' CSS holographic effects tutorial](https://effect-labs.com/en/pages/blog/effet-holographique-css.html) — dark base, color-dodge gradient sweep, fine holo grid — recolored to a celestial pink/blue/lavender palette and set to animate continuously.

## Notes & future ideas

- Every data change is a commit: `git log -- data.json` is your audit trail, and reverting a mistake is reverting a commit.
- The admin page is "hidden" only by URL — that's fine; without your token it can't write anything.
- Legacy files from the Supabase era (`schema.sql`, `seed.sql`, `migrate.sql`) can be deleted from the repo once the migration is done and verified.
- Possible later additions: a "current book" banner, a member leaderboard, CSV export, custom domain.
