# GodotPrompter — Contributor Guidelines

## Project Overview

GodotPrompter is an open-source agentic skills framework for Godot 4.x game development, supporting both GDScript and C#. It provides domain-specific skills that AI coding agents load on demand for Godot-specific guidance.

## Supported Platforms

- Claude Code (primary — tool names are canonical)
- GitHub Copilot CLI
- Gemini CLI
- Codex
- Cursor
- OpenCode

## Conventions

- Skills use Claude Code tool names as the canonical reference
- Each platform has a tool mapping file in `skills/using-godot-prompter/references/`
- Skill files use kebab-case naming: `skills/<skill-name>/SKILL.md`
- YAML frontmatter is required on every SKILL.md: `name`, `description`
- GDScript examples follow Godot style guide (snake_case, PascalCase for classes)
- C# examples follow Godot C# conventions (PascalCase methods, matching Godot API)
- Target Godot 4.x API only

## Skill Authoring

- One skill per folder under `skills/`
- `SKILL.md` is required, supporting `*.md` files are optional
- Skills must be self-contained and independently useful
- Include both GDScript and C# examples where applicable
- Test skills against real Godot projects before merging
