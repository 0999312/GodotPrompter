# GodotPrompter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.x](https://img.shields.io/badge/Godot-4.3+-blue.svg)](https://godotengine.org)
[![Skills: 44](https://img.shields.io/badge/Skills-44-green.svg)](#available-skills)

Agentic skills framework for Godot 4.x game development. Gives AI coding agents domain-specific expertise for GDScript and C# projects.

Inspired by and built on top of the [Superpowers](https://github.com/obra/superpowers) plugin for Claude Code — which provides the underlying skill loading, brainstorming, and workflow infrastructure that GodotPrompter extends with Godot-specific domain knowledge.

## What is this?

GodotPrompter is a plugin that provides **skills** — structured domain knowledge that AI agents load on demand. When you ask your agent to "add a state machine" or "set up multiplayer", it loads the relevant GodotPrompter skill and follows Godot-specific best practices instead of relying on generic knowledge.

**44 skills** covering project setup, architecture, gameplay systems, input handling, physics, 2D/3D systems, animation, shaders, audio, UI, multiplayer, localization, procedural generation, XR/VR, optimization, and C# patterns. All targeting Godot 4.3+ with both GDScript and C# examples.

## Quick Start

### Claude Code (recommended)

```bash
# Clone the fork
git clone https://github.com/0999312/GodotPrompter.git

# Add local marketplace and install
claude plugins marketplace add ./GodotPrompter
claude plugins install godot-prompter@godot-prompter
```

Or install from a local clone:

```bash
git clone https://github.com/0999312/GodotPrompter.git
claude plugins marketplace add ./GodotPrompter
claude plugins install godot-prompter@godot-prompter
```

Then start a new session and ask:

```
"I'm starting a new Godot 4.3 project. How should I organize it?"
```

The agent loads the `godot-project-setup` skill and provides a complete directory structure, autoload setup, and .gitignore — not generic advice.

### Gemini CLI

```bash
gemini extensions install https://github.com/0999312/GodotPrompter
```

### GitHub Copilot CLI

```bash
# Clone the fork
git clone https://github.com/0999312/GodotPrompter.git

# Add local marketplace and install
copilot plugin marketplace add ./GodotPrompter
copilot plugin install godot-prompter@godot-prompter
```

### Cursor

```
/add-plugin godot-prompter
```

Or clone and place in your project — Cursor reads `.cursor-plugin/plugin.json`.

### Codex

```bash
git clone https://github.com/0999312/GodotPrompter.git ~/.codex/godot-prompter
mkdir -p ~/.agents/skills
ln -s ~/.codex/godot-prompter/skills ~/.agents/skills/godot-prompter
```

See `.codex/INSTALL.md` for Windows instructions.

### OpenCode

Add to `opencode.json`:

```json
{
  "plugin": ["godot-prompter@git+https://github.com/0999312/GodotPrompter.git"]
}
```

See `.opencode/INSTALL.md` for details.

## How It Works

### 1. Design Phase
Ask the agent to brainstorm a feature. It loads `godot-brainstorming` and walks you through:
- Clarifying questions about your game/system
- Architectural approaches with trade-offs
- Scene tree design, signal maps, and data flow
- An implementation plan with ordered tasks

### 2. Implementation Phase
For each task, the agent loads the relevant domain skill:
- Building a player? → `player-controller` + `input-handling` + `state-machine`
- Adding inventory? → `inventory-system` + `resource-pattern`
- Setting up 3D scene? → `3d-essentials` + `assets-pipeline`
- Adding particles? → `particles-vfx` + `shader-basics`
- Need animations? → `animation-system` + `tween-animation`
- Need save/load? → `save-load`

### 3. Review Phase
Ask for a code review. The agent loads `godot-code-review` and checks against Godot-specific checklists.

### Example Use Cases

- **"Set up a new Godot project"** — Loads the `godot-project-setup` skill and scaffolds a complete directory structure, autoloads, input map, and .gitignore following Godot best practices.
- **"Add a platformer player controller with coyote time and jump buffering"** — Loads `player-controller` and `input-handling` skills, providing complete CharacterBody2D code with physics-correct movement in both GDScript and C#.
- **"Design an enemy AI system with patrol, chase, and attack"** — Uses the `godot-game-architect` agent to plan the system with `ai-navigation`, `state-machine`, and `animation-system` skills, then the `godot-game-dev` agent to implement it.
- **"Set up a 3D scene with lighting, materials, and fog"** — Loads `3d-essentials` skill with StandardMaterial3D PBR workflow, DirectionalLight3D shadow configuration, environment setup, and volumetric fog.
- **"Add particle effects for explosions and fire"** — Loads `particles-vfx` skill with GPUParticles2D/3D recipes, ParticleProcessMaterial configuration, color ramps, and one-shot burst patterns.
- **"Review my code for Godot best practices"** — Uses the `godot-code-reviewer` agent with the `godot-code-review` skill to check node architecture, signal patterns, performance, input handling, and resource management.

### Agents

GodotPrompter includes 3 specialized agents:

| Agent | Purpose |
|-------|---------|
| **godot-game-architect** | Designs systems, plans scene trees, chooses patterns |
| **godot-game-dev** | Implements features guided by skills |
| **godot-code-reviewer** | Reviews code against Godot best practices |

## Supported Platforms

| Platform | Status | Install |
|----------|--------|---------|
| Claude Code | Primary | Clone + local install (`claude plugins marketplace add ./GodotPrompter`) |
| Gemini CLI | Supported | `gemini extensions install https://github.com/0999312/GodotPrompter` |
| GitHub Copilot CLI | Supported | Clone + local install |
| Cursor | Supported | `/add-plugin godot-prompter` or clone with `.cursor-plugin/` |
| Codex | Supported | Clone + symlink (see `.codex/INSTALL.md`) |
| OpenCode | Supported | Add to `opencode.json` (see `.opencode/INSTALL.md`) |

> This is a **fork** of [`jame581/GodotPrompter`](https://github.com/jame581/GodotPrompter). The original remains the canonical upstream. This fork is maintained independently at [`0999312/GodotPrompter`](https://github.com/0999312/GodotPrompter).

## Available Skills

### Core / Process (6 skills)

| Skill | Description |
|-------|-------------|
| `using-godot-prompter` | Bootstrap — skill catalog, workflow guide, platform setup |
| `godot-project-setup` | Scaffold directory structure, autoloads, .gitignore, input maps |
| `godot-brainstorming` | Scene tree planning, node selection, architectural decisions |
| `godot-code-review` | Review checklist — best practices, anti-patterns, Godot pitfalls |
| `godot-debugging` | Remote debugger, print techniques, signal tracing, error patterns |
| `godot-testing` | TDD with GUT and gdUnit4 — test structure, mocking, CI |

### Architecture & Patterns (6 skills)

| Skill | Description |
|-------|-------------|
| `scene-organization` | Scene tree composition, when to split scenes, node hierarchy |
| `state-machine` | Enum-based, node-based, resource-based FSM with trade-offs |
| `event-bus` | Global EventBus autoload with typed signals, decoupled communication |
| `component-system` | Hitbox/Hurtbox/Health components, composition over inheritance |
| `resource-pattern` | Custom Resources for items, stats, config, editor integration |
| `dependency-injection` | Autoloads, service locators, @export injection, scene injection |

### Physics, 2D/3D & XR (4 skills)

| Skill | Description |
|-------|-------------|
| `physics-system` | RigidBody, Area, raycasting, collision shapes, Jolt, ragdolls, interpolation |
| `2d-essentials` | TileMaps, parallax, 2D lights/shadows, particles, custom drawing, canvas layers |
| `3d-essentials` | Materials, lighting, shadows, environment, GI, fog, LOD, occlusion, decals |
| `xr-development` | OpenXR, XROrigin3D, hand tracking, controllers, passthrough, Meta Quest |

### Gameplay Systems (12 skills)

| Skill | Description |
|-------|-------------|
| `player-controller` | CharacterBody2D/3D movement — top-down, platformer, first-person |
| `input-handling` | InputEvent system, Input Map actions, controllers/gamepads, mouse/touch, action rebinding |
| `animation-system` | AnimationPlayer, AnimationTree, blend trees, state machines, sprite animation |
| `tween-animation` | Tween class, easing, chaining, parallel sequences, common motion recipes |
| `audio-system` | Audio buses, music management, SFX pooling, spatial audio, interactive music |
| `inventory-system` | Resource-based items, slot management, stacking, UI binding |
| `dialogue-system` | Branching dialogue trees, conditions, UI presentation |
| `save-load` | ConfigFile, JSON, Resource serialization, version migration |
| `ai-navigation` | NavigationAgent2D/3D, steering behaviors, patrol patterns, async baking |
| `camera-system` | Smooth follow, screen shake, camera zones, transitions |
| `localization` | TranslationServer, CSV/PO files, locale switching, RTL support, pluralization |
| `procedural-generation` | Noise, BSP dungeons, cellular automata, WFC, seeded randomness |

### UI/UX (3 skills)

| Skill | Description |
|-------|-------------|
| `godot-ui` | Control nodes, themes, anchors, containers, layout patterns |
| `responsive-ui` | Multi-resolution scaling, aspect ratios, DPI, mobile adaptation |
| `hud-system` | Health bars, score displays, minimap, damage numbers, notifications |

### Multiplayer (3 skills)

| Skill | Description |
|-------|-------------|
| `multiplayer-basics` | MultiplayerAPI, ENet/WebSocket, RPCs, authority model |
| `multiplayer-sync` | MultiplayerSynchronizer, interpolation, prediction, lag compensation |
| `dedicated-server` | Headless export, server architecture, lobby management |

### Rendering & Visual (2 skills)

| Skill | Description |
|-------|-------------|
| `shader-basics` | Godot shader language, visual shaders, common recipes, post-processing |
| `particles-vfx` | GPUParticles2D/3D, process materials, subemitters, trails, attractors, collision |

### Build & Deploy (4 skills)

| Skill | Description |
|-------|-------------|
| `export-pipeline` | Platform exports, CI/CD with GitHub Actions, itch.io/Steam deploy |
| `godot-optimization` | Profiler, draw calls, physics tuning, object pooling, bottlenecks |
| `addon-development` | EditorPlugin, @tool scripts, custom inspectors, dock panels |
| `assets-pipeline` | Image compression, 3D scene import, audio formats, resource management |

### Scripting (3 skills)

| Skill | Description |
|-------|-------------|
| `gdscript-patterns` | Static typing, await/coroutines, lambdas, match, exports, common idioms |
| `csharp-godot` | C# conventions, GodotSharp API, project setup, GDScript interop |
| `csharp-signals` | [Signal] delegates, EmitSignal, async awaiting, event architecture |

### Math & Data (1 skill)

| Skill | Description |
|-------|-------------|
| `math-essentials` | Vectors, transforms, interpolation, curves, paths, RNG, game math recipes |

## Validation

Skills were validated against a real Godot 4.3+ trial project (top-down 2D action RPG):

- **13/15 skills PASS** — guidance worked as documented
- **2/15 skills PARTIAL** — minor gotchas documented and fixed
- **0/15 skills FAIL**

See `tests/trial-project/VALIDATION.md` for detailed results.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add new skills, conventions, and testing requirements.

## License

[MIT](LICENSE)

## Author

* **0999312** - *Fork maintainer* - [github.com/0999312](https://github.com/0999312)

### Original Creator

* **Jan Mesarč** - *Original creator* - [janmesarc.online/](https://janmesarc.online/) — [Buy Me A Coffee](https://www.buymeacoffee.com/jame581)

This project is a fork of the [original GodotPrompter](https://github.com/jame581/GodotPrompter) by Jan Mesarč, distributed under the MIT license.
