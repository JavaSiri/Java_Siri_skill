---
name: triage
description: 通过分类角色驱动的状态机对 issue 进行分类处理。当用户想要创建 issue、对 issue 进行分类、审核传入的 bug 或功能需求、为 AFK agent 准备 issue，或管理 issue 工作流时使用。
---

# 分类（Triage）

将项目 issue tracker 上的 issue 通过一个小型状态机流转到不同的分类角色状态。

在分类过程中发布到 issue tracker 的每条评论或 issue **必须**以如下声明开头：

```
> *这是分类过程中由 AI 生成的。*
```

## 参考文档

- [AGENT-BRIEF.md](AGENT-BRIEF.md) — 如何撰写持久的 agent 简报
- [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md) — `.out-of-scope/` 知识库的工作原理

## 角色

两个**类别**角色：

- `bug` — 有东西坏了
- `enhancement` — 新功能或改进

五个**状态**角色：

- `needs-triage` — 需要维护者评估
- `needs-info` — 等待报告者提供更多信息
- `ready-for-agent` — 已完全明确，可交给 AFK agent 处理
- `ready-for-human` — 需要人工实现
- `wontfix` — 不会处理

每个经过分类的 issue 应携带**恰好一个**类别角色和一个状态角色。如果状态角色存在冲突，在做任何操作之前先标记并询问维护者。

这些是规范的角色名称 —— issue tracker 中实际使用的标签字符串可能不同。映射关系应该在之前就提供给你了 —— 如果没有，运行 `/setup-matt-pocock-skills`。

状态流转：未打标签的 issue 通常首先进入 `needs-triage`；从那里可以流转到 `needs-info`、`ready-for-agent`、`ready-for-human` 或 `wontfix`。一旦报告者回复，`needs-info` 会回到 `needs-triage`。维护者可以随时覆盖 —— 如果流转看起来异常，标记并询问后再继续。

## 调用方式

维护者调用 `/triage` 并用自然语言描述需求。理解请求并执行。示例：

- "展示所有需要我关注的内容"
- "看一下 #42"
- "将 #42 移至 ready-for-agent"
- "有哪些可以交给 agent 处理的？"

## 展示需要关注的内容

查询 issue tracker 并将结果分为三类，按时间顺序（最旧的在前）：

1. **未打标签** — 从未经过分类的
2. **`needs-triage`** — 评估进行中的
3. **`needs-info` 且报告者有新活动的** — 需要重新评估

每类显示数量和每个 issue 的一行摘要。让维护者选择。

## 对特定 issue 进行分类

1. **收集上下文。** 阅读完整的 issue（正文、评论、标签、报告者、日期）。解析之前的分类记录，避免重复询问已解决的问题。探索代码库，使用项目的领域词汇表，遵守所在区域的 ADR。阅读 `.out-of-scope/*.md`，并呈现与该 issue 相似的历史驳回记录。

2. **给出建议。** 告知维护者类别和状态建议及理由，并附上与 issue 相关的代码库摘要。等待指示。

3. **复现（仅限 bug）。** 在任何追问之前，尝试复现：阅读报告者的步骤，追踪相关代码，运行测试或命令。报告结果 —— 成功复现并找到代码路径、复现失败、或细节不足（这是强烈的 `needs-info` 信号）。确认可复现的 bug 能产出强得多的 agent 简报。

4. **追问（如需要）。** 如果 issue 需要补充细节，执行 `/grill-with-docs` 会话。

5. **应用结果：**
   - `ready-for-agent` — 发布一条 agent 简报评论（参见 [AGENT-BRIEF.md](AGENT-BRIEF.md)）。
   - `ready-for-human` — 使用与 agent 简报相同的结构，但注明为什么不能委托（需要判断、外部访问、设计决策、手动测试）。
   - `needs-info` — 发布分类记录（模板见下方）。
   - `wontfix`（bug）— 礼貌解释，然后关闭。
   - `wontfix`（enhancement）— 写入 `.out-of-scope/`，在评论中附上链接，然后关闭（参见 [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md)）。
   - `needs-triage` — 应用角色。如有部分进展，可选择添加评论。

## 快速状态覆盖

如果维护者说"将 #42 移至 ready-for-agent"，相信他们并直接应用角色。确认你将要做的事（角色变更、评论、关闭），然后执行。跳过追问。如果没有经过追问会话就移至 `ready-for-agent`，询问是否要撰写 agent 简报。

## Needs-info 模板

```markdown
## 分类记录

**目前已确认的内容：**

- 要点 1
- 要点 2

**我们仍然需要你 (@报告者) 提供的内容：**

- 问题 1
- 问题 2
```

将在追问中确认的所有内容记录在"目前已确认的内容"下，以免工作丢失。问题必须具体且可操作，不能是"请提供更多信息"这类笼统表述。

## 恢复之前的会话

如果 issue 上存在之前的分类记录，先阅读这些记录，检查报告者是否已回答任何待处理问题，在继续之前呈现更新后的全貌。不要重复询问已解决的问题。
