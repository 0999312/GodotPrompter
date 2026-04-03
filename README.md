# GodotPrompter

Agentic skills framework for Godot 4.x game development. Gives AI coding agents domain-specific expertise for GDScript and C# Godot projects.

## What is this?

GodotPrompter is a plugin that provides **skills** — structured domain knowledge that AI agents load on demand. When you ask your agent to "add a state machine" or "set up multiplayer", it loads the relevant GodotPrompter skill and follows Godot-specific best practices instead of relying on generic knowledge.

## Supported Platforms

| Platform | Status |
|----------|--------|
| Claude Code | Primary |
| GitHub Copilot CLI | Supported |
| Gemini CLI | Supported |
| Codex | Supported |
| Cursor | Supported |
| OpenCode | Community |

## Installation

### Claude Code

```bash
claude plugins add godot-prompter
```

### Other Platforms

See platform-specific setup files:
- Copilot CLI: Uses `AGENTS.md` automatically
- Gemini CLI: Uses `GEMINI.md` automatically
- Codex: See `.codex/INSTALL.md`
- OpenCode: See `.opencode/INSTALL.md`
- Cursor: Add skills to `.cursorrules`

## Skill Categories

- **Core / Process** — Project setup, brainstorming, code review, debugging, testing
- **Architecture & Patterns** — Scene organization, state machines, signals, composition
- **Gameplay Systems** — Player controllers, inventory, dialogue, save/load, AI, cameras
- **UI/UX** — Control nodes, themes, responsive layouts, HUD
- **Multiplayer** — RPCs, synchronization, dedicated servers
- **Build & Deploy** — Export pipelines, optimization, addon development
- **C# Specific** — C# conventions, signal patterns

## Getting Started

Once installed, invoke skills by name when working on a Godot project:

### Examples

**"Set up a new Godot project"** — triggers `godot-project-setup`

**"Write tests for my health component"** — triggers `godot-testing`

**"Review this GDScript for issues"** — triggers `godot-code-review`

**"I need a platformer player controller"** — triggers `player-controller`

**"Add a state machine to my enemy"** — triggers `state-machine`

**"How should I organize my scene tree?"** — triggers `scene-organization`

**"Implement save/load for my game"** — triggers `save-load`

Skills provide the agent with Godot-specific patterns, code examples, and checklists so it follows best practices instead of generic advice.

## Contributing

See `CLAUDE.md` for contributor guidelines. Each skill is a self-contained folder under `skills/` with a `SKILL.md` file and optional supporting documents.

## License

MIT
