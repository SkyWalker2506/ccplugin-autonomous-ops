#!/usr/bin/env bash
# validate-log-schema.sh — Validates .yolo/log.json against expected schema
# Usage: bash tests/validate-log-schema.sh [path/to/log.json]
# Exit: 0 if valid, 1 if invalid

set -euo pipefail

LOG_FILE="${1:-.yolo/log.json}"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc"
    echo "        $result"
    FAIL=$((FAIL + 1))
  fi
}

VALID_ACTIONS="create modify configure scaffold install skip error watchdog-check complete planned"

echo "================================================"
echo " /yolo Log Schema Validator"
echo " File: $LOG_FILE"
echo "================================================"
echo ""

# Check file existence
if [ ! -f "$LOG_FILE" ]; then
  echo "  FAIL  Log file does not exist: $LOG_FILE"
  echo ""
  echo "  Hint: Run /yolo first to generate the log."
  exit 1
fi
echo "  PASS  File exists: $LOG_FILE"

# Check not empty
if [ ! -s "$LOG_FILE" ]; then
  echo "  FAIL  File is empty"
  exit 1
fi
echo "  PASS  File is non-empty"

# Check valid JSON
if ! command -v jq &>/dev/null; then
  echo "  SKIP  jq not found — install with: brew install jq"
  exit 0
fi

if ! jq . "$LOG_FILE" >/dev/null 2>&1; then
  echo "  FAIL  Invalid JSON in $LOG_FILE"
  echo "        First 200 chars: $(head -c 200 "$LOG_FILE")"
  exit 1
fi
echo "  PASS  Valid JSON"

# Check it's an array
TYPE=$(jq -r 'type' "$LOG_FILE")
if [ "$TYPE" != "array" ]; then
  echo "  FAIL  Expected JSON array, got: $TYPE"
  exit 1
fi
echo "  PASS  Is a JSON array"

# Check if array is empty
COUNT=$(jq 'length' "$LOG_FILE")
if [ "$COUNT" -eq 0 ]; then
  echo "  WARN  Empty array — no steps recorded yet"
  echo ""
  echo " Results: $PASS passed, $FAIL failed, 1 warning"
  exit 0
fi
echo "  PASS  Contains $COUNT entries"
echo ""

echo "## Entry Validation"

# Validate each entry
ENTRY_FAIL=0
jq -c '.[]' "$LOG_FILE" | while IFS= read -r entry; do
  idx=$(echo "$entry" | jq -r '.step // "?"')

  # Required fields
  for field in step action what ts; do
    val=$(echo "$entry" | jq -r ".$field // empty")
    if [ -z "$val" ]; then
      echo "  FAIL  Entry step=$idx: missing required field '$field'"
      ENTRY_FAIL=$((ENTRY_FAIL + 1))
    fi
  done

  # Validate action type
  action=$(echo "$entry" | jq -r '.action // empty')
  if [ -n "$action" ]; then
    valid=false
    for a in $VALID_ACTIONS; do
      [ "$action" = "$a" ] && valid=true && break
    done
    if [ "$valid" = "false" ]; then
      echo "  FAIL  Entry step=$idx: invalid action '$action'"
      echo "        Valid: $VALID_ACTIONS"
      ENTRY_FAIL=$((ENTRY_FAIL + 1))
    fi
  fi

  # If action=error, must have error field
  if [ "$action" = "error" ]; then
    err=$(echo "$entry" | jq -r '.error // empty')
    if [ -z "$err" ]; then
      echo "  WARN  Entry step=$idx: action=error but no 'error' field"
    fi
  fi

  # files must be array
  files_type=$(echo "$entry" | jq -r '.files | type // empty' 2>/dev/null)
  if [ -n "$files_type" ] && [ "$files_type" != "array" ]; then
    echo "  FAIL  Entry step=$idx: 'files' must be array, got $files_type"
    ENTRY_FAIL=$((ENTRY_FAIL + 1))
  fi

  echo "  PASS  Entry step=$idx (action=$action)"
done

echo ""
echo "================================================"
echo " Schema validation complete"
echo "================================================"

if [ "$ENTRY_FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
