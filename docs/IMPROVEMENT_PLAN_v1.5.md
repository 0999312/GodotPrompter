# GodotPrompter v1.5.0 — Improvement Plan

This document records the complete improvement plan for GodotPrompter v1.5.0, covering Process, Skill Structure, Agent Behavior, and Testing changes.

---

## Motivation

Based on analysis of LLM Agent programming patterns (Dec 2025+), the project addresses the following gaps:

| Gap | Resolution |
|-----|-----------|
| Skills are imperative (how) but lack declarative goals (what) | Success Criteria section |
| Agents make conceptual errors unique to each domain | Common Agent Mistakes section |
| Agents do not pause for user decisions | Decision Points section |
| Agents cannot self-validate their output | Self-Verification loop with GUT + Godot headless |
| Runtime plugin awareness missing | Addon Discovery step + ADDON_REGISTRY.md |
| Requirement ambiguity not detected | Requirement Validation step (Step 0) |

---

## Revised Workflow (AGENTS.md)

```
Step 0:    Requirement Validation
Step 0.5:  Addon Discovery & Override
Step 1:    Load the matching Skill
Step 2:    Understand existing code
Step 3:    Scene-first principle
Step 4:    UI framework constraints
Step 5:    Agent dispatch
Step 6:    Post-generation validation
Step 7:    Full-Depth Self-Verification (NEW)
```

---

## Pilot Skills (Phase 1)

Six skills selected for initial migration:

| Skill | Rationale | Key Additions |
|-------|-----------|---------------|
| `state-machine` | Most complex decision tree; 3 FSM patterns | Success Criteria per pattern; Decision Points at pattern selection |
| `player-controller` | Highest usage frequency | Interface Contract with state-machine; physics-correct criteria |
| `event-bus` | Subtle memory leak & lifecycle errors | Common Mistakes around signal connection lifetime |
| `resource-pattern` | Shared vs copied semantic confusion | Common Mistakes: make_unique vs duplicate |
| `scene-organization` | Foundational architecture errors cascade | Common Mistakes: % vs $, owner semantics |
| `godot-code-review` | Already has Error-Prone Patterns table | Upgrade to full template; add Self-Verification |

---

## Deliverables by Phase

### Phase 0 — Template & Standards

- `docs/SKILL_TEMPLATE_v2.md` — new skill template
- `docs/ADDON_REGISTRY.md` — centralized addon → skill mapping
- `docs/SELF_VERIFICATION_GUIDE.md` — full-depth verification protocol
- `docs/IMPROVEMENT_PLAN_v1.5.md` — this document
- `CONTRIBUTING.md` — updated with new template requirements
- `CLAUDE.md` — updated SKILL.md Format section
- `AGENTS.md` — added Step 0, Step 0.5, Step 7
- `skills/using-godot-prompter/SKILL.md` — updated

### Phase 1 — Pilot Skills (6)

Each skill gets: Success Criteria + Decision Points + Common Mistakes + Addon Override + Self-Verification

### Phase 2 — Agent Files (3)

- `godot-game-dev` — Pre-Implementation Protocol (req check + addon scan)
- `godot-game-architect` — Requirement Validation Protocol + Decision Protocol
- `godot-code-reviewer` — Requirement Compliance + Self-Verification check

### Phase 4 — Testing

- Updated test plan for new steps and sections

---

## Per-Skill Migration Checklist

When migrating any existing skill to v2 template:

- [ ] Add `godot_version`, `status`, `last_validated`, `agent_tested_on` to frontmatter
- [ ] Add `## Success Criteria` — 3-6 verifiable criteria with GUT test references
- [ ] Add `## Decision Points` — 1-3 architecture decisions requiring user input
- [ ] Move existing anti-patterns into `## Common Agent Mistakes` table
- [ ] Add `## Addon Override` if applicable
- [ ] Add `## Self-Verification` with automated/manual/behavioral checks
- [ ] Add/update `## Implementation Checklist`
- [ ] Add `Addon Override:` and `Interface Contract:` lines below Related skills
- [ ] Verify code examples still compile on Godot 4.3+

---

## Version

- **Plan version**: 1.0
- **Target release**: v1.5.0
- **Status**: In implementation

*This file is maintained by GodotPrompter. Last updated: 2026-04-27.*
