---
name: yolo
description: "Full autonomous task runner. Zero questions, bypass all obstacles, commit at every milestone. Triggers: yolo, otonom yap, salliyorum, full auto."
argument-hint: "<task description>"
---

# /yolo — Full Autonomous Mode

Execute the given task with **zero questions asked**, going as far as possible. Obstacles are bypassed, every milestone gets a commit, and results are reported.

## Core Principles

1. **NEVER ask questions** — no user prompts, no confirmation waits
2. **Bypass obstacles, don't stop** — DB? Mock. Login? Skip. Jira? Skip. API key? Fake. Paid service? Skip.
3. **Commit at every significant step** — small, meaningful commits
4. **Run in background** — `run_in_background: true`
5. **Keep logs** — write activity to `.yolo/`

---

## Flow

### 0. Git Check

```
CHECK: git rev-parse --is-inside-work-tree 2>/dev/null
```

| State | Action |
|-------|--------|
| Git exists | Continue |
| No git | `git init` + `gh repo create <folder-name> --private --source=. --push`. If gh auth fails, just `git init` + local commits |

### 1. Create Log Directory

```bash
mkdir -p .yolo
echo '[]' > .yolo/log.json  # reset on each /yolo run
```

Add `.yolo/` to `.gitignore` (create if missing, append if exists).

### 2. Analysis (max 5 tool calls)

Quick scan of the project: language, framework, structure. No long exploration.

### 3. Execution

At each step:

1. **Do** — write code, create files, set up configs
2. **Log** — append entry to `.yolo/log.json` (format below)
3. **Commit** — meaningful conventional commit message

#### Log Format (.yolo/log.json)

JSON array, each entry:

```json
{
  "step": 1,
  "action": "create",
  "what": "Next.js project scaffolded with App Router",
  "files": ["package.json", "app/layout.tsx", "app/page.tsx"],
  "commit": "abc1234",
  "ts": "2026-04-02T14:30:00Z"
}
```

- `action`: `create` | `modify` | `configure` | `scaffold` | `install` | `skip`
- `what`: what was done (1 sentence, English)
- `files`: changed/created files
- `commit`: commit hash (`null` if none)

#### Skip Log (.yolo/skipped.json)

Skipped items go to a separate file:

```json
{
  "what": "Database setup",
  "reason": "No credentials, used mock data instead",
  "workaround": "In-memory SQLite with seed data"
}
```

### 4. Obstacle Bypass Strategies

| Obstacle | Strategy |
|----------|----------|
| **Database** | SQLite in-memory or JSON file with seed data |
| **Auth/Login** | Fake auth middleware, hardcoded test user |
| **API key** | `.env.example` created, code uses `process.env.X \|\| "demo-key"` fallback |
| **Jira/Ticket** | Skip entirely, log it |
| **Paid service** | Skip or use free tier alternative |
| **Docker/Container** | Run locally, skip Docker |
| **CI/CD** | Write simple script, skip platform integration |
| **Test** | Write simple happy-path test, skip edge cases |
| **Type error** | `as any` or minimal type definition, move on |
| **Missing dependency** | `npm install` / `pip install` / whatever, run it |
| **Permission** | If sudo required, skip and log |

### 5. Commit Rules

- 1 commit per logical step (scaffold, feature, config, fix...)
- Conventional commit: `feat:`, `fix:`, `chore:`, `scaffold:`
- Commit message in English, short, describes what was done
- `git add` specific files (don't use `.`)
- NEVER commit `.yolo/` directory

### 6. On Completion

Final step:

1. Add final entry to `.yolo/log.json`: `"action": "complete"`
2. Show user a **short summary**:
   ```
   /yolo completed.
   - X steps, Y commits
   - Skipped: Z (details via /yolo-log)
   ```

---

## Agent Prompt Template

```
Agent(
  prompt="""
  YOLO MODE — Fully autonomous task.

  TASK: $ARGUMENTS

  RULES:
  1. NEVER ask questions. Bypass obstacles, keep going.
  2. DB needed: SQLite/JSON mock. Login needed: fake auth. API key: fallback. Jira: skip.
  3. Commit at every significant step (conventional commit, English).
  4. Log to .yolo/log.json (JSON array, each step one entry).
  5. Skipped items: .yolo/skipped.json (JSON array).
  6. Add .yolo/ to gitignore, never commit it.
  7. No git: git init + gh repo create <folder-name> --private (fallback to local if fails).
  8. On completion: add "complete" entry to .yolo/log.json.

  LOG ENTRY FORMAT:
  {"step": N, "action": "create|modify|configure|scaffold|install|skip", "what": "...", "files": [...], "commit": "hash|null", "ts": "ISO"}

  SKIP ENTRY FORMAT:
  {"what": "...", "reason": "...", "workaround": "..."}

  OBSTACLE BYPASS: DB->mock, Auth->fake, API key->fallback, Jira->skip, Paid->skip, Docker->skip, CI->simple script.

  WATCHDOG: This task is long. Max 50 tool calls. Self-check every 5 calls.
  """,
  model="sonnet",
  run_in_background=True,
  description="yolo: <task summary>"
)
```

---

## Rules

- NEVER write secrets into code — use `.env.example` + fallback pattern
- `.yolo/` directory never enters git
- Don't break existing code — prefer creating new files
- Still follow the project's `CLAUDE.md` rules (security, filesystem)
- Dangerous operations like `rm -rf`, `git push --force`, repo deletion are FORBIDDEN — even in yolo mode
