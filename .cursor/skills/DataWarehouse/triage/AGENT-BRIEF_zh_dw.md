# 撰写数据仓库 Agent 简报

当 issue 流转到 `ready-for-agent` 时，在 issue 下发布一条结构化的简报（Agent Brief），作为 AFK agent 工作的权威规范。原始 issue 正文和讨论只是背景——Agent 简报才是合同。

## 原则

### 持久性优于精确性

Issue 可能在 `ready-for-agent` 中停留数天甚至数周，期间代码库会发生变化。编写简报时要考虑这些文件可能被重命名、迁移或重构。

- **应当**描述接口、数据类型和行为契约
- **应当**指明需要修改的表、字段、指标、分区策略
- **不要**引用文件路径——它们会过时
- **不要**引用行号
- **不要**假设当前实现结构会保持不变

### 行为导向，而非流程导向

描述**系统应该做什么**，而不是**如何实现**。Agent 会重新探索代码库并自行决定实现方式。

- **好：** "日活（DAU）指标应按用户首次活跃日期进行归因，而非事件日期"
- **差：** "在 `dws_user_daily_stats` 表的第 150 行修改 `dt` 字段的使用逻辑"

### 完整的验收标准

Agent 需要知道何时算完成。每个简报必须包含具体、可测试的验收标准。每条标准应可独立验证。

- **好：** "分区 `pt=20260101` 下 `active_users` 字段值与上游 `dwd_user_action` 独立核算值一致"
- **差：** "数据要准确"

### 明确的范围边界

说明哪些不在范围内。这能防止 Agent 过度发挥或对相邻功能做出假设。

## 模板

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** 一句话描述需要做什么

**Current behavior:**
描述当前发生了什么。Bug 则描述错误行为；Enhancement 则描述现状。

**Desired behavior:**
描述完成工作后应该发生什么。对边界条件和异常情况要具体。

**Key data assets:**
- 涉及的源表 / ODS 表及字段
- 涉及的中间层表（DWD/DWS）及字段
- 涉及的目标表（ADS）及字段
- 相关的指标口径或数据质量规则

**Acceptance criteria:**
- [ ] 具体、可测试的验收标准 1
- [ ] 具体、可测试的验收标准 2
- [ ] 具体、可测试的验收标准 3

**Out of scope:**
- 不应被修改或处理的内容
- 可能看起来相关但实际独立的内容
```

## 示例

### 好的 Agent 简报（Bug）

```markdown
## Agent Brief

**Category:** bug
**Summary:** DAU 指标在跨日数据回刷时未正确去重

**Current behavior:**
当对历史分区（如 `pt=20260101`）进行数据回刷时，`dws_user_daily_active` 表中的 DAU 数值与 `dwd_user_action` 分区独立核算值不一致。回刷分区被重复累加到结果中。

**Desired behavior:**
无论以何种顺序回刷历史分区，`dws_user_daily_active` 中每个分区的 DAU 值应与 `dwd_user_action` 中对应分区的去重用户数完全一致。

**Key data assets:**
- `dwd_user_action` — 源明细表，`dt` 分区字段，用户粒度的行为记录
- `dws_user_daily_active` — 结果表，`pt` 分区字段，存储每日活跃用户数
- 口径定义：DAU = count(distinct user_id) 按事件日期归一化到自然日

**Acceptance criteria:**
- [ ] `pt=20260101` 分区下 `dws_user_daily_active.active_users` = `dwd_user_action` 中 `dt=20260101` 分区去重用户数
- [ ] 依次回刷 `pt in (20260101, 20260102, 20260103)` 后，各分区结果与独立核算值一致
- [ ] 重复回刷同一分区不导致数据膨胀

**Out of scope:**
- 修改 `dwd_user_action` 的上游 ETL 逻辑
- 历史累计 DAU（如 30 日滚动 DAU）的计算口径变更
```

### 好的 Agent 简报（Enhancement）

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** 新增"商品类目维度"到销售汇总宽表

**Current behavior:**
`ads_sale_daily_summary` 表仅支持按地区（`region_code`）和渠道（`channel`）维度聚合日销售数据，缺少商品类目维度。

**Desired behavior:**
在 `ads_sale_daily_summary` 表中新增 `category_level1`、`category_level2` 两列，按商品一级类目和二级类目进行销售汇总。新维度的口径与现有地区、渠道维度保持一致。

**Key data assets:**
- `dwd_product_info` — 商品信息表，包含 `category_level1`、`category_level2` 字段
- `dwd_order_detail` — 订单明细表，通过 `product_id` 与商品表关联
- `ads_sale_daily_summary` — 目标汇总宽表，新增分区字段

**Acceptance criteria:**
- [ ] 新增字段 `category_level1`、`category_level2` 可正常写入，类型与 `region_code` 一致
- [ ] 历史分区（近 30 天）重新计算后，汇总结果与明细表独立核算一致
- [ ] 新维度不影响现有 `region_code`、`channel` 维度的数据准确性

**Out of scope:**
- 新增商品三级类目维度
- 修改汇总表的分区策略（现有按 `dt` 分区保持不变）
- 指标扩展（如新增客单价、连带率等）
```

### 差的 Agent 简报

```markdown
## Agent Brief

**Summary:** 修复 DAU 计算问题

**What to do:**
DAU 数据不准。看一下 ads_sale_daily_summary 表和相关脚本，
找到问题修复。涉及的文件在 jobs/ 目录下，大概在第 150 行左右。

**Files to change:**
- jobs/dws/daily_active.sql（第 150 行）
- jobs/dwd/user_action.sql（第 42 行）
```

差的原因：
- 无 Category
- 描述模糊（"DAU 数据不准"）
- 引用了文件路径和行号，会过时
- 无验收标准
- 无范围边界
- 无当前行为与期望行为的对比
