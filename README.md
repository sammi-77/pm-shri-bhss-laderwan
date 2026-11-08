# PM SHRI BHSS Laderwan website

A responsive, multi-page school information portal for Classes 9–12. Secondary covers Classes 9–10; Higher Secondary covers Classes 11–12. Staff, student and alumni identities are not fabricated.

## Preview

Open `index.html` in a browser and use the shared navigation to visit About, Academics, Community, Gallery, Updates and Admissions. Without backend configuration, admin-managed content can be previewed and edited locally in that browser. Local edits are not shared. The complaint form clearly reports that messages are not transmitted in preview mode.

## Deploy on Vercel

This is a static site; no build step or framework is required. `vercel.json` adds basic browser security headers. To publish, connect the project folder to a Git repository and import that repository in Vercel, or deploy the folder with the Vercel CLI while signed in to your own Vercel account. Use this folder as the project root and leave the build command empty. The site will serve `index.html` at the project URL.

After deployment, the site is publicly viewable. Do not add student or complaint data until the Supabase backend and its access policies are configured and tested. Supabase's browser anon key can be included in the frontend config; it is not a password and must be protected by the row-level security policies in `supabase-schema.sql`.

## Secure shared mode (Supabase)

1. Create a Supabase project and run `supabase-schema.sql` in its SQL Editor.
   To enable direct Gallery uploads, also run `supabase-gallery-storage.sql` once. Gallery images are public to visitors; only signed-in admins with the admin role can upload, and image files are limited to 5 MB.
2. Create an administrator login in Supabase Authentication. Using a trusted server-side admin method, set that account's **app_metadata** to `{ "role": "admin" }`. Do not use user-editable `user_metadata` for authorization.
3. Copy `config.example.js` to `config.js`, then set the project URL and public anon key. The page loads `config.js` before the Supabase and app scripts. The anon key is intended for the browser; never use a service role key.
4. Deploy the folder to a static HTTPS host. Configure the Supabase Auth site URL and allowed redirect URLs to the deployed site. Use a strong unique admin password and enable MFA in Supabase Auth if available for your project.
5. Test with a non-admin session: published content should be readable, edits and complaint reads denied, complaint submissions allowed. Test that an administrator can edit content and read complaints.

Supabase Row Level Security makes content public-readable and admin-writable; complaints are insert-only for the public and readable only by an authenticated administrator. There is no public API for listing complaints. The schema constrains class and text lengths. For a production school deployment, add CAPTCHA/rate limiting and a retention policy for complaints at the hosting/backend layer, and ensure administrators follow school privacy and child-protection procedures. Do not collect sensitive personal details in the form.

## Admin-managed sections

Sign in from the header to edit notices, staff, students, alumni, class-wise date sheets and gallery entries, and to review complaints and private admission enquiries. Admins can upload JPG, PNG, WebP or GIF images directly to the configured Supabase Storage bucket, or use an HTTPS image URL. Date sheet URLs should point to PDFs accessible to the intended audience. Add content only after the school verifies it and has permission to publish identifying information.

## Files

- `index.html` — home page and admin sign-in/editor
- `about.html` — school history, profile and service areas
- `academics.html` — streams and subjects
- `community.html` — staff, students and alumni
- `gallery.html` — photo gallery
- `updates.html` — date sheets, notices and complaint portal
- `admissions.html` — private admission enquiry form for Classes 9–12
- `styles.css` — shared responsive visual design
- `app.js` — shared rendering, navigation, local preview, Supabase authentication and editing
- `config.example.js` — safe configuration template
- `supabase-schema.sql` — tables, constraints and row-level access policies, including admissions
- `supabase-admissions.sql` — additive migration for private admission requests

