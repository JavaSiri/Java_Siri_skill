# ads_customer_by_annual_rate_weekly_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_customer_by_annual_rate_weekly_df` |
| **描述** | 客户定价周维表，按【统计周 + 分流类型 + 产品 + 年利率】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 周维（统计周） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 统计周 + 分流类型 + 产品 + 年利率 |
| **回刷窗口** | [week_start(T-2), T] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

周维表字段与月维表 `ads_customer_by_annual_rate_monthly_df` 完全一致，共 74 个字段，区别仅在于时间维度为周。

### 时间维度字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | week_start_date | VARCHAR(8) | 【分组维度】统计周起始日（周一），格式 yyyyMMdd |
| 3 | week_end_date | VARCHAR(8) | 【分组维度】统计周结束日（周日），格式 yyyyMMdd |

（其余字段与月维表一致，字段序号顺延）

---

## 关键口径说明

### 与 ads_customer_by_annual_rate_monthly_df 的关系

两表结构完全一致，区别仅在时间维度：

| 维度 | monthly | weekly |
|------|---------|--------|
| 时间维度 | month_start/end_date | week_start/end_date |
| 回刷窗口 | [month_start(T-2), T] | [week_start(T-2), T] |
| 写入分区 | ds=T | ds=T |

### 与 ads_customer_by_level_weekly_df 的关系

两表结构一致，区别在于分组维度：

| 维度 | annual_rate 系列 | level 系列 |
|------|----------------|----------|
| 分组维度 | annual_rate（年利率） | customer_level（客户等级） |

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 年利率维度原始指标 | dws_customer_by_annual_rate_daily_di | 各指标字段 |
| 授信全局汇总 | dws_credit_application_daily_count_di | credit_application_num/pass_num/all_amount |
| 借款全局汇总 | dws_loan_application_daily_count_di | loan_application_num/pass_num/all_amount |
