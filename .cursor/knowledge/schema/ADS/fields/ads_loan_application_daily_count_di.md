# ads_loan_application_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_loan_application_daily_count_di` |
| **描述** | 借款申请日维统计（产品粒度），包含申请/通过/决策/规则命中/环比等全链路指标 |
| **分区键** | `ds`（yyyymmdd），按借款申请日期动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（借款申请日期） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 借款申请日期 + 产品 + 分流类型 + 是否首次支用 |
| **回刷窗口** | [T-3, T-1] |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据日期（与借款申请日期相同） |
| 2 | loan_application_date | VARCHAR(8) | 【分组维度】借款申请日期，格式 yyyyMMdd |
| 3 | diversion_type | VARCHAR(10) | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 4 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 5 | is_first_loan | VARCHAR(1) | 【分组维度】是否首次支用：Y=是；N=否 |

### 借款申请与审批

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | loan_application_num | BIGINT | 借款申请笔数 |
| 7 | loan_pass_num | BIGINT | 借款通过笔数 |
| 8 | loan_deny_num | BIGINT | 借款拒绝笔数 |
| 9 | loan_fail_num | BIGINT | 借款失败笔数 |
| 10 | loan_other_num | BIGINT | 借款其他笔数 |

### 复借申请与审批

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | loan_repayment_application_num | BIGINT | 复借申请笔数 |
| 12 | loan_repayment_pass_num | BIGINT | 复借通过笔数 |
| 13 | loan_repayment_deny_num | BIGINT | 复借拒绝笔数 |
| 14 | loan_repayment_fail_num | BIGINT | 复借失败笔数 |
| 15 | loan_repayment_other_num | BIGINT | 复借其他笔数 |

### 决策指标

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 16 | decision_application_num | BIGINT | 决策申请笔数 |
| 17 | decision_pass_num | BIGINT | 决策通过笔数 |
| 18 | decision_deny_num | BIGINT | 决策拒绝笔数 |
| 19 | decision_pre_deny_num | BIGINT | 决策前拒绝笔数（系统漏出） |
| 20 | decision_suf_deny_num | BIGINT | 决策后拒绝笔数 |
| 21 | decision_application_amount | DECIMAL(38,18) | 决策申请额度（元） |
| 22 | decision_pass_amount | DECIMAL(38,18) | 决策通过额度（元） |
| 23 | decision_pass_rate_by_amount | DECIMAL(38,18) | 决策通过率（按额度）= decision_pass_amount / decision_application_amount |
| 24 | decision_pass_rate_by_num | DECIMAL(38,18) | 决策通过率（按笔数）= decision_pass_num / decision_application_num |

### 规则命中

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 25 | system_leakage_num | BIGINT | 系统漏出笔数 = decision_pre_deny_num |
| 26 | system_leakage_rate | DECIMAL(38,18) | 系统漏出率 = system_leakage_num / loan_application_num |
| 27 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（历史逾期）命中笔数 |
| 28 | global_hard_rule_ovd_rate | DECIMAL(38,18) | 全局硬规则（历史逾期）命中率 |
| 29 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（历史未逾期）命中笔数 |
| 30 | global_hard_rule_noovd_rate | DECIMAL(38,18) | 全局硬规则（历史未逾期）命中率 |
| 31 | soft_rule_num | BIGINT | 柔性规则命中笔数 |
| 32 | soft_rule_rate | DECIMAL(38,18) | 柔性规则命中率 |
| 33 | customer_level_num | BIGINT | 客群等级命中笔数 |
| 34 | customer_level_rate | DECIMAL(38,18) | 客群等级命中率 |

### 借款申请金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 35 | loan_application_all_amount | DECIMAL(38,18) | 借款申请总金额（元） |
| 36 | loan_application_max_amount | DECIMAL(38,18) | 借款申请最大金额（元） |
| 37 | loan_application_min_amount | DECIMAL(38,18) | 借款申请最小金额（元） |
| 38 | loan_application_avg_amount | DECIMAL(38,18) | 借款申请平均金额（元） |

### 借款通过金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 39 | loan_pass_all_amount | DECIMAL(38,18) | 借款通过总金额（元） |
| 40 | loan_pass_max_amount | DECIMAL(38,18) | 借款通过最大金额（元） |
| 41 | loan_pass_min_amount | DECIMAL(38,18) | 借款通过最小金额（元） |
| 42 | loan_pass_avg_amount | DECIMAL(38,18) | 借款通过平均金额（元） |

### 复借申请金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 43 | loan_repayment_application_all_amount | DECIMAL(38,18) | 复借申请总金额（元） |
| 44 | loan_repayment_application_max_amount | DECIMAL(38,18) | 复借申请最大金额（元） |
| 45 | loan_repayment_application_min_amount | DECIMAL(38,18) | 复借申请最小金额（元） |
| 46 | loan_repayment_application_avg_amount | DECIMAL(38,18) | 复借申请平均金额（元） |

### 复借通过金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 47 | loan_repayment_pass_all_amount | DECIMAL(38,18) | 复借通过总金额（元） |
| 48 | loan_repayment_pass_max_amount | DECIMAL(38,18) | 复借通过最大金额（元） |
| 49 | loan_repayment_pass_min_amount | DECIMAL(38,18) | 复借通过最小金额（元） |
| 50 | loan_repayment_pass_avg_amount | DECIMAL(38,18) | 复借通过平均金额（元） |

### 通过率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 51 | loan_pass_rate_by_num | DECIMAL(38,18) | 借款通过率（按笔数）= loan_pass_num / loan_application_num |
| 52 | loan_pass_rate_by_amount | DECIMAL(38,18) | 借款通过率（按额度）= loan_pass_all_amount / loan_application_all_amount |
| 53 | end_to_end_pass_rate_by_num | DECIMAL(38,18) | 端到端通过率（按笔数）= loan_repayment_pass_num / loan_application_num |
| 54 | end_to_end_pass_rate_by_amount | DECIMAL(38,18) | 端到端通过率（按额度）= loan_repayment_pass_all_amount / loan_application_all_amount |

### 加权利率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 55 | loan_application_weighted_daily_rate | DECIMAL(38,18) | 借款申请加权日利率 = SUM(日利率×金额) / 申请总金额 |
| 56 | loan_application_weighted_annual_rate | DECIMAL(38,18) | 借款申请加权年利率 |
| 57 | loan_pass_weighted_daily_rate | DECIMAL(38,18) | 借款通过加权日利率 |
| 58 | loan_pass_weighted_annual_rate | DECIMAL(38,18) | 借款通过加权年利率 |
| 59 | loan_repayment_application_weighted_daily_rate | DECIMAL(38,18) | 复借申请加权日利率 |
| 60 | loan_repayment_application_weighted_annual_rate | DECIMAL(38,18) | 复借申请加权年利率 |
| 61 | loan_repayment_pass_weighted_daily_rate | DECIMAL(38,18) | 复借通过加权日利率 |
| 62 | loan_repayment_pass_weighted_annual_rate | DECIMAL(38,18) | 复借通过加权年利率 |

### 环比（DoD）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 63 | loan_pass_amount_dod | DECIMAL(38,18) | 借款通过金额环比增长率 = (当日 - 前日) / 前日 |
| 64 | loan_pass_amount_dod_delta | DECIMAL(38,18) | 借款通过金额环比变化量（元） |
| 65 | loan_pass_num_dod | DECIMAL(38,18) | 借款通过笔数环比增长率 |
| 66 | loan_pass_num_dod_delta | BIGINT | 借款通过笔数环比变化量 |
| 67 | loan_repayment_pass_amount_dod | DECIMAL(38,18) | 复借通过金额环比增长率 |
| 68 | loan_repayment_pass_amount_dod_delta | DECIMAL(38,18) | 复借通过金额环比变化量（元） |
| 69 | loan_repayment_pass_num_dod | DECIMAL(38,18) | 复借通过笔数环比增长率 |
| 70 | loan_repayment_pass_num_dod_delta | BIGINT | 复借通过笔数环比变化量 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 71 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd，等于 loan_application_date） |

---

## 关键口径说明

### 数据来源链路

本表聚合来自三个上游表的指标：

| 上游表 | 提供指标 |
|--------|---------|
| dws_loan_application_daily_count_di | 借款申请/通过/复借数量与金额、加权利率 |
| ads_node_loan_daily_count_di | 决策申请/通过/拒绝/前后拒绝数量与金额 |
| ads_decision_rule_loan_daily_count_di | 各类规则命中笔数 |

### 金额转换规则

- DWS 层来源：分转元（/100.0），在 CTE1 读取时统一完成
- ADS 层来源（节点/规则）：已为元，透传不做转换

### 环比计算逻辑

- 基准数据来自自身表上一日分区（ds = loan_application_date - 1）
- 环比 JOIN 条件包含 product_code_sk，防止跨产品数据错位

### 除零保护

所有比率字段使用 `NULLIF(被除数, 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 借款申请/通过数量与金额 | dws_loan_application_daily_count_di | loan_application_num/pass_num 等 |
| 决策指标 | ads_node_loan_daily_count_di | decision_application_num/pass_num/deny_num 等 |
| 规则命中 | ads_decision_rule_loan_daily_count_di | global_hard_rule_ovd_num/noovd_num/soft_rule_num 等 |
| 加权利率 | dws_loan_application_daily_count_di | *_amount_daily/annual_rate_sum |
