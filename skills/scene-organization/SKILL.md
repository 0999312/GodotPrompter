---
name: scene-organization
description: Use when designing scene tree structure — composition vs inheritance, when to split scenes, node hierarchy patterns
godot_version: "4.3+"
status: stable
last_validated: "2026-04-27"
agent_tested_on: ["claude-4-5-opus", "deepseek-v4-flash"]
---

# Scene Organization

A guide for structuring Godot 4.3+ scene trees: when to split, when to compose, and how nodes should communicate.

> **Related skills:** **component-system** for composition patterns, **event-bus** for decoupled communication, **godot-brainstorming** for scene tree planning, **2d-essentials** for TileMapLayer and CanvasLayer organization.
>
> **Addon Override:** No known addon fully replaces scene organization patterns. Some addons provide visual scene management — see `docs/ADDON_REGISTRY.md`.
>
> **Interface Contract:** When co-loaded with `component-system`, use composition for reusable behavior (HealthComponent, HitboxComponent) and inheritance only for structural variants (Orc → Goblin). When co-loaded with `event-bus`, define signal direction: child signals travel up, method calls travel down, EventBus travels sideways.

---

## Success Criteria

When organizing scene structure, the result MUST satisfy:

1. **Single responsibility**: Every scene can be described in two words or fewer — if it cannot, it needs splitting
   - **GUT test**: Code inspection — verify each `.tscn` file has a clear, single purpose
2. **No get_parent() chains**: No code uses `get_parent()` more than once consecutively (no `get_parent().get_parent(...)`)
   - **GUT test**: Grep for `get_parent()\.get_parent` — flag if found
3. **No hardcoded absolute paths**: No `get_node("/root/...")` or `get_node("../../...")` paths outside the node's own subtree
   - **GUT test**: Grep for `get_node\("/root` and `get_parent\(\)\.get_node\(` — flag if found
4. **Composition over inheritance**: Reusable components are separate `.tscn` files; inheritance is used only for structural variants
   - **GUT test**: Code inspection — verify each `extends` chain is shallow (<3 levels) unless structurally justified

---

## Decision Points

**🛑 Pause and ask the user before proceeding:**

1. **Scene splitting**: "Should this group of nodes be a separate scene, or stay in the parent?"
   - Options: split (if reused elsewhere, exceeds ~15 nodes, or benefits from independent editing), keep (tightly coupled, single-use, small)
   - Recommend: split when you would use it in >1 place; keep when splitting would require >3 signals to reconnect
2. **Composition vs inheritance**: "Should entities share behavior via composition or inheritance?"
   - Options: composition (component nodes, mix-and-match, more flexible), inheritance (extends child scenes, simpler for structural variants)
   - Recommend: composition for behavior (health, damage, movement); inheritance for structural variants of the same entity type
3. **Node grouping strategy**: "How should nodes be organized within a scene?"
   - Options: by function (Visuals, Collision, Components, AI containers), flat (all children directly under root)
   - Recommend: group by function using plain Node containers for scenes with >5 children
4. **Signal direction pattern**: "Should signals travel up (child→parent) or should the parent directly observe children?"
   - Options: signals up + methods down (standard pattern), bidirectional signals (parents listen to children AND emit to children)
   - Recommend: signals up + methods down — it is the clearest and most maintainable pattern

---

## 1. Core Principle

Scenes are building blocks. Each scene encapsulates exactly one concept — a player, an enemy, a health bar, a weapon. A scene should be understandable in isolation, reusable without modification, and replaceable without breaking its neighbors.

> One scene = one responsibility. If you struggle to name a scene in two words or fewer, it is probably doing too much.

---

## 2. Composition Over Inheritance

### Player Scene — Composed from Reusable Parts

```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── HealthComponent
├── HitboxComponent
├── StateMachine
└── AnimationPlayer
```

`HealthComponent`, `HitboxComponent`, and `StateMachine` are separate `.tscn` files instantiated as child scenes. Any entity that needs health — enemy, destructible crate, boss — can include `HealthComponent` without duplicating logic.

### HealthComponent — Full Example

**GDScript**

```gdscript
# health_component.gd
class_name HealthComponent
extends Node

signal health_changed(old_value: int, new_value: int)
signal died

@export var max_health: int = 100

var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    if amount <= 0:
        return
    var old_health := current_health
    current_health = max(0, current_health - amount)
    health_changed.emit(old_health, current_health)
    if current_health == 0:
        died.emit()

func heal(amount: int) -> void:
    if amount <= 0:
        return
    var old_health := current_health
    current_health = min(max_health, current_health + amount)
    health_changed.emit(old_health, current_health)

func is_alive() -> bool:
    return current_health > 0
```

**C#**

```csharp
// HealthComponent.cs
using Godot;

[GlobalClass]
public partial class HealthComponent : Node
{
    [Signal]
    public delegate void HealthChangedEventHandler(int oldValue, int newValue);

    [Signal]
    public delegate void DiedEventHandler();

    [Export]
    public int MaxHealth { get; set; } = 100;

    public int CurrentHealth { get; private set; }

    public override void _Ready()
    {
        CurrentHealth = MaxHealth;
    }

    public void TakeDamage(int amount)
    {
        if (amount <= 0)
            return;
        int oldHealth = CurrentHealth;
        CurrentHealth = Mathf.Max(0, CurrentHealth - amount);
        EmitSignal(SignalName.HealthChanged, oldHealth, CurrentHealth);
        if (CurrentHealth == 0)
            EmitSignal(SignalName.Died);
    }

    public void Heal(int amount)
    {
        if (amount <= 0)
            return;
        int oldHealth = CurrentHealth;
        CurrentHealth = Mathf.Min(MaxHealth, CurrentHealth + amount);
        EmitSignal(SignalName.HealthChanged, oldHealth, CurrentHealth);
    }

    public bool IsAlive() => CurrentHealth > 0;
}
```

### When to Use Inheritance Instead

Inheritance suits cases where scenes share **structure**, not just behavior — when child scenes are variations of the same thing with identical node layout and only a few exported properties differ.

Good candidates:

- `Enemy` → `Orc`, `Goblin` — same bones (Sprite2D, CollisionShape2D, HealthComponent, AI), different stats and art
- `Weapon` → `Sword`, `Bow` — same slot attachment logic, different animations and damage type
- `Pickup` → `HealthPickup`, `AmmoPickup` — same Area2D + CollisionShape2D + animation, different effect on collection

### Rule of Thumb

| Scenario | Pattern |
|---|---|
| You would copy-paste the entire scene and change a few exported properties | **Inheritance** |
| You want to mix and match a subset of nodes across different entity types | **Composition** |

---

## 3. Scene Splitting Rules

### Split a scene when:

- **Reuse** — the sub-scene is needed in more than one parent scene
- **Complexity** — the scene exceeds roughly 15 nodes; it is carrying more than one concern
- **Independence** — the sub-scene can be tested, previewed, or modified without opening its parent
- **Team** — separate scenes reduce merge conflicts when multiple people work on the same feature

### Keep nodes together when:

- Nodes are **tightly coupled** — splitting them would require excessive signal wiring just to replicate what a direct node reference handles cleanly
- The grouping is **small and used only once** — a two-node helper that exists in a single scene does not warrant its own `.tscn` file
- Splitting would create **simple-operation overhead** — if a parent must wire three signals just to tell a child "you were hit", the split is not paying for itself

---

## 4. Node Communication Patterns

```
        [Parent]
        /      \
  [Child A]  [Child B]
       \
     [Child C]
```

### Signals travel up (child → parent)

A child node announces that something happened. The parent — or any node that has connected to the signal — decides what to do about it. This keeps children ignorant of their context and fully reusable.

```gdscript
# Child emits; it does not know who is listening
health_component.died.connect(_on_player_died)
```

### Method calls travel down (parent → child)

A parent drives its children by calling their methods directly. The parent owns the reference; the child exposes a clean API and does not need to know about its parent.

```gdscript
# Parent calls into child
$HealthComponent.take_damage(10)
$AnimationPlayer.play("hurt")
```

### Unique Node IDs (Godot 4.6+)

Since Godot 4.6, every node has a **persistent unique internal ID** that remains stable across renames and scene tree reorganizations.

```gdscript
# Get the unique ID of a node (persists across renames)
var node_id: int = $MyNode.node_id
```

**What this means for refactoring:**

- Renaming a node no longer breaks references in inherited or instantiated scenes
- Moving nodes within the scene tree preserves their identity
- Unique IDs are saved in `.tscn` files — scenes must be re-saved in 4.6 to benefit

**To upgrade existing projects:**

```
Project → Tools → Upgrade Project Files
```

This re-saves all scenes with the new node ID data. After upgrading, refactoring becomes significantly safer.

### EventBus travels sideways (peer → peer)

For communication between scenes that have no ancestor–descendant relationship — e.g., an enemy notifying the HUD — use an Autoload event bus. Emitting on the bus decouples sender from receiver entirely.

```gdscript
# Autoload: EventBus.gd
signal enemy_killed(enemy: Enemy)

# Enemy scene
EventBus.enemy_killed.emit(self)

# HUD scene
EventBus.enemy_killed.connect(_on_enemy_killed)
```

---

## 5. Scene Tree Patterns

### Entity-Component Pattern

```
Enemy (CharacterBody2D)
├── Visuals
│   ├── Sprite2D
│   └── AnimationPlayer
├── Collision
│   └── CollisionShape2D
├── Components
│   ├── HealthComponent
│   └── HitboxComponent
└── AI
    ├── NavigationAgent2D
    └── StateMachine
```

Group by concern using plain `Node` containers (`Visuals`, `Collision`, `Components`, `AI`). Each sub-group can be collapsed in the editor and worked on independently.

### UI Scene Pattern

```
HUD (CanvasLayer)
├── MarginContainer
│   ├── TopBar
│   │   ├── HealthBar
│   │   └── ResourceBar
│   └── BottomBar
│       ├── Hotbar
│       └── MiniMap
└── PauseMenu
```

`CanvasLayer` ensures HUD elements are always rendered on top. `MarginContainer` handles safe-area padding. `TopBar`, `BottomBar`, and `PauseMenu` are separate instantiated scenes so each can be edited without opening the root HUD scene.

### Level Scene Pattern

```
Level01 (Node2D)
├── TileMapLayer
├── Entities
│   ├── Player (instance)
│   └── Enemies (Node2D)
│       ├── Orc (instance)
│       └── Goblin (instance)
├── Pickups (Node2D)
├── Navigation
│   └── NavigationRegion2D
└── Camera2D
```

The level scene is a composition root — it owns the layout and spawns instances, but contains no gameplay logic itself. `Entities`, `Pickups`, and `Navigation` are plain `Node2D` containers used for organizational grouping and to simplify `get_children()` iteration.

---

## N. Common Agent Mistakes

| # | Mistake | Why it's wrong | Correct approach |
|---|---------|---------------|------------------|
| 1 | Using `get_parent().get_parent()` to access an ancestor | Breaks when the scene tree changes; causes runtime null errors in unrelated code changes | Use signals (child→parent) or an EventBus (peer→peer); never traverse up more than one level |
| 2 | Hard-coding absolute node paths like `get_node("/root/Main/Player")` | Path breaks if the root scene changes name or structure; no compile-time validation | Use groups (`add_to_group("player")` + `get_tree().get_first_node_in_group("player")`) or exported NodePath |
| 3 | Putting everything in one monolithic scene | Scene becomes difficult to navigate, edit, and version; merge conflicts are frequent | Split into sub-scenes at ~15 nodes; each sub-scene has a single responsibility |
| 4 | Using inheritance when composition would be better | Deep `extends` chains make it hard to mix behaviors across unrelated entity types | Use components (HealthComponent, HitboxComponent) as child nodes; use inheritance only for structural variants (Orc → Goblin) |
| 5 | Mixing logic-heavy nodes directly as root children | The root scene becomes a dumping ground for unrelated logic; hard to test or reuse individual systems | Group by concern using plain `Node` containers: `Visuals/`, `Components/`, `AI/` |
| 6 | Not using `%` unique names for editor-placed nodes | Renaming a node breaks all `$Path` references to it; fragile refactoring | Use `%UniqueName` (`%Sprite2D`) for nodes that are pre-placed in the scene — they survive renames |
| 7 | Using `%` unique names for runtime-instantiated nodes | `%` only works for nodes in the `.tscn` file; instantiated sub-scenes' nodes are not in the unique name scope | Use `$` relative path inside instantiated sub-scenes, or export a `NodePath` that the parent sets after instantiation |

## N+1. Addon Override

When the project has relevant addons:

| Addon | Coverage Type | Usage Guidance |
|-------|--------------|----------------|
| `orchestrator` | Complementary | Visual node wiring and composition for designer-facing workflows; scene organization patterns still apply for hand-coded logic |

No known addon replaces scene organization fundamentals. `orchestrator` provides visual composition but does not eliminate the need for clear scene boundaries.

## N+2. Self-Verification

After generating code, run this verification loop. Fix any failures before reporting completion.

### Automated checks (agent runs without user)

- [ ] **Parent chain scan**: Grep for `get_parent()\.get_parent` — flag if found
- [ ] **Absolute path scan**: Grep for `get_node\("/root` and `get_parent\(\)\.get_node\(` — flag if found
- [ ] **Unique name scan**: For files that instantiate sub-scenes at runtime, grep for `%` node access — flag as potential runtime error

### Manual checks (agent reviews code, reports to user)

- [ ] **Scene responsibility audit**: Review each `.tscn` file — can you describe it in two words? If not, suggest splitting
- [ ] **Composition vs inheritance audit**: Review each `extends` chain — is inheritance structural (OK) or behavioral (favor composition)?
- [ ] **Node grouping audit**: For scenes with >5 children, verify they are grouped by concern into named container nodes

### Behavioral checks (user must test in Godot)

- [ ] **GUT test**: Generate a test that verifies node references resolve correctly after scene tree changes (rename a node, re-parent — do references still work?)
  - Run: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/skill_verification -gprefix=scene -gexit`
- [ ] **Play test**: Open the game; verify all scenes load without errors; verify UI stays attached to correct elements after scene transitions

## N+3. Implementation Checklist

- [ ] Each scene has exactly one responsibility, named in two words or fewer
- [ ] Reusable components (`HealthComponent`, `StateMachine`, etc.) are separate `.tscn` files
- [ ] No scene exceeds ~15 nodes without a documented reason to keep it together
- [ ] Children emit signals upward; parents call methods downward
- [ ] Peer-to-peer communication uses an EventBus Autoload, not `get_parent()` chains
- [ ] No `get_parent().get_parent()` or `get_node("../../SomeNode")` paths in code
- [ ] Nodes are grouped into logical containers (`Visuals`, `Components`, `AI`, etc.) for readability
- [ ] **New**: `%` unique names used for pre-placed nodes; `$` paths used for runtime-instantiated nodes
- [ ] **New**: Self-Verification loop completed (see section above)
- [ ] **New**: Addon presence checked and user consulted (Step 0.5)
