# 跨环节度量（Cross-Lifecycle Analytics）

> **所属分类**：[业务规则](../README.md) - 跨环节度量
> **覆盖范围**：无法单一归类到授信环节或支用环节的派生指标
> **关联文件**：[credit-rules.md](./credit-rules.md)（授信环节） · [loan-rules.md](./loan-rules.md)（支用环节）

本文件聚焦**跨环节的派生指标**——这些指标既不属于授信环节（不是简单的"授信通过/首次授信"），也不属于支用环节（不是简单的"支用通过/首次支用"），而是要**串联授信 + 支用 + 还款**才能算出来的综合度量。

---

## 收录标准（什么时候放这里？）

**同时满足以下 3 个条件**才收进本文件：

1. ✅ 是**派生指标**（由基础业务规则 + 事实表计算出来的比率/率/分布），不是"业务认定"
2. ✅ **跨环节**（同时涉及授信 + 支用，或至少不能单一归类到 credit-rules / loan-rules）
3. ✅ 有**独立 SQL 计算逻辑**（不是简单的 SUM/COUNT，需要窗口函数、多表关联等）

**反例**（**不**收进 analytics）：
- "授信通过率" → 只用授信规则就能算 → 留在 [credit-rules.md §1](./credit-rules.md#1-授信通过credit-passed)
- "客户分层" → 用授信维度切片 → 留在 [credit-rules.md §2](./credit-rules.md#2-首次成功授信first-successful-credit)
- "支用通过率" → 只用支用规则就能算 → 留在 [loan-rules.md §1](./loan-rules.md#1-支用通过loan-passed)

---

## 章节索引

| # | 度量 | 英文标识 | 跨环节 | 当前成熟度 |
|---|------|---------|--------|-----------|
| 1 | [Vintage 逾期率](#1-vintage-逾期率vintage-delinquency-rate) | `vintage_delinquency_rate` | 授信 + 支用 + 还款 | ✅ 已实现（参见 4 个 SQL） |

---

## 1. Vintage 逾期率（Vintage Delinquency Rate）

> **业务术语**：按"批次月"（Vintage cohort month，通常是首笔授信月或首笔支用月）分群，跟踪该批次的借据在后续每个 MOB（Month on Book）观察日的逾期表现。
> **英文标识**：`vintage_delinquency_rate`
> **核心作用**：跨期、跨产品的**风险表现**度量，**必须带 `diversion_type` 切片**（业务策略对比）

### 1.1 业务定义

Vintage 逾期率回答的是**一个核心问题**：

> "**某月获得授信（或支用）的客户群**，在后续第 N 个月末（MOB N），**还有多少比例的钱没还**？"

**核心指标**：
- **分子**：`mob_N_overdue_prin`（MOB N 观察日，逾期 N+ 天 的借据剩余本金 SUM）
- **分母**：`mob_N_total_prin`（MOB N 观察日，所有借据剩余本金 SUM）
- **逾期率** = 分子 / 分母

**典型输出字段**（按月份分群，按 MOB 展开）：

| 字段 | 说明 |
|------|------|
| `cohort_month` | 批次月（首笔授信月 / 首笔支用月） |
| `diversion_type` | 分流类型（必带） |
| `overdue_level` | 逾期层次（0+ / 7+ / 30+） |
| `mob1_overdue_prin` ~ `mob24_overdue_prin` | 各 MOB 观察日的逾期本金（分子） |
| `mob1_total_prin` ~ `mob24_total_prin` | 各 MOB 观察日的全部本金（分母） |
| `total_loan_amount` | 批次累计放款金额 |
| `total_outstanding_principal` | 时点在贷余额 |

### 1.2 关键口径选择

Vintage 分析有**多种切分维度**，在不同实现里选择不同：

| 切分维度 | 实现表 | 说明 |
|---------|--------|------|
| **按首笔授信月** | `dws_customer_vintage_df`<br>`ads_customer_credit_month_vintage_df` | 客户层面的"获客批次"（marketing vintage） |
| **按首次成功授信月** | `dws_customer_first_credit_month_vintage_df`<br>`ads_customer_first_credit_month_vintage_df` | 客户在【产品+分流】下的"获客批次"（marketing vintage，粒度③） |

**为什么会有两种？**
- **首笔授信月**反映"我们什么时候获客" → 适合评估**获客质量**（早期申请被拒的客户不会进这个批次）
- **首笔支用月**反映"我们什么时候放款" → 适合评估**风控模型**（所有通过风控的客户都会进这个批次）

### 1.3 三个实现的对比

| 表名 | 批次口径 | 数据库 | 关键差异 |
|------|---------|--------|---------|
| `dws_customer_vintage_df` | `first_credit_month` | Hive | 授信级 type=1 + 借据级 type=2 兜底；24 MOB 宽表 |
| `dws_customer_first_credit_month_vintage_df` | `first_credit_month` | PostgreSQL | 授信级 type=1 + 粒度③（客户+产品+分流）；新增 product_code_sk 切片 |
| `ads_customer_credit_month_vintage_df` | `credit_month` | PostgreSQL | GA 客户数/余额 + DA 复支客户数 + 多维切片（period/annual_rate/customer_level） |

### 1.4 关键 SQL 模式（跨实现共享）

#### 模式 A：MOB 观察日计算

**Hive 版**：

```sql
CASE
    WHEN DATE_FORMAT(DATE_SUB(FROM_UNIXTIME(UNIX_TIMESTAMP('${prebizdate}', 'yyyyMMdd')), 1),'yyyyMMdd')
         >= CASE
                WHEN m.mob_n = 1
                THEN REPLACE(CAST(CONCAT(t.credit_month, '-01') AS DATE), '-', '')
                ELSE REPLACE(ADD_MONTHS(CAST(CONCAT(t.credit_month, '-01') AS DATE), m.mob_n), '-', '')
            END
    THEN LEAST(
             DATE_FORMAT(DATE_SUB(FROM_UNIXTIME(UNIX_TIMESTAMP('${prebizdate}', 'yyyyMMdd')), 1),'yyyyMMdd'),
             REPLACE(LAST_DAY(ADD_MONTHS(CAST(CONCAT(t.credit_month, '-01') AS DATE), m.mob_n)),'-', '')
         )
    ELSE NULL
END AS obs_date
```

**PostgreSQL 版**：

```sql
CASE
    WHEN TO_CHAR(TO_DATE('${prebizdate}', 'YYYYMMDD') - INTERVAL '1 day', 'YYYYMMDD') >=
         TO_CHAR((CAST(t.first_credit_month || '-01' AS DATE) + (m.mob_n || ' months')::INTERVAL) - INTERVAL '1 day', 'YYYYMMDD')
    THEN
        LEAST(
            TO_CHAR(TO_DATE('${prebizdate}', 'YYYYMMDD') - INTERVAL '1 day', 'YYYYMMDD'),
            TO_CHAR((CAST(t.first_credit_month || '-01' AS DATE) + (m.mob_n || ' months')::INTERVAL) - INTERVAL '1 day', 'YYYYMMDD')
        )
    ELSE NULL
END AS obs_date
```

**逻辑**：
- 每个 cohort_month × mob_n 计算一个**观察日**（月末日期）
- **裁剪规则**：观察日不能晚于 T-1（T-1 还没到的 MOB 不算）
- `LEAST(T-1, 每月末)`：观察日上限

#### 模式 B：MOB 月份序列生成

**Hive**：

```sql
mob_months AS (
    SELECT  1 AS mob_n UNION ALL
    SELECT  2 UNION ALL SELECT  3 UNION ALL ... SELECT  24
)
```

**PostgreSQL**：

```sql
cte5_mob_months AS (
    SELECT  1 AS mob_n UNION ALL
    SELECT  2 UNION ALL
    SELECT  3 UNION ALL
    ...
    SELECT  24
)
```

> 为什么不直接 `generate_series(1, 24)`？——**保持跨库一致性**。Hive 部分版本不支持 generate_series。

#### 模式 C：逾期本金聚合（按 overdue_level 切档）

```sql
-- 0+ / 7+ / 30+ 三档
CAST(SUM(CASE WHEN ls_mob.overdue_days_cpd > 0
              THEN NVL(ls_mob.loan_outstanding_principal, 0) ELSE 0 END) AS BIGINT) AS overdue_prin_0
CAST(SUM(CASE WHEN ls_mob.overdue_days_cpd > 7
              THEN NVL(ls_mob.loan_outstanding_principal, 0) ELSE 0 END) AS BIGINT) AS overdue_prin_7
CAST(SUM(CASE WHEN ls_mob.overdue_days_cpd > 30
              THEN NVL(ls_mob.loan_outstanding_principal, 0) ELSE 0 END) AS BIGINT) AS overdue_prin_30
```

> ⚠️ **逾期层次的口径需要业务方确认**：是 `overdue_days_cpd > 0` 还是 `>= 1`？—— `dws_repay_loan_snapshot_df.overdue_days_cpd` 字段定义参见对应 schema 文档。

#### 模式 D：Mob 行转列（24 MOB → 48 列）

```sql
MAX(CASE WHEN mob_n = 1  THEN overdue_prin ELSE NULL END) AS mob1_overdue_prin,
MAX(CASE WHEN mob_n = 1  THEN total_prin   ELSE NULL END) AS mob1_total_prin,
MAX(CASE WHEN mob_n = 2  THEN overdue_prin ELSE NULL END) AS mob2_overdue_prin,
MAX(CASE WHEN mob_n = 2  THEN total_prin   ELSE NULL END) AS mob2_total_prin,
-- ... 重复 24 次
```

#### 模式 E：分流类型兜底（多级 COALESCE）

```sql
-- 优先级：授信级 type=1 > 借据级 type=2
COALESCE(cd.credit_diversion_type, dml.diversion_type) AS diversion_type
```

> 兜底的**业务原因**：授信时已分流嵩海（`type=1 diversion_type='2'`），但支用时某些情况下 `type=2` 没记录，使用**上游分流**作为兜底，保证上下游口径一致。

### 1.5 适用场景

| 场景 | 是否使用本度量 | 典型应用 |
|------|--------------|----------|
| 跨期风险表现对比 | ✅ | "2025-Q1 获客批次的 mob3 逾期率 vs 2025-Q2 批次的 mob3 逾期率" |
| 嵩海 vs 晋商/华通 风险对比 | ✅ | **必带 `diversion_type` 切片**，衡量陪跑通道效果 |
| 新客 vs 老客 风险对比 | ✅ | 配合 `is_first_credit` 切片 |
| 客群分层风险监控 | ✅ | 配合 `customer_level` 切片（仅 ADS 表有） |
| 实时逾期监控 | ❌ | 应使用 `dws_loan_*_daily_count_di`（T+1 监控） |
| 授信通过率分析 | ❌ | 应使用 [credit-rules.md §1](./credit-rules.md#1-授信通过credit-passed) 的简单比率 |

### 1.6 关键边界

| 边界场景 | 判定 | 备注 |
|----------|------|------|
| 批次月 + MOB > T-1 月份 | 该 MOB 不计算 | `obs_date IS NULL` 过滤 |
| 客户跨产品多次授信/支用 | 取**全产品**范围内最早的批次 | 不重复计数 |
| 客户只有"申请未通过"记录 | 不进入 Vintage 批次 | 必须"首次成功" |
| `diversion_type` 为 NULL | 用下游 type=2 兜底 | 参见模式 E |
| 借据在观察日已结清（`loan_outstanding_principal = 0`） | 计入分母但分子为 0 | 不剔除结清借据 |

### 1.7 决策来源

- **业务背景**：跨期、跨产品的**风险表现**度量是风控报表的核心需求
- **实现演进**：
  - `dws_customer_vintage_df`（最早版，按首笔授信月）
  - `dws_customer_first_credit_month_vintage_df`（改为按首次成功授信月 + 产品+分流粒度③）
  - `ads_customer_credit_month_vintage_df`（增加 GA/DA 客户数 + 多维切片）
- **代码实现出处**：
  - `21-字节晋消/05-code_scripts/jcfc_xinxuan/exe_sql/dws/客户主题/dws_customer_vintage_df.sql`
  - `21-字节晋消/05-code_scripts/jcfc_xinxuan/exe_sql/dws/客户主题/dws_customer_first_credit_month_vintage_df.sql`
  - `21-字节晋消/05-code_scripts/jcfc_xinxuan/exe_sql/ads/客户主题/ads_customer_credit_month_vintage_df.sql`
- **关键设计**：
  - 必带 `diversion_type` 切片（业务策略对比）
  - 必带 `overdue_level` 切档（0+ / 7+ / 30+）
  - MOB 最多到 24（24 个月的观察期）

---

## 横向关系图（跨环节度量）

```
授信环节                支用环节                还款环节
─────────              ─────────              ─────────
dwd_fact_credit_app   dwd_fact_loan_app    dws_repay_loan_snapshot_df
       │                      │                        │
       │ 首次授信月            │ 首次支用月              │ overdue_days_cpd
       │ (cohort_month)        │ (cohort_month)          │ loan_outstanding_principal
       │                      │                        │
       └──────────┬───────────┴──────────┬─────────────┘
                  │                      │
                  │  cross join mob_n    │
                  │  (1~24)              │
                  │                      │
                  ▼                      ▼
        ┌─────────────────────────────────────────┐
        │  Vintage 逾期率（跨环节派生指标）         │
        │  - cohort_month × diversion_type         │
        │  - mob1~mob24 overdue_prin / total_prin  │
        │  - overdue_level 0+ / 7+ / 30+          │
        └─────────────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────────┐
        │  3 个实现表：                              │
        │  - dws_customer_vintage_df (Hive)         │
        │  - dws_customer_first_credit_month_vintage_df (Pg) │
        │  - ads_customer_credit_month_vintage_df (Pg)       │
        └─────────────────────────────────────────┘
```

**关键洞察**：
- Vintage **必须串联授信 + 支用 + 还款**三表
- **任何一个环节的字段口径变动**（如 `diversion_type` 判定逻辑调整）都会影响 Vintage 结果
- 这就是为什么它属于 **analytics（跨环节度量）**，而不是单环节业务规则

---

## 待补充度量（占位）

> 以下度量**当前**没有正式 SQL 实现，但有明确业务需求。当需求方提出时再补全。

| 度量 | 业务定义 | 涉及环节 | 状态 |
|------|---------|---------|------|
| 客户首支时效 | 从授信通过到首次支用申请的时间间隔 | 授信 → 支用 | 🟡 业务有需求，未实现 |
| 复支间隔 | 同客户相邻两次支用申请的时间间隔 | 支用 → 支用 | 🟡 业务有需求，未实现 |
| 授信-支用转化率 | 成功授信客户中最终有支用的客户占比 | 授信 + 支用 | 🟡 业务有需求，未实现 |
| 嵩海 vs 晋商复支率对比 | 按 `diversion_type` 切片的复支率 | 支用（带分流维度） | 🟡 业务有需求，未实现 |

---

## SQL 模板汇总（跨环节度量）

### 模板 1：Vintage 核心结构（5 个 CTE）

```sql
WITH
-- ① 业务日期参数
cte0_refresh_date_scope AS (
    SELECT '${prebizdate}' AS cur_ds
        ,TO_CHAR(TO_DATE('${prebizdate}', 'YYYYMMDD') - INTERVAL '1 day', 'YYYYMMDD') AS yesterday_ds
),

-- ② 分流维度
cte1_diversion_map AS (
    SELECT id, diversion_type
    FROM ttsp_it.dim_application_classification_mapping_di
    WHERE type = '2'  -- 借据级
      AND is_active = 'Y'
      AND ds <= '${prebizdate}'
),

-- ③ 客户首次成功授信月（粒度③：customer + product_code_sk + diversion_type）
cte2_customer_first_credit AS (
    SELECT customer_sk
        ,product_code_sk
        ,diversion_type
        ,SUBSTR(MIN(ca.apply_time), 1, 7) AS first_credit_month
    FROM ttsp_it.dwd_fact_credit_application_di ca
    WHERE ds = TO_CHAR(TO_DATE('${prebizdate}', 'YYYYMMDD') - INTERVAL '1 day', 'YYYYMMDD')
      AND is_active = 'Y'
      AND credit_status = '1'
    GROUP BY customer_sk, product_code_sk, diversion_type
),

-- ④ MOB 月份序列
cte5_mob_months AS (
    SELECT 1 AS mob_n UNION ALL SELECT 2 UNION ALL ...
    SELECT 24
),

-- ⑤ MOB 观察日计算（参见模式 A）
cte6_mob_obs_dates AS (...)

-- 主查询
SELECT ... FROM cte8_mob_agg GROUP BY ...
```

### 模板 2：分流兜底（必须）

```sql
COALESCE(cd.credit_diversion_type, dml.diversion_type) AS diversion_type
```

### 模板 3：MOB 行转列

```sql
-- 生成 24 MOB × 2 指标 = 48 列
MAX(CASE WHEN mob_n = 1  THEN overdue_prin ELSE NULL END) AS mob1_overdue_prin,
MAX(CASE WHEN mob_n = 1  THEN total_prin   ELSE NULL END) AS mob1_total_prin,
-- ... 24 次
```

### 模板 4：跨库差异（关键避坑点）

| 操作 | Hive SQL | PostgreSQL SQL |
|------|---------|---------------|
| 当前日期 | `'${prebizdate}'` | `'${prebizdate}'` |
| 减一天 | `DATE_SUB(FROM_UNIXTIME(UNIX_TIMESTAMP('${prebizdate}','yyyyMMdd')), 1)` | `TO_DATE('${prebizdate}','YYYYMMDD') - INTERVAL '1 day'` |
| 月末 | `LAST_DAY(date)` | `(date + INTERVAL '1 month' - INTERVAL '1 day')` |
| 序列生成 | `UNION ALL` 堆叠 | `UNION ALL` 堆叠（或 `generate_series`） |
| 字符串拼接 | `CONCAT(a, b)` | `a || b` |
| 空值处理 | `NVL(x, 0)` 或 `COALESCE(x, 0)` | `COALESCE(x, 0)` |

---

## 变更历史

| 日期 | 变更内容 | 变更人 |
|------|---------|--------|
| 2026-06-16 | 初始版本（Vintage 逾期率从 3 个 SQL 中提取统一模式） | - |
