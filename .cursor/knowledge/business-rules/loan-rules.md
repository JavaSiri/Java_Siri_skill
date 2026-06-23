# 支用环节业务规则（Loan Rules）

> **所属分类**：[业务规则](../README.md) - 业务环节 → 支用
> **覆盖范围**：支用申请生命周期内的状态认定 + 支用场景下的分流类型 + 陪跑标记
> **关联文件**：[credit-rules.md](./credit-rules.md)（授信环节） · [analytics.md](./analytics.md)（跨环节度量）

本文件聚焦**支用环节**的所有业务规则，定义"什么算支用通过、什么算额度首次成功支用、什么算额度首次支用申请、支用场景下的分流类型怎么定、陪跑标记怎么标记"。

---

## 章节索引

| # | 业务术语 | 英文标识 | 核心判定 |
|---|---------|---------|---------|
| 1 | [支用通过](#1-支用通过loan-passed) | `loan_passed` | 支用状态 = 通过 + 数据有效 |
| 2 | [首次成功支用](#2-首次成功支用first-successful-loan) | `first_successful_loan` | 额度首笔通过支用（按申请时间） |
| 3 | [首次支用申请](#3-首次支用申请first-loan-application) | `first_loan_application` | 额度首笔支用申请（不论结果） |
| 4 | [分流类型（支用场景）](#4-分流类型支用场景diversion-type) | `diversion_type` | 1=晋商/华通；2=嵩海 |
| 5 | [陪跑标记](#5-陪跑标记accompany-flag) | `if_sh_flag` | 1=陪跑；0=非陪跑（仅嵩海分流有效） |

---

## 1. 支用通过（Loan Passed）

> **业务术语**：指有效的支用申请中，支用状态为通过的支用申请。
> **英文标识**：`loan_passed`
> **DWD 字段**：`dwd_fact_loan_application_di.loan_status = '1'`

### 业务定义

一笔支用（借款）申请被认定为"**支用通过**"，**必须同时满足**以下条件：

| 条件 | 判定规则 | 字段来源 |
|------|---------|---------|
| ① 支用状态为通过 | `loan_status = '1'` | `ttsp_it.dwd_fact_loan_application_di` |
| ② 数据有效 | `is_active = 'Y'`（拉链当前有效记录） | `dwd_fact_loan_application_di` |

> ⚠️ 注意区分"**支用通过**"与"**放款成功**"：
> - **支用通过**：借款申请审批通过，可能未实际放款
> - **放款成功**：实际放款到账，参见 `dwd_fact_loan_application_di.loan_repayment_time IS NOT NULL`
>
> 通常报表上"支用通过"用 `loan_status='1'` 即可，但"放款金额"需结合 `loan_repayment_time` 或 `actual_amount`。

### 字段字典引用

| 状态码 | 含义 | 是否算"支用通过" |
|--------|------|-----------------|
| 1 | 通过 | ✅ 是 |
| 0 | 拒绝 | ❌ 否 |
| 2 | 失败 | ❌ 否 |
| 3 | 其他（处理中等中间态） | ❌ 否 |

字段详情参见 [`dwd_fact_loan_application_di.md`](../../schema/DWD/fields/dwd_fact_loan_application_di.md)。

### 适用场景

| 场景 | 是否使用本定义 | 典型应用 |
|------|--------------|----------|
| 支用通过客户数 | ✅ | `dws_customer_by_level_daily_di.loan_pass_customer_num` |
| 支用通过笔数 | ✅ | `dws_loan_application_daily_count_di.loan_pass_num` |
| 支用通过率 | ✅ | 通过笔数 / 申请笔数 |
| 支用通过额度 | ✅ | `dws_loan_application_daily_count_di.loan_pass_all_amount` |
| 放款金额 | ❌ | 需结合 `loan_repayment_time` 或 `actual_amount` |

### SQL 实现参考

**笔数口径**：

```sql
COUNT(CASE WHEN t.loan_status = '1' THEN 1 END) AS loan_pass_num
FROM ttsp_it.dwd_fact_loan_application_di t
WHERE t.is_active = 'Y'
  AND t.ds BETWEEN '{win_start_ds}' AND '{prebizdate}'
```

**客户数口径（去重）**：

```sql
COUNT(DISTINCT CASE WHEN t.loan_status = '1' THEN t.customer_sk END) AS loan_pass_customer_num
FROM ttsp_it.dwd_fact_loan_application_di t
WHERE t.is_active = 'Y'
  AND t.ds BETWEEN '{win_start_ds}' AND '{prebizdate}'
```

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 首次成功支用 | [§2](#2-首次成功支用first-successful-loan) | 授信维度的"首次" + "通过" 组合 |
| 授信通过 | [credit-rules.md §1](./credit-rules.md#1-授信通过credit-passed) | 上游授信场景的对偶概念 |

### 决策来源

- **2024-XX 业务需求会议**：首次提出"支用通过"统计口径
- **2024-XX 风控会议**：确认 `loan_status = '1'` 为"通过"判定码
- **代码实现出处**：`mid/dim_application_classification_mapping_di.sql`（first_loan 子查询）

---

## 2. 首次成功支用（First Successful Loan）

> **业务术语**：指客户首次获得"支用通过"的支用申请。
> **英文标识**：`first_successful_loan`（业务概念）
> **DWD 落表**：⚠️ **本文件不绑定 DWD 字段**。`is_first_loan='Y'` 在不同实现里可能对应不同粒度（参见 [§2.1 三种粒度一览](#21-三种粒度一览)），实现方需在 SQL 中显式声明使用哪种粒度。

### 业务概念

"**首次成功支用**"本质上是一个**判定 + 排序**操作：

> 找出一笔支用申请，在某个**统计粒度**内，是**通过**（`loan_status='1'`）的**最早一笔**。

**判定条件（不变量）**：

| 条件 | 判定规则 | 字段来源 |
|------|---------|---------|
| ① 支用状态为通过 | `loan_status = '1'` | `dwd_fact_loan_application_di` |
| ② 数据有效 | `is_active = 'Y'` | `dwd_fact_loan_application_di` |
| ③ "首次"取最早 | 按 `apply_time` 升序，row_number = 1 | `dwd_fact_loan_application_di` |

**关键变量**：条件③ 中的 `PARTITION BY` 列表**可变**——它决定"首次"在哪个**统计粒度**内取。粒度越细，"首次"出现得越多（因为换产品/换分流后又算一次"首次"）。

> 💡 **与授信规则的对称性**：本节与 [credit-rules.md §2](./credit-rules.md#2-首次成功授信first-successful-credit) 完全平行——3 个粒度的 `PARTITION BY` 列表**完全相同**，只是事实表从 `dwd_fact_credit_application_di` 换成 `dwd_fact_loan_application_di`，`credit_status` 换成 `loan_status`。

### 2.1 三种粒度一览

| 粒度 | 名称 | `PARTITION BY` | 业务含义 | 典型应用 |
|------|------|----------------|---------|---------|
| ① | 客户历史首次成功支用 | `customer_sk` | 客户**终身**只有一次 | 新支总数、终身首支风险 |
| ② | 产品下客户首次成功支用 | `customer_sk, product_code_sk` | 客户在该**产品**下首次（换产品再算） | 单产品风控、单产品客群 |
| ③ | 产品+分流下客户首次成功支用 | `customer_sk, product_code_sk, diversion_type` | 客户在该**产品 + 分流**下首次 | 嵩海 vs 晋商/华通 横向对比 |

**粒度关系**：

```
粒度① ⊇ 粒度② ⊇ 粒度③
（粗）            （细）

例：客户 A 的支用记录
  - 2025-02：产品 P1 + 晋商/华通 → 通过
  - 2025-04：产品 P1 + 嵩海     → 通过
  - 2025-07：产品 P2 + 晋商/华通 → 通过

则在 3 个粒度下，"首次"分别落在：
  - 粒度①：2025-02（P1 + 晋商） ← 客户终身首次支用
  - 粒度②：2025-02（P1 首次）+ 2025-07（P2 首次）= 2 条
  - 粒度③：2025-02 + 2025-04 + 2025-07 = 3 条
```

> 💡 **粒度越细，"首次"越分散**。粒度③ 客户可能出现在 2 个分流通道下，导致其后续行为被重复统计——**这是横向分流对比所需，但要明确这是"细粒度下的首次"**。

### 2.2 粒度①：客户历史首次成功支用

> **业务含义**：客户**终身**只有一次"首次"——换产品、换分流都不影响，**最早一笔通过的支用**就是客户的"首次支用"。

**PARTITION BY**：`customer_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 新支总数（终身口径） | ✅ | 业务上"新支"通常以这个粒度为准 |
| 新支转化漏斗 | ✅ | "终身首次成功支用" → "复支" |
| 终身首支风险分析 | ✅ | 跟踪所有首支的 Vintage 表现 |
| 跨产品新支对比 | ❌ | 粒度② 才有意义 |
| 分流横向对比 | ❌ | 粒度③ 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,apply_time
        ,row_number() over(
            partition by customer_sk              -- 关键：只按 customer_sk 分区
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      and loan_status = '1'                      -- 关键：只对"通过"的记录编号
)
select *
from ranked
where rn = 1
```

### 2.3 粒度②：产品下客户首次成功支用

> **业务含义**：客户**在该产品下**的首次支用——**换产品后再算一次**"首次"。同一客户可能同时有 P1 和 P2 的"产品首次支用"。

**PARTITION BY**：`customer_sk, product_code_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 单产品新支分析 | ✅ | 某产品线拉到了多少"产品新支" |
| 跨产品客群迁移分析 | ✅ | 客户在 P1 支用成功后，P2 又是"新支" |
| 单产品风控策略评估 | ✅ | 隔离产品干扰，看纯风控效果 |
| 终身新支总数 | ❌ | 粒度① 才有意义（否则客户在多个产品下被重复计为新支） |
| 分流横向对比 | ❌ | 粒度③ 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk   -- 关键：加 product_code_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      and loan_status = '1'
)
select *
from ranked
where rn = 1
```

### 2.4 粒度③：产品+分流下客户首次成功支用

> **业务含义**：客户**在该产品 + 该分流**下的首次支用——**换产品、换分流都再算一次**。同一客户在 P1 晋商、P1 嵩海、P2 晋商都可能是"首次"。

**PARTITION BY**：`customer_sk, product_code_sk, diversion_type`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 嵩海 vs 晋商/华通 横向对比 | ✅ | **必选**。客户在两个通道下都被记为"首次"，可比对两个通道的风险表现 |
| 陪跑模型效果评估 | ✅ | 仅看嵩海分流下的"首次"表现 |
| 客户终身新支分析 | ❌ | 粒度① 才有意义 |
| 单产品新支分析 | ❌ | 粒度② 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk, diversion_type   -- 关键：加 diversion_type
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      and loan_status = '1'
)
select *
from ranked
where rn = 1
```

> ⚠️ `diversion_type` 需要先关联到支用申请。参见 [§4 分流类型（支用场景）](#4-分流类型支用场景diversion-type) 的判定逻辑。

### 2.5 三个粒度的 SQL 差异（极简对比）

| 粒度 | 唯一变化（其他完全相同） |
|------|------------------------|
| ① 客户历史 | `partition by customer_sk` |
| ② 产品下客户 | `partition by customer_sk, product_code_sk` |
| ③ 产品+分流下客户 | `partition by customer_sk, product_code_sk, diversion_type` |

**其余 SQL 条件（where、order by、status 过滤）完全相同**。

### 2.6 关键边界

| 边界场景 | ① 客户历史 | ② 产品下 | ③ 产品+分流下 |
|----------|-----------|---------|--------------|
| 客户首次支用即通过 | ✅（在最早一笔上） | ✅ | ✅ |
| 客户首次支用未通过，第二次才通过 | ✅（在第二次通过记录上） | ✅ | ✅ |
| 客户在产品 P1 通过后，又在 P2 通过 | ✅（P1 首次） | ✅（P1 + P2 各 1 条） | ✅（P1 + P2 各 1 条） |
| 客户在 P1 晋商通过后，又在 P1 嵩海通过 | ✅（晋商 首次） | ✅（P1 首次 = 晋商） | ✅（P1+晋商、P1+嵩海 各 1 条） |
| 客户有支用但从未通过 | ❌ 无 | ❌ 无 | ❌ 无 |
| 同一客户同一天多次申请 | 按 `apply_time` 精确排序，**取最早** | 同左 | 同左 |

> ⚠️ **共同的不变量**：3 个粒度都**只看"通过"**（`loan_status='1'`）。客户首次申请未通过时，**取该客户该粒度内最早一笔通过的支用**——这与"首次支用申请"（§3）的口径有本质区别。

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 首次支用申请 | [§3](#3-首次支用申请first-loan-application) | "首次成功支用" ⊆ "首次支用申请" 不成立（看结果 vs 看行为） |
| 支用通过 | [§1](#1-支用通过loan-passed) | 前置条件 |
| 分流类型（支用场景） | [§4](#4-分流类型支用场景diversion-type) | 粒度③ 需要 |
| 首次成功授信 | [credit-rules.md §2](./credit-rules.md#2-首次成功授信first-successful-credit) | 上游授信环节（口径完全平行） |

### 决策来源

- **2024-XX 业务需求会议**：首次提出新支/老支分层口径（基于客户终身粒度 ①）
- **业务演进**：随着分流策略上线，业务方提出"按产品"和"按产品+分流"对比需求 → 引入粒度 ②、③
- **代码实现**：3 个粒度对应 `mid/dim_application_classification_mapping_di.sql` 的不同子查询（具体行号由实现方按实际代码标注）

---

## 3. 首次支用申请（First Loan Application）

> **业务术语**：指客户首次发起的支用申请（不论结果）。
> **英文标识**：`first_loan_application`（业务概念）
> **DWD 落表**：⚠️ **本文件不绑定 DWD 字段**。"首次支用申请"需在 SQL 中实时计算，**且有 3 种粒度**（参见 [§3.1 三种粒度一览](#31-三种粒度一览)）。

### 业务概念

"**首次支用申请**"本质上是一个**判定 + 排序**操作：

> 找出一笔支用申请，在某个**统计粒度**内，是**最早一笔**（**不论结果**）。

**判定条件（不变量）**：

| 条件 | 判定规则 | 字段来源 |
|------|---------|---------|
| ① 数据有效 | `is_active = 'Y'` | `dwd_fact_loan_application_di` |
| ② "首次"取最早 | 按 `apply_time` 升序，row_number = 1 | `dwd_fact_loan_application_di` |
| ③ **不限制状态** | `loan_status IN ('0', '1', '2', '3')` | - |

**与"首次成功支用"的本质区别**：判定条件**不去掉未通过的记录**——客户首次申请即被拒绝时，**首次支用申请"算"但"首次成功支用"不算**。

**关键变量**：条件② 中的 `PARTITION BY` 列表**可变**——它决定"首次"在哪个**统计粒度**内取。

> 💡 **与 [credit-rules.md §3](./credit-rules.md#3-首次授信申请first-credit-application) 的对称性**：本节口径完全平行——3 个粒度的 `PARTITION BY` 列表相同。

### 3.1 三种粒度一览

| 粒度 | 名称 | `PARTITION BY` | 业务含义 | 典型应用 |
|------|------|----------------|---------|---------|
| ① | 客户历史首次支用申请 | `customer_sk` | 客户**终身**只有一次 | 申请漏斗起点、终身客户触达 |
| ② | 产品下客户首次支用申请 | `customer_sk, product_code_sk` | 客户在该**产品**下首次（换产品再算） | 单产品获客分析 |
| ③ | 产品+分流下客户首次支用申请 | `customer_sk, product_code_sk, diversion_type` | 客户在该**产品 + 分流**下首次 | 分流通道的获客漏斗 |

**粒度关系**：`① ⊇ ② ⊇ ③`（与 [§2](#2-首次成功支用first-successful-loan) 完全平行）。

### 3.2 粒度①：客户历史首次支用申请

> **业务含义**：客户**终身**最早一次发起的支用申请——**不论结果**。

**PARTITION BY**：`customer_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 支用申请漏斗起点 | ✅ | "客户终身首次支用申请" → "客户终身首次成功支用" 转化率 |
| 客户首次触达时点 | ✅ | 衡量业务获客时点（看行为） |
| 客户终身申请撤回率 | ✅ | 分子：首次申请=拒绝；分母：首次申请笔数 |
| 跨产品获客分析 | ❌ | 粒度② 才有意义 |
| 分流横向对比 | ❌ | 粒度③ 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,loan_status
        ,apply_time
        ,row_number() over(
            partition by customer_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      -- ⚠️ 关键：不去掉 loan_status 过滤，保留所有状态
)
select *
from ranked
where rn = 1
```

### 3.3 粒度②：产品下客户首次支用申请

> **业务含义**：客户**在该产品下**最早一次发起的支用申请。

**PARTITION BY**：`customer_sk, product_code_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 单产品获客分析 | ✅ | 某产品线拉到了多少"产品新客" |
| 跨产品客群迁移 | ✅ | 客户在 P1 申请后，P2 又算"产品首次申请" |
| 终身新客漏斗 | ❌ | 粒度① 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,loan_status
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
)
select *
from ranked
where rn = 1
```

### 3.4 粒度③：产品+分流下客户首次支用申请

> **业务含义**：客户**在该产品 + 该分流**下最早一次发起的支用申请。

**PARTITION BY**：`customer_sk, product_code_sk, diversion_type`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 分流通道的获客漏斗 | ✅ | 看嵩海 vs 晋商/华通各自的"首次申请"漏斗 |
| 陪跑模型的获客质量 | ✅ | 仅看嵩海分流下的"首次申请"特征 |
| 终身客户漏斗 | ❌ | 粒度① 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,loan_status
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk, diversion_type
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
)
select *
from ranked
where rn = 1
```

### 3.5 三个粒度的 SQL 差异（极简对比）

| 粒度 | 唯一变化（其他完全相同） |
|------|------------------------|
| ① 客户历史 | `partition by customer_sk` |
| ② 产品下客户 | `partition by customer_sk, product_code_sk` |
| ③ 产品+分流下客户 | `partition by customer_sk, product_code_sk, diversion_type` |

**其余 SQL 条件（where、order by）完全相同**。

### 3.6 关键边界

| 边界场景 | ① 客户历史 | ② 产品下 | ③ 产品+分流下 |
|----------|-----------|---------|--------------|
| 客户首次支用即通过 | ✅ | ✅ | ✅ |
| 客户首次支用即拒绝 | ✅ | ✅ | ✅ |
| 客户首次支用失败，第二次才成功 | ✅（在第一次记录上） | ✅ | ✅ |
| 客户在 P1 申请后，又在 P2 申请 | ✅（P1 首次） | ✅（P1 + P2 各 1 条） | ✅（P1 + P2 各 1 条） |
| 客户在 P1 晋商申请后，又在 P1 嵩海申请 | ✅（晋商 首次） | ✅（P1 首次 = 晋商） | ✅（P1+晋商、P1+嵩海 各 1 条） |
| 客户之前已有支用申请被拒，今天重新申请 | ❌ 不是"首次" | ❌ | ❌ |
| 同一客户同一天多次申请 | 按 `apply_time` 精确排序，**取最早** | 同左 | 同左 |

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 首次成功支用 | [§2](#2-首次成功支用first-successful-loan) | "首次支用申请" ⊇ "首次成功支用"（行为 ⊇ 结果） |
| 支用通过 | [§1](#1-支用通过loan-passed) | 无关（首次申请不要求通过） |
| 首次授信申请 | [credit-rules.md §3](./credit-rules.md#3-首次授信申请first-credit-application) | 上游授信环节的对应概念（口径完全平行） |

### 决策来源

- **业务背景**：漏斗分析需要"行为起点"与"结果起点"分别计量
- **代码缺口**：DWD 维表未维护"首次支用申请"，需在 SQL 中实时计算
- **设计演进**：与 [§2](#2-首次成功支用first-successful-loan) 对齐，引入 3 粒度设计

---

## 4. 分流类型（支用场景）（Diversion Type - Loan Scenario）

> **业务术语**：指支用申请所分配到的资金通道。
> **英文标识**：`diversion_type`（支用侧）
> **DWD 落表**：`ttsp_it.dim_application_classification_mapping_di.diversion_type`（type='2'）

> 💡 **为什么这里也写分流类型？** `diversion_type` 跨授信/支用两个环节，但**授信场景和借款场景的判定逻辑不同**（参见下方判定逻辑）。为避免跨文件跳转，本文件在支用章节下保留一份；完整的字段定义和"两场景对比"参见 [credit-rules.md §4](./credit-rules.md#4-分流类型授信场景diversion-type) 和 [README.md 横向对比](../README.md#横向对比分流类型两场景)。

### 业务定义

每笔支用申请在发起时被分配到某个资金通道：

| 枚举值 | 含义 | 资金性质 |
|--------|------|----------|
| `1` | 晋商/华通 | 核心资金通道 |
| `2` | 嵩海 | 陪跑资金通道（用于风控模型验证） |

### 字段字典引用

| 字段 | 表 | 数据来源 |
|------|------|----------|
| `diversion_type` | `dim_application_classification_mapping_di` | 业务规则加工生成（参见下文） |

字段详情参见 [`dim_application_classification_mapping_di.md`](../../schema/DWD/fields/dim_application_classification_mapping_di.md)。

### 判定逻辑（支用场景）

参考 `mid/dim_application_classification_mapping_di.sql` 第 85-110 行的 `fenliu` CTE：

```sql
case
    when mapp.id is not null then '2'                                -- ① 关联授信表已标记嵩海
    when white.cust_id is not null and disbt.seqnum is not null then '2'  -- ② 白名单 + 内部最新
    else '1'                                                          -- ③ 默认晋商/华通
end as diversion_type
```

**判定优先级（从高到低）**：
1. **关联授信已分流嵩海**：借款关联的授信在 `dim_application_classification_mapping_di` 中 `diversion_type='2'` → 嵩海
2. **白名单 + 内部最新**：客户在 `o_ttsp_t_white_infos`（model_code='JSXJ_DISBT'）且申请关联到 `o_ttsp_ods_re_jinshang_disbt_info_di.seqnum` → 嵩海
3. **默认**：晋商/华通

### 关键边界

| 边界场景 | 判定 | 备注 |
|----------|------|------|
| 客户授信阶段已被标记嵩海 | 借款沿用 → `2` 嵩海 | 上下游一致 |
| 客户在 `o_ttsp_t_white_infos` 白名单 | 借款场景下 → `2` 嵩海 | 运营白名单 |
| 同一客户跨申请 | 按**每笔申请**独立判定 | 不会因历史分流影响新申请 |

> 📌 **授信场景的判定逻辑不同**，参见 [credit-rules.md §4](./credit-rules.md#4-分流类型授信场景diversion-type)。

### 适用场景

| 场景 | 是否使用本维度 | 说明 |
|------|--------------|------|
| 按资金通道分析通过率 | ✅ | 嵩海 vs 晋商/华通的策略对比 |
| 按通道分析风险表现 | ✅ | Vintage 必带 `diversion_type` 切片（详见 [analytics.md](./analytics.md)） |
| 运营白名单效果分析 | ✅ | 哪些白名单客户走嵩海 |
| 授信/借款联合分析 | ✅ | 上下游需保持 `diversion_type` 一致 |

### SQL 实现参考

**直接使用维表（推荐）**：

```sql
from ttsp_it.dwd_fact_loan_application_di t
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.loan_id = m.id
    and m.type = '2'
    and m.is_active = 'Y'
where m.diversion_type = '2'   -- 仅嵩海
```

**分组聚合（按分流类型）**：

```sql
select
    m.diversion_type
    ,count(distinct t.loan_id) as loan_num
    ,count(distinct case when t.loan_status='1' then t.loan_id end) as pass_num
from ttsp_it.dwd_fact_loan_application_di t
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.loan_id = m.id
    and m.type = '2'
    and m.is_active = 'Y'
where t.is_active = 'Y'
  and t.ds between '{win_start_ds}' and '{prebizdate}'
group by m.diversion_type
```

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 分流类型（授信场景） | [credit-rules.md §4](./credit-rules.md#4-分流类型授信场景diversion-type) | 判定逻辑不同，详见授信侧 |
| 陪跑标记 | [§5](#5-陪跑标记accompany-flag) | 仅在 `diversion_type='2'`（嵩海）有值 |

### 决策来源

- **业务背景**：晋商/华通是核心资金通道，嵩海是用于风控模型验证的陪跑通道
- **代码实现出处**：`mid/dim_application_classification_mapping_di.sql`（支用场景，第 85-110 行）

---

## 5. 陪跑标记（Accompany Flag）

> **业务术语**：指嵩海资金通道下，借款是否走"陪跑模型"审批的标记。
> **英文标识**：`if_sh_flag`
> **DWD 落表**：`ttsp_it.dim_application_classification_mapping_di.if_sh_flag`（**仅 type='2' 支用场景有值**）

### 业务定义

仅在嵩海分流（`diversion_type='2'`）的支用申请上，标记是否走陪跑模型审批：

| 枚举值 | 含义 | 业务含义 |
|--------|------|----------|
| `1` | 陪跑 | 支用走嵩海陪跑风控模型审批 |
| `0` | 非陪跑 | 支用走嵩海常规风控模型审批 |

> ⚠️ **陪跑标记仅在嵩海分流下有意义**。晋商/华通分流（`diversion_type='1'`）下，支用不走嵩海模型，该字段无业务含义。

### 字段字典引用

| 字段 | 表 | 备注 |
|------|------|------|
| `if_sh_flag` | `dim_application_classification_mapping_di` | **type='2' 才有值，type='1' 为 NULL** |

字段详情参见 [`dim_application_classification_mapping_di.md`](../../schema/DWD/fields/dim_application_classification_mapping_di.md)。

### 判定逻辑（来自现有 DWD 代码）

参考 `mid/dim_application_classification_mapping_di.sql` 第 92 行：

```sql
case
    when mapp.id is not null and person_acount.sys__run_model is null then '0'
    else person_acount.sys__run_model
end as if_sh_flag
```

**判定规则**：
- 支用关联到 `o_ttsp_ods_datamodel_personalinfo_dataaccount`（个人信息维表）→ 取该表的 `sys__run_model` 字段作为陪跑标记
- `sys__run_model` 通常取值 `'0'`（非陪跑）或 `'1'`（陪跑）
- 特殊情况：上游授信已标记嵩海（`mapp.id is not null`）但 `sys__run_model` 为空 → 标记 `'0'`（非陪跑，作为兜底）

> 字段来源链路：
> ```
> if_sh_flag
>   └─ sys__run_model（o_ttsp_ods_datamodel_personalinfo_dataaccount）
>         └─ seqnum（与 o_ttsp_ods_re_jinshang_disbt_info_di.seqnum 关联）
>               └─ bank_loan_apply_seq（拆串前缀与支用申请关联）
> ```

### 关键边界

| 边界场景 | 判定 | 备注 |
|----------|------|------|
| 嵩海分流 + `sys__run_model='1'` | `1` 陪跑 | 正常情况 |
| 嵩海分流 + `sys__run_model='0'` | `0` 非陪跑 | 正常情况 |
| 嵩海分流 + `sys__run_model` 为空 + 授信已标嵩海 | `0` 非陪跑 | 兜底逻辑 |
| 晋商/华通分流 | NULL | **无业务含义** |
| 嵩海分流 + 个人信息表无记录 | 取决于 `LEFT JOIN` 结果 | 需验证是否有值 |

### 适用场景

| 场景 | 是否使用本维度 | 说明 |
|------|--------------|------|
| 嵩海陪跑模型效果分析 | ✅ | 对比陪跑 vs 非陪跑的风险表现 |
| 嵩海风控策略调优 | ✅ | 区分陪跑/非陪跑后的策略 |
| 晋商/华通分析 | ❌ | 该字段无值，无意义 |
| 联合 `diversion_type` 切片 | ✅ | 必须先 `diversion_type='2'` 才有意义 |

### SQL 实现参考

**直接使用维表（推荐）**：

```sql
from ttsp_it.dwd_fact_loan_application_di t
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.loan_id = m.id
    and m.type = '2'
    and m.is_active = 'Y'
    and m.diversion_type = '2'         -- ⚠️ 必加：仅嵩海分流
where m.if_sh_flag = '1'              -- 陪跑
```

**联合分流类型分组**：

```sql
select
    m.diversion_type
    ,coalesce(m.if_sh_flag, '__NULL__') as if_sh_flag
    ,count(distinct t.loan_id) as loan_num
    ,count(distinct case when t.loan_status='1' then t.loan_id end) as pass_num
from ttsp_it.dwd_fact_loan_application_di t
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.loan_id = m.id
    and m.type = '2'
    and m.is_active = 'Y'
where t.is_active = 'Y'
  and t.ds between '{win_start_ds}' and '{prebizdate}'
group by m.diversion_type, m.if_sh_flag
```

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 分流类型（支用场景） | [§4](#4-分流类型支用场景diversion-type) | 本字段仅在 `diversion_type='2'` 有意义 |

### 决策来源

- **业务背景**：嵩海是陪跑性质的资金通道，陪跑标记区分走陪跑模型还是常规模型
- **代码实现出处**：`mid/dim_application_classification_mapping_di.sql`（fenliu CTE 第 92 行）

---

## 横向关系图（支用环节）

```
授信（credit_sk）
 │
 ├─① 首次支用申请（行为起点，不看结果，按 credit_sk 分区）
 │     │
 │     ▼
 │   支用通过（结果，含 status='1' 的所有支用）
 │     │
 │     ▼
 │   首次成功支用（credit_sk 维度首次通过的支用）
 │     │
 │     ├─ ② 关联 credit_sk + apply_time 取 rn=1
 │     └─ ③ 关联 dim.is_first_loan='Y'（type='2'）
 │
 ├─ ④ 分流类型（每笔支用独立判定）
 │     ├─ 1=晋商/华通（默认）
 │     └─ 2=嵩海（白名单 + 时间切分 + 上下游一致）
 │
 └─ ⑤ 陪跑标记（仅 type='2' 嵩海有值）
       ├─ 1=陪跑（走嵩海陪跑模型）
       └─ 0=非陪跑（走嵩海常规模型）
```

**关键关联**：
- ① ⊇ ② ⊇ ③  ← 行为起点 ⊇ 所有通过 ⊇ 额度首次通过
- ⑤ 是 ④ 的子维度（仅嵩海有值）

---

## SQL 模板汇总（支用环节）

> 跨章节复用的 SQL 模式集中在这里。

### 模板 1：行号取"首次"（按授信）

```sql
-- 适用于：首次支用申请、首次成功支用
with ranked as (
    select
        loan_id
        ,credit_sk
        ,customer_sk
        ,loan_status
        ,apply_time
        ,row_number() over(
            partition by credit_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_loan_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      -- 可选：过滤状态（首次成功 vs 首次申请）
)
select *
from ranked
where rn = 1
```

### 模板 2：客户级首支聚合

```sql
-- 客户级首支（终身首次支用，按 customer 聚合）
select
    customer_sk
    ,min(apply_time) as first_loan_time
from ttsp_it.dwd_fact_loan_application_di
where is_active = 'Y'
  and loan_status = '1'
  and ds <= '{prebizdate}'
group by customer_sk
```

### 模板 3：分流判定（支用侧）

```sql
case
    when mapp.id is not null then '2'
    when white.cust_id is not null and disbt.seqnum is not null then '2'
    else '1'
end as diversion_type
```

### 模板 4：维表关联（避免重复写 join 条件）

```sql
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.loan_id = m.id
    and m.type = '2'
    and m.is_active = 'Y'
```

### 模板 5：陪跑标记安全过滤（必加 diversion_type 限定）

```sql
where m.diversion_type = '2'    -- ⚠️ 必加：仅嵩海分流
  and m.if_sh_flag = '1'        -- 陪跑
```

---

## 变更历史

| 日期 | 变更内容 | 变更人 |
|------|---------|--------|
| 2026-06-16 | 初始版本（从 status-rules/loan-passed.md 等 3 个文件 + diversion-rules/ 2 个文件合并重组） | - |
