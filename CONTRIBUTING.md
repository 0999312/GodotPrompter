# Contributing to GodotPrompter

Thanks for your interest in contributing! GodotPrompter is an open-source skills framework for Godot 4.x. Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before participating. Here's how to add skills and improve existing ones.

## Adding a New Skill

### 1. Create the skill folder

```
skills/<skill-name>/
  SKILL.md          # Required — main skill document
  *.md              # Optional — supporting references
```

Use **kebab-case** for folder names (e.g., `my-new-skill`).

### 2. Write SKILL.md with frontmatter

Every `SKILL.md` must start with YAML frontmatter:

```yaml
---
name: my-new-skill
description: Use when [specific trigger] — [brief scope]
---
```

- `name` must match the folder name
- `description` should start with "Use when" to help agents decide when to load it

### 3. Structure your content

Follow this general structure:

1. **Title and intro** — What this skill covers, when to use it
2. **Related skills** — `> **Related skills:** **skill-a** for X, **skill-b** for Y.`
3. **Numbered sections** — Each major concept or pattern
4. **Code examples** — GDScript first, then C# equivalent
5. **Checklist** — Implementation checklist at the end

### 4. Code examples

- Include **both GDScript and C#** where applicable
- GDScript comes first, C# follows
- Use ` ```gdscript ` and ` ```csharp ` language tags (never `gd` or `cs`)
- Target **Godot 4.3+** APIs only — no deprecated methods
- Follow Godot style: snake_case for GDScript, PascalCase for C#

### 5. Cross-references

Add a related skills line after the intro paragraph:

```markdown
> **Related skills:** **event-bus** for decoupled communication, **component-system** for composition patterns.
```

Keep to 3-5 references max. Only link genuinely related skills.

## Improving Existing Skills

- Fix incorrect API references or deprecated methods
- Add missing C# examples where GDScript-only
- Add cross-references to related skills
- Expand checklist items
- Fix typos or unclear wording

## Testing Skills

Before submitting:

1. **Read through** — Does the skill make sense for someone new to Godot?
2. **Try the code** — Open Godot 4.3+ and verify examples compile and run
3. **Check C# parity** — Every GDScript example should have a C# equivalent (unless language-specific)
4. **Verify cross-refs** — Referenced skills must exist

## Adding Agents

Agent definitions go in `agents/<agent-name>.md` with YAML frontmatter:

```yaml
---
name: my-agent
description: |
  When to use this agent, with examples.
model: inherit
---

Agent system prompt goes here.
```

## Releasing a New Version

When publishing a new version (e.g., v1.4.1):

1. **Make changes** in the GodotPrompter repo, commit, push
2. **Update version** in these files:
   - `.claude-plugin/plugin.json` → `"version": "1.4.1"`
   - `.cursor-plugin/plugin.json` → `"version": "1.4.1"`
   - `gemini-extension.json` → `"version": "1.4.1"`
   - `package.json` → `"version": "1.4.1"`
   - `CHANGELOG.md` → add `## [1.4.1]` section
3. **Commit and tag:**
   ```bash
   git add .claude-plugin/plugin.json .cursor-plugin/plugin.json gemini-extension.json package.json CHANGELOG.md
   git commit -m "chore: bump version to 1.4.1"
   git tag -a v1.4.1 -m "v1.4.1 — description of changes"
   git push origin master --tags
   ```
4. **Create GitHub release:**
   ```bash
   gh release create v1.4.1 --title "v1.4.1 — GodotPrompter" --notes "Release notes here"
   ```
5. **Install via local clone:**
   ```bash
   claude plugins marketplace add ./GodotPrompter
   claude plugins install godot-prompter@godot-prompter
   ```

Users update with:
```bash
cd /path/to/GodotPrompter && git pull     # pull latest fork changes
# then restart the agent session
```

## Conventions

- Skills must be self-contained and independently useful
- One skill per folder under `skills/`
- GDScript follows [Godot style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- C# follows [Godot C# conventions](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_style_guide.html)
- Target Godot 4.3+ minimum
- YAML frontmatter is required on every SKILL.md

## Questions?

Open an issue on GitHub or check existing skills for examples of the expected format.
