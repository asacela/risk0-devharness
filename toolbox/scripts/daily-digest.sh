#!/usr/bin/env bash
# Runs /daily as a background Claude session on this machine and republishes the Daily Update artifact.
# --bg (not -p): print mode has no Artifact tools, a background session has the full set.
# Schedule it with cron or launchd. On macOS cron alone cannot read the keychain, so gh/glab would be logged out:
# have cron kickstart an on-demand launchd job (`launchctl kickstart gui/<uid>/<your.label>`) that calls this script.
# The artifact's Refresh button copies `bash` + this path for a manual run. Log: ~/Library/Logs/daily-digest.log
# Usage: bash "$RISK0/toolbox/scripts/daily-digest.sh"   ($RISK0 = the workspace root, see root AGENTS.md)
set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
RISK0="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# Observability plugins (e.g. PostHog) are often enabled per repo in its settings.local.json: set DAILY_CWD to that repo's
# main checkout to get them in the session; default is the workspace root.
cd "${DAILY_CWD:-$RISK0}" || exit 1
LOG="$HOME/Library/Logs/daily-digest.log"
exec >>"$LOG" 2>&1
echo "== $(date '+%Y-%m-%d %H:%M:%S') daily-digest start"
claude --bg "/daily" --model sonnet \
  --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Skill" "Artifact" \
    "Bash(gh:*)" "Bash(glab:*)" "Bash(git:*)" "Bash(find:*)" "Bash(ls:*)" "Bash(date:*)" "Bash(grep:*)" "Bash(jq:*)" "Bash(python3:*)" \
    "mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql" \
    "mcp__claude_ai_Slack__slack_search_public" "mcp__claude_ai_Slack__slack_read_channel" \
    "mcp__claude_ai_Google_Calendar__list_events" \
    "mcp__plugin_posthog_posthog__exec" "ListAgents" "ToolSearch"
echo "== $(date '+%Y-%m-%d %H:%M:%S') daily-digest launched (exit $?). Output: claude agents / claude logs <id>"
