# 授信环节业务规则（Credit Rules）

> **所属分类**：[业务规则](../README.md) - 业务环节 → 授信
> **覆盖范围**：授信申请生命周期内的状态认定 + 授信场景下的分流类型判定
> **关联文件**：[loan-rules.md](./loan-rules.md)（支用环节） · [analytics.md](./analytics.md)（跨环节度量）

本文件聚焦**授信环节**的所有业务规则，定义"什么算授信通过、什么算客户首次成功授信、什么算客户首次发起授信申请、授信场景下的分流类型怎么定"。

---

## 章节索引

| # | 业务术语 | 英文标识 | 核心判定 |
|---|---------|---------|---------|
| 1 | [授信通过](#1-授信通过credit-passed) | `credit_passed` | 授信状态 = 通过 + 数据有效 |
| 2 | [首次成功授信](#2-首次成功授信first-successful-credit) | `first_successful_credit` | 客户首笔通过授信（按申请时间） |
| 3 | [首次授信申请](#3-首次授信申请first-credit-application) | `first_credit_application` | 客户首笔授信申请（不论结果） |
| 4 | [分流类型（授信场景）](#4-分流类型授信场景diversion-type) | `diversion_type` | 1=晋商/华通；2=嵩海 |

---

## 1. 授信通过（Credit Passed）

> **业务术语**：指有效的授信申请中，授信状态为通过的授信申请。
> **英文标识**：`credit_passed`
> **DWD 字段**：`dwd_fact_credit_application_di.credit_status = '1'`

### 业务定义

一笔授信申请被认定为"**授信通过**"，**必须同时满足**以下条件：

| 条件 | 判定规则 | 字段来源 |
|------|---------|---------|
| ① 授信状态为通过 | `credit_status = '1'` | `ttsp_it.dwd_fact_credit_application_di` |
| ② 数据有效 | `is_active = 'Y'`（拉链当前有效记录） | `dwd_fact_credit_application_di` |

> **本术语不强制要求"申请有效"判断**（即不排除"已失效"等中间态）。
> 如果业务方要求"申请必须未被撤回/未被覆盖"等口径，需要单独定义"有效授信申请"规则（当前未维护）。

### 字段字典引用

| 状态码 | 含义 | 是否算"授信通过" |
|--------|------|-----------------|
| 1 | 通过 | ✅ 是 |
| 0 | 拒绝 | ❌ 否 |
| 2 | 失败 | ❌ 否 |
| 3 | 其他（处理中等中间态） | ❌ 否 |

字段详情参见 [`dwd_fact_credit_application_di.md`](../../schema/DWD/fields/dwd_fact_credit_application_di.md)。

### 适用场景

| 场景 | 是否使用本定义 | 典型应用 |
|------|--------------|----------|
| 授信通过客户数 | ✅ | `dws_customer_by_level_daily_di.credit_pass_customer_num` |
| 授信通过笔数 | ✅ | `dws_credit_application_daily_count_di.credit_pass_num` |
| 授信通过率 | ✅ | 通过笔数 / 申请笔数 |
| 授信通过额度 | ✅ | `dws_credit_application_daily_count_di.credit_pass_all_amount` |

### SQL 实现参考

**笔数口径**：

```sql
COUNT(CASE WHEN t.credit_status = '1' THEN 1 END) AS credit_pass_num
FROM ttsp_it.dwd_fact_credit_application_di t
WHERE t.is_active = 'Y'
  AND t.ds = '{prebizdate}'
```

**客户数口径（去重）**：

```sql
COUNT(DISTINCT CASE WHEN t.credit_status = '1' THEN t.customer_sk END) AS credit_pass_customer_num
FROM ttsp_it.dwd_fact_credit_application_di t
WHERE t.is_active = 'Y'
  AND t.ds = '{prebizdate}'
```

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 首次成功授信 | [§2](#2-首次成功授信first-successful-credit) | 客户维度的"首次" + "通过" 组合 |
| 支用通过 | [loan-rules.md §1](./loan-rules.md#1-支用通过loan-passed) | 借款场景的对偶概念 |

### 决策来源

- **2024-XX 业务需求会议**：首次提出"授信通过"统计口径
- **2024-XX 风控会议**：确认 `credit_status = '1'` 为"通过"判定码
- **代码实现出处**：`mid/dim_application_classification_mapping_di.sql`（first_credit 子查询）

---

## 2. 首次成功授信（First Successful Credit）

> **业务术语**：指客户首次获得"授信通过"的授信申请。
> **英文标识**：`first_successful_credit`（业务概念）
> **DWD 落表**：⚠️ **本文件不绑定 DWD 字段**。`is_first_credit='Y'` 在不同实现里可能对应不同粒度（参见 [§2.1 三种粒度一览](#21-三种粒度一览)），实现方需在 SQL 中显式声明使用哪种粒度。

### 业务概念

"**首次成功授信**"本质上是一个**判定 + 排序**操作：

> 找出一笔授信申请，在某个**统计粒度**内，是**通过**（`credit_status='1'`）的**最早一笔**。

**判定条件（不变量）**：

| 条件 | 判定规则 | 字段来源 |
|------|---------|---------|
| ① 授信状态为通过 | `credit_status = '1'` | `dwd_fact_credit_application_di` |
| ② 数据有效 | `is_active = 'Y'` | `dwd_fact_credit_application_di` |
| ③ "首次"取最早 | 按 `apply_time` 升序，row_number = 1 | `dwd_fact_credit_application_di` |

**关键变量**：条件③ 中的 `PARTITION BY` 列表**可变**——它决定"首次"在哪个**统计粒度**内取。粒度越细，"首次"出现得越多（因为换产品/换分流后又算一次"首次"）。

### 2.1 三种粒度一览

| 粒度 | 名称 | `PARTITION BY` | 业务含义 | 典型应用 |
|------|------|----------------|---------|---------|
| ① | 客户历史首次成功授信 | `customer_sk` | 客户**终身**只有一次 | 新客总数、终身新客风险 |
| ② | 产品下客户首次成功授信 | `customer_sk, product_code_sk` | 客户在该**产品**下首次（换产品再算） | 单产品风控、单产品客群 |
| ③ | 产品+分流下客户首次成功授信 | `customer_sk, product_code_sk, diversion_type` | 客户在该**产品 + 分流**下首次 | 嵩海 vs 晋商/华通 横向对比 |

**粒度关系**：

```
粒度① ⊇ 粒度② ⊇ 粒度③
（粗）            （细）

例：客户 A 的授信记录
  - 2025-01：产品 P1 + 晋商/华通 → 通过
  - 2025-03：产品 P1 + 嵩海     → 通过
  - 2025-06：产品 P2 + 晋商/华通 → 通过

则在 3 个粒度下，"首次"分别落在：
  - 粒度①：2025-01（P1 + 晋商） ← 客户终身首次
  - 粒度②：2025-01（P1 首次）+ 2025-06（P2 首次）= 2 条
  - 粒度③：2025-01 + 2025-03 + 2025-06 = 3 条
```

> 💡 **粒度越细，"首次"越分散**。粒度③ 客户可能出现在 2 个分流通道下，导致其后续行为被重复统计——**这是横向分流对比所需，但要明确这是"细粒度下的首次"**。

### 2.2 粒度①：客户历史首次成功授信

> **业务含义**：客户**终身**只有一次"首次"——换产品、换分流都不影响，**最早一笔通过的授信**就是客户的"首次"。

**PARTITION BY**：`customer_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 新客总数（终身口径） | ✅ | 业务上"新客"通常以这个粒度为准 |
| 新客转化漏斗 | ✅ | "终身首次成功授信" → "终身首次支用" |
| 终身新客风险分析 | ✅ | 跟踪所有新客的 Vintage 表现 |
| 跨产品新客对比 | ❌ | 粒度② 才有意义 |
| 分流横向对比 | ❌ | 粒度③ 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,apply_time
        ,row_number() over(
            partition by customer_sk              -- 关键：只按 customer_sk 分区
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      and credit_status = '1'                     -- 关键：只对"通过"的记录编号
)
select *
from ranked
where rn = 1
```

### 2.3 粒度②：产品下客户首次成功授信

> **业务含义**：客户**在该产品下**的首次——**换产品后再算一次**"首次"。同一客户可能同时有 P1 和 P2 的"产品首次"。

**PARTITION BY**：`customer_sk, product_code_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 单产品新客分析 | ✅ | 某产品线拉到了多少"产品新客" |
| 跨产品客群迁移分析 | ✅ | 客户在 P1 成功后，P2 又是"新客" |
| 单产品风控策略评估 | ✅ | 隔离产品干扰，看纯风控效果 |
| 终身新客总数 | ❌ | 粒度① 才有意义（否则客户在多个产品下被重复计为新客） |
| 分流横向对比 | ❌ | 粒度③ 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk   -- 关键：加 product_code_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      and credit_status = '1'
)
select *
from ranked
where rn = 1
```

### 2.4 粒度③：产品+分流下客户首次成功授信

> **业务含义**：客户**在该产品 + 该分流**下的首次——**换产品、换分流都再算一次**。同一客户在 P1 晋商、P1 嵩海、P2 晋商都可能是"首次"。

**PARTITION BY**：`customer_sk, product_code_sk, diversion_type`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 嵩海 vs 晋商/华通 横向对比 | ✅ | **必选**。客户在两个通道下都被记为"首次"，可比对两个通道的风险表现 |
| 陪跑模型效果评估 | ✅ | 仅看嵩海分流下的"首次"表现 |
| 客户终身新客分析 | ❌ | 粒度① 才有意义 |
| 单产品新客分析 | ❌ | 粒度② 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk, diversion_type   -- 关键：加 diversion_type
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      and credit_status = '1'
)
select *
from ranked
where rn = 1
```

> ⚠️ `diversion_type` 需要先关联到授信申请。参见 [§4 分流类型（授信场景）](#4-分流类型授信场景diversion-type) 的判定逻辑。

### 2.5 三个粒度的 SQL 差异（极简对比）

| 粒度 | 唯一变化（其他完全一致） |
|------|------------------------|
| ① 客户历史 | `partition by customer_sk` |
| ② 产品下客户 | `partition by customer_sk, product_code_sk` |
| ③ 产品+分流下客户 | `partition by customer_sk, product_code_sk, diversion_type` |

**其余 SQL 条件（where、order by、status 过滤）完全相同**。

### 2.6 关键边界

| 边界场景 | ① 客户历史 | ② 产品下 | ③ 产品+分流下 |
|----------|-----------|---------|--------------|
| 客户首次申请即通过 | ✅（在最早一笔上） | ✅ | ✅ |
| 客户首次申请未通过，第二次才通过 | ✅（在第二次通过记录上） | ✅ | ✅ |
| 客户在产品 P1 通过后，又在 P2 通过 | ✅（P1 首次） | ✅（P1 + P2 各 1 条） | ✅（P1 + P2 各 1 条） |
| 客户在 P1 晋商通过后，又在 P1 嵩海通过 | ✅（晋商 首次） | ✅（P1 首次 = 晋商） | ✅（P1+晋商、P1+嵩海 各 1 条） |
| 客户有授信但从未通过 | ❌ 无 | ❌ 无 | ❌ 无 |
| 同一客户同一天多次申请 | 按 `apply_time` 精确排序，**取最早** | 同左 | 同左 |

> ⚠️ **共同的不变量**：3 个粒度都**只看"通过"**（`credit_status='1'`）。客户首次申请未通过时，**取该客户该粒度内最早一笔通过的授信**——这与"首次授信申请"（§3）的口径有本质区别。

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 首次授信申请 | [§3](#3-首次授信申请first-credit-application) | "首次成功授信" ⊆ "首次授信申请" 不成立（看结果 vs 看行为） |
| 授信通过 | [§1](#1-授信通过credit-passed) | 前置条件 |
| 分流类型（授信场景） | [§4](#4-分流类型授信场景diversion-type) | 粒度③ 需要 |
| 新客/老客 | - | 业务上的"新客"通常以**粒度①**为口径（终身首次） |

### 决策来源

- **2024-XX 业务需求会议**：首次提出新客/老客分层口径（基于客户终身粒度 ①）
- **业务演进**：随着分流策略上线，业务方提出"按产品"和"按产品+分流"对比需求 → 引入粒度 ②、③
- **代码实现**：3 个粒度对应 `mid/dim_application_classification_mapping_di.sql` 的不同子查询（具体行号由实现方按实际代码标注）

---

## 3. 首次授信申请（First Credit Application）

> **业务术语**：指客户首次发起的授信申请（不论结果）。
> **英文标识**：`first_credit_application`（业务概念）
> **DWD 落表**：⚠️ **本文件不绑定 DWD 字段**。"首次授信申请"需在 SQL 中实时计算，**且有 3 种粒度**（参见 [§3.1 三种粒度一览](#31-三种粒度一览)）。

### 业务概念

"**首次授信申请**"本质上是一个**判定 + 排序**操作：

> 找出一笔授信申请，在某个**统计粒度**内，是**最早一笔**（**不论结果**）。

**判定条件（不变量）**：

| 条件 | 判定规则 | 字段来源 |
|------|---------|---------|
| ① 数据有效 | `is_active = 'Y'` | `dwd_fact_credit_application_di` |
| ② "首次"取最早 | 按 `apply_time` 升序，row_number = 1 | `dwd_fact_credit_application_di` |
| ③ **不限制状态** | `credit_status IN ('0', '1', '2', '3')` | - |

**与"首次成功授信"的本质区别**：判定条件**不去掉未通过的记录**——客户首次申请即被拒绝时，**首次授信申请"算"但"首次成功授信"不算**。

**关键变量**：条件② 中的 `PARTITION BY` 列表**可变**——它决定"首次"在哪个**统计粒度**内取。

> 💡 **与 [§2](#2-首次成功授信first-successful-credit) 的对称性**：本节口径完全平行——3 个粒度的 `PARTITION BY` 列表相同，**唯一区别是 `credit_status` 不限制**（去掉了"通过"过滤）。

### 3.1 三种粒度一览

| 粒度 | 名称 | `PARTITION BY` | 业务含义 | 典型应用 |
|------|------|----------------|---------|---------|
| ① | 客户历史首次授信申请 | `customer_sk` | 客户**终身**只有一次 | 申请漏斗起点、终身客户触达 |
| ② | 产品下客户首次授信申请 | `customer_sk, product_code_sk` | 客户在该**产品**下首次（换产品再算） | 单产品获客分析 |
| ③ | 产品+分流下客户首次授信申请 | `customer_sk, product_code_sk, diversion_type` | 客户在该**产品 + 分流**下首次 | 分流通道的获客漏斗 |

**粒度关系**：`① ⊇ ② ⊇ ③`（与 [§2](#2-首次成功授信first-successful-credit) 完全平行）。

### 3.2 粒度①：客户历史首次授信申请

> **业务含义**：客户**终身**最早一次发起的授信申请——**不论结果**。

**PARTITION BY**：`customer_sk`

**适用场景**：

| 场景 | 是否使用 | 说明 |
|------|---------|------|
| 申请漏斗起点 | ✅ | "客户终身首次授信申请" → "客户终身首次成功授信" 转化率 |
| 客户首次触达 | ✅ | 衡量业务获客时点（看行为） |
| 客户终身申请撤回率 | ✅ | 分子：首次申请=拒绝；分母：首次申请笔数 |
| 跨产品获客分析 | ❌ | 粒度② 才有意义 |
| 分流横向对比 | ❌ | 粒度③ 才有意义 |

**SQL 模板**：

```sql
with ranked as (
    select
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,credit_status
        ,apply_time
        ,row_number() over(
            partition by customer_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      -- ⚠️ 关键：不去掉 credit_status 过滤，保留所有状态
)
select *
from ranked
where rn = 1
```

### 3.3 粒度②：产品下客户首次授信申请

> **业务含义**：客户**在该产品下**最早一次发起的授信申请。

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
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,credit_status
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
)
select *
from ranked
where rn = 1
```

### 3.4 粒度③：产品+分流下客户首次授信申请

> **业务含义**：客户**在该产品 + 该分流**下最早一次发起的授信申请。

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
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,credit_status
        ,apply_time
        ,row_number() over(
            partition by customer_sk, product_code_sk, diversion_type
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
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
| 客户首次申请即通过 | ✅ | ✅ | ✅ |
| 客户首次申请即拒绝 | ✅ | ✅ | ✅ |
| 客户首次申请失败，第二次才成功 | ✅（在第一次记录上） | ✅ | ✅ |
| 客户在 P1 申请后，又在 P2 申请 | ✅（P1 首次） | ✅（P1 + P2 各 1 条） | ✅（P1 + P2 各 1 条） |
| 客户在 P1 晋商申请后，又在 P1 嵩海申请 | ✅（晋商 首次） | ✅（P1 首次 = 晋商） | ✅（P1+晋商、P1+嵩海 各 1 条） |
| 客户之前已有授信申请被拒，今天重新申请 | ❌ 不是"首次" | ❌ | ❌ |
| 同一客户同一天多次申请 | 按 `apply_time` 精确排序，**取最早** | 同左 | 同左 |

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 首次成功授信 | [§2](#2-首次成功授信first-successful-credit) | "首次授信申请" ⊇ "首次成功授信"（行为 ⊇ 结果） |
| 授信通过 | [§1](#1-授信通过credit-passed) | 无关（首次申请不要求通过） |
| 首次支用申请 | [loan-rules.md §3](./loan-rules.md#3-首次支用申请first-loan-application) | 下游支用环节的对应概念（口径完全平行） |

### 决策来源

- **业务背景**：漏斗分析需要"行为起点"与"结果起点"分别计量
- **代码缺口**：DWD 维表未维护"首次授信申请"，需在 SQL 中实时计算
- **设计演进**：与 [§2](#2-首次成功授信first-successful-credit) 对齐，引入 3 粒度设计

---

## 4. 分流类型（授信场景）（Diversion Type - Credit Scenario）

> **业务术语**：指授信申请所分配到的资金通道。
> **英文标识**：`diversion_type`（授信侧）
> **DWD 落表**：`ttsp_it.dim_application_classification_mapping_di.diversion_type`（type='1'）

> 💡 **为什么这里也写分流类型？** `diversion_type` 跨授信/支用两个环节，但**授信场景和借款场景的判定逻辑不同**（参见下方判定逻辑）。为避免跨文件跳转，本文件在授信章节下保留一份；完整的字段定义和"两场景对比"参见 [loan-rules.md §4](./loan-rules.md#4-分流类型支用场景diversion-type) 和 [README.md 横向对比](../README.md#横向对比分流类型两场景)。

### 业务定义

每笔授信申请在发起时被分配到某个资金通道：

| 枚举值 | 含义 | 资金性质 |
|--------|------|----------|
| `1` | 晋商/华通 | 核心资金通道 |
| `2` | 嵩海 | 陪跑资金通道（用于风控模型验证） |

### 字段字典引用

| 字段 | 表 | 数据来源 |
|------|------|----------|
| `diversion_type` | `dim_application_classification_mapping_di` | 业务规则加工生成（参见下文） |

字段详情参见 [`dim_application_classification_mapping_di.md`](../../schema/DWD/fields/dim_application_classification_mapping_di.md)。

### 判定逻辑（授信场景）

参考 `mid/dim_application_classification_mapping_di.sql` 第 25-27 行：

```sql
case
    when inside.seqnum is not null then '2'              -- ① 命中"内部最新"白名单
    when to_char(apply_time, 'YYYYMMDD') >= '20251203' then '2'  -- ② 申请时间 ≥ 切分日
    else '1'                                              -- ③ 默认晋商/华通
end as diversion_type
```

**判定优先级（从高到低）**：
1. **白名单命中**：`o_ttsp_ods_re_jinshang_inside_info_di.seqnum` 关联到 `bank_credit_apply_seq` 的拆串前缀 → 嵩海
2. **时间切分**：申请日期 ≥ `20251203` → 嵩海（业务上线/分流策略切换日）
3. **默认**：其余 → 晋商/华通

> ⚠️ **时间切分点 `20251203` 是硬编码业务策略**，未来若调整需同步更新本规则。

### 关键边界

| 边界场景 | 判定 | 备注 |
|----------|------|------|
| 申请时间 < 20251203 + 未命中白名单 | `1` 晋商/华通 | 历史数据走核心通道 |
| 申请时间 ≥ 20251203 | `2` 嵩海 | 新申请走陪跑通道 |
| 客户在 `o_ttsp_ods_re_jinshang_inside_info_di` 白名单 | → `2` 嵩海 | 运营白名单 |
| 同一客户跨申请 | 按**每笔申请**独立判定 | 不会因历史分流影响新申请 |

> 📌 **借款场景的判定逻辑不同**，参见 [loan-rules.md §4](./loan-rules.md#4-分流类型支用场景diversion-type)。

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
from ttsp_it.dwd_fact_credit_application_di t
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.credit_sk = m.id
    and m.type = '1'
    and m.is_active = 'Y'
where m.diversion_type = '2'   -- 仅嵩海
```

**分组聚合（按分流类型）**：

```sql
select
    m.diversion_type
    ,count(distinct t.credit_sk) as credit_num
    ,count(distinct case when t.credit_status='1' then t.credit_sk end) as pass_num
from ttsp_it.dwd_fact_credit_application_di t
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.credit_sk = m.id
    and m.type = '1'
    and m.is_active = 'Y'
where t.is_active = 'Y'
  and t.ds = '{prebizdate}'
group by m.diversion_type
```

### 关联术语

| 术语 | 章节 | 关系 |
|------|------|------|
| 分流类型（支用场景） | [loan-rules.md §4](./loan-rules.md#4-分流类型支用场景diversion-type) | 判定逻辑不同，详见支用侧 |
| 陪跑标记 | [loan-rules.md §5](./loan-rules.md#5-陪跑标记accompany-flag) | 仅在 `diversion_type='2'`（嵩海）有值 |

### 决策来源

- **业务背景**：晋商/华通是核心资金通道，嵩海是用于风控模型验证的陪跑通道
- **时间切分点 `20251203`**：业务上线/分流策略切换日（需向业务方确认）
- **代码实现出处**：`mid/dim_application_classification_mapping_di.sql`（授信场景，第 25-27 行）

---

## 横向关系图（授信环节）

```
客户（customer_sk）
 │
 ├─① 首次授信申请（行为起点，不看结果）
 │     │
 │     │   ┌─ 粒度① 客户历史         partition by customer_sk
 │     ├─► ├─ 粒度② 产品下客户       partition by customer_sk, product_code_sk
 │     │   └─ 粒度③ 产品+分流下客户  partition by customer_sk, product_code_sk, diversion_type
 │     ▼
 │   授信通过（结果，含 status='1' 的所有授信）
 │     │
 │     │   ┌─ 粒度① 客户历史         partition by customer_sk
 │     ├─► ├─ 粒度② 产品下客户       partition by customer_sk, product_code_sk
 │     │   └─ 粒度③ 产品+分流下客户  partition by customer_sk, product_code_sk, diversion_type
 │     ▼
 │   首次成功授信（"行为起点 + 通过" 组合）
 │
 └─④ 分流类型（每笔授信独立判定，3 种粒度都会用到）
       ├─ 1=晋商/华通（默认）
       └─ 2=嵩海（白名单 + 时间切分）
```

**关键关联**：
- ① ⊇ ② ⊇ ③  ← 3 个粒度的包含关系（粒度① 包含 ②，粒度② 包含 ③）
- **首次授信申请** ⊇ **首次成功授信**  ← 行为 ⊇ 结果
- ④ 是独立维度，与①②③正交，但**粒度 ②、③ 直接在 PARTITION BY 中使用 diversion_type**

---

## SQL 模板汇总（授信环节）

> 跨章节复用的 SQL 模式集中在这里。

### 模板 1：行号取"首次"（3 粒度通用）

```sql
-- 适用于：首次授信申请（不限制状态）、首次成功授信（status='1'）
-- 3 个粒度的唯一差别是 partition by 列表
with ranked as (
    select
        credit_sk
        ,customer_sk
        ,product_code_sk
        ,diversion_type
        ,credit_status
        ,apply_time
        ,row_number() over(
            -- 粒度① 客户历史：partition by customer_sk
            -- 粒度② 产品下客户：partition by customer_sk, product_code_sk
            partition by customer_sk, product_code_sk, diversion_type   -- 粒度③
            order by apply_time
        ) as rn
    from ttsp_it.dwd_fact_credit_application_di
    where is_active = 'Y'
      and ds <= '{prebizdate}'
      -- 首次成功：and credit_status = '1'
      -- 首次申请：不加 status 过滤
)
select *
from ranked
where rn = 1
```

> 💡 **业务概念 → SQL 模板的映射**：
> - 粒度① 客户历史 → `partition by customer_sk`
> - 粒度② 产品下客户 → `partition by customer_sk, product_code_sk`
> - 粒度③ 产品+分流下客户 → `partition by customer_sk, product_code_sk, diversion_type`
> - "首次成功" → `+ where credit_status = '1'`
> - "首次申请" → 不加 status 过滤

### 模板 2：分流判定（授信侧）

```sql
case
    when inside.seqnum is not null then '2'
    when to_char(apply_time, 'YYYYMMDD') >= '20251203' then '2'
    else '1'
end as diversion_type
```

### 模板 3：维表关联（避免重复写 join 条件）

```sql
inner join ttsp_it.dim_application_classification_mapping_di m
    on t.credit_sk = m.id
    and m.type = '1'
    and m.is_active = 'Y'
```

---

## 变更历史

| 日期 | 变更内容 | 变更人 |
|------|---------|--------|
| 2026-06-16 | 初始版本（从 status-rules/credit-passed.md 等 3 个文件合并重组） | - |
