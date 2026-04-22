#!/usr/bin/env bash
# team-build.sh — Autonomous multi-agent development loop
# Part of ccplugin-autonomous-ops
#
# Usage: bash scripts/team-build.sh [--project-dir <path>]
#
# Expects .team-build/config.json to exist (created by /team-build setup).
# Each iteration: picks next agent → Claude codes → lint → commit → Opus review.

set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
PROJECT_DIR="${1:-$(pwd)}"
CONFIG_FILE="$PROJECT_DIR/.team-build/config.json"
SPECS_DIR="$PROJECT_DIR/.team-build/specs"
REPORTS_DIR="$PROJECT_DIR/.team-build/reports"
REVIEW_NOTES="$PROJECT_DIR/.team-build/review-notes.md"
FINAL_REPORT="$PROJECT_DIR/.team-build/final-report.md"

# ---------------------------------------------------------------------------
# Guards
# ---------------------------------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[team-build] ERROR: $CONFIG_FILE not found."
  echo "  Run /team-build setup first to create the configuration."
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "[team-build] ERROR: 'claude' CLI not found in PATH."
  echo "  Install Claude Code: https://claude.ai/code"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "[team-build] ERROR: 'jq' not found. Install it: brew install jq"
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log() { echo "[team-build $(date '+%H:%M:%S')] $*"; }

get_config() { jq -r "$1" "$CONFIG_FILE"; }

agent_count() { jq '.agents | length' "$CONFIG_FILE"; }

# Get agent field by index
agent_field() { jq -r ".agents[$1].$2" "$CONFIG_FILE"; }

# Find next incomplete agent (status != "completed") ordered by priority
next_agent_index() {
  jq -r '
    .agents
    | to_entries
    | map(select(.value.status != "completed"))
    | sort_by(.value.priority)
    | .[0].key
    // empty
  ' "$CONFIG_FILE"
}

mark_agent_completed() {
  local idx="$1"
  local tmp
  tmp=$(mktemp)
  jq ".agents[$idx].status = \"completed\"" "$CONFIG_FILE" > "$tmp"
  mv "$tmp" "$CONFIG_FILE"
}

completed_count() {
  jq '[.agents[] | select(.status == "completed")] | length' "$CONFIG_FILE"
}

# ---------------------------------------------------------------------------
# Setup dirs
# ---------------------------------------------------------------------------
mkdir -p "$SPECS_DIR" "$REPORTS_DIR"

# ---------------------------------------------------------------------------
# Read top-level config
# ---------------------------------------------------------------------------
PROJECT_NAME=$(get_config '.project')
MAX_LOOPS=$(get_config '.loops // 10')
TOTAL_AGENTS=$(agent_count)

log "Starting team-build for: $PROJECT_NAME"
log "Agents: $TOTAL_AGENTS | Max loops: $MAX_LOOPS"
echo ""

TURN=0

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
while true; do
  TURN=$((TURN + 1))

  if [ "$TURN" -gt "$MAX_LOOPS" ]; then
    log "Max loops ($MAX_LOOPS) reached. Wrapping up."
    break
  fi

  AGENT_IDX=$(next_agent_index)

  if [ -z "$AGENT_IDX" ]; then
    log "All agents completed!"
    break
  fi

  AGENT_ID=$(agent_field "$AGENT_IDX" 'id')
  AGENT_NAME=$(agent_field "$AGENT_IDX" 'name')
  AGENT_MODEL=$(agent_field "$AGENT_IDX" 'model // "sonnet"')
  SPEC_FILE=$(agent_field "$AGENT_IDX" 'specFile')
  REPORT_FILE=$(agent_field "$AGENT_IDX" 'reportFile')

  log "Turn $TURN — Agent $AGENT_ID: $AGENT_NAME (model: $AGENT_MODEL)"

  # Resolve paths relative to project dir
  SPEC_PATH="$PROJECT_DIR/$SPEC_FILE"
  REPORT_PATH="$PROJECT_DIR/$REPORT_FILE"

  if [ ! -f "$SPEC_PATH" ]; then
    log "WARN: Spec file not found: $SPEC_PATH — skipping agent $AGENT_ID"
    continue
  fi

  # Build review notes context
  REVIEW_CONTEXT=""
  if [ -f "$REVIEW_NOTES" ]; then
    REVIEW_CONTEXT=$(cat "$REVIEW_NOTES")
  fi

  # Build previous reports summary
  PREV_REPORTS=""
  for rpt in "$REPORTS_DIR"/*.md; do
    [ -f "$rpt" ] || continue
    PREV_REPORTS="$PREV_REPORTS\n\n### $(basename "$rpt")\n$(cat "$rpt")"
  done

  # ---------------------------------------------------------------------------
  # 3a. Code iteration (Sonnet/Haiku per config)
  # ---------------------------------------------------------------------------
  log "Running code agent ($AGENT_MODEL)..."

  CODE_PROMPT="$(cat <<PROMPT
TEAM BUILD — Code Agent Turn $TURN

You are Agent $AGENT_ID: $AGENT_NAME.
Project: $PROJECT_NAME
Project dir: $PROJECT_DIR

## Your Spec
$(cat "$SPEC_PATH")

## Previous Turn Review Notes
${REVIEW_CONTEXT:-No review notes yet.}

## Previously Completed Agent Reports
${PREV_REPORTS:-No completed agents yet.}

## Your Job
1. Implement everything in your spec scope. Follow design rules precisely.
2. Stay inside the project directory: $PROJECT_DIR
3. Run lint/typecheck after coding (ignore if no lint config exists).
4. Commit your changes with conventional commits (feat:, fix:, chore:).
5. Write a report to: $REPORT_FILE
   Format:
   ## Turn $TURN — $AGENT_NAME
   - Date: $(date '+%Y-%m-%d %H:%M')
   - Status: completed / partial / failed
   - Done: <what was implemented>
   - Changed files: <list>
   - Issues: <any problems encountered>
   - Learnings: <anything the next agent should know>

RULES:
- Never ask questions — make decisions and proceed.
- Do not break existing code.
- Follow the design system from agent-01 spec if it exists.
- Dangerous operations (rm -rf, force push) are FORBIDDEN.
PROMPT
)"

  if ! claude --model "$AGENT_MODEL" --print "$CODE_PROMPT" --allowedTools "Bash,Read,Write,Edit" 2>&1; then
    log "WARN: Code agent exited non-zero for $AGENT_ID — continuing."
  fi

  # Commit anything staged by the agent
  cd "$PROJECT_DIR"
  if git diff --quiet && git diff --cached --quiet; then
    log "No changes committed by agent $AGENT_ID."
  else
    git add -A
    git commit -m "feat($AGENT_ID): $AGENT_NAME — team-build turn $TURN" \
      --author "Claude Code <noreply@anthropic.com>" 2>/dev/null || true
    git push origin HEAD 2>/dev/null || log "WARN: push failed (no remote?)"
    log "Committed and pushed changes for $AGENT_ID."
  fi

  mark_agent_completed "$AGENT_IDX"
  log "Agent $AGENT_ID marked completed."

  # ---------------------------------------------------------------------------
  # 3b. Opus review
  # ---------------------------------------------------------------------------
  log "Running Opus review for turn $TURN..."

  DONE_COUNT=$(completed_count)
  REMAINING=$((TOTAL_AGENTS - DONE_COUNT))

  REVIEW_PROMPT="$(cat <<PROMPT
TEAM BUILD — Opus Review Turn $TURN

Project: $PROJECT_NAME
Completed agents: $DONE_COUNT / $TOTAL_AGENTS
Remaining: $REMAINING

## Reports from all completed agents
$(for rpt in "$REPORTS_DIR"/*.md; do [ -f "$rpt" ] && cat "$rpt" && echo "---"; done)

## Your Job
Write updated review notes to: $REVIEW_NOTES

Format:
# Review Notes — Turn $TURN

## Overall Status
- Completed: $DONE_COUNT/$TOTAL_AGENTS agents
- Remaining agents: <list names>

## Instructions for Next Turn
- <Agent ID>: <specific instruction>

## Warnings
- <Any critical issues noticed>

## Consistency Notes
- <Cross-agent consistency concerns>

RULES:
- Be concise — each instruction max 1 sentence.
- Focus on consistency across agents (design system, data structures, naming).
- Do NOT write code — only instructions and observations.
PROMPT
)"

  if ! claude --model opus --print "$REVIEW_PROMPT" --allowedTools "Read,Write" 2>&1; then
    log "WARN: Opus review failed for turn $TURN — continuing."
  fi

  log "Turn $TURN complete. ($DONE_COUNT/$TOTAL_AGENTS agents done)"
  echo ""
done

# ---------------------------------------------------------------------------
# Final report
# ---------------------------------------------------------------------------
log "Writing final report..."

DONE_COUNT=$(completed_count)

cat > "$FINAL_REPORT" <<REPORT
# Team Build Final Report — $PROJECT_NAME

**Date:** $(date '+%Y-%m-%d %H:%M')
**Total turns:** $TURN
**Agents completed:** $DONE_COUNT / $TOTAL_AGENTS

## Agent Summary

$(jq -r '.agents[] | "- **\(.id)** (\(.name)): \(.status // "not started")"' "$CONFIG_FILE")

## Agent Reports

$(for rpt in "$REPORTS_DIR"/*.md; do [ -f "$rpt" ] && cat "$rpt" && echo ""; done)
REPORT

log "Final report written to: $FINAL_REPORT"
log "Team build complete. $DONE_COUNT/$TOTAL_AGENTS agents finished in $TURN turns."
