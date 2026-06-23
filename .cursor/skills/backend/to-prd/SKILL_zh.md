---
name: to-prd
description: 将当前对话上下文转化为 PRD 并发布到项目 issue tracker。当用户想从当前上下文创建 PRD 时使用。
---

这个 skill 接收当前对话上下文和代码库理解，产出 PRD。**不要**去访谈用户 —— 直接综合你已经知道的内容。

Issue tracker 和分类标签词汇应该在之前就提供给你了 —— 如果没有，运行 `/setup-matt-pocock-skills`。

## 流程

1. 如果还没有，探索代码库以理解当前状态。在整个 PRD 中使用项目的领域词汇表，并尊重所在区域的 ADR。

2. 勾勒出你将用来测试这个功能的接缝（seams）。优先使用已有接缝，而非新建。尽可能使用高层次的接缝。如果需要新接缝，在你能做到的**最高点**提出。

   与用户确认这些接缝是否符合他们的预期。

3. 使用下方模板撰写 PRD，然后发布到项目 issue tracker。添加 `ready-for-agent` 分类标签 —— 不需要额外的分类。

<prd-template>

## Problem Statement

用户面临的问题，从用户的视角出发。

## Solution

问题的解决方案，从用户的视角出发。

## User Stories

一份**详尽**的编号用户故事列表。每条用户故事格式如下：

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

这份用户故事列表应当极其详尽，覆盖功能的各个方面。

## Implementation Decisions

已做出的实现决策列表。包括：

- 将要构建/修改的模块
- 将要修改的模块接口
- 开发者的技术说明
- 架构决策
- Schema 变更
- API 契约
- 特定交互

**不要**包含具体文件路径或代码片段。它们可能很快就会过时。

例外：如果原型产生的代码片段比文字描述更精确地表达了某个决策（状态机、reducer、schema、类型形状），可以将其内联到相关决策中，并简要注明它来自原型。只保留决策密集的部分 —— 不是可运行的 demo，只是重要的部分。

## Testing Decisions

已做出的测试决策列表。包括：

- 什么样的测试是好的测试的描述（只测外部行为，不测实现细节）
- 哪些模块将被测试
- 测试的先例（即代码库中类似类型的测试）

## Out of Scope

此 PRD 范围之外的事项说明。

## Further Notes

关于此功能的任何其他说明。

</prd-template>
