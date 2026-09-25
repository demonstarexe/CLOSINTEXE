# INTELLIGENCE LOCATION - FIXED

1. Run `supabase-setup.sql` completely in Supabase SQL Editor.
2. Create an admin user in Supabase Authentication > Users.
3. Put your Supabase Project URL and Publishable key in `config.js`.
4. Upload all files to GitHub and deploy the repo on Vercel (Framework: Other; no build command).
5. User flow: index -> explicit YES/NO -> browser GPS -> `set_location` RPC -> locations table.
6. Admin flow: Supabase Auth -> authenticated SELECT -> Leaflet map + Realtime.

Do NOT put a secret/service_role key in the browser.

Because usernames are intentionally arbitrary and can collide, this prototype is not suitable for high-security identity verification: the same username maps to the same location row.
