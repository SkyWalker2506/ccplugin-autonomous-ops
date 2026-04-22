# Forge Run 2 Lessons — Sprint 2

**Date:** 2026-04-22

## What Went Well

1. **Shell script is the right tool for team-build.sh**: The loop-based shell script approach is resilient to interruption (each iteration commits+pushes), context-clean (claude CLI opens fresh sessions), and readable by any contributor.
2. **`jq` as config parser**: Using `jq` for JSON config parsing makes the script portable and avoids Python/Node dependencies. The `jq` guard at startup gives a clear error message.
3. **Spec-driven agent prompts**: Embedding the spec file content directly in the agent prompt means the agent has everything it needs even in a fresh session — no implicit state required.

## What Could Improve

1. **`claude --print` flag**: This is assumed to be the correct flag for non-interactive Claude CLI usage. If the flag name changes or isn't available, team-build.sh will fail silently. A startup check for `claude --help | grep print` would catch this.
2. **`agent_count` is dynamic but `mark_agent_completed` modifies in-place**: If two processes ran team-build.sh simultaneously they'd conflict on `config.json`. This is acceptable for single-user use but worth noting.
3. **The `/rbg` `disable-model-invocation` clarification**: The real behavior of this Claude Code plugin frontmatter field is not fully documented publicly — the dispatch section was written based on best interpretation. May need revision once official Claude Code plugin docs are published.

## Patterns to Carry Forward

- Shell scripts for long-running autonomous loops are more resilient than in-process agent calls — each iteration can be independently resumed.
- Any command spec that references an external file path should ship that file in the same repo, not assume it exists elsewhere.
- Validation guards for user-facing output (yolo-log) should cover all 5 states: missing, empty, invalid, empty-array, and valid.
