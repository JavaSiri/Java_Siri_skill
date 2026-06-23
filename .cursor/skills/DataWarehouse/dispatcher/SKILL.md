---
name: dispatcher
description: 从 Ticket 列表按 task_type 分发到对应开发 workflow。当用户说「处理 Ticket」或需要从 Ticket 列表进入开发流程时触发。
---

# Ticket 分发器

## 分发步骤

### Step 1: 读取 Ticket 列表

> 前提：无

读取 `.cursor/tickets/` 目录，扫描所有 `.md` 文件的 frontmatter 元数据。

```
1. 检查 .cursor/tickets/ 目录是否存在
2. 读取目录下所有 .md 文件的 frontmatter 元数据
3. 按以下优先级过滤：
   → 如果用户指定了 Ticket 编号，精确匹配
   → 否则返回所有 status != 'done' 的 Ticket
4. 返回 Ticket 编号 + 标题 + 任务类型 + 状态
```

**读取清单格式**：

```
已读取：.cursor/tickets/ 目录
已扫描 Ticket 数量：N
待处理 Ticket：
  - {编号} [{任务类型}] [{状态}]：{标题}
  - ...
```

> 如果目录不存在或无 Ticket 文件，提示用户：「未找到 Ticket 记录。请先通过 to_issues 将需求拆解为 Ticket。」

### Step 2: 确定分发目标

> 前提：Step 1 Ticket 列表已输出

根据 Ticket 数量确定分发行为：

```
用户指定了 Ticket 编号：
  → 仅分发该 Ticket，进入 Step 3

用户未指定 Ticket 编号：
  → 列出所有待处理 Ticket（status != 'done'）
  → 询问用户选择要处理的 Ticket（或选择「处理全部」）
  → 等待用户选择后，进入 Step 3
```

### Step 3: 按任务类型分发

> 前提：Step 2 已确定目标 Ticket

根据目标 Ticket 的 `task_type` 字段分发到对应 Workflow：

```
task_type == "新建开发"
  → 分发至「[新建开发] 流程」
  → 读取 .cursor/workflows/Datawarehouse/new-dev.mdc

task_type == "调整开发"
  → 分发至「[调整开发] 流程」
  → 读取 .cursor/workflows/Datawarehouse/modify-dev.mdc

task_type == "转译开发"
  → 分发至「[转译开发] 流程」
  → 读取 .cursor/workflows/Datawarehouse/translate-dev.mdc

task_type == "代码审查"
  → 分发至「[代码审查] 流程」
  → 读取 .cursor/workflows/Datawarehouse/code-review.mdc
```

### Step 4: 读取对应 Workflow

> 前提：Step 3 分发结果已输出

```
使用 Read 工具读取对应的 workflow 文件（路径见上方分发结果）。
Workflow 文件中已包含完整的步骤编排。
后续步骤严格遵循 workflow 文件中定义的前提条件与输出要求。
```

---

## Workflow 文件索引

| 流程 | 文件路径 | 前置输入 |
|------|---------|---------|
| 代码审查 | `.cursor/workflows/Datawarehouse/code-review.mdc` | Ticket + 语法类型 |
| 新建开发 | `.cursor/workflows/Datawarehouse/new-dev.mdc` | Ticket + 语法类型 |
| 调整开发 | `.cursor/workflows/Datawarehouse/modify-dev.mdc` | Ticket + 语法类型 |
| 转译开发 | `.cursor/workflows/Datawarehouse/translate-dev.mdc` | Ticket + 源/目标语法类型 |

---

> 提示：每次进入 workflow 后，**禁止跳过其中任何 Step**，读取清单是进入下一步的唯一凭证。
