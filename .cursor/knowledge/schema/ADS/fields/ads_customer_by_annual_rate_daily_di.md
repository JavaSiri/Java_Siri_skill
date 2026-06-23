# ads_customer_by_annual_rate_daily_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_customer_by_annual_rate_daily_di` |
| **描述** | 客户定价日维表，按【申请日期 + 分流类型 + 产品 + 年利率】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **分区键** | `ds`（yyyymmdd），按申请日期动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（申请日期） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 申请日期 + 分流类型 + 产品 + 年利率 |
| **回刷窗口** | [T-2, T] |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

日维表字段与月维表 `ads_customer_by_annual_rate_monthly_df` 结构一致，共 74 个字段（含 ds）。

### 时间维度字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据业务日期 |
| 2 | application_date | VARCHAR(8) | 【分组维度】申请日期，格式 yyyyMMdd |

（其余字段与月维表一致，字段序号顺延）

---

## 关键口径说明

### 全局占比计算逻辑

通过 `cte1_credit_info` 和 `cte3_loan_info` 分别构建授信/借款全局汇总（不区分年利率），再与年利率维度数据 LEFT JOIN，计算各类全局占比和通过率。

### 授信与借款 FULL OUTER JOIN 合并

`cte2_credit_part` 和 `cte4_loan_part` 通过 FULL OUTER JOIN 合并，维度字段使用 `COALESCE` 取非空值，确保授信或借款单边有数据时不丢失。

### 与 ads_customer_by_level_daily_di 的关系

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
