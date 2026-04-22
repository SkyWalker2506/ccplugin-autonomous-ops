---
name: team-build
description: "Multi-agent team builder: Opus designs, Sonnet/Haiku codes, autonomous loop with commits. Triggers: team build, agent team, multi-agent."
user-invocable: true
argument-hint: "[setup|run|status]"
---

# Team Build — Multi-Agent Autonomous Development

Opus agents design + write specs, Sonnet/Haiku agents code. Runs in an autonomous loop, committing and pushing at every turn, producing reports.

## Flow

```
Setup -> Opus Spec -> Loop [ Sonnet/Haiku Code -> Commit+Push -> Opus Review -> Next Turn ]
```

## Arguments

| Arg | What it does |
|-----|-------------|
| *(empty)* or `setup` | Ask questions -> create config -> write specs -> start loop |
| `run` | Start loop with existing config (setup already done) |
| `status` | Show current state (completed agents, remaining turns) |

## When Invoked

Start the appropriate phase based on the argument:

---

## Status Subcommand (`/team-build status`)

Read `.team-build/config.json` and `.team-build/reports/` to show current progress.

### Output Format

```
## Team Build Status — <Project Name>

| Agent | Name | Status | Last Turn | Files Changed |
|-------|------|--------|-----------|---------------|
| agent-01 | Design System | completed | 2 | src/styles/... |
| agent-02 | Data Factory | in-progress | — | — |
| agent-03 | Landing Page | not started | — | — |

Completed: 1/3 agents | Turns used: 2/10
```

### Edge Cases

- **No config found:** `No .team-build/config.json found. Run /team-build setup first.`
- **No reports yet:** Show all agents as "not started"
- **Config missing version:** Treat as version "1.0" (backward compatible)

---

## Phase 1: Setup (interactive — first time only)

Ask the user these questions (use parenthesized defaults if no answer):

### Questions

1. **What is the project type?**
   - Website / Mobile app / Game / CLI tool / API / Other
   - *(This answer drives agent domain suggestions)*

2. **Short project description?**
   - 1-2 sentences (e.g., "Trust-focused project matching platform")

3. **Which domains do you want agents for?**
   - Suggest based on project type, user can add/remove

   | Project Type | Suggested Domains |
   |-------------|------------------|
   | Website | Design System, Landing Page, Main Pages, Component Library, Data Layer, Animation |
   | Mobile app | UI Kit, Screens, State Management, API Integration, Navigation, Test |
   | Game | Game Engine, Mechanics, UI/HUD, Asset Pipeline, Audio, Level Design |
   | API | Schema, Endpoints, Auth, Validation, Test, Documentation |

4. **How many agents? (default: 6-10 based on type)**

5. **How many loops/turns? (default: 10)**

6. **Need mock/demo data? (default: no)**
   - Yes -> a separate "Data Factory" agent is added

7. **Run web research? (inspiration, reference sites, design trends)**
   - Yes -> Opus uses WebSearch/WebFetch during spec phase

### Config Output

Create `.team-build/config.json` from answers:

```json
{
  "version": "1.0",
  "project": "Project Name",
  "description": "Short description",
  "type": "website",
  "agents": [
    {
      "id": "agent-01",
      "name": "Design System",
      "role": "Color, font, spacing, animation rules and shared component specs",
      "specFile": ".team-build/specs/agent-01-design-system.md",
      "reportFile": ".team-build/reports/agent-01-report.md",
      "model": "sonnet",
      "dependsOn": [],
      "priority": 1
    }
  ],
  "loops": 10,
  "mockData": true,
  "webResearch": true,
  "createdAt": "2026-04-01T12:00:00Z"
}
```

> **Note:** If `version` is missing from an existing config file, treat it as `"1.0"` for backward compatibility.
```

Agent model assignment:
- **Simple/repetitive work** (mock data, simple component, literal spec implementation) -> `haiku`
- **Medium-heavy coding** (complex UI, state, animation, filtering) -> `sonnet`
- Model field is specified in config, loop script uses it

---

## Phase 2: Opus Spec Writing (autonomous — no questions)

Opus writes a detailed spec file for each agent. **Opus DOES NOT write code**, only:

- What to build (component list, page structure, behaviors)
- Design rules (colors, spacing, typography — from reference sites if available)
- File structure (which files to create/edit)
- Acceptance criteria (when is it "done")
- Dependencies (which agent's output is needed)
- Mock data structure (if data factory agent exists)

### Spec File Format

`.team-build/specs/agent-XX-domain-name.md`:

```markdown
# Agent XX: Domain Name

## Purpose
One-sentence mission for this agent.

## Scope
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Design Rules
(Colors, spacing, font, animation rules — reference agent-01 spec)

## File Plan
- `src/components/X.tsx` — description
- `src/app/page/page.tsx` — description

## Mock Data
(Data structure and examples if needed)

## Acceptance Criteria
- Lint passes
- Typecheck passes
- Visual verification in browser
- Consistent with design system

## Dependencies
- agent-01 (design system) must be completed

## Notes
(Opus special instructions, things to watch out for)
```

### Spec Order

1. Agents with no dependencies first (design system, data factory)
2. Then dependent agents

### Web Research

If `webResearch: true`, Opus during spec writing:
- WebSearch for inspiration/references
- WebFetch to inspect reference site designs
- Add findings as a "References" section in the spec

After specs are written, move to Phase 3.

---

## Phase 3: Autonomous Loop (no questions — fully autonomous)

Start the shell script (bundled with the plugin):

```bash
# From the project root where .team-build/ lives:
bash "$(claude plugin path autonomous-ops)/scripts/team-build.sh"

# Or if running from the plugin directory directly:
bash scripts/team-build.sh
```

The script works as follows (each iteration):

### 3a. Code Iteration (Sonnet/Haiku)

1. Read `.team-build/config.json`
2. Read previous reports from `.team-build/reports/`
3. Read `.team-build/review-notes.md` (Opus notes from previous turn)
4. Pick the next agent spec (by priority order, first incomplete agent)
5. Code according to the spec
6. Run `pnpm lint` / typecheck (project-dependent)
7. Commit + push
8. Write report to `.team-build/reports/agent-XX-report.md`:
   ```markdown
   ## Turn N — Agent XX: Domain Name
   - Date: YYYY-MM-DD HH:mm
   - Status: completed / partial / failed
   - Done: ...
   - Changed files: ...
   - Issues: ...
   - Learnings: ...
   ```
9. Update agent status in config

### 3b. Opus Review (after each iteration)

After each code iteration, Opus does a short, cost-effective review:

1. Read all reports
2. Update `.team-build/review-notes.md`:
   ```markdown
   # Review Notes — Turn N

   ## Overall Status
   - Completed: X/Y agents
   - Remaining: ...

   ## Instructions for Next Turn
   - Agent-03: Align color palette with agent-01, use #1a1a2e
   - Agent-05: Filter component must match agent-04 card structure

   ## Warnings
   - Agent-02 data structure is incompatible with agent-06, needs fixing
   ```
3. Update spec files if necessary

### 3c. Context Cleanup

After each commit+push:
- Script opens a new Claude session each iteration (like ralph.sh)
- Context starts fresh automatically
- Notes and reports are on disk so the new session reads them

### Loop End

When all agents are completed:
1. Write `.team-build/final-report.md` (summary)
2. Notify user
3. Script exits

---

## File Structure

```
.team-build/
  config.json          # Project config
  review-notes.md      # Opus inter-turn notes
  final-report.md      # Summary after all turns
  specs/
    agent-01-design-system.md
    agent-02-data-factory.md
    ...
  reports/
    agent-01-report.md
    agent-02-report.md
    ...
```

## Key Rules

1. **Opus never writes code** — only spec, plan, review, notes
2. **Sonnet handles heavy coding** — complex components, animation, state
3. **Haiku handles simple tasks** — mock data, simple components, literal implementation
4. **Every iteration commits+pushes** — resilient to interruption
5. **Reports live on disk** — information survives context cleanup
6. **Stay inside the project** — only work in the project directory
7. **No questions** — fully autonomous after setup
8. **Consistency** — every agent must follow the design system
