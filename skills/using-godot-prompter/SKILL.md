---
name: using-godot-prompter
description: Bootstrap skill — establishes how to find and use GodotPrompter skills, with platform-specific tool mapping
---

# Using GodotPrompter

GodotPrompter provides Godot 4.x domain-specific skills for AI coding agents. Skills cover project setup, architecture patterns, gameplay systems, UI, multiplayer, testing, and deployment — for both GDScript and C#.

## How to Access Skills

**In Claude Code:** Use the `Skill` tool with the skill name (e.g., `Skill: "godot-prompter:state-machine"`).

**In Copilot CLI:** Use the `skill` tool. Skills are auto-discovered from installed plugins.

**In Gemini CLI:** Use the `activate_skill` tool. See `references/gemini-tools.md` for tool mapping.

**In Cursor:** Skills are loaded via custom instructions / rules system.

## Platform Adaptation

Skills use Claude Code tool names as the canonical reference. Non-Claude platforms: see the appropriate tool mapping file in `references/` for your platform's equivalents.

## Available Skill Categories

### Core / Process
- `using-godot-prompter` — This skill (bootstrap)
- `godot-project-setup` — Scaffold new projects
- `godot-brainstorming` — Godot-specific design exploration
- `godot-code-review` — GDScript/C# review against Godot best practices
- `godot-debugging` — Godot-specific debugging techniques
- `godot-testing` — TDD with GUT and gdUnit4

### Architecture & Patterns
- `scene-organization` — Scene tree structure, composition patterns
- `state-machine` — FSM patterns (node-based, resource-based, enum-based)
- `event-bus` — Signal-based decoupling, autoload event systems
- `component-system` — Composition over inheritance
- `resource-pattern` — Custom Resources as data containers
- `dependency-injection` — Autoloads, service locators

### Gameplay Systems
- `player-controller` — CharacterBody2D/3D movement, input handling
- `inventory-system` — Resource-based inventory patterns
- `dialogue-system` — Dialogue trees and patterns
- `save-load` — Serialization strategies
- `ai-navigation` — NavigationAgent, behavior trees
- `camera-system` — Camera follow, shake, zones

### UI/UX *(Planned — Phase 3)*
- `godot-ui` — Control nodes, themes, containers
- `responsive-ui` — Multi-resolution scaling
- `hud-system` — In-game HUD patterns

### Multiplayer *(Planned — Phase 3)*
- `multiplayer-basics` — MultiplayerAPI, RPCs, authority
- `multiplayer-sync` — Synchronization, interpolation
- `dedicated-server` — Headless export, server architecture

### Build & Deploy *(Planned — Phase 3)*
- `export-pipeline` — Platform exports, CI/CD
- `godot-optimization` — Profiler, performance patterns
- `addon-development` — EditorPlugin, tool scripts

### C# Specific *(Planned — Phase 3)*
- `csharp-godot` — C# conventions, GodotSharp API
- `csharp-signals` — C# signal patterns
