---
name: godot-optimization
description: Use when optimizing Godot games — profiler, draw calls, physics tuning, memory management, and common bottlenecks
---

# Godot Optimization

This skill covers performance optimization for Godot 4.3+ projects in both GDScript and C#. It covers the built-in profiler, draw call reduction, physics tuning, GDScript performance patterns, memory management, object pooling, and a reference table of common bottlenecks.

---

## 1. Using the Profiler

### Frame Time Budget

At 60 fps, the entire frame (update, physics, rendering) must complete in **16.6 ms**. At 30 fps the budget is 33.3 ms. Any single system that consumes the majority of that budget is a bottleneck.

| Target FPS | Frame budget |
|---|---|
| 120 | 8.3 ms |
| 60 | 16.6 ms |
| 30 | 33.3 ms |

### Reading Profiler Output

Open **Debugger > Profiler**, click **Start**, play through the scenario you want to measure, then click **Stop**.

- **Frame Time** — total wall-clock time for that frame in milliseconds.
- **Self** — time spent inside that function *excluding* callees. This is the primary hotspot indicator. A function with a high Self time is doing expensive work directly.
- **Total** — time including all callees. Useful for identifying expensive subtrees.
- **Calls** — call count per frame. A function called thousands of times per frame (even if each call is cheap) can dominate the frame.
- Click any function name to jump to its source in the script editor.

```gdscript
# Manual micro-benchmark for a specific block
var start := Time.get_ticks_usec()
_run_expensive_operation()
var elapsed := Time.get_ticks_usec() - start
print("_run_expensive_operation: %d µs" % elapsed)
```

### Monitors Tab

**Debugger > Monitors** shows real-time engine metrics while the game is running. Click a monitor name to open a live graph. Key monitors to watch:

| Monitor | What to watch for |
|---|---|
| `Time > FPS` | Below target — frame budget overrun |
| `Time > Process` | High — `_process()` callbacks are expensive |
| `Time > Physics Process` | High — `_physics_process()` or physics sim is expensive |
| `Render > Total Draw Calls` | Above ~500 (mobile) or ~2 000 (desktop) — needs batching |
| `Render > Video RAM` | Steadily growing — unfreed textures or meshes (memory leak) |
| `Object > Object Count` | Growing across scene reloads — nodes are not being freed |
| `Physics 3D > Active Bodies` | Large count in simple scenes — bodies not sleeping |

```gdscript
# Query any monitor at runtime from code
var fps := Performance.get_monitor(Performance.TIME_FPS)
var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
var video_ram := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
print("FPS: %d | Draw calls: %d | VRAM: %.1f MB" % [fps, draw_calls, video_ram / 1_048_576.0])
```

---

## 2. Draw Call Optimization

Every distinct mesh, sprite, or canvas item that cannot be batched with its neighbours costs one draw call. Reducing draw calls is one of the highest-leverage optimisations, especially on mobile.

### 2D Batching with CanvasGroup

Wrap sibling nodes inside a `CanvasGroup` so Godot batches them into a single draw call. This is most effective for HUD elements, tile layers, and groups of sprites that share the same texture.

```gdscript
# In the scene tree, add a CanvasGroup parent node.
# CanvasGroup batches all children into one draw call automatically.
# No code is required — the node type itself enables batching.
# Ensure children share the same texture and blend mode for maximum benefit.
```

Constraints for batching to occur:
- Children must share the same texture (use a texture atlas).
- Children must use the same blend mode and shader (or none).
- No `CanvasItem.clip_children` or light occluder between them.

### Reducing Unique Materials

Each unique material combination breaks a batch. Keep the material count low:

```gdscript
# WRONG — creating a new material per instance duplicates draw calls
func _ready() -> void:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(randf(), randf(), randf())
    $MeshInstance3D.material_override = mat  # unique material = unique draw call

# RIGHT — vary colour via a shader parameter on a shared material
@export var shared_material: ShaderMaterial

func _ready() -> void:
    # All instances share the same material; vary only the instance parameter
    var mat := shared_material.duplicate()  # only duplicate when variance is truly needed
    mat.set_shader_parameter("tint", Color(randf(), randf(), randf()))
    $MeshInstance3D.material_override = mat
```

For 3D scenes, enable **Rendering > Mesh LOD** and use `GeometryInstance3D.gi_mode = BAKE_STATIC` where possible to let the engine merge static geometry.

### Texture Atlases

Pack multiple sprites into a single atlas texture so all sprites sharing that atlas batch into one draw call.

- In the editor: **Import > Sprite Frames** supports atlas import.
- For tilemaps, use a single TileSet with one atlas texture per tile layer.
- For UI, pack icons into a single `AtlasTexture` or use `StyleBoxTexture` regions.

### Visibility Culling

Stop processing and rendering objects that are off-screen.

```gdscript
# 2D — VisibleOnScreenNotifier2D pauses processing when the node leaves the viewport
extends Sprite2D

@onready var _vis: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
    _vis.screen_entered.connect(_on_screen_entered)
    _vis.screen_exited.connect(_on_screen_exited)
    set_process(false)  # start paused; enable only when visible

func _on_screen_entered() -> void:
    set_process(true)

func _on_screen_exited() -> void:
    set_process(false)
```

```gdscript
# 3D — VisibleOnScreenNotifier3D works identically
extends Node3D

@onready var _vis: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

func _ready() -> void:
    _vis.screen_entered.connect(func(): set_process(true))
    _vis.screen_exited.connect(func(): set_process(false))
    set_process(false)
```

You can also query visibility directly:

```gdscript
# Only update expensive logic when the node is visible on screen
func _process(_delta: float) -> void:
    if not $VisibleOnScreenNotifier2D.is_on_screen():
        return
    _run_expensive_animation_logic()
```

### LOD for 3D

Use `VisibleOnScreenNotifier3D` distance thresholds or Godot's built-in LOD system to swap high-poly meshes for low-poly equivalents at range.

```gdscript
# Manually swap mesh at distance
@export var lod_distance: float = 50.0
@onready var _camera := get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
    var dist := global_position.distance_to(_camera.global_position)
    $HighPolyMesh.visible = dist < lod_distance
    $LowPolyMesh.visible = dist >= lod_distance
```

For automatic LOD: set `GeometryInstance3D.lod_bias` and enable **Rendering > Mesh LOD** in Project Settings. Godot 4 generates LOD levels automatically during import if **Import > Generate LODs** is enabled on the mesh asset.

---

## 3. Physics Optimization

### Collision Layers and Masks

Every physics body checks for collisions against bodies whose layer is included in its mask. Unnecessary mask bits cause wasted broadphase work.

```gdscript
# Project Settings > Layer Names > 3D Physics defines readable names.
# Assign layers so bodies only collide with what they need to.

# Example layer assignments (set in Inspector or via code):
# Layer 1 — Player
# Layer 2 — Enemies
# Layer 3 — Environment
# Layer 4 — Projectiles
# Layer 5 — Triggers / Sensors

# Player: layer = 1, mask = 2 | 3          (collides with enemies and environment)
# Enemy:  layer = 2, mask = 1 | 3          (collides with player and environment)
# Bullet: layer = 4, mask = 2 | 3          (hits enemies and environment only)
# Sensor: layer = 5, mask = 1              (detects player only)

func _ready() -> void:
    # Set via code (bit index is layer number minus 1)
    collision_layer = 1 << 3   # this body is on layer 4 (Projectiles)
    collision_mask  = (1 << 1) | (1 << 2)  # checks layers 2 and 3
```

### Simplified Collision Shapes

Mesh colliders (`ConcavePolygonShape3D`) are extremely expensive. Replace with primitives wherever possible.

| Shape | Cost | Use for |
|---|---|---|
| `SphereShape3D` | Cheapest | Projectiles, pickups, rolling objects |
| `CapsuleShape3D` | Cheap | Characters, pillars |
| `BoxShape3D` | Cheap | Walls, crates, platforms |
| `ConvexPolygonShape3D` | Moderate | Irregular convex geometry |
| `ConcavePolygonShape3D` | Expensive | Static-only complex terrain (never on moving bodies) |

```gdscript
# WRONG — mesh collider on a moving character body
# CollisionShape3D with ConcavePolygonShape3D on CharacterBody3D

# RIGHT — capsule approximates the character with minimal cost
# CollisionShape3D with CapsuleShape3D

# For static terrain that must be exact: ConcavePolygonShape3D is acceptable
# on StaticBody3D only, and only if the mesh is not overly dense.
```

### Physics Tick Rate Tuning

The default physics tick is 60 Hz (`Engine.physics_ticks_per_second`). Lowering it reduces CPU load at the cost of simulation fidelity.

```gdscript
# Lower the physics tick rate at runtime (e.g. for a top-down game that
# does not need 60 Hz physics accuracy)
func _ready() -> void:
    Engine.physics_ticks_per_second = 30

# Use max_physics_steps_per_frame to prevent the spiral-of-death
# (physics trying to catch up when the frame takes too long)
Engine.max_physics_steps_per_frame = 4
```

Change project-wide defaults in **Project Settings > Physics > Common > Physics Ticks Per Second** and **Max Physics Steps Per Frame**.

### Area2D for Detection vs Raycasts

For detecting whether something enters a region, `Area2D`/`Area3D` is cheaper than running a raycast or shape query every frame because the engine maintains the overlap state incrementally.

```gdscript
# PREFER Area2D for "is the player in range?" checks
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _begin_aggro(body)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _end_aggro()
```

```gdscript
# Use raycasts only when you need directionality or line-of-sight checks,
# and cache the RayCast2D/3D node — do NOT create PhysicsRayQueryParameters
# every frame unless necessary.
@onready var _ray: RayCast3D = $RayCast3D

func _physics_process(_delta: float) -> void:
    if _ray.is_colliding():
        _handle_hit(_ray.get_collider())
```

---

## 4. GDScript Performance

### Avoid Allocations in _process

Allocating new objects (Arrays, Dictionaries, Vector2/3 via constructor, Strings) inside `_process` or `_physics_process` triggers the garbage collector more frequently and creates per-frame heap pressure.

```gdscript
# WRONG — allocates a new Array every frame
func _process(_delta: float) -> void:
    var nearby := get_tree().get_nodes_in_group("enemies")  # new Array each call
    for enemy in nearby:
        _check_aggro(enemy)

# RIGHT — cache the group query result, or use an Area2D overlap list
var _enemies: Array[Node] = []

func _ready() -> void:
    _enemies = get_tree().get_nodes_in_group("enemies")
    get_tree().node_added.connect(_on_node_added)
    get_tree().node_removed.connect(_on_node_removed)

func _on_node_added(node: Node) -> void:
    if node.is_in_group("enemies"):
        _enemies.append(node)

func _on_node_removed(node: Node) -> void:
    _enemies.erase(node)

func _process(_delta: float) -> void:
    for enemy in _enemies:  # no allocation
        _check_aggro(enemy)
```

```gdscript
# WRONG — constructing temporary vectors in a tight loop
func _process(_delta: float) -> void:
    for i in range(100):
        var offset := Vector2(i * 10.0, 0.0)  # 100 allocations per frame
        _draw_marker(position + offset)

# RIGHT — reuse a variable declared outside the loop
var _offset := Vector2.ZERO

func _process(_delta: float) -> void:
    for i in range(100):
        _offset.x = i * 10.0
        _offset.y = 0.0
        _draw_marker(position + _offset)
```

### Use StringName for Comparisons

`StringName` uses interned hashing; comparing two `StringName` values is an O(1) integer comparison. Comparing `String` values is O(n) and allocates temporaries.

```gdscript
# WRONG — String comparison in a hot path
func _on_body_entered(body: Node) -> void:
    if body.name == "Player":  # String comparison
        _start_aggro()

# RIGHT — StringName literal (&"...") is interned at compile time
func _on_body_entered(body: Node) -> void:
    if body.name == &"Player":  # O(1) hash comparison
        _start_aggro()
```

```gdscript
# Cache StringName constants at the class level for repeated use
const ACTION_JUMP := &"jump"
const ACTION_FIRE := &"fire"
const GROUP_ENEMIES := &"enemies"

func _process(_delta: float) -> void:
    if Input.is_action_pressed(ACTION_JUMP):
        _jump()
    if Input.is_action_just_pressed(ACTION_FIRE):
        _fire()
```

### Typed Arrays

Typed arrays (`Array[Node]`, `Array[int]`) skip per-element type checks and allow the VM to use more efficient access paths.

```gdscript
# Untyped — element type checked at every access
var bullets = []

# Typed — no per-element type check; also self-documents intent
var bullets: Array[Bullet] = []

# PackedArrays are the most efficient for value types — stored as contiguous memory
var positions: PackedVector2Array = PackedVector2Array()
var velocities: PackedFloat32Array = PackedFloat32Array()
```

### Static Typing Benefits

Static typing enables the GDScript VM to emit more efficient bytecode and catches errors at parse time rather than runtime.

```gdscript
# Untyped — every operation goes through dynamic dispatch
func move(delta):
    velocity = direction * speed
    position += velocity * delta

# Typed — the compiler knows the exact types, generates faster bytecode
func move(delta: float) -> void:
    velocity = direction * speed
    position += velocity * delta
```

Type inference with `:=` is equivalent to explicit types — use whichever is more readable.

### preload vs load

`preload` resolves the resource path at **parse time** and embeds it into the script binary. `load` resolves at **runtime** and may trigger a disk read (or cache lookup).

```gdscript
# preload — resolved at compile time; safe to use at class scope
const BulletScene: PackedScene = preload("res://scenes/bullet.tscn")
const HitSound: AudioStream = preload("res://audio/hit.ogg")

# load — resolved at runtime; use for dynamic paths or optional resources
func _load_skin(skin_name: String) -> Texture2D:
    return load("res://skins/%s.png" % skin_name)

# WRONG — load() inside _process reads from disk (or cache) every frame
func _process(_delta: float) -> void:
    var tex = load("res://icon.svg")  # repeated runtime resolution
    $Sprite2D.texture = tex

# RIGHT — preload at class scope, assign once in _ready()
const IconTexture: Texture2D = preload("res://icon.svg")

func _ready() -> void:
    $Sprite2D.texture = IconTexture
```

---

## 5. Memory Management

### Monitoring Memory at Runtime

```gdscript
# Query engine memory monitors via Performance singleton
func _print_memory_stats() -> void:
    var static_mem  := Performance.get_monitor(Performance.MEMORY_STATIC)
    var dynamic_mem := Performance.get_monitor(Performance.MEMORY_DYNAMIC)
    var video_ram   := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
    var obj_count   := Performance.get_monitor(Performance.OBJECT_COUNT)
    var node_count  := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)

    print("Static RAM : %.2f MB" % (static_mem   / 1_048_576.0))
    print("Dynamic RAM: %.2f MB" % (dynamic_mem  / 1_048_576.0))
    print("Video RAM  : %.2f MB" % (video_ram    / 1_048_576.0))
    print("Objects    : %d" % obj_count)
    print("Nodes      : %d" % node_count)
```

Watch for `MEMORY_STATIC` growing between identical scene loads — this usually means a resource is held by a long-lived reference.

### ResourceLoader Caching Behaviour

Godot caches every resource loaded via `load()` or `preload()` by path. Subsequent loads of the same path return the **same instance** from cache. This means:

- Resources are shared by default — modifying one instance modifies all users.
- Use `resource.duplicate()` when you need a per-instance copy (e.g. per-enemy stats).
- Resources are not freed until all references are released **and** the cache entry is cleared.

```gdscript
# Shared resource — all enemies use the same stats object (intended for read-only data)
const EnemyStats: Resource = preload("res://data/enemy_stats.tres")

# Per-instance copy — each enemy gets its own mutable copy
func _ready() -> void:
    _stats = EnemyStats.duplicate()
    _stats.health = _stats.max_health  # safe to modify
```

To force a resource out of the cache:

```gdscript
# Remove from ResourceLoader cache — the resource will be freed once
# all script references to it are also released.
ResourceLoader.load_threaded_request("res://large_texture.png")  # if using async
# For synchronous cache eviction there is no direct API; drop all references
# and call OS.gc() or wait for the next GC pass.
```

For large resources that are only needed temporarily (e.g. a loading-screen video), keep them in a local variable and let it go out of scope — Godot's reference counting will free it.

### Freeing Unused Resources

```gdscript
# Nodes: always use queue_free() unless you need synchronous teardown
func _on_enemy_died() -> void:
    queue_free()  # safe — deferred until end of current frame processing

# Nodes: free() is synchronous and immediate — only use when you are certain
# no other code will access the node in the same frame
func _force_remove_node(node: Node) -> void:
    node.free()  # dangerous if called from a signal emitted by `node` itself

# Non-node RefCounted resources are freed automatically when the last
# reference is released — no manual call needed.
var texture: ImageTexture = ImageTexture.new()
# texture is freed when it goes out of scope or is set to null

# Non-node Object (not RefCounted) — must be freed manually
var raw_obj := Object.new()
raw_obj.free()
```

### queue_free vs free

| Method | Timing | Safe inside callbacks | Use when |
|---|---|---|---|
| `queue_free()` | End of current frame | Yes | Normal node removal |
| `free()` | Immediate | Only if not inside own signal | Synchronous teardown, editor tools |

Always prefer `queue_free()` for nodes created during gameplay. `free()` inside a signal handler emitted by the same node is undefined behaviour and will crash.

---

## 6. Object Pooling

Calling `instantiate()` and `queue_free()` repeatedly for short-lived objects (bullets, hit effects, particles) is expensive because each cycle allocates and deallocates memory and re-runs `_ready()`. A pool pre-allocates a fixed set of instances and recycles them.

### GDScript Pool

```gdscript
# object_pool.gd
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var initial_size: int = 20
@export var grow_size: int = 10

var _pool: Array[Node] = []

func _ready() -> void:
    _grow(initial_size)

## Return an available instance from the pool, growing the pool if needed.
func get_instance() -> Node:
    for instance in _pool:
        if not instance.is_inside_tree() or not instance.visible:
            _activate(instance)
            return instance
    # Pool exhausted — grow and return one new instance
    push_warning("ObjectPool: pool exhausted, growing by %d" % grow_size)
    _grow(grow_size)
    return get_instance()

## Return an instance to the pool by deactivating it.
func release(instance: Node) -> void:
    instance.visible = false
    instance.set_process(false)
    instance.set_physics_process(false)
    # Move off-screen so it does not interfere with queries
    if instance is Node2D:
        (instance as Node2D).global_position = Vector2(-10_000, -10_000)
    elif instance is Node3D:
        (instance as Node3D).global_position = Vector3(-10_000, -10_000, -10_000)

# --- private ---

func _grow(count: int) -> void:
    for i in count:
        var instance := scene.instantiate()
        add_child(instance)
        instance.visible = false
        instance.set_process(false)
        instance.set_physics_process(false)
        _pool.append(instance)

func _activate(instance: Node) -> void:
    instance.visible = true
    instance.set_process(true)
    instance.set_physics_process(true)
```

**Usage:**

```gdscript
# bullet_spawner.gd
@onready var _pool: ObjectPool = $BulletPool

func _fire(direction: Vector2) -> void:
    var bullet: Bullet = _pool.get_instance() as Bullet
    bullet.global_position = $Muzzle.global_position
    bullet.direction = direction
    bullet.speed = 600.0

# In bullet.gd — return self to pool when done
func _on_hit_something() -> void:
    # Do not queue_free — return to pool instead
    _pool.release(self)
```

### C# Pool

```csharp
// ObjectPool.cs
using Godot;
using System.Collections.Generic;

public partial class ObjectPool : Node
{
    [Export] public PackedScene Scene { get; set; }
    [Export] public int InitialSize { get; set; } = 20;
    [Export] public int GrowSize { get; set; } = 10;

    private readonly List<Node> _pool = new();

    public override void _Ready()
    {
        Grow(InitialSize);
    }

    /// <summary>Returns an available instance from the pool, growing if needed.</summary>
    public T GetInstance<T>() where T : Node
    {
        foreach (var node in _pool)
        {
            if (node is CanvasItem ci && !ci.Visible)
            {
                Activate(node);
                return (T)node;
            }
            if (node is Node3D n3d && !n3d.Visible)
            {
                Activate(node);
                return (T)node;
            }
        }
        GD.PushWarning($"ObjectPool: pool exhausted, growing by {GrowSize}");
        Grow(GrowSize);
        return GetInstance<T>();
    }

    /// <summary>Returns an instance to the pool.</summary>
    public void Release(Node instance)
    {
        if (instance is CanvasItem ci)
        {
            ci.Visible = false;
            if (instance is Node2D n2d)
                n2d.GlobalPosition = new Vector2(-10_000f, -10_000f);
        }
        else if (instance is Node3D n3d)
        {
            n3d.Visible = false;
            n3d.GlobalPosition = new Vector3(-10_000f, -10_000f, -10_000f);
        }
        instance.SetProcess(false);
        instance.SetPhysicsProcess(false);
    }

    private void Grow(int count)
    {
        for (int i = 0; i < count; i++)
        {
            var instance = Scene.Instantiate();
            AddChild(instance);
            if (instance is CanvasItem ci) ci.Visible = false;
            else if (instance is Node3D n3d) n3d.Visible = false;
            instance.SetProcess(false);
            instance.SetPhysicsProcess(false);
            _pool.Add(instance);
        }
    }

    private static void Activate(Node instance)
    {
        if (instance is CanvasItem ci) ci.Visible = true;
        else if (instance is Node3D n3d) n3d.Visible = true;
        instance.SetProcess(true);
        instance.SetPhysicsProcess(true);
    }
}
```

**Usage in C#:**

```csharp
// BulletSpawner.cs
public partial class BulletSpawner : Node2D
{
    [Export] private ObjectPool _pool;

    private void Fire(Vector2 direction)
    {
        var bullet = _pool.GetInstance<Bullet>();
        bullet.GlobalPosition = GetNode<Marker2D>("Muzzle").GlobalPosition;
        bullet.Direction = direction;
    }
}

// Bullet.cs — return to pool instead of QueueFree
public partial class Bullet : CharacterBody2D
{
    [Export] private ObjectPool _pool;

    private void OnHitSomething()
    {
        _pool.Release(this);
    }
}
```

---

## 7. Common Bottlenecks

| Problem | Diagnosis tool | Fix |
|---|---|---|
| Too many draw calls | Debugger > Monitors `Render > Total Draw Calls`; Viewport > Debug > Draw Calls overlay | Use `CanvasGroup` for 2D batching; merge meshes for 3D; use texture atlases; reduce unique materials |
| Heavy GDScript in `_process` | Profiler > Self column shows script functions at top | Move logic to `_physics_process` (runs less often), cache queries, avoid per-frame allocations, consider C# for tight loops |
| Excessive signal connections | Profiler shows signal dispatch overhead; manually audit `get_signal_connection_list()` | Remove redundant connections; prefer polling over per-frame signals for high-frequency data; use `CONNECT_ONE_SHOT` for fire-and-forget |
| Unoptimised TileMap | Profiler shows `TileMap._process` or high draw call count | Split into fewer layers; use a single atlas texture per layer; disable `use_parent_material` if not needed; use `TileMapLayer` (Godot 4.3+) instead of legacy TileMap |
| Large uncompressed textures | Monitors `Render > Video RAM` is high; check Import dock for texture settings | Enable texture compression (VRAM Compressed) in the Import dock; use mipmaps; halve resolution of assets not viewed up-close |
| Too many active physics bodies | Monitors `Physics 3D > Active Bodies` is high; slow `_physics_process` in Profiler | Enable sleeping on `RigidBody3D` (`can_sleep = true`); lower physics tick rate; replace distant bodies with fake animations; use layers/masks to narrow collision checks |
| String operations in hot paths | Profiler shows `String` allocation functions; high GC pressure | Replace `String` comparisons with `StringName` (`&"..."`); avoid `String` formatting in `_process`; build strings once and cache |
| `instantiate()` in hot paths | Profiler shows `PackedScene.instantiate` with high Self time | Implement object pooling (see Section 6); preload scenes at startup; spawn during loading screens rather than during gameplay |

---

## 8. Checklist

Work through this list before shipping or when investigating a performance complaint.

**Profiler**
- [ ] Run the Profiler during the most demanding gameplay scenario.
- [ ] Confirm no single function's Self time exceeds 30% of the frame budget.
- [ ] Confirm total frame time stays under budget (16.6 ms at 60 fps).

**Draw Calls**
- [ ] Draw call count is within target (≤500 mobile, ≤2 000 desktop).
- [ ] 2D sprite groups that share a texture are wrapped in `CanvasGroup`.
- [ ] Textures are atlas-packed where possible; duplicate materials are eliminated.
- [ ] Off-screen nodes use `VisibleOnScreenNotifier2D/3D` to pause processing.
- [ ] 3D meshes have LOD enabled via import settings or manual swap logic.

**Physics**
- [ ] Collision layers and masks are minimal — no body checks layers it never needs.
- [ ] No moving body uses `ConcavePolygonShape` — replaced with capsule, box, or convex.
- [ ] Physics tick rate is appropriate for the game type (30 Hz may be fine for turn-based or top-down).
- [ ] `Area2D/3D` is used for overlap detection instead of per-frame raycasts.
- [ ] `RigidBody3D` nodes have `can_sleep = true` where applicable.

**GDScript**
- [ ] No `Array`, `Dictionary`, or `String` is allocated inside `_process` or `_physics_process`.
- [ ] All hot-path string comparisons use `StringName` (`&"..."`).
- [ ] All arrays in hot paths are typed (`Array[T]` or `PackedArray`).
- [ ] All function parameters and return types in hot paths are statically typed.
- [ ] All scene and resource references use `preload` at class scope, not `load` per frame.

**Memory**
- [ ] `Performance.get_monitor(Performance.MEMORY_STATIC)` is stable between scene reloads.
- [ ] Resources that require per-instance mutation are `.duplicate()`d.
- [ ] All node removals use `queue_free()` unless synchronous teardown is explicitly required.

**Object Pooling**
- [ ] Bullets, hit effects, particles, and other frequently spawned objects use a pool.
- [ ] Pool initial size is large enough to avoid runtime growth during normal gameplay.
- [ ] Pooled objects reset all state on reactivation (position, velocity, signals).
