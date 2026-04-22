# Forge Run 1 Lessons — Sprint 1

**Date:** 2026-04-22

## What Went Well

1. **Critical bug density was higher than expected**: 4 of the 5 tasks were true blockers (plugin non-functional without them). The analysis correctly prioritized these.
2. **plugin.json fix was the highest-value single change**: Without `commands`/`skills` arrays, no commands would load after install — this was the root cause of the "installation works, commands don't" failure mode.
3. **`error` action type was missing from a completed spec**: Even well-written autonomous prompts omit error handling paths. Always check: "what happens when a step fails?"

## What Could Improve

1. **The stash was a no-op**: `git stash` found nothing to stash (working tree was clean). The pre-flight check should include `git status` to verify state rather than assuming dirty.
2. **Analysis file placement**: `analysis/` dir was created on this branch. If another branch is created from main, these files are already there — no issue, but worth noting for future multi-branch coordination.

## Patterns to Carry Forward

- When a plugin/command system has a manifest file, always validate it has `commands` and `skills` fields — this is the #1 discoverability failure mode.
- Install instructions in README must be tested before committing — broken install slugs erode user trust immediately.
- Log formats for autonomous agents need an `error` entry type by default — autonomous systems will encounter errors.
