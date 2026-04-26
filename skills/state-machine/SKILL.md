---
name: state-machine
description: Use when implementing state machines in Godot — enum-based, node-based, and resource-based FSM patterns with trade-offs
godot_version: "4.3+"
status: stable
last_validated: "2026-04-27"
agent_tested_on: ["claude-4-5-opus", "deepseek-v4-flash"]
---

# State Machines in Godot 4.3+

Choose the right FSM pattern for your complexity level. All examples target Godot 4.3+ with no deprecated APIs.

> **Related skills:** **player-controller** for movement state integration, **ai-navigation** for AI state patterns, **resource-pattern** for resource-based state configuration.
>
> **Addon Override:** `orchestrator` provides full visual FSM replacement — see `docs/ADDON_REGISTRY.md`.
>
> **Interface Contract:** When co-loaded with `player-controller`, delegate movement velocity updates to state nodes via `StateMachine.physics_update()` — do NOT set velocity directly in `_physics_process()`. When co-loaded with `event-bus`, emit state-change signals rather than calling transition_to by name from outside the state machine.

---

## Success Criteria

When implementing a state machine, the result MUST satisfy:

1. **Correct state transitions**: All defined transitions work without visual glitches; the target state's `enter()` method is called exactly once on transition
   - **GUT test**: Mock a state machine, trigger each defined transition, assert the correct state is active after each
2. **No transition loops**: No state can trigger a transition that leads back to itself in the same frame, causing infinite recursion
   - **GUT test**: Add a counter in `enter()`; verify no state's enter is called more than once per frame
3. **Enter/exit pairing**: Every `enter()` call has a corresponding `exit()` call before the next `enter()` on the same state
   - **GUT test**: Maintain a global counter incremented on enter and decremented on exit; assert counter is always 0 between transitions
4. **Animation sync**: All animation changes happen inside `enter()` — never inside `update()`/`physics_update()`/`handle_input()`
   - **GUT test** (manual): Code inspection — grep for `.play(` in `update()` and `physics_update()` methods
5. **Invalid state handling**: Transitioning to an undefined state logs an error and does not crash or leave the machine in an undefined state
   - **GUT test**: Call `transition_to("non_existent_state")`; assert current state remains unchanged

---

## Decision Points

**🛑 Pause and ask the user before proceeding:**

1. **FSM approach selection**: "Your use case has [N] expected states. I recommend [approach] because [reason]. Does that work, or do you prefer a different approach?"
   - Options: enum-based (simple, <5 states), node-based (recommended for characters, enter/exit hooks), resource-based (data-driven, editor-configurable)
   - Recommend: node-based for most character implementations
2. **State ownership**: "Should each state node manage its own sub-scene, or should all states be children of a single StateMachine node?"
   - Options: flat children (simpler, single scene), nested sub-scenes (modular, reusable states)
   - Recommend: flat children for single-player characters; nested for reusable AI state packs
3. **Parallel vs hierarchical vs flat**: "Your character has [movement + combat + animation] concerns. Should I use parallel machines, a hierarchical machine, or a single flat FSM?"
   - Options: parallel (independent concerns), hierarchical (nested states), flat (simple, <8 states)
   - Recommend: parallel for player characters (movement + combat), hierarchical for complex AI enemies

---

## 1. Approach Comparison

| Approach       | Complexity | Best For                              |
|----------------|------------|---------------------------------------|
| Enum-Based     | Low        | Simple objects, fewer than 5 states   |
| Node-Based     | Medium     | Characters with complex behavior      |
| Resource-Based | High       | Data-driven or editor-configurable AI |

---

## 2. Approach 1: Enum-Based (Simplest)

Use when you have a small number of states and no significant enter/exit logic.

### GDScript

```gdscript
extends CharacterBody2D

enum State { IDLE, PATROL, CHASE, ATTACK }

@export var patrol_range: float = 200.0
@export var chase_range: float = 300.0
@export var attack_range: float = 50.0
@export var speed: float = 80.0

var current_state: State = State.IDLE
var patrol_target: Vector2 = Vector2.ZERO

@onready var player: Node2D = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle()
		State.PATROL:
			_state_patrol()
		State.CHASE:
			_state_chase()
		State.ATTACK:
			_state_attack()

	move_and_slide()


func _state_idle() -> void:
	velocity = Vector2.ZERO
	if _player_in_range(chase_range):
		current_state = State.CHASE
	elif randf() < 0.005:
		patrol_target = global_position + Vector2(randf_range(-patrol_range, patrol_range), 0.0)
		current_state = State.PATROL


func _state_patrol() -> void:
	var direction := (patrol_target - global_position)
	if direction.length() < 4.0:
		current_state = State.IDLE
		return
	velocity = direction.normalized() * speed
	if _player_in_range(chase_range):
		current_state = State.CHASE


func _state_chase() -> void:
	if not is_instance_valid(player):
		current_state = State.IDLE
		return
	if _player_in_range(attack_range):
		current_state = State.ATTACK
		return
	if not _player_in_range(chase_range):
		current_state = State.PATROL
		return
	velocity = (player.global_position - global_position).normalized() * speed


func _state_attack() -> void:
	velocity = Vector2.ZERO
	if not _player_in_range(attack_range):
		current_state = State.CHASE


func _player_in_range(range: float) -> bool:
	if not is_instance_valid(player):
		return false
	return global_position.distance_to(player.global_position) <= range
```

### C# Equivalent

```csharp
using Godot;

public partial class SimpleEnemy : CharacterBody2D
{
    private enum State { Idle, Patrol, Chase, Attack }

    [Export] public float PatrolRange { get; set; } = 200f;
    [Export] public float ChaseRange  { get; set; } = 300f;
    [Export] public float AttackRange { get; set; } = 50f;
    [Export] public float Speed       { get; set; } = 80f;

    private State _currentState = State.Idle;
    private Vector2 _patrolTarget = Vector2.Zero;
    private Node2D _player;

    public override void _Ready()
    {
        _player = GetTree().GetFirstNodeInGroup("player") as Node2D;
    }

    public override void _PhysicsProcess(double delta)
    {
        switch (_currentState)
        {
            case State.Idle:   StateIdle();   break;
            case State.Patrol: StatePatrol(); break;
            case State.Chase:  StateChase();  break;
            case State.Attack: StateAttack(); break;
        }
        MoveAndSlide();
    }

    private void StateIdle()
    {
        Velocity = Vector2.Zero;
        if (PlayerInRange(ChaseRange))
        {
            _currentState = State.Chase;
        }
        else if (GD.Randf() < 0.005f)
        {
            _patrolTarget = GlobalPosition + new Vector2(GD.RandRange(-PatrolRange, PatrolRange), 0f);
            _currentState = State.Patrol;
        }
    }

    private void StatePatrol()
    {
        var direction = _patrolTarget - GlobalPosition;
        if (direction.Length() < 4f) { _currentState = State.Idle; return; }
        Velocity = direction.Normalized() * Speed;
        if (PlayerInRange(ChaseRange)) _currentState = State.Chase;
    }

    private void StateChase()
    {
        if (!IsInstanceValid(_player)) { _currentState = State.Idle; return; }
        if (PlayerInRange(AttackRange)) { _currentState = State.Attack; return; }
        if (!PlayerInRange(ChaseRange)) { _currentState = State.Patrol; return; }
        Velocity = (_player.GlobalPosition - GlobalPosition).Normalized() * Speed;
    }

    private void StateAttack()
    {
        Velocity = Vector2.Zero;
        if (!PlayerInRange(AttackRange)) _currentState = State.Chase;
    }

    private bool PlayerInRange(float range) =>
        IsInstanceValid(_player) && GlobalPosition.DistanceTo(_player.GlobalPosition) <= range;
}
```

> **When to upgrade away from enum-based:**
> - Enter/exit logic starts duplicating across state methods
> - Animation sync requires explicit enter/exit hooks
> - The `match`/`switch` block grows beyond ~100 lines

---

## 3. Approach 2: Node-Based (Recommended for Characters)

Each state is its own node. The `StateMachine` node delegates input and process calls to whichever state is active, and states trigger transitions by name.

### Scene Tree

```
Player (CharacterBody2D)
└── StateMachine (Node)
    ├── Idle  (State)
    ├── Run   (State)
    ├── Jump  (State)
    └── Attack (State)
```

### State Base Class

**GDScript (`state.gd`)**

```gdscript
class_name State
extends Node

## Populated by StateMachine._ready()
var entity: CharacterBody2D
var state_machine: StateMachine


## Called when this state becomes active.
func enter() -> void:
	pass


## Called when this state is deactivated.
func exit() -> void:
	pass


## Mirrors _process. Return a state name string to transition, or "" to stay.
func update(delta: float) -> String:
	return ""


## Mirrors _physics_process. Return a state name string to transition, or "".
func physics_update(delta: float) -> String:
	return ""


## Mirrors _unhandled_input.
func handle_input(event: InputEvent) -> String:
	return ""
```

**C# (`State.cs`)**

```csharp
using Godot;

public partial class State : Node
{
    /// Populated by StateMachine._Ready()
    public CharacterBody2D Entity { get; set; }
    public StateMachine StateMachine { get; set; }

    public virtual void Enter() { }
    public virtual void Exit() { }
    public virtual string Update(double delta) => string.Empty;
    public virtual string PhysicsUpdate(double delta) => string.Empty;
    public virtual string HandleInput(InputEvent @event) => string.Empty;
}
```

### StateMachine Class

**GDScript (`state_machine.gd`)**

```gdscript
class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.entity = owner as CharacterBody2D
			child.state_machine = self

	if initial_state:
		current_state = initial_state
		current_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	var next := current_state.handle_input(event)
	if next:
		transition_to(next)


func _process(delta: float) -> void:
	var next := current_state.update(delta)
	if next:
		transition_to(next)


func _physics_process(delta: float) -> void:
	var next := current_state.physics_update(delta)
	if next:
		transition_to(next)


func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		push_error("StateMachine: unknown state '%s'" % state_name)
		return
	current_state.exit()
	current_state = states[state_name]
	current_state.enter()
```

**C# (`StateMachine.cs`)**

```csharp
using System.Collections.Generic;
using Godot;

public partial class StateMachine : Node
{
    [Export] public State InitialState { get; set; }

    public State CurrentState { get; private set; }
    private readonly Dictionary<string, State> _states = new();

    public override void _Ready()
    {
        foreach (var child in GetChildren())
        {
            if (child is State state)
            {
                _states[state.Name] = state;
                state.Entity = Owner as CharacterBody2D;
                state.StateMachine = this;
            }
        }

        if (InitialState != null)
        {
            CurrentState = InitialState;
            CurrentState.Enter();
        }
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        var next = CurrentState.HandleInput(@event);
        if (!string.IsNullOrEmpty(next)) TransitionTo(next);
    }

    public override void _Process(double delta)
    {
        var next = CurrentState.Update(delta);
        if (!string.IsNullOrEmpty(next)) TransitionTo(next);
    }

    public override void _PhysicsProcess(double delta)
    {
        var next = CurrentState.PhysicsUpdate(delta);
        if (!string.IsNullOrEmpty(next)) TransitionTo(next);
    }

    public void TransitionTo(string stateName)
    {
        if (!_states.TryGetValue(stateName, out var next))
        {
            GD.PushError($"StateMachine: unknown state '{stateName}'");
            return;
        }
        CurrentState.Exit();
        CurrentState = next;
        CurrentState.Enter();
    }
}
```

### Concrete Example: IdleState

**GDScript (`idle_state.gd`)**

```gdscript
class_name IdleState
extends State


func enter() -> void:
	entity.get_node("AnimationPlayer").play("idle")


func physics_update(delta: float) -> String:
	if not entity.is_on_floor():
		return "Jump"
	if Input.get_axis("move_left", "move_right") != 0.0:
		return "Run"
	return ""


func handle_input(event: InputEvent) -> String:
	if event.is_action_pressed("jump") and entity.is_on_floor():
		return "Jump"
	if event.is_action_pressed("attack"):
		return "Attack"
	return ""
```

---

## 4. Approach 3: Resource-Based (Data-Driven)

Use when designers need to configure states in the Godot Inspector without modifying code.

### StateData Resource

```gdscript
class_name StateData
extends Resource

@export var state_name: String = ""
@export var animation_name: String = ""
@export var move_speed: float = 0.0
@export var can_transition_to: Array[String] = []
```

Export an `Array[StateData]` on your AI controller. Designers populate each entry in the Inspector — no code changes needed to tune behavior or add states. The runtime reads `can_transition_to` to validate transitions and picks `animation_name` / `move_speed` for each active state.

---

## 5. Hierarchical and Parallel State Machines

When a single flat FSM grows beyond 8–10 states, or when separate concerns (movement, combat, animation) create a combinatorial explosion, split into hierarchical or parallel machines.

### The Problem: State Explosion

A character with 3 movement states (idle, walk, run) and 3 combat states (none, attack, block) creates 9 combined states in a flat FSM. Add crouching and that's 18. Hierarchical/parallel machines keep it at 3 + 3 = 6.

### Approach A: Hierarchical (Nested State Machines)

States can contain sub-state machines. The outer machine handles high-level states; inner machines handle details.

**Scene Tree:**

```
Player (CharacterBody2D)
└── StateMachine (handles: OnGround, InAir, Climbing)
    ├── OnGround (contains sub-states: Idle, Walk, Run, Crouch)
    │   └── SubStateMachine
    │       ├── Idle
    │       ├── Walk
    │       ├── Run
    │       └── Crouch
    ├── InAir (contains sub-states: Jump, Fall, DoubleJump)
    │   └── SubStateMachine
    │       ├── Jump
    │       ├── Fall
    │       └── DoubleJump
    └── Climbing
```

**GDScript — Hierarchical State (extends the Node-based State from Section 3):**

```gdscript
# hierarchical_state.gd — a state that owns a sub-state machine
class_name HierarchicalState
extends State

@export var sub_state_machine: StateMachine

func enter() -> void:
	if sub_state_machine:
		sub_state_machine.set_physics_process(true)
		sub_state_machine.set_process(true)
		# Sub-machine starts from its initial state
		sub_state_machine.current_state.enter()

func exit() -> void:
	if sub_state_machine:
		sub_state_machine.current_state.exit()
		sub_state_machine.set_physics_process(false)
		sub_state_machine.set_process(false)

func physics_update(delta: float) -> String:
	# Check for transitions OUT of this hierarchical state first
	if not entity.is_on_floor():
		return "InAir"
	# Otherwise, let the sub-machine handle it internally
	return ""
```

**C# — Hierarchical State:**

```csharp
public partial class HierarchicalState : State
{
    [Export] public StateMachine SubStateMachine { get; set; }

    public override void Enter()
    {
        if (SubStateMachine != null)
        {
            SubStateMachine.SetPhysicsProcess(true);
            SubStateMachine.SetProcess(true);
            SubStateMachine.CurrentState.Enter();
        }
    }

    public override void Exit()
    {
        if (SubStateMachine != null)
        {
            SubStateMachine.CurrentState.Exit();
            SubStateMachine.SetPhysicsProcess(false);
            SubStateMachine.SetProcess(false);
        }
    }

    public override string PhysicsUpdate(double delta)
    {
        if (!Entity.IsOnFloor()) return "InAir";
        return string.Empty;
    }
}
```

### Approach B: Parallel State Machines

Run multiple independent state machines simultaneously. Each handles a different concern.

**Scene Tree:**

```
Player (CharacterBody2D)
├── MovementSM (StateMachine: Idle, Walk, Run, Jump, Fall)
├── CombatSM   (StateMachine: None, Attack, Block, Dodge)
└── AnimationSM (StateMachine: reads from Movement + Combat to pick animation)
```

**GDScript — Parallel machines on a character:**

```gdscript
extends CharacterBody2D

@onready var movement_sm: StateMachine = $MovementSM
@onready var combat_sm: StateMachine = $CombatSM

func _physics_process(delta: float) -> void:
	# Both machines update independently each frame.
	# The StateMachine class (Section 3) handles its own _physics_process.
	# Movement and combat don't interfere with each other.
	move_and_slide()

func get_animation_name() -> String:
	# Combine states to pick the right animation
	var move_state: String = movement_sm.current_state.name
	var combat_state: String = combat_sm.current_state.name

	if combat_state == "Attack":
		return "attack"  # combat overrides movement animation
	match move_state:
		"Run":
			return "run"
		"Jump", "Fall":
			return "air"
		_:
			return "idle"
```

**C#:**

```csharp
public partial class ParallelPlayer : CharacterBody2D
{
    private StateMachine _movementSM;
    private StateMachine _combatSM;

    public override void _Ready()
    {
        _movementSM = GetNode<StateMachine>("MovementSM");
        _combatSM = GetNode<StateMachine>("CombatSM");
    }

    public override void _PhysicsProcess(double delta)
    {
        MoveAndSlide();
    }

    public string GetAnimationName()
    {
        string moveState = _movementSM.CurrentState.Name;
        string combatState = _combatSM.CurrentState.Name;

        if (combatState == "Attack") return "attack";
        return moveState switch
        {
            "Run" => "run",
            "Jump" or "Fall" => "air",
            _ => "idle"
        };
    }
}
```

### Which to Choose

| Pattern | Use When |
|---------|----------|
| **Flat FSM** | ≤ 8 states, single concern |
| **Hierarchical** | States naturally nest (OnGround has sub-states), transitions exist between top-level groups |
| **Parallel** | Independent concerns (movement + combat + animation), no nesting relationship |

---

## 6. Decision Flowchart

```
Start
  │
  ▼
Fewer than 5 states?
  ├─ Yes ──────────────────────────────────► Enum-Based
  └─ No
       │
       ▼
     Multiple independent concerns
     (movement + combat + animation)?
       ├─ Yes ──────────────────────────────► Parallel State Machines
       └─ No
            │
            ▼
          States naturally nest
          (sub-states within states)?
            ├─ Yes ────────────────────────► Hierarchical State Machine
            └─ No
                 │
                 ▼
               Designers need to configure
               states in the Inspector?
                 ├─ Yes ──────────────────► Resource-Based
                 └─ No ──────────────────► Node-Based
```

---

## N. Common Agent Mistakes

| # | Mistake | Why it's wrong | Correct approach |
|---|---------|---------------|------------------|
| 1 | Calling `transition_to()` inside `enter()` of the new state | Creates infinite recursion — `enter()` triggers transition, which triggers exit+enter on the same state, which triggers `enter()` again | Return a state name string from `update()`/`physics_update()`; never call `transition_to()` from within `enter()` |
| 2 | Using `match`/`switch` with states but forgetting `return` after transition | Falls through to the next state's logic in the same frame; both states run their logic | Always `return` after `current_state = NewState` unless the match is the last branch |
| 3 | Not calling `enter()` on the initial state in `_ready()` | The starter state's `enter()` never runs; animations, timers, or initial positioning are skipped | Call `current_state.enter()` in `StateMachine._ready()` after setting `initial_state` |
| 4 | Using `StringName` for state names inconsistently | `transition_to("idle")` and `transition_to(&"idle")` work differently in Dictionary lookups | Pick one convention (prefer `&"name"` for performance) and stick to it everywhere |
| 5 | Sharing the same State node instance across multiple entities | State nodes store per-entity references like `entity` or `animation_player`; sharing them leaks references between instances | Each entity needs its own StateMachine and State node instances — never `preload()` a State scene for reuse without instantiation |
| 6 | Placing animation code in `_physics_process()` instead of `enter()` | Animation re-triggers every frame, causing flickering and performance loss | All `.play()` calls go in `enter()`; only movement logic goes in `physics_update()` |
| 7 | Defining state transitions in both the parent (via `_process`) and children (via return from `update`) | Transitions can fire twice or conflict; debugging becomes harder | Pick ONE pattern: either parent checks all transitions (simple FSMs) or each child returns transition names (node-based pattern) |

## N+1. Addon Override

When the project has `orchestrator` installed:

| Addon | Coverage Type | Usage Guidance |
|-------|--------------|----------------|
| `orchestrator` | Full replacement | Use Orchestrator's visual state machine instead of the patterns below |
| `pandora` | Partial (quest states) | Use Pandora for quest/objective tracking; use skill patterns for character FSM |

**Conflict warning**: `orchestrator` and `state-machine` skill patterns should not be mixed in the same entity. Pick one per character.

**When orchestrator is present but user declines to use it**: Fall back to the node-based pattern (Section 3). The enum-based pattern is too rigid for characters that would plausibly use Orchestrator.

## N+2. Self-Verification

After generating code, run this verification loop. Fix any failures before reporting completion.

### Automated checks (agent runs without user)

- [ ] **Infinite recursion scan**: Grep for `transition_to(` inside `enter()` — flag if found
- [ ] **Enter/exit parity scan**: For each State subclass, check that `enter()` and `exit()` are both defined (or both inherited)
- [ ] **Animation placement scan**: Grep for `.play(` inside `update()` — flag any matches

### Manual checks (agent reviews code, reports to user)

- [ ] **Circular transition audit**: Trace all transition paths manually; verify no path loops back to the starting state without an exit condition
- [ ] **Unused state detection**: Check if every defined state is reachable via at least one transition path from the initial state

### Behavioral checks (user must test in Godot)

- [ ] **GUT test**: Generate a test that transitions through all defined states and asserts correct enter/exit sequence
  - Run: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/skill_verification -gprefix=state_machine -gexit`
- [ ] **Play test**: Run the game; trigger each state transition via input or gameplay; verify animation changes and no stuck states

## N+3. Implementation Checklist

- [ ] Chose the approach that matches actual complexity (enum / node / resource)
- [ ] Every state has explicit `enter()` and `exit()` methods (or equivalent)
- [ ] All transitions are named explicitly — no implicit fallthrough between states
- [ ] Animations are started in `enter()` and cleaned up in `exit()` where needed
- [ ] No circular transition loops that could cause infinite recursion in a single frame
- [ ] Flat FSM is replaced with hierarchical or parallel when states exceed ~8 or span multiple concerns
- [ ] Parallel state machines don't modify the same state (e.g., both setting velocity) — one concern per machine
- [ ] **New**: Self-Verification loop completed (see section above)
- [ ] **New**: Addon presence checked and user consulted (Step 0.5)
