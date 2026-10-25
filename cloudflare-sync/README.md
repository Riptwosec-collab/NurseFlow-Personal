# Optional encrypted Cloud Sync API (Cloudflare Workers + D1)

This folder is *source code and deployment instructions*. The API is **not deployed**. No cloud sync will work until you configure your own Cloudflare account and URL.

1. `cd cloudflare-sync`
2. `npx wrangler@latest login`
3. `npx wrangler@latest d1 create nurseflow-personal-db`
4. Copy `wrangler.toml.example` to `wrangler.toml` and fill `database_id` from step 3.
5. `npx wrangler@latest d1 execute nurseflow-personal-db --remote --file=./schema.sql`
6. `npx wrangler@latest deploy`
7. Copy your `https://...workers.dev` URL into NurseFlow Settings > Cloud Sync. Click Generate ID/Token; enter a distinct encryption passphrase with >=12 characters; click Save. On a new empty profile click Upload. On a second device enter the same URL, ID, Token, and passphrase, then click Pull.

Cloudflare D1 stores AES-GCM encrypted JSON only. PBKDF2-SHA256 (210,000 rounds) derives an AES-256 key in the browser. The encryption passphrase is kept in memory only (re-enter after refresh); the token is saved in browser localStorage to support syncing while the app is open. Profile token and encryption passphrase are both necessary to recover a synced copy. There is no email-based password recovery. This is a personal demo design, not a certified medical-records processing service.

The server implements optimistic revision checks, responding HTTP 409 on a conflicting write. Pull explicitly asks permission before replacing local content, after recording a local recovery point. Automatic upload only occurs while the app is open and after an initial pull/upload. Do not deploy the Worker at a public profile known to others without adding server-side rate limiting and Cloudflare WAF protections; possession of ID+token grants profile access.
