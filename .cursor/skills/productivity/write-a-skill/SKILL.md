---
name: write-a-skill
description: 创建新的 agent skill，包含正确的结构、渐进式展开和配套资源。当用户想要创建、编写或构建新 skill 时使用。
---

# 如何编写 Skill

## 流程

1. **收集需求** - 向用户确认：
   - skill 覆盖什么任务/领域？
   - 需要处理哪些具体场景？
   - 需要可执行脚本还是仅需要指令？
   - 是否需要附带参考资料？

2. **起草 skill** - 创建：
   - SKILL.md（必填），指令简洁
   - 额外参考文件（内容超过 500 行时）
   - 工具脚本（需要确定性操作时）

3. **与用户评审** - 展示草稿并确认：
   - 是否覆盖了你的使用场景？
   - 是否有遗漏或不清楚的地方？
   - 各章节是否需要调整详略？

## Skill 结构

```
skill-name/
├── SKILL.md           # 主指令（必填）
├── REFERENCE.md       # 详细文档（可选）
├── EXAMPLES.md        # 使用示例（可选）
└── scripts/           # 工具脚本（可选）
    └── helper.js
```

## SKILL.md 模板

```md
---
name: skill-name
description: 简短描述能力。Use when [触发条件]。
---

# Skill 名称

## Quick start

[最小可用示例]

## Advanced features

[进阶内容，链接到独立文件：参见 [REFERENCE.md](REFERENCE.md)]
```

## Description 写作规范

description 是**唯一会被 agent 看到的内容**，用于决定是否加载该 skill。它会和其他 skill 的 description 一起出现在系统提示词中。

**目标**：让 agent 能判断：

1. 这个 skill 提供什么能力
2. 何时/为何触发它（触发关键词、使用场景、文件类型）

**格式要求**：

- 最多 1024 字符
- 第三人称
- 第一句：能力是什么
- 第二句：触发条件（"Use when [具体触发条件]"）

**好的例子**：

```
从 PDF 文件提取文本和表格，填写表单，合并文档。Use when 处理 PDF 文件或提到 PDF、表单、文档提取时。
```

**坏的例子**：

```
帮助处理文档。
```

坏例子无法让 agent 将它与其他文档类 skill 区分开。

## 何时添加脚本

当以下情况出现时，添加工具脚本：

- 操作是确定性的（校验、格式化）
- 同一段代码会被反复生成
- 错误需要明确的处理逻辑

脚本比生成代码节省 tokens，且更可靠。

## 何时拆分文件

满足以下任一条件时，拆分到独立文件：

- SKILL.md 超过 100 行
- 内容涉及不同领域（如金融 schema vs 销售 schema）
- 进阶功能很少用到
- 存在多步骤流程编排（应抽离为 `.cursor/workflows/` 下的 workflow 文件）

## 评审检查清单

起草完成后，逐一核对：

- [ ] description 包含触发条件（"Use when..."）
- [ ] SKILL.md 控制在 100 行以内
- [ ] 无时间敏感信息
- [ ] 术语一致
- [ ] 包含具体示例
- [ ] 引用层级不超过一层
