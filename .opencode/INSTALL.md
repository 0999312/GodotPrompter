# Installing GodotPrompter for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add godot-prompter to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["godot-prompter@git+https://github.com/jame581/GodotPrompter.git"]
}
```

Restart OpenCode. That's it — the plugin auto-installs and registers all skills.

Verify by asking: "What Godot skills are available?"

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load godot-prompter/state-machine
```

## Updating

GodotPrompter updates automatically when you restart OpenCode.

To pin a specific version:

```json
{
  "plugin": ["godot-prompter@git+https://github.com/jame581/GodotPrompter.git#v1.0.0"]
}
```

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i godot`
2. Verify the plugin line in your `opencode.json`
3. Make sure you're running a recent version of OpenCode

### Tool mapping

When skills reference Claude Code tools:
- `TodoWrite` → `todowrite`
- `Task` with subagents → `@mention` syntax
- `Skill` tool → OpenCode's native `skill` tool
- File operations → your native tools

## Getting Help

Report issues: https://github.com/jame581/GodotPrompter/issues
