---
name: to-prd
description: 将数据仓库需求转化为业务 PRD 并发布到项目 issue tracker。它是数据仓库需求的**唯一权威入口**——所有 Ticket 必须从 PRD 拆出。PRD 只描述业务需求和用户价值，**不涉及数仓实现决策**（由 to_issues 独立判断）。
---

这个 skill 接收当前对话上下文和代码库理解，产出数据仓库领域的 PRD。**不要**去访谈用户 —— 直接综合你已经知道的内容。

Issue tracker 和分类标签词汇应该在之前就提供给你了 —— 如果没有，运行 `/setup-matt-pocock-skills`。

## 流程

1. **了解项目上下文**（轻量，非必须）：如有需要，了解：
   - 所在区域的 ADR
   - 已有口径和指标库（在 `.cursor/knowledge/` 下）

   > **注意**：涉及哪些层、是否需要新建表，由 `to_issues` 在读取代码库后判断。

2. **勾勒验证切入点**：与用户确认从哪些角度可以验证功能正确性，例如：
   - 原始数据是否正确接入
   - 业务逻辑处理是否与预期一致
   - 指标计算结果是否符合口径
   - 报表/下游是否能正常消费

   > **注意**：具体在哪层（DWD / DWS / ADS）验证由 `to_issues` 拆 Ticket 时确定，此步仅与用户确认验证思路。

3. **撰写 PRD 并发布**：使用下方模板撰写 PRD，发布到 `.cursor/issues/` 目录，添加 `ready-for-agent` 分类标签。

<prd-template>

## 问题陈述

用户面临的问题，从用户的视角出发。

## 需求范围

描述需要满足的业务需求边界，不描述技术实现方式。

> **约束**：此章节描述"要什么"（WHAT），不描述"怎么做"（HOW）。涉及哪些层、是否新建表，由 `to_issues` 在读取代码库后独立判断。

## 用户故事

一份**详尽**的编号用户故事列表。每条用户故事格式如下：

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a data analyst, I want to see daily active users by region, so that I can analyze user engagement trends
</user-story-example>

这份用户故事列表应当极其详尽，覆盖功能的各个方面。

## 实现决策

> **此章节已废弃。** 实现决策（涉及哪些层、DDL 变更、ETL 逻辑）由 `to_issues` 在读取代码库实际表结构后确定，不在 PRD 阶段决策。
>
> PRD 只描述业务需求和用户价值，拆 Ticket 时的技术判断由 `to_issues` 负责。

## 测试决策

已做出的测试决策列表。包括：

- 什么样的测试是好的测试（只测数据结果，不测实现细节）
- 需要验证的业务口径
- 数据质量检查的关注点（空值、去重、数据量波动、口径一致性）
- 先例（代码库中类似功能的测试方式）

> **注意**：具体在哪层（DWD / DWS / ADS）验证、验证哪张表，由 `to_issues` 在拆 Ticket 时确定。

## 范围之外

此 PRD 范围之外的业务边界说明：

- 暂不满足的业务场景
- 暂不接入的数据源
- 暂不满足的性能/时效要求

## 进一步说明

关于此功能的任何其他说明。

</prd-template>

---

## PRD 命名规范

**文件命名**：

```
.cursor/issues/{项目编号}-PRD-{序号}-{标题简写}.md
```

例如：`RdyDW-PRD-CLV-01-clv-board.md`

**frontmatter id**：

```
id: {项目编号}-PRD-{序号}
```

例如：`id: RdyDW-PRD-CLV-01`

> **命名语义**：
> - `PRD-` 前缀标识需求层（区别于 Ticket）
> - `parent` → Ticket 层：填 PRD ID（如 `RdyDW-PRD-CLV-01`）
> - 文件名排序后，PRD 与其子 Ticket 自然相邻

---

## Skill 关系定位

```
对话/需求 → to-prd（业务需求）→ PRD 文档 → to_issues（技术落地）→ Ticket → skill-selector → workflow
```

| Skill | 职责 |
|-------|------|
| `to-prd` | 需求入口，只聚焦业务需求和用户价值，不涉及数仓实现决策 |
| `to_issues` | 读取代码库实际表结构，按层判断 task_type，拆 Ticket |

> **关键约束**：不经过 `to-prd` 的需求不得进入 `to_issues` 拆 Ticket。
