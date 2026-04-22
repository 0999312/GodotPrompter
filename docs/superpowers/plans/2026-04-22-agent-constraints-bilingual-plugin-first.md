# Agent Constraints Update Progress / Agent 约束更新进度

## English (Primary)

### Scope
- Add new constraints to relevant project agents so they preserve plugin-first behavior, enforce bilingual reference outputs, and require bilingual progress docs after implementation.

### Completed
- Updated `agents/godot-game-dev.md` with:
  - Plugin-first documentation and implementation priority rules.
  - Conflict resolution rule: plugin docs override skill guidance on conflicts.
  - Bilingual documentation output rules (English first, Chinese second).
  - Process updates that place plugin-doc reading before skill loading.
- Updated `agents/godot-game-architect.md` with:
  - Plugin-first architecture/design rules.
  - Plugin-native solution preference over generic best-practice alternatives.
  - Bilingual output requirements for reference docs and progress docs.
  - Process order updated to plugin docs first, then skills.
- Updated `agents/godot-code-reviewer.md` with:
  - Plugin-first review baseline.
  - Review rule that respects plugin conventions when they differ from generic best practices.
  - Bilingual review/progress artifact requirements.
  - Review process reordered: plugin docs -> code-review skill -> domain skills -> review.

### Constraint Mapping
- Constraint 1 (plugin priority): implemented in all three agent files under `Priority Rules` and process steps.
- Constraint 2 (bilingual reference docs, EN first): implemented in all three agent files under `Documentation Output Rules`.
- Constraint 3 (post-implementation bilingual progress doc): implemented in all three agent files under `Documentation Output Rules`.

### Verification
- Confirmed the three relevant agent definitions exist in `agents/` and were updated in place.
- Confirmed no change was made that removes existing plugin-priority behavior; new rules reinforce it.

## 中文（镜像）

### 范围
- 为本项目相关 agent 增加新约束，确保保持插件优先原则、强制参考文档双语输出，并在实现完成后输出双语进度文档。

### 已完成
- 已更新 `agents/godot-game-dev.md`：
  - 增加插件文档优先与插件能力优先实现规则。
  - 增加冲突处理规则：插件文档与 skill 指引冲突时，插件文档优先。
  - 增加双语文档输出规则（英文在前，中文在后）。
  - 调整流程顺序为先读插件文档，再读技能文档。
- 已更新 `agents/godot-game-architect.md`：
  - 增加插件优先的架构/设计规则。
  - 明确优先推荐插件原生方案，其次再用通用最佳实践。
  - 增加参考文档与进度文档双语输出要求。
  - 调整流程顺序为插件文档优先，其后技能文档。
- 已更新 `agents/godot-code-reviewer.md`：
  - 增加代码评审的插件优先基线。
  - 明确当插件规范与通用最佳实践不同步时，应优先遵循插件规范。
  - 增加评审产物与进度文档双语输出要求。
  - 调整评审流程顺序：插件文档 -> 代码评审技能 -> 领域技能 -> 评审。

### 约束映射
- 约束 1（插件优先）：已在三个 agent 文件的 `Priority Rules` 与流程步骤中落实。
- 约束 2（参考文档双语且英文优先）：已在三个 agent 文件的 `Documentation Output Rules` 中落实。
- 约束 3（实现后双语进度文档）：已在三个 agent 文件的 `Documentation Output Rules` 中落实。

### 验证
- 已确认 `agents/` 下三个相关 agent 定义文件存在并完成原位更新。
- 已确认未破坏现有插件优先逻辑，新增规则为增强而非替换。
