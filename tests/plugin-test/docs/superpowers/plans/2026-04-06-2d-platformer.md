# 2D Platformer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 2D side-scrolling platformer with node-based state machine, light/heavy attacks, two enemy types (Slime, Skeleton), coin collectibles, and a stat upgrade system.

**Architecture:** Node-based state machine for player and enemies. Reusable components (HealthComponent, Hitbox, Hurtbox) shared via separate scenes. PlayerStats as an Autoload Resource for global state. EventBus Autoload for cross-system signals.

**Tech Stack:** Godot 4.3+, GDScript, GUT (testing framework)

---

## File Structure

```
project.godot
scripts/
  autoloads/
    event_bus.gd              # global signals
    player_stats.gd           # singleton stats/coins/upgrades
  components/
    health_component.gd       # reusable HP tracking
    hitbox.gd                 # deals damage
    hurtbox.gd                # receives damage
  state_machine/
    state_machine.gd          # manages states
    state.gd                  # base state class
  player/
    player.gd                 # player controller
    states/
      player_idle.gd
      player_run.gd
      player_jump.gd
      player_fall.gd
      player_light_attack.gd
      player_heavy_attack.gd
      player_hurt.gd
      player_death.gd
  enemies/
    enemy_base.gd             # shared enemy logic
    slime/
      slime.gd
      slime_patrol.gd
      slime_chase.gd
      slime_attack.gd
      slime_hurt.gd
      slime_death.gd
    skeleton/
      skeleton.gd
      skeleton_patrol.gd
      skeleton_attack.gd
      skeleton_hurt.gd
      skeleton_death.gd
    bone_projectile.gd
  collectibles/
    coin.gd
  ui/
    hud.gd
    upgrade_ui.gd
  interactables/
    upgrade_station.gd
  resources/
    upgrade_data.gd
scenes/
  components/
    health_component.tscn
    hitbox.tscn
    hurtbox.tscn
  player/
    player.tscn
  enemies/
    slime.tscn
    skeleton.tscn
    bone_projectile.tscn
  collectibles/
    coin.tscn
  ui/
    hud.tscn
    upgrade_ui.tscn
  interactables/
    upgrade_station.tscn
  levels/
    test_level.tscn
resources/
  upgrades/
    health_upgrade.tres
    attack_upgrade.tres
    attack_speed_upgrade.tres
```

---

## Task 1: Project Setup & Autoloads

**Files:**
- Create: `project.godot`
- Create: `scripts/autoloads/event_bus.gd`
- Create: `scripts/autoloads/player_stats.gd`
- Create: `scripts/resources/upgrade_data.gd`

- [ ] **Step 1: Create project.godot**

```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; but it can also be manually edited.

config_version=5

[application]

config/name="2D Platformer"
config/features=PackedStringArray("4.3", "GL Compatibility")

[autoload]

EventBus="*res://scripts/autoloads/event_bus.gd"
PlayerStats="*res://scripts/autoloads/player_stats.gd"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[input]

move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":32,"key_label":0,"unicode":32,"location":0,"echo":false,"script":null)
]
}
light_attack={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":74,"key_label":0,"unicode":106,"location":0,"echo":false,"script":null)
]
}
heavy_attack={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":75,"key_label":0,"unicode":107,"location":0,"echo":false,"script":null)
]
}
interact={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":70,"key_label":0,"unicode":102,"location":0,"echo":false,"script":null)
]
}

[layer_names]

2d_physics/layer_1="World"
2d_physics/layer_2="Player"
2d_physics/layer_3="Enemies"
2d_physics/layer_4="PlayerHitbox"
2d_physics/layer_5="EnemyHitbox"
2d_physics/layer_6="Collectibles"

[rendering]

renderer/rendering_method="gl_compatibility"
```

Input map: A/D = move, Space = jump, J = light attack, K = heavy attack, F = interact.

- [ ] **Step 2: Create EventBus**

```gdscript
# scripts/autoloads/event_bus.gd
extends Node

signal coin_collected(value: int)
signal player_died
signal enemy_died(position: Vector2, coin_value: int)
signal upgrade_purchased(upgrade_type: String, new_level: int)
```

- [ ] **Step 3: Create UpgradeData resource script**

```gdscript
# scripts/resources/upgrade_data.gd
class_name UpgradeData
extends Resource

@export var upgrade_name: String
@export var base_cost: int = 10
@export var cost_scaling: float = 1.5
@export var max_level: int = 5
@export var value_per_level: float = 0.2

var current_level: int = 0


func get_cost() -> int:
	return int(base_cost * pow(cost_scaling, current_level))


func can_upgrade() -> bool:
	return current_level < max_level


func get_current_value() -> float:
	return value_per_level * current_level
```

- [ ] **Step 4: Create PlayerStats autoload**

```gdscript
# scripts/autoloads/player_stats.gd
extends Node

signal health_changed(current: int, maximum: int)
signal coins_changed(total: int)
signal stats_changed

var max_health: int = 100
var current_health: int = 100
var base_attack: float = 10.0
var attack_multiplier: float = 1.0
var heavy_attack_multiplier: float = 2.5
var attack_speed: float = 1.0
var move_speed: float = 200.0
var jump_velocity: float = -400.0
var coins: int = 0

var health_upgrade: UpgradeData
var attack_upgrade: UpgradeData
var attack_speed_upgrade: UpgradeData


func _ready() -> void:
	health_upgrade = UpgradeData.new()
	health_upgrade.upgrade_name = "Health"
	health_upgrade.base_cost = 10
	health_upgrade.value_per_level = 20.0

	attack_upgrade = UpgradeData.new()
	attack_upgrade.upgrade_name = "Attack"
	attack_upgrade.base_cost = 15
	attack_upgrade.value_per_level = 0.2

	attack_speed_upgrade = UpgradeData.new()
	attack_speed_upgrade.upgrade_name = "Attack Speed"
	attack_speed_upgrade.base_cost = 20
	attack_speed_upgrade.value_per_level = 0.15


func get_light_damage() -> float:
	return base_attack * attack_multiplier


func get_heavy_damage() -> float:
	return base_attack * attack_multiplier * heavy_attack_multiplier


func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)


func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		EventBus.player_died.emit()


func heal_full() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func try_upgrade(upgrade: UpgradeData) -> bool:
	if not upgrade.can_upgrade():
		return false
	var cost := upgrade.get_cost()
	if coins < cost:
		return false

	coins -= cost
	upgrade.current_level += 1
	coins_changed.emit(coins)

	if upgrade == health_upgrade:
		max_health += int(upgrade.value_per_level)
		current_health += int(upgrade.value_per_level)
		health_changed.emit(current_health, max_health)
	elif upgrade == attack_upgrade:
		attack_multiplier += upgrade.value_per_level
	elif upgrade == attack_speed_upgrade:
		attack_speed += upgrade.value_per_level

	stats_changed.emit()
	EventBus.upgrade_purchased.emit(upgrade.upgrade_name, upgrade.current_level)
	return true
```

- [ ] **Step 5: Commit**

```bash
git add project.godot scripts/autoloads/ scripts/resources/
git commit -m "feat: project setup with autoloads and upgrade data"
```

---

## Task 2: State Machine Framework

**Files:**
- Create: `scripts/state_machine/state.gd`
- Create: `scripts/state_machine/state_machine.gd`

- [ ] **Step 1: Create base State class**

```gdscript
# scripts/state_machine/state.gd
class_name State
extends Node

var player: CharacterBody2D
var state_machine: StateMachine


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
```

- [ ] **Step 2: Create StateMachine**

```gdscript
# scripts/state_machine/state_machine.gd
class_name StateMachine
extends Node

signal state_changed(old_state: StringName, new_state: StringName)

@export var initial_state: State

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
	if initial_state:
		current_state = initial_state
		current_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition_to(target_state_name: String) -> void:
	var target_state_key := target_state_name.to_lower()
	if not states.has(target_state_key):
		push_warning("State '%s' not found" % target_state_name)
		return
	var old_name := current_state.name
	current_state.exit()
	current_state = states[target_state_key]
	current_state.enter()
	state_changed.emit(old_name, current_state.name)
```

- [ ] **Step 3: Commit**

```bash
git add scripts/state_machine/
git commit -m "feat: node-based state machine framework"
```

---

## Task 3: Reusable Components (HealthComponent, Hitbox, Hurtbox)

**Files:**
- Create: `scripts/components/health_component.gd`
- Create: `scenes/components/health_component.tscn`
- Create: `scripts/components/hitbox.gd`
- Create: `scenes/components/hitbox.tscn`
- Create: `scripts/components/hurtbox.gd`
- Create: `scenes/components/hurtbox.tscn`

- [ ] **Step 1: Create HealthComponent script**

```gdscript
# scripts/components/health_component.gd
class_name HealthComponent
extends Node

signal damaged(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0

var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	damaged.emit(amount)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	healed.emit(amount)
```

- [ ] **Step 2: Create HealthComponent scene**

```tscn
; scenes/components/health_component.tscn
[gd_scene load_steps=2 format=3 uid="uid://health_comp"]

[ext_resource type="Script" path="res://scripts/components/health_component.gd" id="1"]

[node name="HealthComponent" type="Node"]
script = ExtResource("1")
```

- [ ] **Step 3: Create Hitbox script**

```gdscript
# scripts/components/hitbox.gd
class_name Hitbox
extends Area2D

@export var damage: float = 10.0

var is_active: bool = false


func activate(attack_damage: float) -> void:
	damage = attack_damage
	is_active = true
	monitoring = true


func deactivate() -> void:
	is_active = false
	monitoring = false
```

- [ ] **Step 4: Create Hitbox scene**

```tscn
; scenes/components/hitbox.tscn
[gd_scene load_steps=2 format=3 uid="uid://hitbox"]

[ext_resource type="Script" path="res://scripts/components/hitbox.gd" id="1"]

[node name="Hitbox" type="Area2D"]
script = ExtResource("1")
collision_layer = 0
collision_mask = 0
monitoring = false

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = null
```

- [ ] **Step 5: Create Hurtbox script**

```gdscript
# scripts/components/hurtbox.gd
class_name Hurtbox
extends Area2D

signal hit_received(damage: float)


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.is_active:
		hit_received.emit(area.damage)
```

- [ ] **Step 6: Create Hurtbox scene**

```tscn
; scenes/components/hurtbox.tscn
[gd_scene load_steps=2 format=3 uid="uid://hurtbox"]

[ext_resource type="Script" path="res://scripts/components/hurtbox.gd" id="1"]

[node name="Hurtbox" type="Area2D"]
script = ExtResource("1")
collision_layer = 0
collision_mask = 0

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = null
```

- [ ] **Step 7: Commit**

```bash
git add scripts/components/ scenes/components/
git commit -m "feat: reusable health, hitbox, and hurtbox components"
```

---

## Task 4: Player Scene & Script

**Files:**
- Create: `scripts/player/player.gd`
- Create: `scenes/player/player.tscn`

- [ ] **Step 1: Create player script**

```gdscript
# scripts/player/player.gd
class_name Player
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox_pivot: Node2D = $HitboxPivot
@onready var hitbox: Hitbox = $HitboxPivot/Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var attack_cooldown: Timer = $AttackCooldown

var facing_right: bool = true
var can_coyote_jump: bool = false
var can_attack: bool = true


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit_received)
	coyote_timer.timeout.connect(func(): can_coyote_jump = false)
	attack_cooldown.timeout.connect(func(): can_attack = true)


func flip(direction: float) -> void:
	if direction > 0 and not facing_right:
		facing_right = true
		sprite.flip_h = false
		hitbox_pivot.scale.x = 1
	elif direction < 0 and facing_right:
		facing_right = false
		sprite.flip_h = true
		hitbox_pivot.scale.x = -1


func start_coyote_time() -> void:
	can_coyote_jump = true
	coyote_timer.start()


func start_attack_cooldown() -> void:
	can_attack = false
	attack_cooldown.wait_time = 0.4 / PlayerStats.attack_speed
	attack_cooldown.start()


func _on_hit_received(damage: float) -> void:
	PlayerStats.take_damage(int(damage))
	if PlayerStats.current_health > 0:
		state_machine.transition_to("Hurt")
	else:
		state_machine.transition_to("Death")
```

- [ ] **Step 2: Create player scene file**

```tscn
; scenes/player/player.tscn
[gd_scene load_steps=3 format=3 uid="uid://player"]

[ext_resource type="Script" path="res://scripts/player/player.gd" id="1"]
[ext_resource type="Script" path="res://scripts/state_machine/state_machine.gd" id="2"]

[node name="Player" type="CharacterBody2D"]
collision_layer = 2
collision_mask = 1
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]

[node name="StateMachine" type="Node" parent="."]
script = ExtResource("2")

[node name="HitboxPivot" type="Node2D" parent="."]

[node name="Hitbox" type="Area2D" parent="HitboxPivot"]
collision_layer = 16
collision_mask = 0
monitoring = false

[node name="CollisionShape2D" type="CollisionShape2D" parent="HitboxPivot/Hitbox"]

[node name="Hurtbox" type="Area2D" parent="."]
collision_layer = 0
collision_mask = 32

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hurtbox"]

[node name="CoyoteTimer" type="Timer" parent="."]
wait_time = 0.1
one_shot = true

[node name="AttackCooldown" type="Timer" parent="."]
wait_time = 0.4
one_shot = true
```

Note: Hitbox on layer 5 (PlayerHitbox, value 16), Hurtbox mask on layer 5 (EnemyHitbox, value 32). CollisionShapes need to be assigned actual shapes in the editor (RectangleShape2D/CapsuleShape2D).

- [ ] **Step 3: Commit**

```bash
git add scripts/player/player.gd scenes/player/
git commit -m "feat: player scene and controller script"
```

---

## Task 5: Player States

**Files:**
- Create: `scripts/player/states/player_idle.gd`
- Create: `scripts/player/states/player_run.gd`
- Create: `scripts/player/states/player_jump.gd`
- Create: `scripts/player/states/player_fall.gd`
- Create: `scripts/player/states/player_light_attack.gd`
- Create: `scripts/player/states/player_heavy_attack.gd`
- Create: `scripts/player/states/player_hurt.gd`
- Create: `scripts/player/states/player_death.gd`
- Modify: `scenes/player/player.tscn` (add state nodes)

- [ ] **Step 1: Create Idle state**

```gdscript
# scripts/player/states/player_idle.gd
extends State


func enter() -> void:
	player.animation_player.play("idle")
	player.velocity.x = 0.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	if not player.is_on_floor():
		player.start_coyote_time()
		state_machine.transition_to("Fall")
		return

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		state_machine.transition_to("Run")
		return

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
```

- [ ] **Step 2: Create Run state**

```gdscript
# scripts/player/states/player_run.gd
extends State


func enter() -> void:
	player.animation_player.play("run")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction == 0.0:
		state_machine.transition_to("Idle")
		return

	player.flip(direction)
	player.velocity.x = direction * PlayerStats.move_speed

	if not player.is_on_floor():
		player.start_coyote_time()
		state_machine.transition_to("Fall")
		return

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
```

- [ ] **Step 3: Create Jump state**

```gdscript
# scripts/player/states/player_jump.gd
extends State


func enter() -> void:
	player.velocity.y = PlayerStats.jump_velocity
	player.animation_player.play("jump")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		player.flip(direction)
	player.velocity.x = direction * PlayerStats.move_speed

	if player.velocity.y > 0.0:
		state_machine.transition_to("Fall")
		return

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump") and player.velocity.y < 0.0:
		player.velocity.y *= 0.5
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
```

- [ ] **Step 4: Create Fall state**

```gdscript
# scripts/player/states/player_fall.gd
extends State


func enter() -> void:
	player.animation_player.play("fall")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		player.flip(direction)
	player.velocity.x = direction * PlayerStats.move_speed

	player.move_and_slide()

	if player.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0.0:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.can_coyote_jump:
		state_machine.transition_to("Jump")
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
```

- [ ] **Step 5: Create LightAttack state**

```gdscript
# scripts/player/states/player_light_attack.gd
extends State


func enter() -> void:
	player.velocity.x = 0.0
	player.hitbox.activate(PlayerStats.get_light_damage())
	player.animation_player.play("light_attack")
	player.animation_player.speed_scale = PlayerStats.attack_speed
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	player.start_attack_cooldown()


func exit() -> void:
	player.hitbox.deactivate()
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Fall")
```

- [ ] **Step 6: Create HeavyAttack state**

```gdscript
# scripts/player/states/player_heavy_attack.gd
extends State


func enter() -> void:
	player.velocity.x = 0.0
	player.hitbox.activate(PlayerStats.get_heavy_damage())
	player.animation_player.play("heavy_attack")
	player.animation_player.speed_scale = PlayerStats.attack_speed * 0.7
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	player.start_attack_cooldown()


func exit() -> void:
	player.hitbox.deactivate()
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Fall")
```

- [ ] **Step 7: Create Hurt state**

```gdscript
# scripts/player/states/player_hurt.gd
extends State

const KNOCKBACK_FORCE := 200.0


func enter() -> void:
	player.hitbox.deactivate()
	player.animation_player.play("hurt")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

	var knockback_dir := -1.0 if player.facing_right else 1.0
	player.velocity.x = knockback_dir * KNOCKBACK_FORCE
	player.velocity.y = -150.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 400.0 * delta)
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Fall")
```

- [ ] **Step 8: Create Death state**

```gdscript
# scripts/player/states/player_death.gd
extends State


func enter() -> void:
	player.hitbox.deactivate()
	player.hurtbox.set_deferred("monitoring", false)
	player.animation_player.play("death")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	player.velocity = Vector2.ZERO


func _on_animation_finished(_anim_name: StringName) -> void:
	await player.get_tree().create_timer(1.0).timeout
	player.get_tree().reload_current_scene()
```

- [ ] **Step 9: Update player.tscn — add state nodes under StateMachine**

Add these nodes to `scenes/player/player.tscn` under the StateMachine node. Each state node needs its script assigned and the StateMachine's `initial_state` export should point to the Idle node.

State nodes to add under `StateMachine`:
- `Idle` (Node, script: `res://scripts/player/states/player_idle.gd`)
- `Run` (Node, script: `res://scripts/player/states/player_run.gd`)
- `Jump` (Node, script: `res://scripts/player/states/player_jump.gd`)
- `Fall` (Node, script: `res://scripts/player/states/player_fall.gd`)
- `LightAttack` (Node, script: `res://scripts/player/states/player_light_attack.gd`)
- `HeavyAttack` (Node, script: `res://scripts/player/states/player_heavy_attack.gd`)
- `Hurt` (Node, script: `res://scripts/player/states/player_hurt.gd`)
- `Death` (Node, script: `res://scripts/player/states/player_death.gd`)

The StateMachine needs each state's `player` variable set. Update `state_machine.gd` `_ready()` to auto-assign:

```gdscript
# Add to state_machine.gd _ready(), before entering initial state:
func _ready() -> void:
	var character := get_parent()
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = character
	if initial_state:
		current_state = initial_state
		current_state.enter()
```

- [ ] **Step 10: Commit**

```bash
git add scripts/player/states/ scripts/state_machine/state_machine.gd
git commit -m "feat: all player states — idle, run, jump, fall, attacks, hurt, death"
```

---

## Task 6: Enemy Base & Slime

**Files:**
- Create: `scripts/enemies/enemy_base.gd`
- Create: `scripts/enemies/slime/slime.gd`
- Create: `scripts/enemies/slime/slime_patrol.gd`
- Create: `scripts/enemies/slime/slime_chase.gd`
- Create: `scripts/enemies/slime/slime_hurt.gd`
- Create: `scripts/enemies/slime/slime_death.gd`
- Create: `scenes/enemies/slime.tscn`

- [ ] **Step 1: Create EnemyBase script**

```gdscript
# scripts/enemies/enemy_base.gd
class_name EnemyBase
extends CharacterBody2D

@export var coin_drop_value: int = 1
@export var coin_drop_count: int = 3

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox

var facing_right: bool = true


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit_received)
	health_component.died.connect(_on_died)


func flip(direction: float) -> void:
	if direction > 0 and not facing_right:
		facing_right = true
		sprite.flip_h = false
	elif direction < 0 and facing_right:
		facing_right = false
		sprite.flip_h = true


func _on_hit_received(damage: float) -> void:
	health_component.take_damage(damage)
	if health_component.current_health > 0.0:
		state_machine.transition_to("Hurt")


func _on_died() -> void:
	state_machine.transition_to("Death")
```

- [ ] **Step 2: Create Slime script**

```gdscript
# scripts/enemies/slime/slime.gd
extends EnemyBase

@export var move_speed: float = 60.0
@export var chase_speed: float = 100.0
@export var contact_damage: float = 10.0

@onready var detection_zone: Area2D = $DetectionZone
@onready var hitbox: Hitbox = $Hitbox
@onready var patrol_left: Marker2D = $PatrolPath/Left
@onready var patrol_right: Marker2D = $PatrolPath/Right

var target: Node2D = null


func _ready() -> void:
	super._ready()
	hitbox.damage = contact_damage
	hitbox.is_active = true
	detection_zone.body_entered.connect(_on_detection_body_entered)
	detection_zone.body_exited.connect(_on_detection_body_exited)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
```

- [ ] **Step 3: Create Slime patrol state**

```gdscript
# scripts/enemies/slime/slime_patrol.gd
extends State

var direction: float = 1.0


func enter() -> void:
	player.animation_player.play("walk")
	direction = 1.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var slime := player as EnemyBase
	var left_x: float = slime.get_node("PatrolPath/Left").global_position.x
	var right_x: float = slime.get_node("PatrolPath/Right").global_position.x

	if slime.global_position.x <= left_x:
		direction = 1.0
	elif slime.global_position.x >= right_x:
		direction = -1.0

	slime.flip(direction)
	slime.velocity.x = direction * slime.move_speed
	slime.move_and_slide()

	if slime.target != null:
		state_machine.transition_to("Chase")
```

- [ ] **Step 4: Create Slime chase state**

```gdscript
# scripts/enemies/slime/slime_chase.gd
extends State


func enter() -> void:
	player.animation_player.play("walk")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var slime := player as EnemyBase
	if slime.target == null:
		state_machine.transition_to("Patrol")
		return

	var direction := sign(slime.target.global_position.x - slime.global_position.x)
	slime.flip(direction)
	slime.velocity.x = direction * slime.chase_speed
	slime.move_and_slide()
```

- [ ] **Step 5: Create Slime hurt state**

```gdscript
# scripts/enemies/slime/slime_hurt.gd
extends State

const KNOCKBACK_FORCE := 100.0


func enter() -> void:
	player.animation_player.play("hurt")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

	var slime := player as EnemyBase
	var knockback_dir := -1.0 if slime.facing_right else 1.0
	slime.velocity.x = knockback_dir * KNOCKBACK_FORCE
	slime.velocity.y = -100.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 300.0 * delta)
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	state_machine.transition_to("Patrol")
```

- [ ] **Step 6: Create Slime death state**

```gdscript
# scripts/enemies/slime/slime_death.gd
extends State


func enter() -> void:
	var slime := player as EnemyBase
	slime.hitbox.deactivate()
	slime.hurtbox.set_deferred("monitoring", false)
	slime.animation_player.play("death")
	slime.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	slime.velocity = Vector2.ZERO

	EventBus.enemy_died.emit(slime.global_position, slime.coin_drop_value * slime.coin_drop_count)


func _on_animation_finished(_anim_name: StringName) -> void:
	player.queue_free()
```

- [ ] **Step 7: Create Slime scene**

```tscn
; scenes/enemies/slime.tscn
[gd_scene load_steps=9 format=3 uid="uid://slime"]

[ext_resource type="Script" path="res://scripts/enemies/slime/slime.gd" id="1"]
[ext_resource type="Script" path="res://scripts/state_machine/state_machine.gd" id="2"]
[ext_resource type="Script" path="res://scripts/components/health_component.gd" id="3"]
[ext_resource type="Script" path="res://scripts/components/hurtbox.gd" id="4"]
[ext_resource type="Script" path="res://scripts/components/hitbox.gd" id="5"]
[ext_resource type="Script" path="res://scripts/enemies/slime/slime_patrol.gd" id="6"]
[ext_resource type="Script" path="res://scripts/enemies/slime/slime_chase.gd" id="7"]
[ext_resource type="Script" path="res://scripts/enemies/slime/slime_hurt.gd" id="8"]
[ext_resource type="Script" path="res://scripts/enemies/slime/slime_death.gd" id="9"]

[node name="Slime" type="CharacterBody2D"]
collision_layer = 4
collision_mask = 1
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]

[node name="StateMachine" type="Node" parent="."]
script = ExtResource("2")

[node name="Patrol" type="Node" parent="StateMachine"]
script = ExtResource("6")

[node name="Chase" type="Node" parent="StateMachine"]
script = ExtResource("7")

[node name="Hurt" type="Node" parent="StateMachine"]
script = ExtResource("8")

[node name="Death" type="Node" parent="StateMachine"]
script = ExtResource("9")

[node name="HealthComponent" type="Node" parent="."]
script = ExtResource("3")
max_health = 30.0

[node name="Hurtbox" type="Area2D" parent="."]
collision_layer = 0
collision_mask = 16
script = ExtResource("4")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hurtbox"]

[node name="Hitbox" type="Area2D" parent="."]
collision_layer = 32
collision_mask = 0
script = ExtResource("5")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hitbox"]

[node name="DetectionZone" type="Area2D" parent="."]
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="DetectionZone"]

[node name="PatrolPath" type="Node2D" parent="."]

[node name="Left" type="Marker2D" parent="PatrolPath"]
position = Vector2(-100, 0)

[node name="Right" type="Marker2D" parent="PatrolPath"]
position = Vector2(100, 0)
```

Collision layers: Slime body on layer 3 (Enemies), Hurtbox mask = layer 5 (PlayerHitbox), Hitbox layer = 5 (EnemyHitbox), DetectionZone mask = layer 2 (Player).

- [ ] **Step 8: Commit**

```bash
git add scripts/enemies/ scenes/enemies/slime.tscn
git commit -m "feat: slime enemy with patrol, chase, hurt, death states"
```

---

## Task 7: Skeleton Enemy & Projectile

**Files:**
- Create: `scripts/enemies/skeleton/skeleton.gd`
- Create: `scripts/enemies/skeleton/skeleton_patrol.gd`
- Create: `scripts/enemies/skeleton/skeleton_attack.gd`
- Create: `scripts/enemies/skeleton/skeleton_hurt.gd`
- Create: `scripts/enemies/skeleton/skeleton_death.gd`
- Create: `scripts/enemies/bone_projectile.gd`
- Create: `scenes/enemies/skeleton.tscn`
- Create: `scenes/enemies/bone_projectile.tscn`

- [ ] **Step 1: Create BoneProjectile script**

```gdscript
# scripts/enemies/bone_projectile.gd
class_name BoneProjectile
extends Area2D

@export var speed: float = 250.0
@export var damage: float = 15.0

var direction: Vector2 = Vector2.RIGHT

@onready var lifetime_timer: Timer = $LifetimeTimer


func _ready() -> void:
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start()
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var hurtbox := body.get_node_or_null("Hurtbox") as Hurtbox
		if hurtbox:
			hurtbox.hit_received.emit(damage)
	queue_free()
```

- [ ] **Step 2: Create BoneProjectile scene**

```tscn
; scenes/enemies/bone_projectile.tscn
[gd_scene load_steps=2 format=3 uid="uid://bone_proj"]

[ext_resource type="Script" path="res://scripts/enemies/bone_projectile.gd" id="1"]

[node name="BoneProjectile" type="Area2D"]
collision_layer = 32
collision_mask = 2
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]

[node name="LifetimeTimer" type="Timer" parent="."]
wait_time = 3.0
one_shot = true
```

- [ ] **Step 3: Create Skeleton script**

```gdscript
# scripts/enemies/skeleton/skeleton.gd
extends EnemyBase

@export var move_speed: float = 40.0
@export var attack_range: float = 200.0
@export var projectile_scene: PackedScene

@onready var detection_zone: Area2D = $DetectionZone
@onready var projectile_spawn: Marker2D = $ProjectileSpawn
@onready var attack_cooldown: Timer = $AttackCooldown

var target: Node2D = null
var can_attack: bool = true


func _ready() -> void:
	super._ready()
	detection_zone.body_entered.connect(_on_detection_body_entered)
	detection_zone.body_exited.connect(_on_detection_body_exited)
	attack_cooldown.timeout.connect(func(): can_attack = true)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null


func shoot() -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as BoneProjectile
	projectile.global_position = projectile_spawn.global_position
	var dir := sign(target.global_position.x - global_position.x)
	projectile.direction = Vector2(dir, 0)
	get_tree().current_scene.add_child(projectile)
	can_attack = false
	attack_cooldown.start()
```

- [ ] **Step 4: Create Skeleton patrol state**

```gdscript
# scripts/enemies/skeleton/skeleton_patrol.gd
extends State

var direction: float = 1.0
var left_bound: float
var right_bound: float


func enter() -> void:
	player.animation_player.play("walk")
	left_bound = player.global_position.x - 80.0
	right_bound = player.global_position.x + 80.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var skeleton: EnemyBase = player

	if skeleton.global_position.x <= left_bound:
		direction = 1.0
	elif skeleton.global_position.x >= right_bound:
		direction = -1.0

	skeleton.flip(direction)
	skeleton.velocity.x = direction * skeleton.move_speed
	skeleton.move_and_slide()

	if skeleton.target != null:
		var dist := abs(skeleton.target.global_position.x - skeleton.global_position.x)
		if dist <= skeleton.attack_range and skeleton.can_attack:
			state_machine.transition_to("Attack")
```

- [ ] **Step 5: Create Skeleton attack state**

```gdscript
# scripts/enemies/skeleton/skeleton_attack.gd
extends State


func enter() -> void:
	var skeleton: EnemyBase = player
	skeleton.velocity.x = 0.0

	if skeleton.target:
		var dir := sign(skeleton.target.global_position.x - skeleton.global_position.x)
		skeleton.flip(dir)

	skeleton.animation_player.play("attack")
	skeleton.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	player.shoot()
	state_machine.transition_to("Patrol")
```

- [ ] **Step 6: Create Skeleton hurt state**

```gdscript
# scripts/enemies/skeleton/skeleton_hurt.gd
extends State

const KNOCKBACK_FORCE := 80.0


func enter() -> void:
	player.animation_player.play("hurt")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

	var skeleton: EnemyBase = player
	var knockback_dir := -1.0 if skeleton.facing_right else 1.0
	skeleton.velocity.x = knockback_dir * KNOCKBACK_FORCE
	skeleton.velocity.y = -80.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 200.0 * delta)
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	state_machine.transition_to("Patrol")
```

- [ ] **Step 7: Create Skeleton death state**

```gdscript
# scripts/enemies/skeleton/skeleton_death.gd
extends State


func enter() -> void:
	var skeleton: EnemyBase = player
	skeleton.hurtbox.set_deferred("monitoring", false)
	skeleton.animation_player.play("death")
	skeleton.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	skeleton.velocity = Vector2.ZERO

	EventBus.enemy_died.emit(skeleton.global_position, skeleton.coin_drop_value * skeleton.coin_drop_count)


func _on_animation_finished(_anim_name: StringName) -> void:
	player.queue_free()
```

- [ ] **Step 8: Create Skeleton scene**

Build `scenes/enemies/skeleton.tscn` with same structure as slime:
- Root: `Skeleton` (CharacterBody2D, layer 4/Enemies, script: skeleton.gd)
- Children: Sprite2D, AnimationPlayer, CollisionShape2D
- StateMachine with: Patrol, Attack, Hurt, Death state nodes
- HealthComponent (max_health = 50.0)
- Hurtbox (mask = layer 5/PlayerHitbox)
- DetectionZone (mask = layer 2/Player, large radius ~250px)
- ProjectileSpawn (Marker2D, offset to side)
- AttackCooldown (Timer, wait_time = 2.0, one_shot = true)
- Set `projectile_scene` export to `res://scenes/enemies/bone_projectile.tscn` in editor

- [ ] **Step 9: Commit**

```bash
git add scripts/enemies/skeleton/ scripts/enemies/bone_projectile.gd scenes/enemies/
git commit -m "feat: skeleton enemy with ranged attack and bone projectile"
```

---

## Task 8: Coin Collectible

**Files:**
- Create: `scripts/collectibles/coin.gd`
- Create: `scenes/collectibles/coin.tscn`

- [ ] **Step 1: Create Coin script**

```gdscript
# scripts/collectibles/coin.gd
class_name Coin
extends Area2D

@export var value: int = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_player.play("spin")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		PlayerStats.add_coins(value)
		EventBus.coin_collected.emit(value)
		audio.play()
		set_deferred("monitoring", false)
		hide()
		await audio.finished
		queue_free()
```

- [ ] **Step 2: Create Coin scene**

```tscn
; scenes/collectibles/coin.tscn
[gd_scene load_steps=2 format=3 uid="uid://coin"]

[ext_resource type="Script" path="res://scripts/collectibles/coin.gd" id="1"]

[node name="Coin" type="Area2D"]
collision_layer = 64
collision_mask = 2
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[node name="AudioStreamPlayer2D" type="AudioStreamPlayer2D" parent="."]
```

Collision: layer 7 (Collectibles = 64), mask = layer 2 (Player).

- [ ] **Step 3: Spawn coins on enemy death — update test_level or a coin spawner**

Add a coin spawning function. The simplest approach: connect `EventBus.enemy_died` in the level script.

```gdscript
# Add to whichever script manages the level, or create scripts/levels/level_base.gd
extends Node2D

@export var coin_scene: PackedScene


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(pos: Vector2, total_value: int) -> void:
	for i in total_value:
		var coin := coin_scene.instantiate() as Coin
		coin.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-30, -10))
		call_deferred("add_child", coin)
```

- [ ] **Step 4: Commit**

```bash
git add scripts/collectibles/ scenes/collectibles/ scripts/levels/
git commit -m "feat: coin collectible with pickup and enemy death spawning"
```

---

## Task 9: HUD

**Files:**
- Create: `scripts/ui/hud.gd`
- Create: `scenes/ui/hud.tscn`

- [ ] **Step 1: Create HUD script**

```gdscript
# scripts/ui/hud.gd
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HBoxContainer/HealthBar
@onready var health_label: Label = $MarginContainer/HBoxContainer/HealthBar/Label
@onready var coin_label: Label = $MarginContainer/HBoxContainer/CoinLabel


func _ready() -> void:
	PlayerStats.health_changed.connect(_on_health_changed)
	PlayerStats.coins_changed.connect(_on_coins_changed)
	_on_health_changed(PlayerStats.current_health, PlayerStats.max_health)
	_on_coins_changed(PlayerStats.coins)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [current, maximum]


func _on_coins_changed(total: int) -> void:
	coin_label.text = "Coins: %d" % total
```

- [ ] **Step 2: Create HUD scene**

```tscn
; scenes/ui/hud.tscn
[gd_scene load_steps=2 format=3 uid="uid://hud"]

[ext_resource type="Script" path="res://scripts/ui/hud.gd" id="1"]

[node name="HUD" type="CanvasLayer"]
script = ExtResource("1")

[node name="MarginContainer" type="MarginContainer" parent="."]
anchors_preset = 10
anchor_right = 1.0
offset_bottom = 50.0
grow_horizontal = 2
theme_override_constants/margin_left = 10
theme_override_constants/margin_top = 10
theme_override_constants/margin_right = 10

[node name="HBoxContainer" type="HBoxContainer" parent="MarginContainer"]
layout_mode = 2
theme_override_constants/separation = 20

[node name="HealthBar" type="ProgressBar" parent="MarginContainer/HBoxContainer"]
custom_minimum_size = Vector2(200, 30)
layout_mode = 2
max_value = 100.0
value = 100.0
show_percentage = false

[node name="Label" type="Label" parent="MarginContainer/HBoxContainer/HealthBar"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
horizontal_alignment = 1
vertical_alignment = 1

[node name="CoinLabel" type="Label" parent="MarginContainer/HBoxContainer"]
layout_mode = 2
text = "Coins: 0"
```

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/hud.gd scenes/ui/hud.tscn
git commit -m "feat: HUD with health bar and coin counter"
```

---

## Task 10: Upgrade Station & Upgrade UI

**Files:**
- Create: `scripts/interactables/upgrade_station.gd`
- Create: `scenes/interactables/upgrade_station.tscn`
- Create: `scripts/ui/upgrade_ui.gd`
- Create: `scenes/ui/upgrade_ui.tscn`

- [ ] **Step 1: Create UpgradeUI script**

```gdscript
# scripts/ui/upgrade_ui.gd
extends CanvasLayer

signal closed

@onready var health_btn: Button = $Panel/VBoxContainer/HealthRow/BuyButton
@onready var health_info: Label = $Panel/VBoxContainer/HealthRow/InfoLabel
@onready var attack_btn: Button = $Panel/VBoxContainer/AttackRow/BuyButton
@onready var attack_info: Label = $Panel/VBoxContainer/AttackRow/InfoLabel
@onready var speed_btn: Button = $Panel/VBoxContainer/SpeedRow/BuyButton
@onready var speed_info: Label = $Panel/VBoxContainer/SpeedRow/InfoLabel
@onready var close_btn: Button = $Panel/VBoxContainer/CloseButton


func _ready() -> void:
	health_btn.pressed.connect(func(): _buy(PlayerStats.health_upgrade))
	attack_btn.pressed.connect(func(): _buy(PlayerStats.attack_upgrade))
	speed_btn.pressed.connect(func(): _buy(PlayerStats.attack_speed_upgrade))
	close_btn.pressed.connect(_close)
	_refresh()


func open() -> void:
	_refresh()
	show()
	get_tree().paused = true


func _close() -> void:
	hide()
	get_tree().paused = false
	closed.emit()


func _buy(upgrade: UpgradeData) -> void:
	if PlayerStats.try_upgrade(upgrade):
		_refresh()


func _refresh() -> void:
	_update_row(health_info, health_btn, PlayerStats.health_upgrade, "+%d HP")
	_update_row(attack_info, attack_btn, PlayerStats.attack_upgrade, "+%d%% ATK")
	_update_row(speed_info, speed_btn, PlayerStats.attack_speed_upgrade, "+%d%% SPD")


func _update_row(info: Label, btn: Button, upgrade: UpgradeData, fmt: String) -> void:
	if not upgrade.can_upgrade():
		info.text = "%s Lv.%d (MAX)" % [upgrade.upgrade_name, upgrade.current_level]
		btn.text = "MAX"
		btn.disabled = true
	else:
		var bonus := int(upgrade.get_current_value() * 100) if upgrade.value_per_level < 1.0 else int(upgrade.get_current_value())
		info.text = "%s Lv.%d (%s)" % [upgrade.upgrade_name, upgrade.current_level, fmt % bonus]
		btn.text = "Buy (%d coins)" % upgrade.get_cost()
		btn.disabled = PlayerStats.coins < upgrade.get_cost()
```

- [ ] **Step 2: Create UpgradeUI scene**

```tscn
; scenes/ui/upgrade_ui.tscn
[gd_scene load_steps=2 format=3 uid="uid://upgrade_ui"]

[ext_resource type="Script" path="res://scripts/ui/upgrade_ui.gd" id="1"]

[node name="UpgradeUI" type="CanvasLayer"]
layer = 10
process_mode = 3
script = ExtResource("1")
visible = false

[node name="Panel" type="PanelContainer" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -200.0
offset_top = -150.0
offset_right = 200.0
offset_bottom = 150.0
grow_horizontal = 2
grow_vertical = 2

[node name="VBoxContainer" type="VBoxContainer" parent="Panel"]
layout_mode = 2
theme_override_constants/separation = 10

[node name="Title" type="Label" parent="Panel/VBoxContainer"]
layout_mode = 2
text = "UPGRADES"
horizontal_alignment = 1

[node name="HealthRow" type="HBoxContainer" parent="Panel/VBoxContainer"]
layout_mode = 2

[node name="InfoLabel" type="Label" parent="Panel/VBoxContainer/HealthRow"]
layout_mode = 2
size_flags_horizontal = 3

[node name="BuyButton" type="Button" parent="Panel/VBoxContainer/HealthRow"]
layout_mode = 2

[node name="AttackRow" type="HBoxContainer" parent="Panel/VBoxContainer"]
layout_mode = 2

[node name="InfoLabel" type="Label" parent="Panel/VBoxContainer/AttackRow"]
layout_mode = 2
size_flags_horizontal = 3

[node name="BuyButton" type="Button" parent="Panel/VBoxContainer/AttackRow"]
layout_mode = 2

[node name="SpeedRow" type="HBoxContainer" parent="Panel/VBoxContainer"]
layout_mode = 2

[node name="InfoLabel" type="Label" parent="Panel/VBoxContainer/SpeedRow"]
layout_mode = 2
size_flags_horizontal = 3

[node name="BuyButton" type="Button" parent="Panel/VBoxContainer/SpeedRow"]
layout_mode = 2

[node name="CloseButton" type="Button" parent="Panel/VBoxContainer"]
layout_mode = 2
text = "Close"
```

- [ ] **Step 3: Create UpgradeStation script**

```gdscript
# scripts/interactables/upgrade_station.gd
extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel
@onready var upgrade_ui: CanvasLayer = $UpgradeUI

var player_nearby: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt_label.hide()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		upgrade_ui.open()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		prompt_label.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		prompt_label.hide()
```

- [ ] **Step 4: Create UpgradeStation scene**

```tscn
; scenes/interactables/upgrade_station.tscn
[gd_scene load_steps=3 format=3 uid="uid://upgrade_station"]

[ext_resource type="Script" path="res://scripts/interactables/upgrade_station.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/ui/upgrade_ui.tscn" id="2"]

[node name="UpgradeStation" type="StaticBody2D"]
collision_layer = 1
collision_mask = 0
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]

[node name="InteractionArea" type="Area2D" parent="."]
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="InteractionArea"]

[node name="PromptLabel" type="Label" parent="."]
offset_top = -50.0
offset_right = 100.0
offset_bottom = -30.0
text = "Press F to upgrade"
horizontal_alignment = 1

[node name="UpgradeUI" parent="." instance=ExtResource("2")]
```

- [ ] **Step 5: Commit**

```bash
git add scripts/interactables/ scenes/interactables/ scripts/ui/upgrade_ui.gd scenes/ui/upgrade_ui.tscn
git commit -m "feat: upgrade station with health, attack, and speed upgrades"
```

---

## Task 11: Test Level

**Files:**
- Create: `scripts/levels/level_base.gd`
- Create: `scenes/levels/test_level.tscn`

- [ ] **Step 1: Create level base script**

```gdscript
# scripts/levels/level_base.gd
extends Node2D

@export var coin_scene: PackedScene


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	PlayerStats.heal_full()


func _on_enemy_died(pos: Vector2, total_value: int) -> void:
	for i in total_value:
		var coin := coin_scene.instantiate() as Coin
		coin.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-30, -10))
		call_deferred("add_child", coin)
```

- [ ] **Step 2: Create test level scene**

Build `scenes/levels/test_level.tscn` in the editor with:

```
TestLevel (Node2D, script: level_base.gd)
├── TileMapLayer              # ground and platforms (layer 1/World)
├── Player (instance player.tscn)
├── Camera2D                  # child of Player or following via RemoteTransform2D
├── HUD (instance hud.tscn)
├── Enemies (Node2D)
│   ├── Slime (instance slime.tscn)
│   └── Skeleton (instance skeleton.tscn)
├── UpgradeStation (instance upgrade_station.tscn)
└── WorldEnvironment           # optional
```

Set `coin_scene` export to `res://scenes/collectibles/coin.tscn`.

In project.godot set the main scene:

```ini
[application]
run/main_scene="res://scenes/levels/test_level.tscn"
```

- [ ] **Step 3: Commit**

```bash
git add scripts/levels/ scenes/levels/ project.godot
git commit -m "feat: test level with player, enemies, and upgrade station"
```

---

## Task 12: Final Integration & Polish

- [ ] **Step 1: Verify collision layers**

| Layer | Name | Used By |
|---|---|---|
| 1 | World | TileMapLayer, StaticBody2D (walls, ground) |
| 2 | Player | Player CharacterBody2D |
| 3 | Enemies | Enemy CharacterBody2D |
| 4 | (unused) | |
| 5 | PlayerHitbox | Player's Hitbox (layer), Enemy Hurtbox (mask) |
| 6 | EnemyHitbox | Enemy Hitbox & Projectile (layer), Player Hurtbox (mask) |
| 7 | Collectibles | Coin (layer), Player (mask on coin) |

- [ ] **Step 2: Test each system manually**

Run the game and verify:
1. Player moves with A/D, jumps with Space
2. Player faces correct direction
3. Light attack (J) deals damage to enemies
4. Heavy attack (K) deals more damage, slower animation
5. Attack cooldown prevents spam
6. Slime patrols and chases player
7. Skeleton shoots bone projectiles
8. Enemies drop coins on death
9. Coins are picked up and HUD updates
10. Upgrade station opens UI with F
11. Buying upgrades deducts coins and increases stats
12. Player takes damage from enemies and knockback works
13. Player death reloads the scene
14. Coyote jump works (jump shortly after leaving ledge)

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: complete 2D platformer — player, enemies, coins, upgrades"
```
