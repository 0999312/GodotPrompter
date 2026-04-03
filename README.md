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

## Contributing

See `CLAUDE.md` for contributor guidelines. Each skill is a self-contained folder under `skills/` with a `SKILL.md` file and optional supporting documents.

## License

MIT
