# autonomous-ops — Claude Code Plugin

by [Musab Kara](https://linkedin.com/in/musab-kara-85580612a) · [GitHub](https://github.com/SkyWalker2506)

Claude Code plugin bundling autonomous execution modes: full YOLO mode, background agent delegation, and multi-agent team build loops.

## Install

```bash
claude plugin install autonomous-ops@musabkara-claude-marketplace
```

## Commands

| Command | Description |
|---------|-------------|
| `/yolo <task>` | Full autonomous mode — zero questions, bypass obstacles, commit at every milestone |
| `/rbg <task>` | Run a task in a background agent |
| `/team-build [setup\|run\|status]` | Multi-agent team loop — Opus designs, Sonnet/Haiku codes |
| `/yolo-log [--all]` | Show what the last /yolo run did |

## How It Works

### /yolo — Full Autonomous Mode

Executes a task with zero questions asked. Obstacles like missing databases, auth systems, API keys, and Jira tickets are bypassed using mocks and fallbacks. Every significant step gets a conventional commit. Activity is logged to `.yolo/log.json`.

### /rbg — Background Agent

Delegates a task to a background agent using `run_in_background: true`. Useful for long-running work that should not block the main conversation.

### /team-build — Multi-Agent Team

Creates a multi-agent development team:
1. **Setup** — interactive config: project type, agents, loops
2. **Opus Spec** — Opus writes detailed specs (never code)
3. **Loop** — Sonnet/Haiku code per spec, commit+push, Opus reviews each turn
4. Reports and review notes persist on disk for context-clean iterations

### /yolo-log — YOLO Report

Read-only report of the last /yolo execution. Shows completed steps, changed files, and commit hashes. Use `--all` to include skipped items.

## Plugin Structure

```
ccplugin-autonomous-ops/
  .claude-plugin/
    plugin.json
  commands/
    yolo.md
    rbg.md
    team-build.md
    yolo-log.md
  skills/
    autonomous-ops/
      SKILL.md
  README.md
```

## License

MIT

## Part of

- [claude-config](https://github.com/SkyWalker2506/claude-config) — Multi-Agent OS for Claude Code (110 agents, local-first routing)
- [Plugin Marketplace](https://github.com/SkyWalker2506/claude-marketplace) — Browse & install all 14 plugins
