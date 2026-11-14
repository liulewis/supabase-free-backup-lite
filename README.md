# Backup Supabase Free Tier — Free Lite Version

A free, minimal weekly backup for a Supabase Free-tier database.
`pg_dump` → Cloudflare R2. Nothing else. No encryption, no restore
drill, no alerts, no validation.

**Why this exists:** Supabase Free has no automated backups. Pro is
$25/month. This 30-line workflow is the smallest thing that actually
protects your data — and if it ever saves you once, the full kit
(encryption + restore drill + pre-flight checks + watchdog) is $29
launch / $39 standard.

## Setup (10 minutes)

1. **Use a PRIVATE repo.** GitHub disables scheduled workflows in public
   repos after 60 days without activity, silently.
2. **Create an R2 bucket** + API token (Object Read/Write on that bucket).
3. **Copy the Session pooler string** from Supabase Dashboard → Settings →
   Database → Connection string. Port **5432**, host
   `aws-0-<region>.pooler.supabase.com`. NOT port 6543 (transaction
   pooler — `pg_dump` cannot run through it). NOT the direct host
   `db.<ref>.supabase.co` (IPv6-only on Free; GitHub runners are
   IPv4-only).
4. **Add repo secrets:** `SUPABASE_DB_URL`, `R2_ACCOUNT_ID`,
   `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`.
5. **Copy this folder's files to your repo root** (or use it as its own
   repo — workflows in a subfolder do not run on their own).
6. **Actions → Supabase Backup (Lite) → Run workflow.** Check R2 for
   `supabase-backups/<date>/supabase-<date>.dump`.

## Egress warning

Every dump pulls the full database out of Supabase against the Free
**5 GB/month cap**. A 500 MB database dumped weekly is ~2 GB/month
(fine); dumped daily it is ~15 GB/month (over the cap). Keep it weekly.

## Scope

- ✅ Full database, including `auth.users` (they live in the database).
- ❌ Storage files are NOT included — they live in S3, not Postgres.
- ❌ No encryption: the dump is uploaded as-is. R2 buckets are private
  by default, but anyone with your R2 credentials can read it.

## Want the full kit?

The paid Supabase Backup Kit adds: GPG AES-256 encryption, a
pre-flight validator that rejects the wrong pooler with a clear error,
SHA-256 + `pg_restore --list` validation, a restore drill into a
throwaway Postgres with a step-by-step runbook, failure alerts, the
cron-watchdog bonus, and an egress calculator.

Get it here: https://franklinlewis7.gumroad.com/l/jispyu — $29 launch (first 50 buyers), then $39, one-time, 14-day money-back guarantee.
