# ads_decision_rule_loan_weekly_count_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_rule_loan_weekly_count_df` |
| **描述** | 借款决策规则周维统计表，按【统计周 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记】维度统计决策申请基数及各规则累计命中笔数及比率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 周维（统计周） |
| **金额单位** | 无金额字段 |
| **表粒度** | 统计周 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记 |
| **回刷窗口** | [week_start(T-2), T-1] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | week_start_date | VARCHAR(8) | 【分组维度】统计周起始日（周一），格式 yyyyMMdd |
| 3 | week_end_date | VARCHAR(8) | 【分组维度】统计周结束日（周日），格式 yyyyMMdd |
| 4 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 5 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 6 | if_sh_flag | VARCHAR | 【分组维度】陪跑标记：1=陪跑；0=非陪跑 |
| 7 | is_first_loan | VARCHAR | 【分组维度】是否首次支用：Y=是；N=否 |

### 核心指标-决策申请基数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | decision_application_num | BIGINT | 当周决策申请累计笔数 |

### 核心指标-规则命中笔数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 9 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（历史逾期）累计命中笔数 |
| 10 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（历史未逾期）累计命中笔数 |
| 11 | soft_rule_num | BIGINT | 柔性规则累计命中笔数 |
| 12 | customer_level_num | BIGINT | 客户等级累计命中笔数 |

### 核心指标-规则命中率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 13 | global_hard_rule_ovd_rate | DECIMAL | 全局硬规则（历史逾期）累计命中率 |
| 14 | global_hard_rule_noovd_rate | DECIMAL | 全局硬规则（历史未逾期）累计命中率 |
| 15 | soft_rule_rate | DECIMAL | 柔性规则累计命中率 |
| 16 | customer_level_rate | DECIMAL | 客户等级累计命中率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 17 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 与 ads_decision_rule_loan_daily_count_di / monthly 的关系

三表粒度一致，区别仅在时间维度：

| 维度 | daily | weekly | monthly |
|------|-------|--------|---------|
| 时间维度 | loan_application_date | week_start/end_date | month_start/end_date |
| 回刷窗口 | [T-2, T] | [week_start(T-2), T-1] | [month_start(T-2), T-1] |
| 写入分区 | ds=loan_application_date | ds=T | ds=T |

### 与 ads_decision_rule_credit_weekly_count_df 的关系

两表结构一致，区别在于：

| 维度 | credit | loan |
|------|--------|------|
| 业务类型 | 授信 | 借款 |
| 额外分组维度 | 无 | is_first_loan（是否首次支用） |

### 除零保护

所有命中率使用 `NULLIF(SUM(decision_application_num), 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 决策申请基数 | ads_node_loan_daily_count_di | decision_application_num |
| 规则命中明细 | dws_decision_rule_loan_daily_count_di | rule_code / rule_hit_num |
