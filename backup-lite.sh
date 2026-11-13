#!/usr/bin/env bash
# backup-lite.sh — Free lite backup: weekly pg_dump to Cloudflare R2.
#
# No encryption, no validation, no alerts. See the paid kit for those.
# Env vars: SUPABASE_DB_URL, R2_ACCOUNT_ID, R2_ACCESS_KEY_ID,
# R2_SECRET_ACCESS_KEY, R2_BUCKET.
set -euo pipefail

WORKDIR="${RUNNER_TEMP:-/tmp}/supabase-backup-lite"
mkdir -p "${WORKDIR}"
trap 'rm -rf "${WORKDIR}"' EXIT

DATE=$(date -u +%Y-%m-%d)
DUMP="${WORKDIR}/supabase-${DATE}.dump"
KEY="supabase-backups/${DATE}/supabase-${DATE}.dump"

export AWS_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="auto"
R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"

echo "Dumping database (session pooler, port 5432)..."
pg_dump "${SUPABASE_DB_URL}" --format=custom --no-owner --file="${DUMP}"
echo "Dump size: $(numfmt --to=iec-i --suffix=B "$(stat -c%s "${DUMP}")")"

echo "Uploading to R2..."
aws s3 cp "${DUMP}" "s3://${R2_BUCKET}/${KEY}" --endpoint-url "${R2_ENDPOINT}"
echo "✅ Lite backup complete: s3://${R2_BUCKET}/${KEY}"
echo "NOTE: this dump is NOT encrypted. For encryption, validation, and"
echo "a restore drill, see the full Supabase Backup Kit."
