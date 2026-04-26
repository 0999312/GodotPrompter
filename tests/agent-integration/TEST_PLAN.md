# GodotPrompter Agent Integration Test Plan

Run these tests in a **fresh Claude Code session** with GodotPrompter installed.
Record results in `RESULTS.md` after each test.

---

## Category 1: Cold Start (Installation & Discovery)

### Test 1.1: Plugin loads

**Setup:** Fresh Claude Code session with GodotPrompter installed.

**Prompt:** "What Godot skills are available from GodotPrompter?"

**Expected:**
- Agent loads `using-godot-prompter` skill (or reads it)
- Lists skill categories: Core/Process, Architecture, Gameplay, UI, Multiplayer, Build, C#
- Mentions at least 10 specific skill names

**Pass criteria:** Agent shows awareness of the skill catalog, not generic Godot advice.

---

### Test 1.2: Skill content access

**Prompt:** "What does the state-machine skill cover? Show me the approaches."

**Expected:**
- Agent reads `skills/state-machine/SKILL.md`
- Describes 3 approaches: enum-based, node-based, resource-based
- Shows the comparison table from the skill

**Pass criteria:** Response matches skill content, not generic FSM knowledge.

---

### Test 1.3: Cross-reference navigation

**Prompt:** "The state-machine skill mentions related skills. What are they?"

**Expected:**
- Agent finds the Related Skills line: player-controller, ai-navigation, resource-pattern
- Can describe what each related skill covers

**Pass criteria:** Agent navigates cross-references correctly.

---

## Category 2: Skill Discovery (Open-Ended Prompts)

### Test 2.1: State machine request

**Prompt:** "I need to add a state machine to my player character in Godot 4."

**Expected skill:** `state-machine`

**Expected behavior:**
- Loads the skill (not generic advice)
- Asks about complexity to recommend enum vs node vs resource approach
- Shows GDScript example from the skill
- Mentions C# equivalent

**Pass criteria:** Uses skill content, not generic FSM tutorial.

---

### Test 2.2: Project setup request

**Prompt:** "I'm starting a new Godot 4.3 project. How should I organize it?"

**Expected skill:** `godot-project-setup`

**Expected behavior:**
- Shows the split layout directory structure from the skill
- Recommends autoloads (GameManager, EventBus)
- Shows .gitignore template

**Pass criteria:** Directory structure matches skill exactly.

---

### Test 2.3: Enemy AI request

**Prompt:** "I want enemies that patrol waypoints and chase the player when they get close."

**Expected skill:** `ai-navigation`

**Expected behavior:**
- Shows NavigationAgent2D setup
- Provides patrol pattern with waypoints
- Shows chase behavior with state transitions
- References state-machine skill for FSM integration

**Pass criteria:** Uses NavigationAgent2D (not custom pathfinding), shows patrol code from skill.

---

### Test 2.4: Save/load request

**Prompt:** "Help me set up a save/load system for my Godot game."

**Expected skill:** `save-load`

**Expected behavior:**
- Shows strategy comparison table (ConfigFile, JSON, Resource)
- Recommends JSON for game saves
- Shows SaveManager autoload pattern
- Mentions version migration

**Pass criteria:** Shows the comparison table, recommends JSON with reasoning.

---

### Test 2.5: Code review request

**Prompt:** "Review this GDScript for common Godot issues."

**Sample script to paste with the prompt:**

```gdscript
extends CharacterBody2D

var health = 100
var speed = 200

func _process(delta):
    var player = get_node("/root/Main/Player")
    if player:
        var dir = (player.position - position).normalized()
        position += dir * speed * delta

func take_damage(amount):
    health -= amount
    if health <= 0:
        get_parent().remove_child(self)
        queue_free()
```

**Expected skill:** `godot-code-review`

**Expected behavior:**
- Flags: untyped variables, using `_process` instead of `_physics_process` for movement
- Flags: hardcoded node path `/root/Main/Player` (use groups instead)
- Flags: `position +=` instead of `move_and_slide()` on CharacterBody2D
- Flags: `remove_child` before `queue_free` (unnecessary)
- Uses the checklist structure from the skill

**Pass criteria:** Finds at least 3 of the 4 issues, uses skill checklist format.

---

## Category 3: New Workflow Steps (Step 0, Step 0.5, Step 7)

### Test 3.0: Requirement Validation (ambiguous request)

**Prompt:** "I want to add combat to my game."

**Expected behavior:**
- Agent pauses at Step 0 (Requirement Validation) instead of immediately implementing
- Presents 2-4 short approach options (turn-based, real-time, etc.) with trade-offs
- After user picks, expands that approach with details before proceeding

**Pass criteria:** Agent does NOT start coding before user confirms approach.

---

### Test 3.0b: Requirement Validation (clear request)

**Prompt:** "I need a 2D platformer player that can jump and wall-slide. Speed 200, jump velocity -400."

**Expected behavior:**
- Agent validates the request is clear
- Proceeds directly to Step 0.5 without presenting alternatives

**Pass criteria:** No approach options displayed; moves to addon check.

---

### Test 3.0c: Requirement Validation (vague after 2 rounds — fallback)

**Prompt:** "Add something fun to my player."

**Expected behavior (after 2 clarification rounds):**
- Agent says: "Based on your description, the standard approach is a dash mechanic. Reason: adds immediate feel-good feedback with minimal complexity. I'll proceed, and you can adjust at any time."
- Then loads the relevant skill and implements

**Pass criteria:** Agent applies fallback after 2 rounds; explicitly states the default approach and reason.

---

### Test 3.0.5: Addon Discovery (overlapping addon found)

**Setup:** Install a mock addon folder `addons/dialogic/` in the test project.

**Prompt:** "Add dialogue to my game with branching choices."

**Expected behavior:**
- Agent scans `addons/`, finds `dialogic`
- Matches against `docs/ADDON_REGISTRY.md`
- Pauses: "I see Dialogic installed, which covers dialogue systems. Should I use Dialogic's API or manual dialogue code?"

**Pass criteria:** Agent pauses for user decision; does NOT auto-select either path.

---

### Test 3.0.5b: Addon Discovery (no relevant addon)

**Setup:** Empty `addons/` directory.

**Prompt:** "Add a health bar HUD to my game."

**Expected behavior:**
- Agent scans `addons/`, finds nothing relevant
- Proceeds to load `hud-system` skill without pausing

**Pass criteria:** No pause; proceeds directly to skill-based implementation.

---

### Test 3.0.5c: Addon Discovery (addon conflict)

**Setup:** Install both `addons/dialogic/` and `addons/dialogue_manager/`.

**Prompt:** "Add dialogue to my game."

**Expected behavior:**
- Agent finds both addons match `dialogue-system` domain
- Pauses: "I see both Dialogic and Dialogue Manager installed. Dialogic is feature-rich with visual editor; Dialogue Manager is simpler. Which do you prefer?"
- Does NOT auto-select

**Pass criteria:** Both addons listed; user must choose; no auto-selection.

---

### Test 3.7: Self-Verification (code with bugs)

**Setup:** Have the agent generate a state machine, then inject a deliberate bug (e.g., missing `enter()` call in initial state).

**Prompt:** "Review the generated state machine and fix any issues."

**Expected behavior (when re-running via Step 7):**
- Agent reads the skill's Success Criteria
- Generates GUT test for "Correct state transitions" criterion
- Runs: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/skill_verification -gexit`
- Test fails → Agent reads failure → fixes code → re-runs test
- Reports completion when test passes

**Pass criteria:** Agent detects the bug via GUT test, fixes it, and re-runs.

---

### Test 3.7b: Self-Verification loop limit

**Setup:** Create a purposely unfixable error.

**Prompt:** "Generate a state machine with the transition_to inside enter() bug, then run Self-Verification."

**Expected behavior:**
- Agent attempts to fix the infinite recursion bug
- After 5 loops, reports: "Self-verification did not pass after 5 attempts. Remaining failures: [list]. Requesting human guidance."

**Pass criteria:** Agent stops after 5 loops; escalates to human; does NOT continue indefinitely.

---

## Category 4: Full Workflow (End-to-End Build)

### Test 4.2: Add Enemy

**Prompt:** "Add an enemy with patrol AI that chases the player and attacks."

**Expected skills:** `ai-navigation`, `state-machine`, `component-system`

**Expected behavior:**
- Creates enemy with NavigationAgent2D
- Uses patrol pattern from ai-navigation
- Adds FSM (idle/patrol/chase/attack) from state-machine
- Uses HitboxComponent/HurtboxComponent/HealthComponent from component-system

**Pass criteria:** Navigation-based patrol, component-based damage.

---

### Test 4.3: Add HUD

**Prompt:** "Add a health bar HUD that shows the player's health."

**Expected skills:** `hud-system`, `event-bus`

**Expected behavior:**
- Creates CanvasLayer HUD from hud-system
- Uses EventBus pattern from event-bus for health updates
- Health bar uses tween animation from hud-system

**Pass criteria:** CanvasLayer HUD, EventBus-driven updates.

---

### Test 4.4: Code Review

**Prompt:** "Review all the code we just wrote for Godot best practices."

**Expected skill:** `godot-code-review`

**Expected behavior:**
- Works through the skill's checklist sections
- Checks node architecture, style, performance, input, signals, resources
- Produces structured review output

**Pass criteria:** Uses checklist format from skill, not ad-hoc review.

---

### Test 4.5: Save/Load

**Prompt:** "Set up save/load for player position and health. F5 to save, F9 to load."

**Expected skill:** `save-load`

**Expected behavior:**
- Creates SaveManager autoload with JSON serialization
- Implements save_game/load_game functions
- Wires to input actions
- Includes version migration pattern

**Pass criteria:** JSON save with version field, matches skill's SaveManager pattern.

---

## How to Run

1. Start a fresh Claude Code session
2. Install GodotPrompter: `claude plugins add ./GodotPrompter`
3. Navigate to an empty test directory
4. Run each test sequentially, recording results in RESULTS.md
5. For Category 4, keep the same session (tests build on each other)
6. For Category 3 (new workflow tests), use separate sessions as needed for different setup conditions

## Results Summary (Current Verification)

| Category | Total | PASS | PARTIAL | FAIL |
|----------|-------|------|---------|------|
| 1. Cold Start | 3 | | | |
| 2. Skill Discovery | 5 | | | |
| 3. Workflow Steps | 6 | | | |
| 4. Full Workflow | 5 | | | |
| **Total** | **19** | | | |
