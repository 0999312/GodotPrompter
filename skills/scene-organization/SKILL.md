---
name: scene-organization
description: Use when designing scene tree structure — composition vs inheritance, when to split scenes, node hierarchy patterns
---

# Scene Organization

A guide for structuring Godot 4.3+ scene trees: when to split, when to compose, and how nodes should communicate.

> **Related skills:** **component-system** for composition patterns, **event-bus** for decoupled communication, **godot-brainstorming** for scene tree planning.

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

## 6. Checklist

- [ ] Each scene has exactly one responsibility, named in two words or fewer
- [ ] Reusable components (`HealthComponent`, `StateMachine`, etc.) are separate `.tscn` files
- [ ] No scene exceeds ~15 nodes without a documented reason to keep it together
- [ ] Children emit signals upward; parents call methods downward
- [ ] Peer-to-peer communication uses an EventBus Autoload, not `get_parent()` chains
- [ ] No `get_parent().get_parent()` or `get_node("../../SomeNode")` paths in code
- [ ] Nodes are grouped into logical containers (`Visuals`, `Components`, `AI`, etc.) for readability
