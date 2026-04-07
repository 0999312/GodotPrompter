# Changelog

All notable changes to GodotPrompter will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-04-07

### Added

- **physics-system** skill — RigidBody2D/3D, StaticBody, Area2D/3D, raycasting, collision shapes/layers, Jolt physics, physics interpolation, ragdolls, SoftBody3D, and troubleshooting
- **2d-essentials** skill — TileMaps, parallax scrolling, 2D lights and shadows, 2D particles, custom drawing, 2D meshes, antialiasing, and pixel-perfect snapping
- **input-handling** skill — InputEvent system, Input Map actions, controllers/gamepads, mouse/touch, action rebinding, input architecture
- Superpowers plugin attribution in README
- Author and support section in README
- Bidirectional cross-references across all related skills

### In Progress

New skills planned (3 remaining):
- `3d-essentials` — materials, lighting, environment, fog, LOD, occlusion, GI
- `particles-vfx` — GPUParticles2D/3D, process materials, subemitters, trails
- `tween-animation` — Tween class, easing, chaining, property/method tweens

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
