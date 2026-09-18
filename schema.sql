-- ============================================================================
-- Realm of Glory Surulere — Supabase schema
-- Run this whole file once in your Supabase project's SQL Editor
-- (Dashboard -> SQL Editor -> New query -> paste this in -> Run).
-- ============================================================================

-- ---------- Tables ----------------------------------------------------------

create table if not exists settings (
  id int primary key default 1,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists sermons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  speaker text,
  series text,
  date date,
  type text check (type in ('audio','video')) default 'audio',
  description text,
  external_url text,
  asset_path text,
  asset_url text,
  created_at timestamptz not null default now()
);

create table if not exists gallery (
  id uuid primary key default gen_random_uuid(),
  service_date date,
  caption text,
  asset_path text,
  asset_url text,
  created_at timestamptz not null default now()
);

create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date date,
  time text,
  location text,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists blog_posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text,
  author_photo_url text,
  cover_image_url text,
  cover_image_path text,
  excerpt text,
  content text not null,
  date date,
  created_at timestamptz not null default now()
);

create table if not exists prayer_requests (
  id uuid primary key default gen_random_uuid(),
  name text,
  contact text,
  request text not null,
  confidential boolean not null default false,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  name text,
  email text,
  phone text,
  subject text,
  message text not null,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

-- ---------- Row Level Security -----------------------------------------------
-- Public visitors can read site content and submit the two forms.
-- Only a signed-in admin (created under Authentication -> Users) can write
-- content, or read submitted prayer requests / messages.

alter table settings enable row level security;
alter table sermons enable row level security;
alter table gallery enable row level security;
alter table events enable row level security;
alter table blog_posts enable row level security;
alter table prayer_requests enable row level security;
alter table messages enable row level security;

drop policy if exists "public read settings" on settings;
create policy "public read settings" on settings for select using (true);
drop policy if exists "admin write settings" on settings;
create policy "admin write settings" on settings for insert to authenticated with check (true);
drop policy if exists "admin update settings" on settings;
create policy "admin update settings" on settings for update to authenticated using (true) with check (true);

drop policy if exists "public read sermons" on sermons;
create policy "public read sermons" on sermons for select using (true);
drop policy if exists "admin write sermons" on sermons;
create policy "admin write sermons" on sermons for insert to authenticated with check (true);
drop policy if exists "admin update sermons" on sermons;
create policy "admin update sermons" on sermons for update to authenticated using (true) with check (true);
drop policy if exists "admin delete sermons" on sermons;
create policy "admin delete sermons" on sermons for delete to authenticated using (true);

drop policy if exists "public read gallery" on gallery;
create policy "public read gallery" on gallery for select using (true);
drop policy if exists "admin write gallery" on gallery;
create policy "admin write gallery" on gallery for insert to authenticated with check (true);
drop policy if exists "admin update gallery" on gallery;
create policy "admin update gallery" on gallery for update to authenticated using (true) with check (true);
drop policy if exists "admin delete gallery" on gallery;
create policy "admin delete gallery" on gallery for delete to authenticated using (true);

drop policy if exists "public read events" on events;
create policy "public read events" on events for select using (true);
drop policy if exists "admin write events" on events;
create policy "admin write events" on events for insert to authenticated with check (true);
drop policy if exists "admin update events" on events;
create policy "admin update events" on events for update to authenticated using (true) with check (true);
drop policy if exists "admin delete events" on events;
create policy "admin delete events" on events for delete to authenticated using (true);

drop policy if exists "public read blog" on blog_posts;
create policy "public read blog" on blog_posts for select using (true);
drop policy if exists "admin write blog" on blog_posts;
create policy "admin write blog" on blog_posts for insert to authenticated with check (true);
drop policy if exists "admin update blog" on blog_posts;
create policy "admin update blog" on blog_posts for update to authenticated using (true) with check (true);
drop policy if exists "admin delete blog" on blog_posts;
create policy "admin delete blog" on blog_posts for delete to authenticated using (true);

-- Anyone can submit a prayer request or a contact message (no login needed),
-- but only the signed-in admin can read, update or delete them afterwards.
drop policy if exists "public submit prayer requests" on prayer_requests;
create policy "public submit prayer requests" on prayer_requests for insert with check (true);
drop policy if exists "admin read prayer requests" on prayer_requests;
create policy "admin read prayer requests" on prayer_requests for select to authenticated using (true);
drop policy if exists "admin update prayer requests" on prayer_requests;
create policy "admin update prayer requests" on prayer_requests for update to authenticated using (true) with check (true);
drop policy if exists "admin delete prayer requests" on prayer_requests;
create policy "admin delete prayer requests" on prayer_requests for delete to authenticated using (true);

drop policy if exists "public submit messages" on messages;
create policy "public submit messages" on messages for insert with check (true);
drop policy if exists "admin read messages" on messages;
create policy "admin read messages" on messages for select to authenticated using (true);
drop policy if exists "admin update messages" on messages;
create policy "admin update messages" on messages for update to authenticated using (true) with check (true);
drop policy if exists "admin delete messages" on messages;
create policy "admin delete messages" on messages for delete to authenticated using (true);

-- ---------- Realtime ----------------------------------------------------------
-- Lets every open tab/device update instantly when content changes.
-- Safe to re-run: each table is only added if it isn't already a member.
do $$
declare t text;
begin
  foreach t in array array['settings','sermons','gallery','events','blog_posts','prayer_requests','messages']
  loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- ---------- Storage -------------------------------------------------------
-- After running this file, create a bucket by hand:
--   Dashboard -> Storage -> New bucket -> name it exactly "media" -> Public bucket: ON
-- Then run the four policies below (they reference that bucket by name).

drop policy if exists "public read media" on storage.objects;
create policy "public read media" on storage.objects for select using (bucket_id = 'media');
drop policy if exists "admin upload media" on storage.objects;
create policy "admin upload media" on storage.objects for insert to authenticated with check (bucket_id = 'media');
drop policy if exists "admin update media" on storage.objects;
create policy "admin update media" on storage.objects for update to authenticated using (bucket_id = 'media');
drop policy if exists "admin delete media" on storage.objects;
create policy "admin delete media" on storage.objects for delete to authenticated using (bucket_id = 'media');

-- ---------- Seed content ------------------------------------------------------
-- Pre-fills the site with Realm of Glory Surulere's real vision, mission,
-- values, leadership and weekly meetings, so the site looks right from the
-- very first load. Edit any of this later from the dashboard instead.

insert into settings (id, data) values (1, $json${
  "churchName": "Realm of Glory Surulere",
  "shortName": "Realm of Glory",
  "shortSub": "Surulere",
  "founded": "2018",
  "tagline": "A people of praise, prayer and sacrifice — existing to honor God and make disciples.",
  "heroHeadline": "A people of praise, prayer and sacrifice.",
  "heroSub": "Realm of Glory Surulere exists to honor God and to make disciples — building transformed lives for a transformed society, since 2018.",
  "vision": "We are a people of praise, prayer and sacrifice — and we exist to honor God and to make disciples.",
  "mission": "We believe in the transformation and discipleship of every believer through establishing strong biblical foundations. \"Transformed Life, Transformed Society.\"",
  "address": "Realm of Glory Surulere, Surulere, Lagos, Nigeria",
  "phone": "+234 800 000 0000",
  "email": "hello@realmofglorysurulere.org",
  "mapQuery": "Realm of Glory Surulere, Surulere, Lagos, Nigeria",
  "serviceLabel": "Sunday Service",
  "serviceTime": "8:00 AM",
  "instagram": "", "facebook": "", "youtube": "", "tiktok": "",
  "giveLink": "", "bankName": "", "bankAccountName": "Realm of Glory Surulere", "bankAccountNumber": "",
  "youtubeChannelUrl": "", "liveEmbedUrl": "", "isLive": false,
  "nextServiceNote": "Join us this Sunday at 8:00 AM — in person or online.",
  "ctaHeadline": "Ready to take your next step?",
  "ctaSub": "Whether it’s your first time with us or you’re ready to go deeper, we’d love to walk with you.",
  "logoUrl": "",
  "values": [
    { "id":"v1", "icon":"i-cross", "title":"Christ-Centredness", "text":"Jesus is the foundation of everything we do. We exist to exalt His name and make Him known in all the earth." },
    { "id":"v2", "icon":"i-book", "title":"Biblical Truth", "text":"The Word of God is our final authority. We are committed to teaching and living the Scripture in all its fullness." },
    { "id":"v3", "icon":"i-flame", "title":"Fervent Prayer", "text":"Prayer is the lifeblood of our church. We are a house of prayer for all nations, interceding without ceasing." },
    { "id":"v4", "icon":"i-heart", "title":"Radical Love", "text":"We love God with all our heart and love our neighbours as ourselves — without condition or reservation." },
    { "id":"v5", "icon":"i-globe", "title":"Kingdom Impact", "text":"We exist to transform communities, influence culture, and extend God’s kingdom across every sphere of society." }
  ],
  "leaders": [
    { "id":"l1", "name":"Pastor Kayode Ajala", "role":"Lead Pastor", "photoUrl":"" },
    { "id":"l2", "name":"Pastor Omowunmi Kayode-Ajala", "role":"Co-Lead Pastor", "photoUrl":"" },
    { "id":"l3", "name":"Catherine Aligame", "role":"Asst. Admin", "photoUrl":"" }
  ],
  "meetings": [
    { "id":"m1", "title":"Believers Foundation Class", "text":"For every new believer, new member and those that want to lay a solid foundation in their Christian life. Come and be grounded in the Word.", "day":"Sundays", "time":"8:00 AM", "place":"Church Auditorium", "icon":"i-book" },
    { "id":"m2", "title":"The Church at Shitta", "text":"Join the Ambassadors and other brethren as we reach out to the Shitta community with the love of Christ.", "day":"Sundays", "time":"8:00 – 9:00 AM", "place":"Shitta Community", "icon":"i-globe" },
    { "id":"m3", "title":"Ascendancy in the Morning", "text":"A one-hour spiritual recharge to seek God early for all-round victory, breakthrough and deliverance. Receive the Word that will carry you through the week.", "day":"Wednesdays", "time":"6:00 – 7:00 AM", "place":"Church Auditorium", "icon":"i-flame" },
    { "id":"m4", "title":"Powerhouse Prayer Meeting", "text":"Our Saturday virtual prayer meeting. Storm the gates of heaven with us! Kindly attend and invite someone to join this powerful prayer time.", "day":"Saturdays", "time":"6:00 – 7:00 AM", "place":"Virtual (Online)", "icon":"i-users" }
  ],
  "scriptures": [
    { "id":"s1", "quote":"Serve the LORD with gladness: come before his presence with singing.", "ref":"Psalm 100:2, KJV", "page":"home" },
    { "id":"s2", "quote":"I beseech you therefore, brethren, by the mercies of God, that ye present your bodies a living sacrifice, holy, acceptable unto God, which is your reasonable service.", "ref":"Romans 12:1, KJV", "page":"about" },
    { "id":"s3", "quote":"If my people, which are called by my name, shall humble themselves, and pray, and seek my face, and turn from their wicked ways; then will I hear from heaven, and will forgive their sin, and will heal their land.", "ref":"2 Chronicles 7:14, KJV", "page":"any" },
    { "id":"s4", "quote":"Go ye therefore, and teach all nations, baptizing them in the name of the Father, and of the Son, and of the Holy Ghost.", "ref":"Matthew 28:19, KJV", "page":"any" },
    { "id":"s5", "quote":"Every man according as he purposeth in his heart, so let him give; not grudgingly, or of necessity: for God loveth a cheerful giver.", "ref":"2 Corinthians 9:7, KJV", "page":"give" }
  ]
}$json$::jsonb)
on conflict (id) do nothing;
