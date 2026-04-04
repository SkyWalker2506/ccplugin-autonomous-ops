---
name: autonomous-ops
description: "Auto-triggers for autonomous execution modes: YOLO (zero-question task runner), background agent delegation (rbg), multi-agent team build loops. Activates when the user mentions autonomous, yolo, team build, background agent, multi-agent, full auto, otonom, salliyorum."
version: 1.0.0
---

# Autonomous Ops Skill

Unified skill for all autonomous execution modes bundled in this plugin.

## Commands

| Command | When to use |
|---------|------------|
| `/yolo <task>` | User wants fully autonomous execution — no questions, bypass obstacles, commit at milestones |
| `/rbg <task>` | User wants to delegate a task to a background agent |
| `/team-build [setup\|run\|status]` | User wants a multi-agent team: Opus designs, Sonnet/Haiku codes |
| `/yolo-log [--all]` | User wants to see what the last /yolo run did |

## Trigger Keywords

This skill activates when the conversation mentions any of these:

- **yolo**: "yolo", "full auto", "otonom yap", "salliyorum", "just do it", "autonomous"
- **rbg**: "background", "arka plan", "rbg", "run in background"
- **team-build**: "team build", "agent team", "multi-agent", "takimla yap", "opus + sonnet"
- **yolo-log**: "yolo log", "yolo-log", "ne yaptin", "yolo rapor", "show yolo"

## How It Works

### YOLO Mode
Full autonomous task execution. Zero questions asked. Obstacles (missing DB, auth, API keys, Jira) are bypassed with mocks/fallbacks. Every significant step gets a conventional commit. Logs are kept in `.yolo/log.json` and `.yolo/skipped.json`.

### Background Agent (rbg)
Delegates a task to a background agent using `run_in_background: true`. Note: within the same Claude Code session, queued messages wait for the current turn to finish. For real parallelism, open a second terminal session.

### Team Build
Multi-agent autonomous development loop:
1. **Setup** — interactive questions to define project, agents, and config
2. **Opus Spec** — Opus writes detailed specs for each agent (never writes code)
3. **Autonomous Loop** — Sonnet/Haiku code per spec, commit+push, Opus reviews, repeat
4. Each iteration produces reports; context is cleaned between turns

### YOLO Log
Read-only report of the last /yolo execution. Shows steps, files changed, and commits. Use `--all` to include skipped obstacles.

## Safety

- Dangerous operations (`rm -rf`, `git push --force`, repo deletion) are FORBIDDEN even in yolo mode
- Secrets are never written to code — only `.env.example` + fallback patterns
- `.yolo/` and `.team-build/` directories are excluded from git
- Project `CLAUDE.md` rules (security, filesystem) are always respected
