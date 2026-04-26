# Skill Template v2 — GodotPrompter

Standardized template for GodotPrompter SKILL.md files. New skills MUST follow this template. Existing skills SHOULD migrate when updated.

---

## Frontmatter

Every SKILL.md starts with YAML frontmatter:

```yaml
---
name: skill-name                       # must match folder name, kebab-case
description: Use when [trigger] — [brief scope]
godot_version: "4.3+"                  # minimum Godot version
status: stable                         # stable | beta | draft
last_validated: "2026-04-27"           # date of last real-world verification
agent_tested_on: ["claude-4-5-opus"]   # models this skill was tested against
---
```

---

## Body Template

```markdown
---
name: example-skill
description: Use when [trigger] — [brief scope]
godot_version: "4.3+"
status: stable
last_validated: "2026-04-27"
agent_tested_on: []
---

# Skill Title in Godot 4.3+

[Short intro — 1-3 sentences about what this skill covers, when to use it.]

> **Related skills:** **skill-a** for X, **skill-b** for Y.
>
> **Addon Override:** `addon-name` provides full/partial coverage — see `docs/ADDON_REGISTRY.md`. *(remove line if no addon overrides this skill)*
>
> **Interface Contract:** When co-loaded with `skill-a`, delegate [X] to skill-a; do NOT implement [X] here. *(remove line if no co-load contracts defined)*

---

## Success Criteria

When implementing this pattern, the result MUST satisfy:

1. **[Criterion name]**: [Verifiable condition]
   - **GUT test**: `assert_eq(...)` or equivalent verification method
2. **[Criterion name]**: [Verifiable condition]
   - **GUT test**: [how to verify]
3. **[Criterion name]**: [Verifiable condition]
   - **GUT test**: [how to verify]

> Every criterion must be verifiable by a GUT test or a deterministic code inspection. Remove this hint line in actual skill content.

---

## Decision Points

**🛑 Pause and ask the user before proceeding:**

1. **[Decision title]**: "[What to ask the user]"
   - Options: [Option A] for [scenario], [Option B] for [scenario]
   - Recommend: [Recommended option] for most projects
2. **[Decision title]**: "[What to ask the user]"
   - Options: [Option A], [Option B], [Option C]
   - Recommend: [Recommended option]

> Every decision point should be a choice the user must make, not the agent. Remove this hint line in actual skill content.

---

## 1. [Section Title]

[Implementation content — patterns, code examples, explanations.]

### GDScript

```gdscript
# Code example
```

### C#

```csharp
// Code example
```

---

## N. Common Agent Mistakes

| # | Mistake | Why it's wrong | Correct approach |
|---|---------|---------------|------------------|
| 1 | [Mistake description] | [Explanation of consequences] | [How to do it right] |
| 2 | [Mistake description] | [Explanation of consequences] | [How to do it right] |

> Include mistakes specific to this domain that AI agents frequently make. Draw from: AGENTS.md Prohibited Patterns, real bug reports, and community issue tracker. Remove this hint line in actual skill content.

---

## N+1. Addon Override

When the project has [addon-name] installed:

| Addon | Coverage Type | Usage Guidance |
|-------|--------------|----------------|
| `addon-a` | Full replacement | Use addon's API instead of patterns below |
| `addon-b` | Partial (covers [sub-domain]) | Use addon for [sub-domain]; use skill patterns for rest |
| `addon-c` | Complementary | Use addon alongside patterns below (see notes) |

**Conflict warning**: `addon-a` and `addon-b` cannot be used together for [domain].

> Remove this entire section if no known addon overrides this skill domain. Keep per-skill even if info already exists in ADDON_REGISTRY.md — this is the quick-reference for the agent while the skill is loaded.

---

## N+2. Self-Verification

After generating code, run this verification loop. Fix any failures before reporting completion.

### Automated checks (agent runs without user)

- [ ] **[Check name]**: [How to check — grep pattern, script, or GUT test]
- [ ] **[Check name]**: [How to check]

### Manual checks (agent reviews code, reports to user)

- [ ] **[Check name]**: [What to look for]
- [ ] **[Check name]**: [What to look for]

### Behavioral checks (user must test in Godot)

- [ ] **GUT test**: [Test scenario description]
  - Run: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/skill_verification -gprefix=<prefix> -gexit`
- [ ] **Play test**: [Describe specific play test scenario]

> See `docs/SELF_VERIFICATION_GUIDE.md` for complete protocol details. Remove this hint line in actual skill content.

---

## N+3. Implementation Checklist

- [ ] [Checklist item]
- [ ] [Checklist item]
```

---

## Section Reference Summary

| Section | Required | Purpose |
|---------|----------|---------|
| YAML frontmatter | ✅ Always | Metadata for skill discovery |
| Title + Intro | ✅ Always | First contact with agent |
| Related skills | ✅ Always | Cross-reference navigation |
| Addon Override line | ✅ When applicable | Runtime plugin awareness |
| Interface Contract line | ✅ When co-loaded | Cross-skill conflict prevention |
| Success Criteria | ✅ Always | Declarative success definition — agent self-verification |
| Decision Points | ✅ Always | Human-in-the-loop for architecture choices |
| Code Patterns | ✅ Always | The core implementation content |
| Common Agent Mistakes | ✅ Always | Domain-specific antipatterns |
| Addon Override section | ✅ When applicable | Full details for addon-aware implementation |
| Self-Verification | ✅ Always | Verification loop — automated + manual + behavioral |
| Implementation Checklist | ✅ Always | Simple final confirmation |
