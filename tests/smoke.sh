#!/usr/bin/env bash
# smoke.sh — Plugin structure validation for ccplugin-autonomous-ops
# Usage: bash tests/smoke.sh
# Exit: 0 if all checks pass, 1 if any fail

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"  # "ok" or "fail: <reason>"
  if [ "$result" = "ok" ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc"
    echo "        $result"
    FAIL=$((FAIL + 1))
  fi
}

file_exists() {
  local path="$REPO_ROOT/$1"
  if [ -f "$path" ]; then
    echo "ok"
  else
    echo "fail: file not found: $1"
  fi
}

file_executable() {
  local path="$REPO_ROOT/$1"
  if [ -x "$path" ]; then
    echo "ok"
  else
    echo "fail: not executable: $1"
  fi
}

json_valid() {
  local path="$REPO_ROOT/$1"
  if [ ! -f "$path" ]; then
    echo "fail: file not found: $1"
    return
  fi
  if command -v jq &>/dev/null; then
    if jq . "$path" >/dev/null 2>&1; then
      echo "ok"
    else
      echo "fail: invalid JSON: $1"
    fi
  else
    echo "ok"  # skip jq check if not available
  fi
}

json_has_key() {
  local path="$REPO_ROOT/$1"
  local key="$2"
  if [ ! -f "$path" ]; then
    echo "fail: file not found: $1"
    return
  fi
  if command -v jq &>/dev/null; then
    local val
    val=$(jq -r "$key // empty" "$path" 2>/dev/null)
    if [ -n "$val" ]; then
      echo "ok"
    else
      echo "fail: key '$key' missing or empty in $1"
    fi
  else
    echo "ok"  # skip if jq not available
  fi
}

shell_syntax_ok() {
  local path="$REPO_ROOT/$1"
  if [ ! -f "$path" ]; then
    echo "fail: file not found: $1"
    return
  fi
  if bash -n "$path" 2>/dev/null; then
    echo "ok"
  else
    echo "fail: syntax error in $1"
  fi
}

frontmatter_has() {
  local path="$REPO_ROOT/$1"
  local field="$2"
  if [ ! -f "$path" ]; then
    echo "fail: file not found: $1"
    return
  fi
  if grep -q "^$field:" "$path" 2>/dev/null; then
    echo "ok"
  else
    echo "fail: frontmatter field '$field' missing in $1"
  fi
}

echo "================================================"
echo " ccplugin-autonomous-ops — Smoke Tests"
echo "================================================"
echo ""

echo "## Plugin Manifest"
check "plugin.json exists"                        "$(file_exists '.claude-plugin/plugin.json')"
check "plugin.json is valid JSON"                 "$(json_valid '.claude-plugin/plugin.json')"
check "plugin.json has name"                      "$(json_has_key '.claude-plugin/plugin.json' '.name')"
check "plugin.json has version"                   "$(json_has_key '.claude-plugin/plugin.json' '.version')"
check "plugin.json has commands array"            "$(json_has_key '.claude-plugin/plugin.json' '.commands[0]')"
check "plugin.json has skills array"              "$(json_has_key '.claude-plugin/plugin.json' '.skills[0]')"
echo ""

echo "## Command Files"
check "commands/yolo.md exists"                   "$(file_exists 'commands/yolo.md')"
check "commands/rbg.md exists"                    "$(file_exists 'commands/rbg.md')"
check "commands/team-build.md exists"             "$(file_exists 'commands/team-build.md')"
check "commands/yolo-log.md exists"               "$(file_exists 'commands/yolo-log.md')"
check "yolo.md has name frontmatter"              "$(frontmatter_has 'commands/yolo.md' 'name')"
check "rbg.md has name frontmatter"               "$(frontmatter_has 'commands/rbg.md' 'name')"
check "team-build.md has name frontmatter"        "$(frontmatter_has 'commands/team-build.md' 'name')"
check "yolo-log.md has name frontmatter"          "$(frontmatter_has 'commands/yolo-log.md' 'name')"
echo ""

echo "## Skill Files"
check "skills/autonomous-ops/SKILL.md exists"     "$(file_exists 'skills/autonomous-ops/SKILL.md')"
check "SKILL.md has name frontmatter"             "$(frontmatter_has 'skills/autonomous-ops/SKILL.md' 'name')"
check "SKILL.md has description frontmatter"      "$(frontmatter_has 'skills/autonomous-ops/SKILL.md' 'description')"
echo ""

echo "## Scripts"
check "scripts/team-build.sh exists"              "$(file_exists 'scripts/team-build.sh')"
check "scripts/team-build.sh is executable"       "$(file_executable 'scripts/team-build.sh')"
check "scripts/team-build.sh syntax OK"           "$(shell_syntax_ok 'scripts/team-build.sh')"
echo ""

echo "## Repo Hygiene"
check ".gitignore exists"                         "$(file_exists '.gitignore')"
check "README.md exists"                          "$(file_exists 'README.md')"
check "LICENSE exists"                            "$(file_exists 'LICENSE')"
echo ""

echo "## Analysis Files"
check "analysis/MASTER_ANALYSIS.md exists"        "$(file_exists 'analysis/MASTER_ANALYSIS.md')"
check "analysis/SPRINT_PLAN.md exists"            "$(file_exists 'analysis/SPRINT_PLAN.md')"
echo ""

echo "================================================"
echo " Results: $PASS passed, $FAIL failed"
echo "================================================"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
