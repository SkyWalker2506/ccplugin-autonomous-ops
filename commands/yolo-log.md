---
name: yolo-log
description: "Show what the last /yolo run did. Only completed work by default — use --all for skips. Triggers: yolo-log, yolo log, ne yaptin, yolo rapor."
argument-hint: "[--all]"
---

# /yolo-log — YOLO Report

Show what the last `/yolo` run **did**. Default: only completed work. `--all` includes skipped items too.

## Flow

### 1. Read Log Files

```bash
cat .yolo/log.json 2>/dev/null
cat .yolo/skipped.json 2>/dev/null
```

If files don't exist:
> No /yolo run found or log files are missing.

### 2. Output Format

#### Default (no argument or `--done`)

Only **completed work**, chronological:

```
## /yolo Report

| # | What was done | Files | Commit |
|---|--------------|-------|--------|
| 1 | Next.js project scaffolded | package.json, app/layout.tsx | abc1234 |
| 2 | Auth middleware added | middleware.ts, lib/auth.ts | def5678 |
| 3 | Dashboard page created | app/dashboard/page.tsx | ghi9012 |

**Total:** 3 steps, 3 commits
```

#### `--all` Argument

Completed work + skipped items:

```
## /yolo Report

### Completed Work
| # | What was done | Files | Commit |
|---|--------------|-------|--------|
| 1 | ... | ... | ... |

### Skipped
| What | Reason | Workaround |
|------|--------|------------|
| Database setup | No credentials | In-memory SQLite |
| Jira task | No access | Skipped |

**Total:** 3 steps, 3 commits, 2 skips
```

### 3. Git Log Cross-check

Verify commit hashes from the log against `git log --oneline`. Mark missing/wrong hashes with `(?)`.

## Rules

- Read-only — do not edit any files
- If `.yolo/log.json` doesn't exist, show a clear error message
- Output in the user's language
