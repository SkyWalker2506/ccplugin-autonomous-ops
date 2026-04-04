---
name: rbg
description: "Run task in background agent (run_in_background). Triggers: rbg, background, arka plan."
argument-hint: "<task — file, bash, MCP, long-running work>"
disable-model-invocation: true
---

# /rbg — Run in Background

Delegate the given task to a background agent using `run_in_background: true`.

## Important: Queue Behavior

In Claude Code, a new message/slash command within the **same session** will **not be processed** until the active agent turn finishes. The UI shows "queued messages" / "Press up to edit queued messages". This **cannot** be bypassed with `run_in_background` or this skill: `/rbg` **will not start** until its turn comes.

**For real parallelism:**

1. **Separate terminal + second session:** Open a new shell in the project -> `claude` (or `claude --continue` in a separate session) — this second process can run in parallel with the first.
2. **Finish or cancel the current turn first** (if your environment has a shortcut / Stop) — then the queued message is processed.
3. **Already typed it:** The message is queued; it will be processed automatically when the turn ends — it's not "not started", it's **waiting**.

## Difference from /btw

| | `/btw` | `/rbg` |
|---|--------|--------|
| Purpose | Short side question | Delegate tool-heavy work to background **agent** |
| Tools | None | Yes |
| Queue | Same — still waits for turn | Same |

---

## Task Payload

```
$ARGUMENTS
```

- **Empty:** Use the previous user message or clear context instruction; confirm with one sentence if needed.
- **Filled:** The entire argument is the background task.

---

## After the Slash is Processed (when turn arrives)

1. Immediately move the task to background: `run_in_background: true` / Background Agent / Task — whichever mechanism the environment supports.
2. Follow **`CLAUDE.md`**, security rules, and Jira/MCP rules from **`docs/CLAUDE_JIRA.md`** if applicable.
3. When done, post a **short summary** to the main conversation.

If you need to edit a file **immediately** in the main session: use `scripts/` or editor directly; `/rbg` waits for its turn.
