---
name: animation-system
description: Use when implementing animations — AnimationPlayer, AnimationTree, blend trees, state machines, sprite animation, and code-driven animation
---

# Animation System in Godot 4.3+

All examples target Godot 4.3+ with no deprecated APIs. GDScript is shown first, then C#.

> **Related skills:** **state-machine** for gameplay state management, **player-controller** for movement that drives animation, **component-system** for reusable animation components.

---

## 1. Core Concepts

### AnimationPlayer vs AnimationTree

| Node              | Use For                                  | Complexity | Notes                                              |
|-------------------|------------------------------------------|------------|----------------------------------------------------|
| `AnimationPlayer` | Simple playback, one-shot effects        | Low        | Play/stop/queue individual clips directly          |
| `AnimationTree`   | Blending, transitions, layered animation | Medium-High| State machines and blend trees for smooth transitions |

**Rule of thumb:** Start with AnimationPlayer. Add AnimationTree when you need blending between animations (walk/run blend, directional movement, layered upper/lower body).

### Animation Workflow

```
1. Create AnimationPlayer node       → holds all animation clips
2. Add tracks in the Animation panel → keyframe properties, methods, audio
3. (Optional) Add AnimationTree      → blend/transition logic
4. Trigger from code                 → play(), travel(), set parameters
```

---

## 2. AnimationPlayer Basics

### Scene Structure

```
Character (CharacterBody2D)
├── Sprite2D
└── AnimationPlayer
```

### Creating Animations

AnimationPlayer can animate **any property** on any sibling or child node:
- Sprite frames, modulate, position, rotation, scale
- Visibility, collision shape disabled state
- Method calls (Call Method track)
- Audio playback (Audio Playback track)

### GDScript — Basic Playback

```gdscript
extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if input_dir != Vector2.ZERO:
        velocity = input_dir * 200.0
        anim_player.play("walk")
    else:
        velocity = Vector2.ZERO
        anim_player.play("idle")

    move_and_slide()
```

### C# — Basic Playback

```csharp
using Godot;

public partial class Character : CharacterBody2D
{
    private AnimationPlayer _animPlayer;

    public override void _Ready()
    {
        _animPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
    }

    public override void _PhysicsProcess(double delta)
    {
        Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

        if (inputDir != Vector2.Zero)
        {
            Velocity = inputDir * 200.0f;
            _animPlayer.Play("walk");
        }
        else
        {
            Velocity = Vector2.Zero;
            _animPlayer.Play("idle");
        }

        MoveAndSlide();
    }
}
```

> Calling `play()` with the same animation name while it's already playing does nothing (no restart). This is safe to call every frame.

### Playback Control

```gdscript
# Play from the beginning
anim_player.play("attack")

# Play backwards
anim_player.play_backwards("attack")

# Queue an animation to play after the current one finishes
anim_player.queue("idle")

# Stop and reset
anim_player.stop()

# Pause / resume
anim_player.pause()
anim_player.play()  # resumes from paused position

# Set playback speed (2x speed)
anim_player.speed_scale = 2.0

# Seek to a specific time
anim_player.seek(0.5)
```

```csharp
_animPlayer.Play("attack");
_animPlayer.PlayBackwards("attack");
_animPlayer.Queue("idle");
_animPlayer.Stop();
_animPlayer.Pause();
_animPlayer.Play();
_animPlayer.SpeedScale = 2.0;
_animPlayer.Seek(0.5);
```

---

## 3. Animation Signals

AnimationPlayer emits useful signals for game logic synchronization.

### GDScript

```gdscript
func _ready() -> void:
    anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
    match anim_name:
        "attack":
            anim_player.play("idle")
        "death":
            queue_free()
```

### C#

```csharp
public override void _Ready()
{
    _animPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
    _animPlayer.AnimationFinished += OnAnimationFinished;
}

private void OnAnimationFinished(StringName animName)
{
    if (animName == "attack")
        _animPlayer.Play("idle");
    else if (animName == "death")
        QueueFree();
}
```

### Method Call Tracks

Add a **Call Method** track to trigger game logic at exact animation frames (spawn projectile at frame 5, play SFX at impact frame, enable hitbox during swing).

In the Animation panel:
1. Add Track → Call Method Track
2. Select the target node
3. Add keyframes at the desired times
4. Set the method name and arguments

```gdscript
# These methods are called by the AnimationPlayer via Call Method tracks
func spawn_projectile() -> void:
    var bullet := preload("res://scenes/bullet.tscn").instantiate()
    get_parent().add_child(bullet)
    bullet.global_position = $Muzzle.global_position

func enable_hitbox() -> void:
    $HitboxArea/CollisionShape2D.disabled = false

func disable_hitbox() -> void:
    $HitboxArea/CollisionShape2D.disabled = true
```

---

## 4. Sprite Frame Animation

### AnimatedSprite2D

For simple frame-by-frame animation without needing property tracks.

```
Character (CharacterBody2D)
├── AnimatedSprite2D
└── (no AnimationPlayer needed)
```

### GDScript

```gdscript
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if input_dir != Vector2.ZERO:
        velocity = input_dir * 200.0
        sprite.play("walk")
        # Flip sprite based on direction
        if input_dir.x != 0.0:
            sprite.flip_h = input_dir.x < 0.0
    else:
        velocity = Vector2.ZERO
        sprite.play("idle")

    move_and_slide()
```

### C#

```csharp
using Godot;

public partial class Character : CharacterBody2D
{
    private AnimatedSprite2D _sprite;

    public override void _Ready()
    {
        _sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
    }

    public override void _PhysicsProcess(double delta)
    {
        Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

        if (inputDir != Vector2.Zero)
        {
            Velocity = inputDir * 200.0f;
            _sprite.Play("walk");
            if (inputDir.X != 0.0f)
                _sprite.FlipH = inputDir.X < 0.0f;
        }
        else
        {
            Velocity = Vector2.Zero;
            _sprite.Play("idle");
        }

        MoveAndSlide();
    }
}
```

### AnimatedSprite2D vs AnimationPlayer + Sprite2D

| Approach               | Pros                                    | Cons                                          |
|------------------------|-----------------------------------------|-----------------------------------------------|
| `AnimatedSprite2D`     | Quick setup, built-in SpriteFrames editor | Can only animate frames; no property tracks  |
| `AnimationPlayer` + `Sprite2D` | Full property animation, method calls, audio | More setup, need to keyframe region/frame |

**Use AnimatedSprite2D** for simple characters with only frame animations. **Use AnimationPlayer** when you also need to animate hitboxes, particles, sounds, or other properties in sync.

---

## 5. AnimationTree — Blend Trees & State Machines

### Scene Structure

```
Character (CharacterBody2D)
├── Sprite2D
├── AnimationPlayer        ← holds all clips
└── AnimationTree          ← controls blending/transitions
    (tree_root = AnimationNodeStateMachine or AnimationNodeBlendTree)
```

### Setup

1. Add an **AnimationTree** node as a sibling (not child) of AnimationPlayer
2. Set `AnimationTree.anim_player` to point at your AnimationPlayer
3. Set `AnimationTree.active = true`
4. Choose a root node type:
   - **AnimationNodeStateMachine** — for discrete states with transitions (idle, walk, run, jump, attack)
   - **AnimationNodeBlendTree** — for continuous blending (walk/run speed blend, directional movement)

### State Machine Setup

In the AnimationTree editor:
1. Set root to **AnimationNodeStateMachine**
2. Add states (right-click → Add Animation) for each clip
3. Connect states with transitions (drag between nodes)
4. Set transition properties: advance mode (auto/manual), switch time, fade time

### GDScript — State Machine

```gdscript
extends CharacterBody2D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if input_dir != Vector2.ZERO:
        velocity = input_dir * 200.0
        state_machine.travel("walk")
    else:
        velocity = Vector2.ZERO
        state_machine.travel("idle")

    move_and_slide()

func attack() -> void:
    # travel() transitions smoothly; use start() for immediate switch
    state_machine.travel("attack")

func get_current_state() -> StringName:
    return state_machine.get_current_node()
```

### C# — State Machine

```csharp
using Godot;

public partial class Character : CharacterBody2D
{
    private AnimationTree _animTree;
    private AnimationNodeStateMachinePlayback _stateMachine;

    public override void _Ready()
    {
        _animTree = GetNode<AnimationTree>("AnimationTree");
        _stateMachine = _animTree.Get("parameters/playback").As<AnimationNodeStateMachinePlayback>();
    }

    public override void _PhysicsProcess(double delta)
    {
        Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

        if (inputDir != Vector2.Zero)
        {
            Velocity = inputDir * 200.0f;
            _stateMachine.Travel("walk");
        }
        else
        {
            Velocity = Vector2.Zero;
            _stateMachine.Travel("idle");
        }

        MoveAndSlide();
    }

    public void Attack()
    {
        _stateMachine.Travel("attack");
    }
}
```

### Blend Tree — Speed Blending

Blend between walk and run based on a speed parameter.

1. Set root to **AnimationNodeBlendTree**
2. Add a **BlendSpace1D** node
3. Add "walk" at position 0.0 and "run" at position 1.0
4. Connect BlendSpace1D → Output

```gdscript
extends CharacterBody2D

@export var walk_speed: float = 100.0
@export var run_speed: float = 250.0

@onready var anim_tree: AnimationTree = $AnimationTree

func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var is_running := Input.is_action_pressed("sprint")
    var target_speed := run_speed if is_running else walk_speed

    if input_dir != Vector2.ZERO:
        velocity = input_dir * target_speed
        # Blend parameter: 0.0 = walk, 1.0 = run
        var blend_amount := inverse_lerp(walk_speed, run_speed, velocity.length())
        anim_tree["parameters/BlendSpace1D/blend_position"] = blend_amount
    else:
        velocity = Vector2.ZERO

    move_and_slide()
```

```csharp
using Godot;

public partial class BlendTreeCharacter : CharacterBody2D
{
    [Export] public float WalkSpeed { get; set; } = 100.0f;
    [Export] public float RunSpeed { get; set; } = 250.0f;

    private AnimationTree _animTree;

    public override void _Ready()
    {
        _animTree = GetNode<AnimationTree>("AnimationTree");
    }

    public override void _PhysicsProcess(double delta)
    {
        Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
        bool isRunning = Input.IsActionPressed("sprint");
        float targetSpeed = isRunning ? RunSpeed : WalkSpeed;

        if (inputDir != Vector2.Zero)
        {
            Velocity = inputDir * targetSpeed;
            float blendAmount = Mathf.InverseLerp(WalkSpeed, RunSpeed, Velocity.Length());
            _animTree.Set("parameters/BlendSpace1D/blend_position", blendAmount);
        }
        else
        {
            Velocity = Vector2.Zero;
        }

        MoveAndSlide();
    }
}
```

### BlendSpace2D — Directional Movement

For top-down games with 4/8-directional animations.

1. Add a **BlendSpace2D** node in the blend tree
2. Add animations at compass positions: idle_down (0,1), idle_up (0,-1), idle_right (1,0), idle_left (-1,0)
3. Set blend position from input direction

```gdscript
# Set blend position to input direction
var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
anim_tree["parameters/BlendSpace2D/blend_position"] = input_dir
```

```csharp
Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
_animTree.Set("parameters/BlendSpace2D/blend_position", inputDir);
```

---

## 6. Common Animation Recipes

### Hit Flash

Flash the sprite white on damage using a shader or modulate.

#### GDScript

```gdscript
# Simple modulate flash — no shader needed
@onready var _sprite: Sprite2D = $Sprite2D

func flash_hit() -> void:
    var tween := create_tween()
    tween.tween_property(_sprite, "modulate", Color(3.0, 3.0, 3.0, 1.0), 0.05)
    tween.tween_property(_sprite, "modulate", Color.WHITE, 0.1)
```

#### C#

```csharp
private Sprite2D _sprite = null!;

public override void _Ready()
{
    _sprite = GetNode<Sprite2D>("Sprite2D");
}

public void FlashHit()
{
    var tween = CreateTween();
    tween.TweenProperty(_sprite, "modulate", new Color(3f, 3f, 3f, 1f), 0.05);
    tween.TweenProperty(_sprite, "modulate", Colors.White, 0.1);
}
```

### Hit Flash with Shader (GDScript)

For a true white flash that overrides the sprite texture:

```gdscript
# Attach this shader to the Sprite2D material:
# shader_type canvas_item;
# uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
# void fragment() {
#     vec4 tex = texture(TEXTURE, UV);
#     COLOR = mix(tex, vec4(1.0, 1.0, 1.0, tex.a), flash_amount);
# }

func flash_hit() -> void:
    var mat: ShaderMaterial = $Sprite2D.material
    var tween := create_tween()
    tween.tween_property(mat, "shader_parameter/flash_amount", 1.0, 0.05)
    tween.tween_property(mat, "shader_parameter/flash_amount", 0.0, 0.15)
```

### Attack Combo (GDScript)

Chain attacks within a buffer window.

```gdscript
extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _combo_step: int = 0
var _combo_window: bool = false  # Set true via Call Method track near end of each attack

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        if _combo_step == 0:
            _start_combo()
        elif _combo_window:
            _advance_combo()

func _start_combo() -> void:
    _combo_step = 1
    anim_player.play("attack_1")

func _advance_combo() -> void:
    _combo_step += 1
    _combo_window = false
    if _combo_step <= 3:
        anim_player.play("attack_%d" % _combo_step)
    else:
        _reset_combo()

# Called by Call Method track in each attack animation
func open_combo_window() -> void:
    _combo_window = true

func _reset_combo() -> void:
    _combo_step = 0
    _combo_window = false

func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name.begins_with("attack"):
        _reset_combo()
        anim_player.play("idle")
```

### Screen Shake on Impact (GDScript)

```gdscript
# On the Camera2D node
func shake(intensity: float = 5.0, duration: float = 0.2) -> void:
    var tween := create_tween()
    for i in int(duration / 0.03):
        var random_offset := Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(self, "offset", random_offset, 0.03)
    tween.tween_property(self, "offset", Vector2.ZERO, 0.03)
```

---

## 7. Common Pitfalls

| Symptom                            | Cause                                            | Fix                                                                 |
|------------------------------------|--------------------------------------------------|---------------------------------------------------------------------|
| Animation snaps instead of blending | Using `AnimationPlayer.play()` instead of AnimationTree | Switch to AnimationTree with state machine or blend tree           |
| AnimationTree does nothing          | `active` property is `false`                     | Set `anim_tree.active = true` in Inspector or `_ready()`           |
| `travel()` doesn't transition       | No transition path between states                | Add transition arrows in the AnimationTree state machine editor    |
| Animation plays but sprite doesn't change | Track targets wrong node path              | Verify the track's node path matches the actual scene tree         |
| Method call track doesn't fire      | Method name typo or wrong target node            | Check the track's node path and method name match exactly          |
| Blend parameters have no effect     | Wrong parameter path string                      | Use `"parameters/<NodeName>/blend_position"` — check in Inspector  |
| Animation resets to frame 0 every physics frame | Calling `play()` every frame on a non-looping clip | Guard with `if anim_player.current_animation != "name"`       |

---

## 8. Implementation Checklist

- [ ] AnimationPlayer is a direct child of the animated node (not nested deeper)
- [ ] All animation track node paths are valid (no broken references after scene restructuring)
- [ ] AnimationTree `active` is set to `true` and `anim_player` points to the correct AnimationPlayer
- [ ] State machine transitions have appropriate fade times (0.1–0.2s for responsive gameplay)
- [ ] Looping animations (idle, walk, run) have loop mode set to **Loop** in the Animation panel
- [ ] One-shot animations (attack, jump, death) have loop mode set to **None**
- [ ] Call Method tracks are used for gameplay events (hitbox enable/disable, spawn projectiles, play SFX)
- [ ] Blend parameters are set from gameplay code every frame (not just on state change)
- [ ] `animation_finished` signal is connected for one-shot animations that need follow-up logic
