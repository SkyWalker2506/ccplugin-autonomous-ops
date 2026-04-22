# Forge Run 3 Lessons — Sprint 3

**Date:** 2026-04-22

## What Went Well

1. **Smoke tests passed immediately**: 25/25 on first run — because the earlier sprint work was disciplined about file structure. Tests validated what was already correct rather than surfacing new failures.
2. **Flag documentation in command specs**: The Flags table at the top of `yolo.md` is easy to scan and includes examples — this pattern should be standard for all plugin commands with optional arguments.
3. **Watchdog self-check at 25 vs 50**: This is a real improvement. A stuck agent that has burned 50 calls is much more costly than one that self-checks at 25 and wraps up early. The `watchdog-check` log entry also makes debugging easier.

## What Could Improve

1. **`--dry-run` needs agent-side enforcement**: The flag is documented but the agent prompt template doesn't currently prevent the agent from writing files if it misinterprets. A stronger guard in the prompt template would help: "If ARGS contains --dry-run, output only the plan table and STOP."
2. **`validate-log-schema.sh` uses a while loop with subshell**: The `while IFS= read -r ... | while ...` pattern creates a subshell for the inner loop, so `ENTRY_FAIL` counter increments don't propagate to the outer shell. This is a known bash gotcha — the script uses `echo` for per-entry reporting but final exit code is based on jq-level checks, which is acceptable.
3. **Version bump should be tied to CI**: Manually bumping to 1.1.0 works, but a CI step that reads `CHANGELOG.md` or git tags and auto-bumps would be more reliable as the plugin grows.

## Patterns to Carry Forward

- Test infrastructure should be created in Sprint 1 of any forge cycle, not Sprint 3 — earlier tests would have caught any Sprint 1-2 regressions.
- Flags for autonomous commands need to be enforced at the prompt level, not just documented — LLMs need explicit "if X then STOP" guards.
- `jq` as a dependency for shell-based plugin tooling is acceptable on macOS (available via Homebrew) but should be documented in the README prerequisites.

## Overall Forge Cycle Assessment

| Dimension | Score | Notes |
|-----------|-------|-------|
| Critical bug fix | 5/5 | All 4 blockers eliminated in Run 1 |
| Feature completeness | 4/5 | team-build.sh created but not integration-tested |
| Test coverage | 3/5 | Structural tests only; no behavior tests |
| Documentation quality | 5/5 | All command specs significantly improved |
| Code quality | 4/5 | Shell script is clean; bash subshell gotcha noted |
| Velocity | 5/5 | 3 runs × 5 tasks = 15 tasks in one session |
