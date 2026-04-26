# Godot Addon Registry — Skill Domain Coverage

Agent reference for Step 0.5: Addon Discovery & Override. When the agent scans `addons/`, it matches installed addons against this table to determine whether to use addon-native APIs or generic skill patterns.

---

## Master Coverage Table

| Addon | Covers Skill Domain | Coverage Type | Since Godot | Stars | Status |
|-------|--------------------|---------------|-------------|-------|--------|
| `dialogic` | `dialogue-system` | Full | 4.2+ | 2.2k | Active |
| `dialogue_manager` | `dialogue-system` | Full (alternative) | 4.6+ | 3.5k | Active |
| `orchestrator` | `state-machine`, `component-system` | Full (FSM), Partial (logic) | 4.2+ | 1.5k | Active |
| `phantom-camera` | `camera-system` | Full | 4.4+ | 3.3k | Active |
| `godot-xr-tools` | `xr-development` | Full | 4.2+ | 701 | Active |
| `voxel-engine` (Zylann) | `procedural-generation`, `3d-essentials` | Partial | 4.x | 3.6k | Active |
| `godot-git-plugin` | `export-pipeline` | Complementary | 4.x | 888 | Active |
| `quest-system` | `state-machine`, `component-system` | Partial | 4.4+ | 447 | Active |
| `pandora` | `inventory-system`, `resource-pattern` | Partial | 4.x | 1k | Alpha |
| `wwise` | `audio-system` | Full | 4.x | 404 | Active |
| `fmod` | `audio-system` | Full | 4.4+ | 844 | Active |
| `gdtoolkit` | `gdscript-patterns` | Complementary | N/A (CLI) | — | Active |
| **`mc_game_framework`** | **`event-bus`**, **`godot-ui`**, **`localization`**, **`save-load`**, **`resource-pattern`**, **`component-system`** | **Full (event/UI/i18n), Partial (data/codec)** | **4.3+** | **N/A** | **Dev** |

---

## Per-Addon Details

### Dialogic

- **Repo**: [dialogic-godot/dialogic](https://github.com/dialogic-godot/dialogic)
- **Coverage**: Full replacement for `dialogue-system`
- **Installed at**: `addons/dialogic/`
- **Covers**: Branching dialogue, character portraits, text display, choices, variables, conditions
- **Does NOT cover**: Save/load of dialogue state (use `save-load` skill alongside), narrative scripting outside Dialogic
- **When to use**: Any project requiring dialogue with multiple characters and branching
- **When NOT to use**: Simple single-line tooltips or notifications (use `godot-ui` or `hud-system`)
- **Activation**: `Dialogic.start("timeline_name")` in GDScript
- **Conflict**: Conflicts with `dialogue_manager` — cannot use both simultaneously
- **References**: [Dialogic Docs](https://docs.dialogic.pro/)

### Dialogue Manager

- **Repo**: [nathanhoad/godot_dialogue_manager](https://github.com/nathanhoad/godot_dialogue_manager)
- **Coverage**: Full replacement for `dialogue-system` (alternative to Dialogic)
- **Installed at**: `addons/dialogue_manager/`
- **Covers**: Branching dialogue, character portraits, text display, choices
- **Does NOT cover**: Same gaps as Dialogic
- **When to use**: Simpler dialogue needs; Dialogic is overly complex for the project
- **Activation**: `DialogueManager.show_dialogue_balloon(scene, "start_title")`
- **Conflict**: Conflicts with `dialogic` — cannot use both simultaneously
- **References**: [Dialogue Manager Docs](https://github.com/nathanhoad/godot_dialogue_manager)

### Orchestrator

- **Repo**: [CraterCrash/godot-orchestrator](https://github.com/CraterCrash/godot-orchestrator)
- **Coverage**: Full replacement for `state-machine`, partial for `component-system`
- **Installed at**: `addons/orchestrator/`
- **Covers**: State machines, behavior trees, event-driven game logic, visual scripting
- **Does NOT cover**: Animation state machines (use `animation-system` skill), movement physics (use `player-controller` skill)
- **When to use**: Projects where non-programmers need to design game logic
- **Activation**: `.orch` scene files loaded via Orchestrator API
- **Version compatibility**:

| Godot | Orchestrator |
|-------|-------------|
| 4.7.x | v2.5.x (main) |
| 4.6.x | v2.4.x |
| 4.5.x | v2.3.x |
| 4.4.x | v2.2.x |
| 4.3.x | v2.1.x (EOL) |
| 4.2.x | v2.0.x (EOL) |

### Phantom Camera

- **Repo**: [ramokz/phantom-camera](https://github.com/ramokz/phantom-camera) (moved from Arnklit/PhantomCamera)
- **Coverage**: Full replacement for `camera-system`
- **Installed at**: `addons/phantom_camera/`
- **Covers**: Smooth camera follow, screen shake, camera transitions, camera zones, priority system (Cinemachine-inspired)
- **Does NOT cover**: Post-processing camera effects (use `shader-basics` skill)
- **Activation**: `PhantomCameraHost.AddCamera(camera)` with priority system
- **References**: [Phantom Camera Docs](https://github.com/ramokz/phantom-camera)

### Godot XR Tools

- **Repo**: [GodotVR/godot-xr-tools](https://github.com/GodotVR/godot-xr-tools)
- **Coverage**: Full replacement for `xr-development`
- **Installed at**: `addons/godot-xr-tools/`
- **Covers**: XR controller models, movement (snap/free teleport, smooth locomotion), interaction (grabbing, throwing, using), player body, hand posing, IK
- **Does NOT cover**: OpenXR plugin itself (separate dependency), custom XR interaction patterns
- **When to use**: Any Godot VR/AR project
- **Activation**: Add scenes from addon to XR origin; requires OpenXR plugin installed
- **References**: [Godot XR Tools](https://github.com/GodotVR/godot-xr-tools)

### Voxel Engine (Voxel Tools by Zylann)

- **Repo**: [Zylann/godot_voxel](https://github.com/Zylann/godot_voxel)
- **Coverage**: Partial replacement for `procedural-generation` and `3d-essentials`
- **Installed at**: `addons/godot_voxel/` (module or GDExtension)
- **Covers**: Real-time editable 3D voxel terrain, Minecraft-style blocky voxels with baked AO, smooth terrain with Transvoxel LOD, infinite terrain, instancing system for foliage/rocks, physics integration
- **Does NOT cover**: Non-voxel procedural generation (dungeons, WFC, caves — use `procedural-generation` skill), mesh-based level design
- **When to use**: Any project requiring voxel terrain (block-building, terraforming, large open worlds)
- **When NOT to use**: Flat or hand-crafted levels with no terrain editing
- **Activation**: C++ module or GDExtension; GDScript bindings available
- **References**: [Voxel Tools Docs](https://github.com/Zylann/godot_voxel)

### Git Plugin

- **Repo**: [godotengine/godot-git-plugin](https://github.com/godotengine/godot-git-plugin)
- **Coverage**: Complementary for `export-pipeline`
- **Installed at**: `addons/godot-git-plugin/` (GDExtension, requires compilation)
- **Covers**: Git commit, diff, branch, staging operations from within Godot Editor via VCS interface
- **Does NOT cover**: Export/deployment pipeline itself (use `export-pipeline` skill alongside)
- **Activation**: Enable in Project → Plugins; uses libgit2 backend

### Quest System

- **Repo**: [shomykohai/quest-system](https://github.com/shomykohai/quest-system)
- **Coverage**: Partial replacement for `state-machine` and `component-system`
- **Installed at**: `addons/quest-system/`
- **Covers**: Resource-based quest definitions, CSV/POT localization, serialization, quest state tracking
- **Does NOT cover**: Generic FSM for characters (use `state-machine` skill), combat/behavior components (use `component-system` skill)
- **Integration**: Has example integration with Pandora addon

### Pandora

- **Repo**: [bitbrain/pandora](https://github.com/bitbrain/pandora)
- **Coverage**: Partial replacement for `inventory-system` and `resource-pattern`
- **Installed at**: `addons/pandora/`
- **Covers**: RPG data management — items, inventories, spells, abilities, characters, monsters, loot tables; dedicated editor UI
- **Does NOT cover**: Slot management UI (use `inventory-system` skill alongside), in-game inventory rendering
- **Status**: Alpha — not recommended for production projects without evaluation
- **References**: [Pandora Docs](https://github.com/bitbrain/pandora)

### Wwise

- **Repo**: [alessandrofama/wwise-godot-integration](https://github.com/alessandrofama/wwise-godot-integration)
- **Coverage**: Full replacement for `audio-system`
- **Installed at**: `addons/Wwise/`
- **Covers**: All audio — buses, spatial, streaming, mixing, dynamic music; GDExtension-based wrapper with custom Godot nodes (AkEvent3D, AkBank, AkListener, etc.)
- **Does NOT cover**: OS-level audio I/O, microphone input
- **When to use**: Any project requiring professional-grade audio (AAA, commercial release)
- **When NOT to use**: Prototypes, jams, or projects where Godot's built-in audio is sufficient
- **Activation**: `AkSoundEngine.PostEvent("event_name", node)`
- **Conflict**: Wwise and FMOD conflict — cannot use both simultaneously

### FMOD

- **Repo**: [utopia-rise/fmod-gdextension](https://github.com/utopia-rise/fmod-gdextension)
- **Coverage**: Full replacement for `audio-system`
- **Installed at**: `addons/FMOD/`
- **Covers**: All audio — FMOD Studio API integration, dedicated Godot nodes (FmodEventEmitter2D/3D, FmodEventListener2D/3D), 3D positional audio
- **Does NOT cover**: C# bindings (GDExtension only, GDScript with auto-binding works)
- **When to use**: Any project requiring professional-grade audio
- **When NOT to use**: Prototypes where built-in audio is sufficient
- **Conflict**: Wwise and FMOD conflict — cannot use both simultaneously
- **References**: [FMOD Godot Docs](https://github.com/utopia-rise/fmod-gdextension)

### GDToolkit (gdlint)

- **Repo**: [godotengine/godot-gdtoolkit](https://github.com/godotengine/godot-gdtoolkit)
- **Coverage**: Complementary for `gdscript-patterns`
- **Install**: `pip install gdtoolkit` (CLI tool, not an editor addon)
- **Covers**: GDScript static analysis, linting (gdlint), formatting (gdformat)
- **Does NOT cover**: Skill-level architecture patterns (use `gdscript-patterns` skill alongside)
- **When to use**: CI/CD pipelines, pre-commit hooks, code review automation
- **Activation**: `gdlint path/to/file.gd` or `gdlint .`

### 🆕 Minecraft-Style-Framework

- **Repo**: Local plugin (see `addons/mc_game_framework/`)
- **Coverage**: Multi-domain — see table below
- **Installed at**: `addons/mc_game_framework/`
- **When to use**: Project uses this framework for data-driven design with registry + event + UI + component pattern
- **When NOT to use**: Project does not install this addon
- **Activation**: Enable in Project → Plugins → "MinecraftStyleFramework"; auto-registers 4 autoloads (RegistryManager, EventBus, I18NManager, UIManager)

#### Override Detail

| Skill Domain | Coverage | Agent Behavior |
|-------------|----------|---------------|
| `event-bus` | **Full replacement** | Use framework's EventBus (string-based pub/sub + cancellation); do NOT use generic event-bus skill patterns |
| `godot-ui`, `hud-system` | **Full replacement** | Use UIManager + UIPanel + UIToast API for all panel/toast/overlay management; do NOT use generic UI stack patterns |
| `localization` | **Full replacement** | Use I18NManager.load_translation() / set_language() for JSON-based i18n; do NOT use generic localization skill patterns (unless CSV/PO/pluralization is required) |
| `save-load` | **Partial (codec layer)** | Use Codec + DataResult for data serialization; CodecResource for .tres bridging; still use generic save-load patterns for SaveManager orchestration |
| `resource-pattern` | **Complementary** | Use ResourceLocation + RegistryBase for runtime data management; use generic resource-pattern patterns for Resource class definition and Inspector editing |
| `component-system` | **Partial (data components)** | Use ComponentHost + ComponentContainer for data components (HP, name, stats); use generic component-system patterns for behavior components (Hitbox, Hurtbox, HealthBehavior) |

**Architecture constraints when using this addon:**
- Autoloads handled by the framework (4 singletons); do NOT register additional autoloads
- Communication via framework EventBus (not typed signals on a separate EventBus)
- UI via UIManager stack (not direct scene tree manipulation)
- Data identified by ResourceLocation `namespace:path` identifiers

---

## Removed Entries

The following addons were previously listed in this registry but have been removed:

| Addon | Reason for Removal |
|-------|-------------------|
| `water-ways` | Godot 3.x only; last release 2021; archived — no Godot 4.x port available |
| `discord-game-sdk` | Godot 3.x only (GDNative); archived; no Godot 4.x port |
| `terrain-automata` | Could not locate a Godot addon matching this name on GitHub |
| `player-manager` | Could not locate a Godot addon matching this name on GitHub |

## Built-in Features (Not Addons)

The following were previously listed as addons but are actually built into Godot or external tools:

| Feature | Location | Notes |
|---------|----------|-------|
| `UPNP` / `UPNPDevice` | Godot engine core classes | Built-in class, no addon needed |
| AssetLib | Godot Editor built-in tab | Built-in, no addon needed |
| JetBrains Rider Godot Support | JetBrains Marketplace | IDE plugin, not a Godot project addon |
| `vala` (GDScript analysis) | Replaced by `gdtoolkit` | Use `gdtoolkit`/`gdlint` (official Godot tooling) |

---

## How to Read This Registry

When scanning `addons/` in Step 0.5:

```
1. List all folders in addons/
2. For each folder, look up in Master Coverage Table
3. For each match:
   - Full → ask user: "Use [addon] or generic patterns?"
   - Partial → ask user: "Use [addon] for [sub-domain]?"
   - Complementary → no pause needed, use alongside skill
4. For conflicts (same domain, two addons):
   - Pause, present both, user chooses
```

---

## Maintenance

This registry is a living document. To add or update an entry:

1. Open a PR with the addon name, coverage domain, and verification notes
2. Every entry must be verified: confirm the addon actually works with Godot 4.3+
3. Update `agent_tested_on` in relevant skill frontmatter when addon integration is verified

*Last updated: 2026-04-27*
