# ads_decision_rule_credit_monthly_count_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_rule_credit_monthly_count_df` |
| **描述** | 授信决策规则月维统计表，按【统计月 + 分流类型 + 是否嵩海 + 产品】维度统计决策申请基数及各规则累计命中笔数及比率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（统计月） |
| **金额单位** | 无金额字段 |
| **表粒度** | 统计月 + 分流类型 + 是否嵩海 + 产品 |
| **回刷窗口** | [month_start(T-2), T] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | month_start_date | VARCHAR(8) | 【分组维度】统计月起始日，格式 yyyyMMdd |
| 3 | month_end_date | VARCHAR(8) | 【分组维度】统计月结束日，格式 yyyyMMdd |
| 4 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 5 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 6 | if_sh_flag | VARCHAR | 【分组维度】是否嵩海：Y/N |

### 核心指标-决策申请基数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | decision_application_num | BIGINT | 当月决策申请累计笔数 |

### 核心指标-规则命中笔数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（有历史逾期）累计命中笔数 |
| 9 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（无历史逾期）累计命中笔数 |
| 10 | soft_rule_num | BIGINT | 柔性规则累计命中笔数 |
| 11 | customer_level_num | BIGINT | 客户评级累计命中笔数 |

### 核心指标-规则命中率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | global_hard_rule_ovd_rate | DECIMAL | 全局硬规则（有历史逾期）累计命中率 |
| 13 | global_hard_rule_noovd_rate | DECIMAL | 全局硬规则（无历史逾期）累计命中率 |
| 14 | soft_rule_rate | DECIMAL | 柔性规则累计命中率 |
| 15 | customer_level_rate | DECIMAL | 客户评级累计命中率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 16 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 与 ads_decision_rule_credit_daily_count_di 的关系

本表为月维汇总表，数据来源于日维表按月聚合：

- 历史月数据从 ds=T-1 分区继承（month_start_date < win_start_ds 的月份）
- 窗口内月份由 ads_node_credit_daily_count_di + dws_decision_rule_credit_daily_count_di 按月重算

### 除零保护

所有命中率使用 `NULLIF(SUM(decision_application_num), 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 决策申请基数 | ads_node_credit_daily_count_di | decision_application_num |
| 规则命中明细 | dws_decision_rule_credit_daily_count_di | rule_code / rule_hit_num |
