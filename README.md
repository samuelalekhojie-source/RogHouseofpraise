# Realm of Glory Surulere — Website (Supabase edition)

One self-contained file, `realm-of-glory-surulere.html`. Pages: Home, About,
Sermons, Live, Events, Gallery, Give, Contact — plus a hidden `/#dashboard`
admin panel. Storage runs on **Supabase** (a real hosted Postgres database +
file storage), so it's genuinely public and handles large audio/video files.

## 1. Create your Supabase project
Go to https://supabase.com, sign up (free tier is plenty to start), and
create a new project. Wait ~2 minutes for it to finish provisioning.

## 2. Run the database setup
Open your project → **SQL Editor** → **New query** → paste in the entire
contents of `schema.sql` (included in this zip) → **Run**.

This creates all six tables, sets up security rules (visitors can read
everything and submit the contact/prayer forms; only a signed-in admin can
edit content or read submitted prayer requests/messages), and pre-fills the
site with Realm of Glory's real vision, mission, values, leadership team and
weekly meeting schedule.

## 3. Create the storage bucket
Your project → **Storage** → **New bucket** → name it exactly `media` →
turn **Public bucket** ON → Create. (The upload/read/delete permissions for
this bucket were already set up by `schema.sql` in step 2.)

## 4. Create your admin login
Your project → **Authentication** → **Users** → **Add user** → enter an
email and password for yourself (or anyone on staff who needs dashboard
access). This is what you'll use to sign in at `/#dashboard` — there's no
more shared passcode.

## 5. Connect the site to your project
Your project → **Project Settings** → **API**. Copy the **Project URL** and
the **anon public** key. Open `realm-of-glory-surulere.html` in a text
editor, find these two lines near the top of the `<script>` section, and
paste your values in:

```js
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

Save the file. That's it — open it in a browser and it's fully live.

## Large file uploads
Sermon audio/video and gallery photos upload straight to Supabase Storage,
with a real progress percentage shown while it uploads (useful for big video
files). Supabase's free tier allows files up to 50 MB each by default; if
you need larger sermon videos, raise the max upload size in **Project
Settings → Storage**, or upgrade your Supabase plan — no code changes
needed either way.

## Using the dashboard
Go to `#/dashboard` (there's a quiet "Admin" link in the footer) and sign in
with the email/password you created in step 4. From there you can edit:
- Site Settings — church name, hero text, vision/mission, contact info,
  service time, socials, giving links, live-stream link
- Scripture CTAs, Core Values, Leadership team
- Sermons (upload audio/video, or paste an external link)
- Gallery (upload Sunday photos, grouped by service date automatically)
- Events, Prayer Requests inbox, Contact Messages inbox

Add or remove staff accounts any time from Supabase's Authentication tab.

## Adding your own logo
Search the HTML file for `navLogoImg` and `footLogoImg` — each is a plain
`<img>` tag. Add a `src="your-logo-file.png"` (a local path or full URL) to
each, and it replaces the text wordmark automatically — including the big
mark on the homepage hero, which switches over the moment either of those
is set (or once you set a Logo URL from the dashboard's Settings tab). No
extra step needed.

## Deploying it for real
This is a single static HTML file — deploy it exactly like you deployed
your previous version (Vercel, or any static host). No build step, no
server code required; it talks to Supabase directly from the browser.

## Notes while watching
On the Live and Sermons pages, a floating "Notes" button appears bottom-right
— a small notepad (bold/italic/underline/list) that can be dragged (by its
header) and resized (drag the bottom-right corner). It auto-saves to that
browser only, with a download-as-text button.

## Pastor's Blog
A new "Blog" page and nav link, fully editable from the dashboard's
**Pastor's Blog** tab: title, author, the pastor's photo, an optional cover
image, an excerpt, and the full post text. Posts show up on the Blog page
and as a small teaser on the homepage once you've published at least one.

**If you already set up Supabase before this update:** your project won't
have the new `blog_posts` table yet. Just re-run all of `schema.sql` in the
SQL Editor again — it's written to be safe to run repeatedly (existing
tables, policies, and your settings row are left untouched; only what's
missing gets created), so this also works as your general "pull in the
latest schema" step any time it changes going forward.

## 3D logo on the homepage
The homepage hero now shows your actual logo as an interactive, drag-to-
rotate 3D model (auto-rotates gently when idle, pauses while you drag it)
instead of the placeholder sunburst mark. Your `.glb` file is embedded
directly in the HTML itself — nothing to host separately, nothing to
configure. If you ever want to swap in a different model, search the file
for `LOGO_MODEL_BASE64` and either paste in a new base64-encoded `.glb`, or
send me the file again and I'll do it for you.

If it's ever unreachable (e.g. a browser with WebGL disabled), it falls back
automatically to your logo image, then to the sunburst mark — never a
blank or broken hero.

## Design notes
Monochrome, grayscale palette throughout (photos are auto-grayscaled via
CSS for consistency, even if the originals are in color). Type is Space
Grotesk (headings) + Manrope (body). Icons are hand-built inline SVGs —
no emoji anywhere.
