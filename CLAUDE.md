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

## Documentation Files

Key documents:

- `docs/SKILL_TEMPLATE_v2.md` — Required template for all new skills
- `docs/ADDON_REGISTRY.md` — Addon → skill domain coverage mapping
- `docs/SELF_VERIFICATION_GUIDE.md` — Full-depth self-verification protocol
- `docs/IMPROVEMENT_PLAN_v1.5.md` — Current improvement plan
- `docs/usage-specification.md` — External project integration guide

## Repository Structure

```
skills/                     # 44 domain-specific skill folders
  <skill-name>/
    SKILL.md                # Main skill document (YAML frontmatter required)
    *.md                    # Optional supporting references
agents/                     # 3 specialized agent definitions
  godot-game-architect.md   # System design and architecture planning
  godot-game-dev.md         # Feature implementation guided by skills
  godot-code-reviewer.md    # Code review against Godot best practices
commands/                   # Slash commands (reserved)
docs/superpowers/           # Design specs and implementation plans
  plans/                    # Phase implementation plans
  specs/                    # Design specification documents
tests/agent-integration/    # Agent test plan and results
.claude-plugin/             # Claude Code plugin manifest
.cursor-plugin/             # Cursor plugin manifest
.codex/                     # Codex install instructions
.opencode/                  # OpenCode plugin loader + install guide
```

## SKILL.md Format

Every skill must start with YAML frontmatter:

```yaml
---
name: skill-name
description: Use when [trigger] — [brief scope]
godot_version: "4.3+"
status: stable          # stable | beta | draft
last_validated: "YYYY-MM-DD"
agent_tested_on: ["model-a", "model-b"]
---
```

Followed by:
1. Title and intro
2. Related skills line + Addon Override line + Interface Contract line
3. **Success Criteria** — 3-6 verifiable criteria (declarative goals)
4. **Decision Points** — Architecture choices requiring user input
5. Numbered sections with patterns and examples
6. **Common Agent Mistakes** — Domain-specific antipatterns table
7. **Addon Override** — section for known addon interactions
8. **Self-Verification** — automated + manual + behavioral checks
9. **Implementation checklist** at the end

New skills MUST follow the v2 template (`docs/SKILL_TEMPLATE_v2.md`). Existing skills SHOULD migrate when updated.

## Agent Format

Agent definitions in `agents/<name>.md` use YAML frontmatter:

```yaml
---
name: agent-name
description: |
  When to use, with <example> blocks.
model: inherit
---
```

## Addon Registry

Addon → skill domain mappings are maintained in `docs/ADDON_REGISTRY.md`. When adding a new addon entry:

1. Verify the addon works with Godot 4.3+
2. Classify coverage: Full / Partial / Complementary
3. Document the activation API
4. Note conflicts with other addons

## Version Management

Current version: check `package.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `gemini-extension.json` (must all match).

When releasing:
1. Update version in `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `gemini-extension.json`, `package.json`, `CHANGELOG.md`
2. Commit, tag (`v<version>`), push with tags
3. Create GitHub release

## Code Style

- GDScript: follow [Godot style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) — snake_case functions/variables, PascalCase classes
- C#: follow [Godot C# conventions](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_style_guide.html) — PascalCase methods matching Godot API
- Target Godot 4.3+ minimum — no deprecated methods
- All code examples must compile and run in Godot 4.3+

## Testing

Before merging skill changes:
1. Read through the skill for clarity
2. Verify code examples compile and run in Godot 4.3+
3. Ensure C# parity for every GDScript example (unless language-specific)
4. Verify cross-referenced skills exist
5. Run agent integration tests from `tests/agent-integration/TEST_PLAN.md` for significant changes
