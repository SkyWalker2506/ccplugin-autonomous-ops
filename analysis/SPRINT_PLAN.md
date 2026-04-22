# Sprint Plan — ccplugin-autonomous-ops

**Generated:** 2026-04-22  
**Forge runs:** 3  
**Total sprints:** 3 (one per run)

---

## Sprint 1 — Critical Fixes (Run 1)

**Goal:** Fix all blockers that prevent the plugin from working after install.

| # | Task | Files | Effort |
|---|------|-------|--------|
| S1-T1 | Fix `plugin.json` — add `commands` and `skills` arrays with correct paths | `.claude-plugin/plugin.json` | S |
| S1-T2 | Fix README install command slug to use correct marketplace reference | `README.md` | XS |
| S1-T3 | Add `error` action type to YOLO log format in `/yolo` command | `commands/yolo.md` | XS |
| S1-T4 | Add `.gitignore` to repo with `.team-build/` and `.yolo/` excluded | `.gitignore` | XS |
| S1-T5 | Add `version` to team-build config schema + document it | `commands/team-build.md` | XS |

---

## Sprint 2 — Team-Build Completion (Run 2)

**Goal:** Make `/team-build run` actually work end-to-end.

| # | Task | Files | Effort |
|---|------|-------|--------|
| S2-T1 | Create `team-build.sh` shell script for autonomous loop | `scripts/team-build.sh` | M |
| S2-T2 | Implement `/team-build status` subcommand spec | `commands/team-build.md` | S |
| S2-T3 | Add JSON schema validation guard to `/yolo-log` | `commands/yolo-log.md` | XS |
| S2-T4 | Add `rbg` dispatch clarification for `disable-model-invocation` | `commands/rbg.md` | XS |
| S2-T5 | Add `SKILL.md` trigger keywords for Turkish variations (`takımla yap` etc.) | `skills/autonomous-ops/SKILL.md` | XS |

---

## Sprint 3 — Quality & Enhancement (Run 3)

**Goal:** Test scaffolding, UX improvements, and `--dry-run`/`--model` flags.

| # | Task | Files | Effort |
|---|------|-------|--------|
| S3-T1 | Add `--dry-run` flag spec to `/yolo` command | `commands/yolo.md` | S |
| S3-T2 | Add `--model <name>` override flag to `/yolo` command | `commands/yolo.md` | S |
| S3-T3 | Create `tests/` directory with basic smoke test scripts | `tests/smoke.sh`, `tests/README.md` | M |
| S3-T4 | Add watchdog self-check at 25-call mark (not just max-50) | `commands/yolo.md` | XS |
| S3-T5 | Update plugin.json version to 1.1.0 reflecting all changes | `.claude-plugin/plugin.json` | XS |
