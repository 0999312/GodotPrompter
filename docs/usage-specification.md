# GodotPrompter 使用规范

**Version:** 1.4.1-fork
**适用:** 任意 Godot 4.x 项目（GDScript / C#）

---

## 1. 概述

GodotPrompter 为 AI 编程助手提供 Godot 4.x 领域专精技能（skills）和 3 个专业代理（agents）。本项目（0999312/GodotPrompter）是原始 jame581/GodotPrompter 的 fork。

### 核心架构

```
AGENTS.md                    # 入口 — 加载引导 skill + 工作流程规约
├─ skills/using-godot-prompter/  # 引导 skill（技能目录、平台映射）
├─ skills/<44 domain skills>/   # 领域技能（SKILL.md）
└─ agents/
  ├─ godot-game-architect.md    # 系统架构师代理
  ├─ godot-game-dev.md          # 实现开发代理
  └─ godot-code-reviewer.md     # 代码审查代理
```

---

## 2. 外部项目集成方式

### 2.1 复制 AGENTS.md（推荐）

将本仓库的 `AGENTS.md` 复制到目标 Godot 项目的根目录。

AGENTS.md 内部通过 `@./skills/...` 引用本仓库的文件。集成时需要确保 `skills/` 和 `agents/` 目录对运行时可见。推荐方式：

**方式 A — Git Submodule（推荐）**
```bash
# 在目标项目根目录
git submodule add https://github.com/0999312/GodotPrompter.git .godot-prompter
```
然后 AGENTS.md 中的路径需要调整为 `.godot-prompter/skills/...`（参见下方 2.2 自定义）。

**方式 B — 符号链接**
```bash
# Windows (PowerShell)
New-Item -ItemType Junction -Path "./skills" -Target "/path/to/GodotPrompter/skills"
New-Item -ItemType Junction -Path "./agents" -Target "/path/to/GodotPrompter/agents"
```

**方式 C — 复制内容**
直接将 `AGENTS.md`、`skills/`、`agents/` 三个目录复制到目标项目根目录，然后按需修改 AGENTS.md 引用路径。

### 2.2 自定义 AGENTS.md

复制后将 AGENTS.md 中的路径前缀改为实际位置：

```markdown
# 如果使用 submodule 放在 .godot-prompter/ 下
@./.godot-prompter/skills/using-godot-prompter/SKILL.md
@./.godot-prompter/skills/using-godot-prompter/references/copilot-tools.md

# 然后修改 Agent 文件路径
| 代码实现 | `./.godot-prompter/agents/godot-game-dev.md` |
```

### 2.3 平台配置

#### OpenCode.ai

在 `opencode.json` 中添加：

```json
{
  "plugin": ["godot-prompter@git+https://github.com/0999312/GodotPrompter.git"]
}
```

OpenCode 会自动将 `AGENTS.md` 作为系统提示注入。如果集成到目标项目中，需确保 AGENTS.md 位于项目根目录。

**OpenCode 的 Agent 局限：** OpenCode 的 `task` 工具仅支持 `subagent_type: "explore"` 和 `"general"`，不支持自定义 agent 类型。因此 AGENTS.md 中的 Step 5 规定：主模型必须先用 `Read` 工具加载 agent 文件，然后直接遵循其指令。

#### Claude Code

```bash
claude plugins marketplace add ./GodotPrompter
claude plugins install godot-prompter@godot-prompter
```

Claude Code 原生支持自定义 agent 类型，可以直接通过 `Task` 工具 + agent name 调派。

#### GitHub Copilot CLI

```bash
copilot plugin marketplace add ./GodotPrompter
copilot plugin install godot-prompter@godot-prompter
```

Copilot CLI 的 `task` 工具行为与 OpenCode 类似，需使用 `Read` agent 文件的方式。

#### Cursor

在项目根目录放置 `.cursor-plugin/plugin.json`（参见本仓库的 `.cursor-plugin/plugin.json`），或者直接复制 `skills/` 目录到项目。

#### Gemini CLI

```bash
gemini extensions install https://github.com/0999312/GodotPrompter
```

Gemini 加载 `GEMINI.md` 作为入口文件（内容与 AGENTS.md 同构）。

---

## 3. Agent 调用规范

### 3.1 原生支持的环境（Claude Code）

`task` 工具直接指定 subagent_type：

```
task:
  description: "Implement player controller"
  subagent_type: "godot-game-dev"    # 直接使用 agent 名
  prompt: "..."
```

### 3.2 非原生支持的环境（OpenCode / Copilot CLI / Cursor / Codex / Gemini）

由于 `task` 工具的 `subagent_type` 仅支持有限类型，采用以下替代方案：

**方案 A — 主模型直接执行（推荐）**
```
1. Read agents/godot-game-dev.md  ← 先加载 agent 指令
2. 在回答中执行 agent 指令内容   ← 主模型按 agent 规则工作
```

**方案 B — 使用 task 工具但手动注入**
```
task:
  subagent_type: "general"
  prompt: |
    Read ./agents/godot-game-dev.md first.
    Then follow its instructions to implement: [任务描述]
```

**方案 C — 按阶段分工**
```
阶段 1：先 Read agents/godot-game-architect.md  → 设计架构
阶段 2：再 Read agents/godot-game-dev.md       → 编写代码
阶段 3：最后 Read agents/godot-code-reviewer.md → 审查代码
```

### 3.3 Agent 职责矩阵

| Agent | 适用场景 | 前置 skill | 输入要求 | 输出产物 |
|-------|---------|-----------|---------|---------|
| `godot-game-architect` | 新功能设计、场景树规划、信号架构、模式选择 | 对应领域 skill | 需求描述、现有代码 | 场景树草图、信号图、实现计划 |
| `godot-game-dev` | 功能实现、bug 修复、系统搭建 | 对应领域 skill | 设计文档或需求 | GDScript/C# 代码、场景配置 |
| `godot-code-reviewer` | 代码审查、质量检查 | `godot-code-review` | 待审查代码 | 审查报告（含严重等级） |

---

## 4. 项目自定义指南

### 4.1 UI 框架适配

如果项目使用了特定 UI 框架（如 UIManager、PanelStack 等），修改 AGENTS.md 的 Step 4：

```markdown
## Step 4: UI framework constraints

本项目使用 UIManager 框架：
- 所有面板继承 `res://ui/base/UIPanel.gd`
- 通过 `UIManager.open_panel("panel_name")` 打开
- 在 `res://ui/registry.gd` 中注册面板
- 禁止手动 `.visible` 控制面板
```

### 4.2 场景优先策略

根据项目类型调整 Step 3：

```markdown
## Step 3: Scene-first principle

本项目使用 Resource 预加载策略：
- UI 面板全部预制在 `res://ui/panels/` 中
- 动态列表使用 `ItemList` + 更新数据而不是重新创建
- 弹幕/粒子效果允许使用 instantiate()
```

### 4.3 命名约定

```markdown
## Project Conventions

- 文件名：snake_case（GDScript）/ PascalCase（C#）
- 节点路径：优先使用 `%UniqueName`
- 信号：过去式命名（`door_opened`）
- 私有方法/变量：`_` 前缀
```

---

## 5. 故障排查

### 技能加载失败

```
问题：skill 工具返回 "Unknown skill"
原因：skills/ 目录未正确配置
解决：
1. 检查 AGENTS.md 中的 @./skills/... 路径是否存在
2. 如果使用 submodule，路径应为 @./.godot-prompter/skills/...
3. 验证 skill 目录下存在 SKILL.md
```

### Agent 文件无法读取

```
问题：Read agents/godot-game-dev.md 返回 "File not found"
原因：agents/ 目录缺失或路径错误
解决：
1. 确认 agents/ 目录存在于项目根目录
2. 如果使用 submodule，路径应为 .godot-prompter/agents/
3. 检查 AGENTS.md 中 agent 路径是否与实际情况匹配
```

### OpenCode 插件不加载

```
问题：OpenCode 启动后 GodotPrompter 技能不可用
原因：opencode.json 配置问题
解决：
1. 确认 opencode.json 中有 "plugin" 数组
2. 确认 plugin 值格式正确
3. 尝试 restart OpenCode
4. 检查版本：opencode --version
```

### Claude Code marketplace 未安装

```
问题：claude plugins install godot-prompter@godot-prompter 失败
原因：本地 marketplace 未注册
解决：
claude plugins marketplace add ./GodotPrompter
# 然后重新执行 install
```

---

## 6. 外部项目 Checklist

在目标项目中部署 GodotPrompter 后，验证以下项目：

- [ ] AGENTS.md 位于项目根目录
- [ ] AGENTS.md 中的 `@./skills/...` 路径正确
- [ ] AGENTS.md 中 Step 4 自定义了项目的 UI 框架
- [ ] 通过 `skill` 工具可以列出技能
- [ ] `Read agents/godot-game-dev.md` 可以正常加载
- [ ] OpenCode .opencode.json 或对应平台配置正确

---

## 7. 版本兼容性

| GodotPrompter 版本 | Godot 版本 | GDScript | C# | 技能数 |
|-------------------|-----------|---------|-----|-------|
| v1.4.1-fork | 4.3+ (strict: 4.4+ / 4.6.2) | ✓ | ✓ | 44 |
| v1.4.0 | 4.3+ | ✓ | ✓ | 44 |
| v1.3.0 | 4.3+ | ✓ | ✓ | 41 |
| v1.0.0 | 4.3+ | ✓ | ✓ | 32 |

---

*本规范文件随 GodotPrompter 项目维护，开源发布于 MIT License。*
