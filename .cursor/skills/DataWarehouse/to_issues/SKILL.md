---
name: to_issues
description: 将数据仓库开发计划拆解为独立可交付的 Ticket，使用垂直切片方法（ODS→DWD→DWS→ADS 全链路覆盖）。适用于需求澄清后将计划落地为具体开发任务的场景。
---

# To Issues

将数据仓库开发计划拆解为独立可交付的 Ticket，每个 Ticket 是一个**垂直切片**，按 task_type 分层拆分，各层独立判断开发类型。

---

## 术语定义

| 术语 | 含义 |
|------|------|
| **垂直切片** | 按 task_type 拆分的独立交付单元，各层独立判断开发类型，Ticket 之间通过 blocked_by 建立依赖关系 |
| **HITL** | Human In The Loop — 需要人工决策（业务口径、架构选择、回刷范围等）后方可推进 |
| **AFK** | Away From Keyboard — 无需人工干预，可直接开发并交付 |
| **ODS** | Operational Data Store，原始数据层 |
| **DWD** | Data Warehouse Detail，业务明细层 |
| **DWS** | Data Warehouse Summary，主题汇总层 |
| **ADS** | Application Data Service，应用服务层（报表/下游） |

---

## 工作流程

### Step 1: 获取父需求

读取 `to_prd` skill，检查对应需求的 PRD 是否已存在：

```
skill: to_prd
检查目标: 当前需求的 PRD 是否已持久化到 .cursor/issues/ 目录

如果 PRD 存在：
  → 读取完整 PRD 内容，作为权威上下文
  → 进入 Step 2

如果 PRD 不存在：
  → 以 table-requirement-analyzer 的澄清结论作为权威上下文
  → 进入 Step 2
```

### Step 2: 探索现有代码库和知识库（必须）

> 前提：Step 1 已确定权威上下文（PRD 或澄清结论）

**此步必须执行，不得跳过。**

从以下两个维度了解情况：

- **代码库**：检查各层表是否存在、字段是否齐全（用于判断新建 / 调整 / 无变更）
  - ODS 层：数据源入湖情况，是否已有原始表
  - DWD 层：现有事实表，是否包含所需字段
  - DWS 层：现有汇总表，是否包含所需指标
  - ADS 层：现有报表表，是否已存在
- **知识库**：检查 `.cursor/knowledge/` 下的口径定义、指标定义（用于口径对齐，避免重复定义）

> **判断目标**：为本步骤 3 起草切片提供依据——各层是新建 / 调整 / 无变更。

### Step 3: 起草垂直切片

将计划拆解为**垂直切片**。每个切片遵循以下原则：

- 切片之间按 **task_type 分组**，同一种 task_type 可全链路（ODS→ADS），也可仅覆盖必要层
- 一个完成的切片，其数据**可查询/报表可出数**
- 优先**多个薄切片**，而非少量厚切片

**切片拆分规则**（核心修正）：

按层级分别判断 task_type，生成对应 Ticket：

| 各层行为 | 拆分策略 | Ticket 数量 |
|---------|---------|------------|
| 某层需要 DDL 变更（加/删/改字段） | 该层生成「调整开发」Ticket | 1+ |
| 某层需要新建表（首次入湖/新建主题表/新建报表） | 该层生成「新建开发」Ticket | 1+ |
| 某层需要 Pgsql → Hive 语法转换 | 该层生成「转译开发」Ticket | 1+ |
| 某层无变更（引用已有表/字段充足） | 不生成该层的 Ticket | 0 |

**依赖关系**：
- 上游层的 Ticket 未完成前，下游层不得开始（单向依赖）
- 调整开发 Ticket 必须在新建开发 Ticket 之前完成（字段先就绪）

**典型拆分示例**：

```
需求：DWS 表字段不足，ADS 表不存在
├─ Ticket A（调整开发）→ DWD 无变更，DWS 新增字段
└─ Ticket B（新建开发，blocked_by: Ticket A）→ ADS 新建表
```

切片分类：

- **HITL**：需要人工决策方可推进，例如：
  - 字段口径定义模糊，需要业务方确认
  - 涉及分区策略变更，需要架构评审
  - 历史数据回刷范围不明确，需要数据治理决策
  - 跨层依赖表尚未建设，需要等上游就绪
- **AFK**：可直接开发交付，无需人工介入

### Step 4: 用户确认切片方案

以编号列表展示切片方案，每个切片包含：

- **标题**：简短描述性名称
- **按层 task_type**：每个覆盖层级的任务类型（见下方决策规则）
- **类型**：HITL / AFK
- **阻塞于**：哪些其他切片需先完成
- **覆盖的垂直层级**：ODS / DWD / DWS / ADS（仅列出有实际变更的层）
- **覆盖的需求点**：对应需求文档中的哪些条目

**任务类型决策规则（按层判断）**：

```
对每个层级分别判断：
1. 该层涉及目标表的 DDL 变更（加字段/删字段/改字段类型）→ 该层为「调整开发」
2. 该层涉及 Pgsql → Hive 语法转换 → 该层为「转译开发」
3. 该层是新表首次开发（ODS 入湖 / DWD 事实表 / DWS 汇总 / ADS 报表）→ 该层为「新建开发」
4. 该层无变更（引用已有表/字段充足）→ 该层不生成 Ticket

合并规则：
- 同一切片内，若所有有变更的层 task_type 相同 → 合并为 1 个 Ticket
- 同一切片内，若有变更的层 task_type 不同 → 按 task_type 拆分为多个 Ticket
```

**切片确认表示例**：

```
切片 1
- 标题：DWD 层事实表扩字段
- 按层 task_type：DWD → 调整开发，DWS → 无变更，ADS → 无变更
- 类型：AFK
- 阻塞于：无
- 覆盖层级：DWD

切片 2
- 标题：CLV 核心指标报表新建
- 按层 task_type：DWD → 无变更，DWS → 调整开发（扩字段），ADS → 新建开发
- 类型：HITL
- 阻塞于：切片 1（需等 DWS 字段就绪）
- 覆盖层级：DWS, ADS
```

询问用户：

- 粒度是否合适？（太粗 / 太细）
- 依赖关系是否正确？
- 是否需要合并或拆分？
- HITL 和 AFK 标注是否准确？
- 各层 task_type 判断是否正确？

迭代确认，直到用户批准切片方案。

### Step 5: 输出 Ticket 文档

将每个已批准的切片输出为一个 Ticket，使用下方模板。按依赖顺序输出（阻塞项在前），便于后续按顺序处理。

### Step 6: 持久化 Ticket

将每个 Ticket 写入 `.cursor/tickets/` 目录下的独立文件。

**文件命名规则**：

```
.cursor/tickets/{父需求编号}-TASK-{切片序号}-{切片标题简写}.md
```

例如：`RdyDW-CLV-01-TASK-01-clv-core-metrics.md`

**文件头部元数据**（YAML frontmatter）：

```yaml
---
id: {父需求编号}-TASK-{切片序号}
parent: {PRD-ID | clarification-record-{timestamp}}
title: {切片标题}
task_type: 新建开发 | 调整开发 | 转译开发
status: pending | in_progress | done | blocked
layers: ODS, DWD, DWS, ADS  # 仅列出有实际变更的层
layer_task_types:            # 按层标注 task_type
  ods: 新建开发 | 无变更
  dwd: 调整开发 | 新建开发 | 无变更
  dws: 调整开发 | 新建开发 | 无变更
  ads: 调整开发 | 新建开发 | 无变更
hitl: true | false
blocked_by: []
created_at: {ISO 8601 时间戳}
updated_at: {ISO 8601 时间戳}
---
```

> **parent 字段语义**：优先填写 PRD ID（格式如 `RdyDW-PRD-CLV-01`）。若需求未经 `to_prd`，则填写 `clarification-record-{timestamp}`，表示来源为 table-requirement-analyzer 的澄清结论。
> **Ticket 状态说明**：
> - `pending`：待处理
> - `in_progress`：开发中
> - `done`：已完成验收
> - `blocked`：被其他 Ticket 阻塞

---

## Ticket 读取规范（供 skill-selector 使用）

当 skill-selector 需要读取 Ticket 列表时，按以下顺序查找：

```
1. 检查 .cursor/tickets/ 目录是否存在
2. 读取目录下所有 .md 文件的 frontmatter 元数据
3. 按以下优先级过滤：
   → 如果用户指定了 Ticket 编号，精确匹配
   → 否则返回所有 status != 'done' 的 Ticket（默认列表）
4. 返回 Ticket 编号 + 标题 + 任务类型 + 状态，供分发决策
```

**读取清单格式**：

```
已读取：.cursor/tickets/ 目录
已扫描 Ticket 数量：N
待处理 Ticket：{编号} {标题} [{任务类型}] [{状态}]
```

---

## Ticket 模板

```markdown
---
id: {父需求编号}-TASK-{切片序号}
parent: {PRD-ID | clarification-record-{timestamp}}
title: {切片标题}
task_type: 新建开发 | 调整开发 | 转译开发
status: pending
layers: ODS, DWD, DWS, ADS  # 仅列出有实际变更的层
layer_task_types:            # 按层标注 task_type
  ods: 新建开发 | 无变更
  dwd: 调整开发 | 新建开发 | 无变更
  dws: 调整开发 | 新建开发 | 无变更
  ads: 调整开发 | 新建开发 | 无变更
hitl: true | false
blocked_by: []
created_at: {ISO 8601 时间戳}
updated_at: {ISO 8601 时间戳}
---

## 父需求

关联的 PRD ID（格式如 `RdyDW-PRD-CLV-01`），或 `clarification-record-{timestamp}`（来自 table-requirement-analyzer 澄清结论）。

## 做什么

简洁描述这个垂直切片的端到端行为，按层级描述而非逐层实现。

## 按层任务类型

各层的开发类型：

| 层级 | 任务类型 | 说明 |
|------|---------|------|
| ODS | 新建开发 / 无变更 | |
| DWD | 调整开发 / 新建开发 / 无变更 | |
| DWS | 调整开发 / 新建开发 / 无变更 | |
| ADS | 调整开发 / 新建开发 / 无变更 | |

## 覆盖的层级

仅列出有实际变更的层级（无变更的层级不列出）：

- [ ] ODS（如有 DDL 变更或新表入湖）
- [ ] DWD（如有 DDL 变更或新建事实表）
- [ ] DWS（如有 DDL 变更或新建汇总表）
- [ ] ADS（如有 DDL 变更或新建报表表）

## 指标定义（如有）

| 指标名称 | 计算口径 | 数据类型 |
|---------|---------|---------|
| xxx | xxx | BIGINT |

## 字段定义

| 字段名 | 来源表.字段 | 说明 |
|-------|-----------|------|
| stat_date | - | 统计日期，分区键 |
| xxx_sk | dwd_xxx_di.xxx_sk | xxx维外键 |
| xxx_name | dim_xxx.xxx_name | xxx名称 |

## 数据质量检查

- [ ] 数据量波动检查（与 T-1 对比，阈值 ±20%）
- [ ] 空值检查（关键字段无 NULL）
- [ ] 去重检查（主键无重复）
- [ ] 枚举值检查（如有枚举字段）

## 验收标准

- [ ] ETL 任务成功执行，无报错
- [ ] 数据可查询，分区可见
- [ ] 数据质量检查全部通过
- [ ] 报表/下游可正常引用

## 阻塞条件

- 列出阻塞此 Ticket 的前置 Ticket（如有）
- 如无阻塞，写"无 — 可立即开始"

## 备注

- 技术选型说明（如有）
- 潜在风险点（如有）
```

---

## 实施纪律

### 垂直切片原则

1. **按层分型**：各层 task_type 独立判断，DDL 变更优先交付，ADS 新建依赖下游字段就绪
2. **切片之间保持低耦合**：一个切片的变更不应强制要求另一个切片重做
3. **AFK 优先**：尽可能将人工决策范围收敛到最小，剩余部分均为 AFK
4. **薄切片优先**：宁可多拆一个 Ticket，不要堆砌成一个巨型 Ticket
5. **顺序依赖**：调整开发 Ticket 必须在新建开发 Ticket 之前完成

### Ticket 持久化纪律

1. **每个切片对应一个文件**：不允许将多个切片合并到一个 .md 文件
2. **frontmatter 必须完整**：id / task_type / status 是分发器的必读字段，不得省略
3. **status 必须及时更新**：进入开发时改为 in_progress，完成时改为 done，阻塞时改为 blocked
4. **文件不可删除**：历史 Ticket 文件保留，即使 done 后依然可追溯

### 常见错误

| 错误 | 正确做法 |
|------|---------|
| 所有层塞进一个 Ticket | 按 task_type 分层拆分 Ticket |
| 切片粒度过粗（一个 Ticket 包含 10 张表） | 拆细，每个切片 1-3 张表 |
| 将 HITL 标记为 AFK | 诚实标注，人工决策未拿到就不开工 |
| 忽略数据质量验收标准 | 每个切片都必须包含 DQ 检查项 |
| 跳过 Ticket 持久化步骤 | 每个切片必须写入 .cursor/tickets/ 目录 |
| ADS 新建 Ticket 排在调整开发 Ticket 之前 | 调整开发先完成，ADS 依赖其字段就绪 |

---

## 与 to-issues 的核心差异

| 方面 | to-issues（前端） | to_issues（数据仓库） |
|------|------------------|--------------------------|
| 分层模型 | schema / API / UI / tests | ODS / DWD / DWS / ADS |
| 交付物 | 可演示的功能 | 可查询的数据 / 可出数的报表 |
| HITL 常见原因 | 架构决策、设计评审 | 口径确认、分区策略、回刷范围 |
| 验证方式 | 功能测试、demo | 数据质量检查、SQL 执行结果 |
| Issue 格式 | user stories | 指标定义、字段血缘 |
| 持久化 | GitHub Issues / Jira | .cursor/tickets/ 目录 + frontmatter |
