# Contributing to GodotPrompter

Thanks for your interest in contributing! GodotPrompter is an open-source skills framework for Godot 4.x. Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before participating. Here's how to add skills and improve existing ones.

**All new skills MUST follow the v2 template.** See `docs/SKILL_TEMPLATE_v2.md` for the complete specification. Existing skills SHOULD migrate to the v2 template when updated (see Migration Checklist below).

## Adding a New Skill

### 1. Create the skill folder

```
skills/<skill-name>/
  SKILL.md          # Required — main skill document (v2 template)
  *.md              # Optional — supporting references
```

Use **kebab-case** for folder names (e.g., `my-new-skill`).

### 2. Write SKILL.md with frontmatter (v2 required)

Every `SKILL.md` must start with YAML frontmatter:

```yaml
---
name: my-new-skill
description: Use when [specific trigger] — [brief scope]
godot_version: "4.3+"                  # minimum target Godot version
status: stable                          # stable | beta | draft
last_validated: "2026-04-27"            # date of last real-world verification
agent_tested_on: ["claude-4-5-opus"]    # models tested against
---
```

- `name` must match the folder name
- `description` should start with "Use when" to help agents decide when to load it
- `godot_version`, `status`, `last_validated`, `agent_tested_on` are required

### 3. Structure your content (v2 template)

Follow the v2 template structure:

1. **Title and intro** — What this skill covers, when to use it
2. **Related skills** + **Addon Override** + **Interface Contract** lines
3. **Success Criteria** — 3-6 verifiable criteria (declarative goals)
4. **Decision Points** — Architecture choices requiring user input
5. **Numbered sections** — Each major concept or pattern with code examples
6. **Common Agent Mistakes** — Domain-specific antipatterns table
7. **Addon Override** — Section for known addon interactions
8. **Self-Verification** — Automated + manual + behavioral checks
9. **Implementation Checklist** — Final confirmation

See `docs/SKILL_TEMPLATE_v2.md` for the complete template with all sections.

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
>
> **Addon Override:** `addon-name` provides full/partial coverage — see `docs/ADDON_REGISTRY.md`.
>
> **Interface Contract:** When co-loaded with `skill-a`, delegate [X] to skill-a.
```

Keep to 3-5 skill references max. Only link genuinely related skills. Remove addon/interface lines if not applicable.

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
5. **Verify Success Criteria** — Each criterion should be verifiable (GUT test or deterministic inspection)
6. **Verify Common Mistakes** — Each mistake should be a real error an AI agent could make, not generic advice

### Addon Registry Contributions

When adding a new addon to `docs/ADDON_REGISTRY.md`:

1. Verify the addon works with Godot 4.3+
2. Classify coverage type: Full / Partial / Complementary
3. Document the activation API (how the agent calls the addon)
4. Note any conflicts with other addons
5. Add the addon to related skill's frontmatter `agent_tested_on` if integration was verified

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

## Migration Checklist (Existing Skills to v2 Template)

When updating an existing skill to the v2 template:

- [ ] Add `godot_version`, `status`, `last_validated`, `agent_tested_on` to frontmatter
- [ ] Add `## Success Criteria` — 3-6 verifiable criteria with GUT test references
- [ ] Add `## Decision Points` — 1-3 architecture decisions requiring user input
- [ ] Move existing anti-patterns into `## Common Agent Mistakes` table format
- [ ] Add `## Addon Override` if any known addon covers this domain
- [ ] Add `## Self-Verification` with automated/manual/behavioral checks
- [ ] Add/update `## Implementation Checklist`
- [ ] Add `Addon Override:` and `Interface Contract:` lines below Related skills
- [ ] Verify code examples still compile on Godot 4.3+

## Full-Depth Self-Verification

When a skill includes GUT test generation in its Self-Verification, the test must:

1. Be placed at `res://tests/skill_verification/<skill>-<criterion>.gd`
2. Use `extends GutTest`
3. Cover each Success Criterion with at least one `assert_*` call
4. Be runnable via `godot --headless` with GUT CLI
5. Be left in the project after passing (not deleted)

See `docs/SELF_VERIFICATION_GUIDE.md` for the complete protocol.

## Questions?

Open an issue on GitHub or check `docs/SKILL_TEMPLATE_v2.md` for the complete template reference.
