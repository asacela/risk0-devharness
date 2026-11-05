#!/usr/bin/env bash
# Names-only view of .env files: prints each variable's name, whether it has a
# value, the value's length, and only a known non-secret prefix (phc_, sk_live_,
# https://, postgres://...). Never prints a value. The block-env-access hook
# (~/.claude/scripts/block-env-access.sh) makes this the only way Claude can
# inspect .env files, and it allows only this exact path.
#
# Usage: env-check.sh [file ...]   (default: every .env* file in the current dir)
set -euo pipefail

files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  shopt -s nullglob
  files=(.env .env.*)
fi
[ ${#files[@]} -eq 0 ] && { echo "env-check: no .env files found"; exit 0; }

known_prefix() {
  local v=$1
  for p in phc_ phx_ phs_ sk_live_ sk_test_ pk_live_ pk_test_ rk_live_ rk_test_ whsec_ \
           https:// http:// postgresql:// postgres:// redis:// rediss://; do
    if [[ $v == "$p"* ]]; then printf '%s…' "$p"; return; fi
  done
  printf '…'
}

for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then echo "== $f (missing)"; continue; fi
  echo "== $f"
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line#"${line%%[![:space:]]*}"}          # trim leading space
    [[ -z $line || $line == \#* ]] && continue
    line=${line#export }
    if [[ $line != *=* ]]; then
      printf '  %-36s %s\n' "$line" "NO '=' (name only, no value)"
      continue
    fi
    name=${line%%=*}
    value=${line#*=}
    value=${value%%[[:space:]]#*}                 # drop inline comment
    value=${value#\"}; value=${value%\"}; value=${value#\'}; value=${value%\'}
    if [ -z "$value" ]; then
      printf '  %-36s %s\n' "$name" "empty"
    else
      printf '  %-36s set   %-14s (%d chars)\n' "$name" "$(known_prefix "$value")" "${#value}"
    fi
  done < "$f"
done
