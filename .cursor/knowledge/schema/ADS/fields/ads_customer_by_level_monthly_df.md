# ads_customer_by_level_monthly_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_customer_by_level_monthly_df` |
| **描述** | 客户分层月维表，按【统计月 + 分流类型 + 客户等级 + 产品】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（统计月） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 统计月 + 分流类型 + 客户等级 + 产品 |
| **回刷窗口** | [month_start(T-2), T] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

字段结构与 `ads_customer_by_annual_rate_monthly_df` 完全一致，共 74 个字段，区别在于 `annual_rate` 维度替换为 `customer_level`。

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | month_start_date | VARCHAR(8) | 【分组维度】统计月起始日，格式 yyyyMMdd |
| 3 | month_end_date | VARCHAR(8) | 【分组维度】统计月结束日，格式 yyyyMMdd |
| 4 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 5 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 6 | customer_level | VARCHAR | 【分组维度】客户等级 |

（其余字段与 `ads_customer_by_annual_rate_monthly_df` 一致）

---

## 关键口径说明

### 与 ads_customer_by_annual_rate_monthly_df 的关系

两表字段结构完全一致，区别在于分组维度：

| 维度 | annual_rate 系列 | level 系列 |
|------|----------------|----------|
| 分组维度 | annual_rate（年利率） | customer_level（客户等级） |

### 全局占比计算逻辑

通过 `cte3_credit_full_month` 和 `cte4_loan_full_month` 分别构建授信/借款全局汇总（不区分客户等级），再与客户等级维度数据 LEFT JOIN，计算各类全局占比和通过率。

### JOIN NULL 值处理

JOIN 条件使用 `COALESCE(...,'__NULL__')` 处理 NULL 值，防止 NULL 匹配丢失数据。

### 除零保护

所有比率字段使用 `NULLIF(..., 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 客户等级维度原始指标 | dws_customer_by_level_daily_di | 各指标字段 |
| 授信全局汇总 | dws_credit_application_daily_count_di | credit_application_num/pass_num/all_amount |
| 借款全局汇总 | dws_loan_application_daily_count_di | loan_application_num/pass_num/all_amount |
