# Changelog

All notable changes to GodotPrompter will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.4.1-fork] - 2026-04-25

### Fork changes

This is a **fork** of the original [jame581/GodotPrompter](https://github.com/jame581/GodotPrompter) (v1.4.1). All prior release history (v1.0.0–v1.4.1) belongs to the original upstream.

### Added

- **godot-game-dev** — GDScript Strict Typing Rules (Godot 4.4+ / 4.6.2): explicit `: Type =` over `:=` for Variant-returning APIs, typed collections, annotated signal handlers/lambdas, `@export` types, pre-submit self-check scan
- **godot-game-architect** — Strict Typing in Designs (Godot 4.4+ / 4.6.2): typed Resource fields, typed signal signatures, typed API declarations in design docs
- **godot-code-reviewer** — Mandatory Variant Inference Audit for all GDScript reviews: 5-point audit checklist covering `:=` misuse, untyped collections, untyped signals/lambdas, untyped `@export`, unjustified warning suppressions
- All 3 agents — Plugin-first documentation and implementation rules (plugin docs override generic best-practices when present)
- All 3 agents — Bilingual documentation output requirement (English first, Chinese second)
- All 3 agents — Prefer plugin-native capabilities over generic patterns in conflicts

### Changed

- **Fork adjustment** — All repository URLs updated from `jame581` to `0999312`
- **using-godot-prompter** — Fixed doc path: `docs/godot-prompter/plans/` → `docs/superpowers/plans/` (actual directory path)
- **CLAUDE.md** — Version management now lists all 4 version-bearing files (.claude-plugin, .cursor-plugin, gemini-extension.json, package.json); removed external marketplace release steps (fork uses local install)
- **CONTRIBUTING.md** — Release process updated for fork workflow (local install, no external marketplace repos)
- **README.md** — All installation URLs updated to fork; marketplace install instructions replaced with clone+local install; fork attribution added
- **gemini-extension.json** — Added missing author, homepage, license, and keywords fields
- **package.json** — Added `contributors` array attributing original creator; updated author and repository URL

### Fixed

- **using-godot-prompter** — Fixed incorrect doc path reference (`docs/godot-prompter/` → `docs/superpowers/`)

## [1.4.1] - 2026-04-09

### Fixed

- **using-godot-prompter** — added coexistence section ensuring GodotPrompter skills are invoked even when another workflow plugin (e.g., Superpowers) drives the session
- **godot-brainstorming** — rewrote Step 4 to inject a `## GodotPrompter` section into project CLAUDE.md and annotate plan tasks with required skill references
- **godot-project-setup** — added CLAUDE.md GodotPrompter section to project setup checklist

## [1.4.0] - 2026-04-09

### Added

- **localization** skill — TranslationServer, CSV/PO translation files, locale switching, RTL support, pluralization
- **procedural-generation** skill — seeded randomness, FastNoiseLite, BSP dungeons, cellular automata caves, wave function collapse
- **xr-development** skill — OpenXR setup, XR controllers, hand tracking, physics grabbing, XR UI, passthrough, Meta Quest export
- 3 new skills bringing total from 41 to 44

### Changed

- **gdscript-patterns** — added `super()` in virtual methods section (Godot 4 breaking change from 3.x)
- **audio-system** — added interactive music streams (AudioStreamPlaylist, AudioStreamSynchronized, AudioStreamInteractive) and runtime WAV loading (Godot 4.3/4.4+)
- **ai-navigation** — added async navigation baking on background threads (Godot 4.4+)
- **animation-system** — added Animation Markers, LookAtModifier3D, SpringBoneSimulator3D, animation retargeting (Godot 4.3/4.4+)
- **shader-basics** — added Compositor effects and custom render passes (Godot 4.3+)
- **state-machine** — added hierarchical and parallel FSM patterns for complex characters
- **2d-essentials** — added TileMap node deprecation notice (use TileMapLayer instead)
- **physics-system** — added Jolt Physics as default recommendation for new 3D projects (Godot 4.4+)

## [1.3.0] - 2026-04-08

### Added

- **input-handling** skill — InputEvent system, Input Map actions, controllers/gamepads, mouse/touch, action rebinding, input architecture
- **3d-essentials** skill — materials, lighting, shadows, environment, global illumination, fog, LOD, occlusion culling, decals, MultiMesh, renderer comparison
- **tween-animation** skill — Tween class, easing/transitions, chaining/parallel, property/method/callback tweeners, common UI and gameplay motion recipes
- **particles-vfx** skill — GPUParticles2D/3D, ParticleProcessMaterial, emission shapes, subemitters, trails, attractors, collision, turbulence, flipbook animation, VFX recipes
- **gdscript-patterns** skill — static typing, await/coroutines, lambdas, match/pattern matching, export annotations, inner classes, common GDScript idioms
- **math-essentials** skill — vectors, transforms, interpolation (lerp/slerp/move_toward/smoothstep), curves/paths, random number generation, common game math recipes
- **assets-pipeline** skill — image import/compression, 3D scene import with naming conventions, audio formats, resource formats (.tres/.res), threaded loading
- 7 new skills bringing total from 34 to 41

## [1.2.0] - 2026-04-07

### Added

- **physics-system** skill — RigidBody2D/3D, StaticBody, Area2D/3D, raycasting, collision shapes/layers, Jolt physics, physics interpolation, ragdolls, SoftBody3D, and troubleshooting
- **2d-essentials** skill — TileMaps, parallax scrolling, 2D lights and shadows, 2D particles, custom drawing, 2D meshes, antialiasing, and pixel-perfect snapping
- Superpowers plugin attribution in README
- Author and support section in README
- Bidirectional cross-references across all related skills

## [1.1.0] - 2026-04-06

### Added

- **animation-system** skill — AnimationPlayer, AnimationTree, blend trees, state machines, sprite animation, and code-driven animation
- **shader-basics** skill — Godot shader language, visual shaders, common visual recipes, and post-processing effects
- **audio-system** skill — audio buses, AudioStreamPlayer, spatial audio, music management, SFX pooling, and dynamic mixing
- Release process documentation in CONTRIBUTING.md
- GitHub Sponsors and Buy Me a Coffee funding configuration

### Removed

- Trial project test files (replaced by real Godot project validation)

## [1.0.0] - 2026-04-06

### Added

- 32 skills covering Godot 4.3+ development (GDScript + C#)
- **Core/Process:** godot-project-setup, godot-brainstorming, godot-code-review, godot-debugging, godot-testing, using-godot-prompter
- **Architecture:** scene-organization, state-machine, event-bus, component-system, resource-pattern, dependency-injection
- **Gameplay:** player-controller, animation-system, audio-system, inventory-system, dialogue-system, save-load, ai-navigation, camera-system
- **Rendering/Visual:** shader-basics
- **UI/UX:** godot-ui, responsive-ui, hud-system
- **Multiplayer:** multiplayer-basics, multiplayer-sync, dedicated-server
- **Build/Deploy:** export-pipeline, godot-optimization, addon-development
- **C#:** csharp-godot, csharp-signals
- Cross-references between related skills
- 3 specialized agents: godot-game-architect, godot-game-dev, godot-code-reviewer
- Claude Code plugin structure (.claude-plugin/plugin.json)
- Platform support: Claude Code, Copilot CLI, Gemini CLI, Codex, Cursor, OpenCode
- Trial project validation (13/15 PASS, 2/15 PARTIAL)
- Agent integration test plan
