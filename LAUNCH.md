# 📣 Why this repo exists — and the full kit behind it

Hi, I'm the author of this repo. I built the backup workflow in **supabase-free-backup-lite** after discovering that my Supabase Free project — with real users in it — had **no automated backups at all**. On the Free plan there is no restore button. Pro ($25/month) is the official fix; this repo is the $0 one.

The workflow itself is ~30 lines. Getting those 30 lines *right* took five separate failures, every one of them silent:

1. **The transaction pooler (port 6543) can't run `pg_dump`** — you need the session pooler on port 5432, and the error messages never tell you that.
2. **The direct host is IPv6-only on Free** — GitHub runners are IPv4-only, so it works on your laptop and fails in CI.
3. **`pg_dump` 16 refuses a PostgreSQL 17 server** — you need `postgresql-client-17` from the PGDG repo (this repo's workflow installs it).
4. **GitHub disables scheduled workflows in public repos after 60 days** — silently. That's why this setup belongs in a *private* repo.
5. **Daily dumps blow the Free 5 GB/month egress cap** — a 500 MB database dumped weekly is ~2 GB/month (fine); daily is ~15 GB/month (not fine).

## The full write-up

I documented all five traps, with fixes, in two places:

- 📖 **dev.to (original):** [Supabase Free Has No Backups — Here's the Free Way to Add Them](https://dev.to/william_lao_0c017fe1ee6cb/supabase-free-has-no-backups-heres-the-free-way-to-add-them-2f9d)
- 📖 **Hashnode (technical version):** [How to Back Up a Supabase Free Project for $0](https://agricalc.hashnode.dev/how-to-back-up-a-supabase-free-project-for-0-weekly-pg-dump-to-cloudflare-r2)

## What this free version does — and doesn't

✅ Weekly `pg_dump` → Cloudflare R2, full database including `auth.users`. Ten-minute setup (see the README).

❌ No encryption (the dump is uploaded as-is), no validation that a dump can actually be restored, no alert if a run fails, and Storage files are not covered (they live in S3, not Postgres).

For a hobby project that's a fair trade. For a project with real user data, those three missing pieces are exactly where backups go to die.

## The full kit

The **Supabase Free-Tier Backup Kit** is this same workflow with the failure modes engineered out:

- 🔐 GPG AES-256 encryption before upload
- 🩺 Pre-flight checks that reject the wrong pooler, the IPv6-only host, and a `pg_dump` version mismatch — with errors that name the fix
- ✔️ SHA-256 + `pg_restore --list` validation of every dump
- 🔁 A restore drill + step-by-step runbook (English + Chinese), so you prove the backup restores *before* you need it
- 🔔 Failure alerts (Slack / Discord webhook), a watchdog for runs that never happen, and a Healthchecks.io heartbeat
- 🧮 An egress calculator for the Free cap, and 90-day R2 retention rules

**$29 one-time for the first 50 buyers, then $39. No subscription. 14-day money-back guarantee.** Current version: **v1.0.7**.

👉 **[Get the kit on Gumroad](https://franklinlewis7.gumroad.com/l/jispyu)**

The lite version in this repo stays free forever — if it saves your data once, it's done its job.

## Feedback

Hit a trap I didn't? Found a bug? [Open an issue](../../issues) — corrections and edge cases (bigger databases, other regions, Storage backups) are very welcome.

— William
