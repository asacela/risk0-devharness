#!/usr/bin/env bash
# Sets KEY=VALUE lines in a .env file without ever printing a value: the write
# side of env-check.sh. Creates the file (mode 600) if it is missing, replaces a
# key's existing line in place, appends a new key at the end, and leaves every
# other line untouched. Prints only each key's name and what happened to it.
# The block-env-access hook (~/.claude/scripts/block-env-access.sh) allows a
# bare call to this script, so agents can set up per-worktree values (ports,
# local database URLs) themselves. Use it for values the agent chose, never to
# move a secret through the chat: secrets reach a worktree by copying files.
#
# Usage: env-set.sh <file> KEY=VALUE [KEY=VALUE ...]
set -euo pipefail

[ $# -lt 2 ] && { echo "usage: env-set.sh <file> KEY=VALUE [KEY=VALUE ...]" >&2; exit 2; }
file=$1; shift
[[ $file == *.example ]] && { echo "env-set: refusing to edit a template ($file)" >&2; exit 2; }

for pair in "$@"; do
  [[ $pair =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || { echo "env-set: not KEY=VALUE: ${pair%%=*}" >&2; exit 2; }
done

if [ ! -e "$file" ]; then
  (umask 077; : > "$file")
  echo "== $file (created)"
else
  echo "== $file"
fi

for pair in "$@"; do
  key=${pair%%=*}
  tmp=$(mktemp "$file.XXXXXX")
  # awk -v would expand backslashes in the value, so pass the pair through the environment.
  PAIR=$pair awk -v key="$key" '
    BEGIN { pair = ENVIRON["PAIR"]; status = "added" }
    {
      line = $0; sub(/^[[:space:]]*(export[[:space:]]+)?/, "", line)
      if (index(line, key "=") == 1) {
        if (found) next                      # drop duplicate lines for the key
        found = 1
        status = ($0 == pair) ? "unchanged" : "updated"
        print pair; next
      }
      print
    }
    END {
      if (!found) print pair
      print status > "/dev/stderr"
    }' "$file" > "$tmp" 2> "$tmp.status"
  status=$(cat "$tmp.status"); rm -f "$tmp.status"
  cat "$tmp" > "$file"; rm -f "$tmp"        # write in place, keeping the file's mode
  printf '  %-36s %s\n' "$key" "$status"
done
