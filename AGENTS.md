@./skills/using-godot-prompter/SKILL.md
@./skills/using-godot-prompter/references/copilot-tools.md

# Godot 4.x Project Development Protocol

This protocol is designed for any Godot 4.x project using GodotPrompter. Follow these steps when implementing Godot features.

---

## Step 0: Requirement Validation (required before any skill loading)

Before loading any skill, the agent MUST validate the user's requirements.

### Ambiguity Assessment

For EVERY request, evaluate:
- **Goal clarity**: Is the objective clearly stated?
- **Scope**: Are the boundaries defined (what's included/excluded)?
- **Behavior**: Is the desired behavior unambiguous?

### When Requirements Are Clear

Proceed directly to Step 0.5 (Addon Discovery).

### When Requirements Are Ambiguous

**First round** — Present 2-4 approach options in short form:

```
I see [N] possible approaches for "[task]":

1. [Approach A] — Best for [scenario]. Complexity: [low/medium/high]
2. [Approach B] — Best for [scenario]. Complexity: [low/medium/high]

Which direction do you want to go?
```

User picks one → expand the chosen approach with implementation details → proceed.

**Second round** (user still vague) — Apply fallback:

```
Based on your description, the standard approach is [X]. 
Reason: [why it fits most projects]. I'll proceed, and you can adjust at any time.
```

### Step 0 vs Skill-level Decision Points

- **Step 0**: Triggered by vague user input — resolves WHAT to build
- **Skill Decision Points**: Triggered by technical choices within a clear requirement — resolves HOW to build it

---

## Step 0.5: Addon Discovery & Override

Before implementing, check if an installed addon already covers the domain.

### Discovery

1. Scan the project's `addons/` directory
2. Match each addon against `docs/ADDON_REGISTRY.md`
3. Identify which addons cover which skill domains

### Override Decision

For each matching addon → skill pair:

**Full coverage**: Pause and ask the user:
- "I see you have [AddonName] installed, which covers [domain]. Should I implement [feature] using [AddonName]'s API?"

**Partial coverage**: Pause and ask:
- "I see you have [AddonName] installed. It covers [sub-domain]. Should I use it for that part?"

**Complementary**: No pause needed; use addon alongside skill patterns.

### Conflict Resolution

If TWO addons cover the same domain: pause, present both with differences, ask user to choose. Do NOT auto-select.

### No Relevant Addon Found

Proceed with standard skill-based implementation.

---

## Step 1: Load the matching Skill (required before any Godot code)

Use the `skill` tool to load the relevant skill before writing code:

| Task | Required skill |
|------|---------------|
| Player controller | `player-controller` |
| State machine / FSM | `state-machine` |
| Signals / EventBus | `event-bus` |
| Scene structure | `scene-organization` |
| UI | `godot-ui` |
| HUD | `hud-system` |
| Inventory | `inventory-system` |
| Save/Load | `save-load` |
| Enemy AI / Navigation | `ai-navigation` |
| Camera | `camera-system` |
| Audio | `audio-system` |
| Weapons / Combat | `component-system` |
| Resources / Data | `resource-pattern` |
| Input handling | `input-handling` |
| Animation | `animation-system` |
| Testing | `godot-testing` |
| Shaders / VFX | `shader-basics`, `particles-vfx` |
| Physics | `physics-system` |
| Multiplayer | `multiplayer-basics` |
| Export / Deploy | `export-pipeline` |
| 2D systems | `2d-essentials` |
| 3D systems | `3d-essentials` |
| Code review | `godot-code-review` |
| Debugging | `godot-debugging` |

## Step 2: Understand existing code (required before writing)

- Use `Read` to read existing project files
- Follow existing code style, naming conventions, node patterns
- Search for similar features using `grep`
- Check if the project uses specific frameworks (UIManager, registry, EventBus, etc.)

## Step 3: Scene-first principle (deviation requires justification)

- **All nodes must be pre-made in `.tscn` scene files**
- Do NOT use `instantiate()` + `add_child()` for procedural node generation unless necessary (spawners, projectiles, etc.)
- Do NOT use `queue_free()` + recreate to refresh content — update existing node data (`.text`, `.value`, `.visible`)
- For dynamic content (lists, inventories), pre-place enough container nodes and toggle visibility

## Step 4: UI framework constraints (if applicable)

If the project has a custom UI framework (UIManager, panel stack, Toast system, etc.):

- All panels must follow the project's base class (e.g., `UIPanel`)
- Use framework APIs (`open_panel` / `back`) for panel lifecycle
- Register panels at the framework's entry point
- Do NOT bypass the framework by manipulating UI nodes directly in the scene tree

## Step 5: Agent dispatch

GodotPrompter provides 3 specialized agents. In environments where custom `task` subagent types are NOT available (OpenCode, etc.), the main model must **read the agent file and follow its instructions directly**:

| Task type | Read this file | Purpose |
|-----------|---------------|---------|
| Code implementation (GDScript/C#) | `./agents/godot-game-dev.md` | Writing feature code |
| System architecture / scene tree design | `./agents/godot-game-architect.md` | Planning before coding |
| Code review / quality check | `./agents/godot-code-reviewer.md` | Reviewing existing code |

**Dispatch workflow (for all environments):**

1. **Read the agent file**: Use `Read` to load `./agents/<agent-name>.md`
2. **Follow agent instructions**: The file contains domain rules, skill references, and checklists
3. **Load skills**: The agent file will reference which skills to load — use `skill` tool to load them
4. **Read existing code**: Before writing/modifying, read the project's existing relevant files
5. **Execute**: Write / design / review code following the loaded rules

### Environment-specific notes

- **OpenCode**: Use `task` with `subagent_type: "general"` or handle directly — always `Read` the agent file first
- **Claude Code**: Use native `Task` tool with the agent name (supports custom subagent types)
- **Copilot CLI**: Use `task` tool — `Read` agent file if custom agents are unsupported
- **Cursor / Codex / Gemini**: Load instructions via the relevant skill file

## Step 6: Post-generation validation (mandatory first-pass checks)

- Read generated `.tscn` files — check `ext_resource` and `sub_resource` declaration order (declare before reference)
- Check `@onready var` path access method:
  - Pre-placed scene nodes → use `%` (unique_name) or `$` (child path)
  - Nodes in runtime-instantiated sub-scenes → **must use `$` child path**
- Check `_unhandled_input` for race conditions (same frame triggering open and close)
- Check `ext_resource` `uid` references exist

## Step 7: Full-Depth Self-Verification (agent-driven validation loop)

After code generation and post-generation validation, the agent MUST run the verification loop defined in the loaded skill's `## Self-Verification` section.

### Verification Loop

```
1. Read the skill's Success Criteria
2. Generate GUT test scripts that cover each criterion
3. Run: godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/skill_verification -gexit
4. IF all pass → report completion with test output
   IF any fail → fix code → re-run (max 5 loops)
5. If loop limit reached → report remaining failures, request human guidance
```

### Verification Layers

- **Layer 1 — Automated**: Code static analysis (grep), GUT tests (headless), type safety scan
- **Layer 2 — Manual**: Agent reviews code for architecture compliance, race conditions, dead code
- **Layer 3 — Behavioral**: User tests in Godot (described by skill's verification section)

### Escalation

| Loop | Action |
|------|--------|
| 1-2 | Fix and re-run silently |
| 3 | Output warning: "Test still failing at attempt 3. Trying [approach]." |
| 4 | Ask user: "May I try a different approach?" |
| 5+ | Escalate: report remaining failures, stop loop |

See `docs/SELF_VERIFICATION_GUIDE.md` for the complete protocol.

---

## Prohibited patterns

- ❌ Procedural node generation (`instantiate()` + `add_child()`) for UI
- ❌ `%` accessor for nodes in runtime-instantiated sub-scenes (must use `$` relative path)
- ❌ Listening for interaction key in `_unhandled_input` to close UI panels (use `ui_cancel` action)
- ❌ Writing Godot code without loading the matching skill first
- ❌ Writing new files without reading existing files first
- ❌ ⚠️ **ALL NEW**: Skipping Step 0 (Requirement Validation) — all tasks require ambiguity check
- ❌ **ALL NEW**: Skipping Step 0.5 (Addon Discovery) — must check addons/ before implementing
- ❌ **ALL NEW**: Skipping Step 7 (Self-Verification) — all generated code must be verified
- ❌ **ALL NEW**: Implementing via skill patterns when an installed addon fully covers the domain without user consent
- ❌ **ALL NEW**: Running Self-Verification more than 5 loops without escalating to human

## Project customisation

When adopting this protocol, modify:

1. **Step 4 (UI framework)**: Replace with actual framework name and APIs used by the project
2. **Step 3 (scene-first)**: Adjust dynamic generation scope based on the project's resource loading strategy
3. **Prohibited patterns**: Add or remove patterns specific to the project's conventions

---

*This file is maintained by GodotPrompter. Adaptable for any Godot 4.x project.*
