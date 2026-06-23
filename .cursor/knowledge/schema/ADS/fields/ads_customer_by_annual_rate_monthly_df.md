# ads_customer_by_annual_rate_monthly_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_customer_by_annual_rate_monthly_df` |
| **描述** | 客户定价月维表，按【统计月 + 分流类型 + 产品 + 年利率】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（统计月） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 统计月 + 分流类型 + 产品 + 年利率 |
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
| 4 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 5 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 6 | annual_rate | VARCHAR | 【分组维度】年利率 |

### 授信指标-客户数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | credit_customer_num_custprc | BIGINT | 授信申请客户数（年利率内） |
| 8 | credit_pass_customer_num_custprc | BIGINT | 授信通过客户数（年利率内） |
| 9 | credit_pass_cust_rate_inner | DECIMAL(18,8) | 授信通过率（年利率内）= credit_pass_customer_num_custprc / credit_customer_num_custprc |

### 授信指标-笔数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | credit_application_num | BIGINT | 授信申请笔数（全局） |
| 11 | credit_application_num_custprc | BIGINT | 授信申请笔数（年利率内） |
| 12 | credit_application_num_rate_to_all | DECIMAL | 授信申请笔数占比（全局）= credit_application_num_custprc / credit_application_num |
| 13 | credit_pass_num | BIGINT | 授信通过笔数（全局） |
| 14 | credit_pass_num_custprc | BIGINT | 授信通过笔数（年利率内） |
| 15 | credit_pass_num_rate_inner | DECIMAL | 授信通过笔数（年利率内）占申请笔数比率 |
| 16 | credit_pass_num_rate_to_all | DECIMAL | 授信通过笔数（年利率内）占全局比率 |
| 17 | credit_pass_num_percent_global | DECIMAL | 授信通过笔数（年利率内）占全局通过笔数比率 |
| 18 | credit_deny_num_custprc | BIGINT | 授信拒绝笔数（年利率内） |
| 19 | credit_deny_num_rate_inner | DECIMAL | 授信拒绝率（年利率内） |
| 20 | credit_fail_num_custprc | BIGINT | 授信失败笔数（年利率内） |
| 21 | credit_fail_num_rate_inner | DECIMAL | 授信失败率（年利率内） |
| 22 | credit_other_num_custprc | BIGINT | 授信其他笔数（年利率内） |
| 23 | credit_other_num_rate_inner | DECIMAL | 授信其他率（年利率内） |

### 授信指标-金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 24 | credit_application_total_amount | DECIMAL | 授信申请总金额（元，全局） |
| 25 | credit_application_total_amount_custprc | DECIMAL | 授信申请总金额（元，年利率内） |
| 26 | credit_application_amt_rate_to_all | DECIMAL | 授信申请金额占比（全局） |
| 27 | credit_pass_total_amount | DECIMAL | 授信通过总金额（元，全局） |
| 28 | credit_pass_total_amount_custprc | DECIMAL | 授信通过总金额（元，年利率内） |
| 29 | credit_pass_amt_rate_inner | DECIMAL | 授信通过金额（年利率内）占申请金额比率 |
| 30 | credit_pass_amt_rate_to_all | DECIMAL | 授信通过金额（年利率内）占全局比率 |
| 31 | credit_pass_amt_percent_global | DECIMAL | 授信通过金额（年利率内）占全局通过金额比率 |
| 32 | credit_pass_avg_amount_custprc | DECIMAL | 授信通过平均金额（元，年利率内） |
| 33 | credit_pass_avg_amount_global | DECIMAL | 授信通过平均金额（元，全局） |

### 借款指标-客户数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 34 | loan_customer_num_custprc | BIGINT | 借款申请客户数（年利率内） |
| 35 | loan_pass_customer_num_custprc | BIGINT | 借款通过客户数（年利率内） |
| 36 | loan_pass_cust_rate_inner | DECIMAL | 借款通过率（年利率内） |

### 借款指标-笔数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 37 | loan_application_num | BIGINT | 借款申请笔数（全局） |
| 38 | loan_application_num_custprc | BIGINT | 借款申请笔数（年利率内） |
| 39 | loan_application_num_rate_to_all | DECIMAL | 借款申请笔数占比（全局） |
| 40 | loan_pass_num | BIGINT | 借款通过笔数（全局） |
| 41 | loan_pass_num_custprc | BIGINT | 借款通过笔数（年利率内） |
| 42 | loan_pass_num_rate_inner | DECIMAL | 借款通过笔数（年利率内）占申请笔数比率 |
| 43 | loan_pass_num_rate_to_all | DECIMAL | 借款通过笔数（年利率内）占全局比率 |
| 44 | loan_pass_num_percent_global | DECIMAL | 借款通过笔数（年利率内）占全局通过笔数比率 |
| 45 | loan_deny_num_custprc | BIGINT | 借款拒绝笔数（年利率内） |
| 46 | loan_deny_num_rate_inner | DECIMAL | 借款拒绝率（年利率内） |
| 47 | loan_fail_num_custprc | BIGINT | 借款失败笔数（年利率内） |
| 48 | loan_fail_num_rate_inner | DECIMAL | 借款失败率（年利率内） |
| 49 | loan_other_num_custprc | BIGINT | 借款其他笔数（年利率内） |
| 50 | loan_other_num_rate_inner | DECIMAL | 借款其他率（年利率内） |

### 借款指标-金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 51 | loan_application_total_amount | DECIMAL | 借款申请总金额（元，全局） |
| 52 | loan_application_total_amount_custprc | DECIMAL | 借款申请总金额（元，年利率内） |
| 53 | loan_application_amt_rate_to_all | DECIMAL | 借款申请金额占比（全局） |
| 54 | loan_pass_total_amount | DECIMAL | 借款通过总金额（元，全局） |
| 55 | loan_pass_total_amount_custprc | DECIMAL | 借款通过总金额（元，年利率内） |
| 56 | loan_pass_amt_rate_inner | DECIMAL | 借款通过金额（年利率内）占申请金额比率 |
| 57 | loan_pass_amt_rate_to_all | DECIMAL | 借款通过金额（年利率内）占全局比率 |
| 58 | loan_pass_amt_percent_global | DECIMAL | 借款通过金额（年利率内）占全局通过金额比率 |
| 59 | loan_pass_avg_amount_custprc | DECIMAL | 借款通过平均金额（元，年利率内） |
| 60 | loan_pass_avg_amount_global | DECIMAL | 借款通过平均金额（元，全局） |

### 逾期/早期/优质客户

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 61 | total_customer_num_custprc | BIGINT | 总客户数（年利率内） |
| 62 | overdue_customer_num_custprc | BIGINT | 逾期客户数（年利率内） |
| 63 | overdue_loan_num_custprc | BIGINT | 逾期笔数（年利率内） |
| 64 | overdue_times_custprc | BIGINT | 逾期次数（年利率内） |
| 65 | overdue_max_period_custprc | BIGINT | 逾期最大期数（年利率内） |
| 66 | overdue_min_period_custprc | BIGINT | 逾期最小期数（年利率内） |
| 67 | early_customer_num_custprc | BIGINT | 早期逾期客户数（年利率内） |
| 68 | early_loan_num_custprc | BIGINT | 早期逾期笔数（年利率内） |
| 69 | early_times_custprc | BIGINT | 早期逾期次数（年利率内） |
| 70 | early_max_period_custprc | BIGINT | 早期逾期最大期数（年利率内） |
| 71 | early_min_period_custprc | BIGINT | 早期逾期最小期数（年利率内） |
| 72 | nice_customer_num_custprc | BIGINT | 优质客户数（年利率内） |
| 73 | nice_application_times_custprc | BIGINT | 优质客户申请次数（年利率内） |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 74 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 与 ads_customer_by_level_monthly_df 的关系

两表结构高度一致，区别在于分组维度：

| 维度 | annual_rate 系列 | level 系列 |
|------|----------------|----------|
| 分组维度 | annual_rate（年利率） | customer_level（客户等级） |

### 全局占比计算逻辑

通过 `cte3_credit_full_month` 和 `cte4_loan_full_month` 分别构建授信/借款全局汇总（不区分年利率），再与年利率维度数据 LEFT JOIN，计算各类全局占比和通过率。

### 除零保护

所有比率字段使用 `NULLIF(..., 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 年利率维度原始指标 | dws_customer_by_annual_rate_daily_di | 各指标字段 |
| 授信全局汇总 | dws_credit_application_daily_count_di | credit_application_num/pass_num/all_amount |
| 借款全局汇总 | dws_loan_application_daily_count_di | loan_application_num/pass_num/all_amount |
