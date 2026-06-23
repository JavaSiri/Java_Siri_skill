# ads_loan_application_monthly_count_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_loan_application_monthly_count_df` |
| **描述** | 借款申请月维统计表，按借款申请月+分流类型+产品维度聚合借款申请、决策、规则命中等指标 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（借款申请月） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 借款申请月 + 产品 + 分流类型 + 是否首次支用 |
| **回刷窗口** | [month_start(T-3), T-1] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T-1 分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | month_start_date | VARCHAR(8) | 【分组维度】借款申请月起始日，格式 yyyyMMdd |
| 3 | month_end_date | VARCHAR(8) | 【分组维度】借款申请月结束日，格式 yyyyMMdd |
| 4 | diversion_type | VARCHAR(10) | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 5 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 6 | is_first_loan | VARCHAR(1) | 【分组维度】是否首次支用：Y=是；N=否 |

### 借款申请与审批

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | loan_application_num | BIGINT | 借款申请笔数 |
| 8 | loan_pass_num | BIGINT | 借款通过笔数 |
| 9 | loan_deny_num | BIGINT | 借款拒绝笔数 |
| 10 | loan_fail_num | BIGINT | 借款失败笔数 |
| 11 | loan_other_num | BIGINT | 借款其他笔数 |

### 复借申请与审批

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | loan_repayment_application_num | BIGINT | 复借申请笔数 |
| 13 | loan_repayment_pass_num | BIGINT | 复借通过笔数 |
| 14 | loan_repayment_deny_num | BIGINT | 复借拒绝笔数 |
| 15 | loan_repayment_fail_num | BIGINT | 复借失败笔数 |
| 16 | loan_repayment_other_num | BIGINT | 复借其他笔数 |

### 决策指标

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 17 | decision_application_num | BIGINT | 决策申请笔数 |
| 18 | decision_pass_num | BIGINT | 决策通过笔数 |
| 19 | decision_deny_num | BIGINT | 决策拒绝笔数 |
| 20 | decision_pre_deny_num | BIGINT | 决策前拒绝笔数（系统漏出） |
| 21 | decision_suf_deny_num | BIGINT | 决策后拒绝笔数 |
| 22 | decision_application_amount | DECIMAL(38,18) | 决策申请额度（元） |
| 23 | decision_pass_amount | DECIMAL(38,18) | 决策通过额度（元） |
| 24 | decision_pass_rate_by_amount | DECIMAL(38,18) | 决策通过率（按额度） |
| 25 | decision_pass_rate_by_num | DECIMAL(38,18) | 决策通过率（按笔数） |

### 规则命中

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 26 | system_leakage_num | BIGINT | 系统漏出笔数 |
| 27 | system_leakage_rate | DECIMAL(38,18) | 系统漏出率 |
| 28 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（历史逾期）命中笔数 |
| 29 | global_hard_rule_ovd_rate | DECIMAL(38,18) | 全局硬规则（历史逾期）命中率 |
| 30 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（历史未逾期）命中笔数 |
| 31 | global_hard_rule_noovd_rate | DECIMAL(38,18) | 全局硬规则（历史未逾期）命中率 |
| 32 | soft_rule_num | BIGINT | 柔性规则命中笔数 |
| 33 | soft_rule_rate | DECIMAL(38,18) | 柔性规则命中率 |
| 34 | customer_level_num | BIGINT | 客群等级命中笔数 |
| 35 | customer_level_rate | DECIMAL(38,18) | 客群等级命中率 |

### 借款申请金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 36 | loan_application_all_amount | DECIMAL(38,18) | 借款申请总金额（元） |
| 37 | loan_application_max_amount | DECIMAL(38,18) | 借款申请最大金额（元） |
| 38 | loan_application_min_amount | DECIMAL(38,18) | 借款申请最小金额（元） |
| 39 | loan_application_avg_amount | DECIMAL(38,18) | 借款申请平均金额（元） |

### 借款通过金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 40 | loan_pass_all_amount | DECIMAL(38,18) | 借款通过总金额（元） |
| 41 | loan_pass_max_amount | DECIMAL(38,18) | 借款通过最大金额（元） |
| 42 | loan_pass_min_amount | DECIMAL(38,18) | 借款通过最小金额（元） |
| 43 | loan_pass_avg_amount | DECIMAL(38,18) | 借款通过平均金额（元） |

### 复借申请金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 44 | loan_repayment_application_all_amount | DECIMAL(38,18) | 复借申请总金额（元） |
| 45 | loan_repayment_application_max_amount | DECIMAL(38,18) | 复借申请最大金额（元） |
| 46 | loan_repayment_application_min_amount | DECIMAL(38,18) | 复借申请最小金额（元） |
| 47 | loan_repayment_application_avg_amount | DECIMAL(38,18) | 复借申请平均金额（元） |

### 复借通过金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 48 | loan_repayment_pass_all_amount | DECIMAL(38,18) | 复借通过总金额（元） |
| 49 | loan_repayment_pass_max_amount | DECIMAL(38,18) | 复借通过最大金额（元） |
| 50 | loan_repayment_pass_min_amount | DECIMAL(38,18) | 复借通过最小金额（元） |
| 51 | loan_repayment_pass_avg_amount | DECIMAL(38,18) | 复借通过平均金额（元） |

### 通过率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 52 | loan_pass_rate_by_num | DECIMAL(38,18) | 借款通过率（按笔数） |
| 53 | loan_pass_rate_by_amount | DECIMAL(38,18) | 借款通过率（按额度） |
| 54 | end_to_end_pass_rate_by_num | DECIMAL(38,18) | 端到端通过率（按笔数） |
| 55 | end_to_end_pass_rate_by_amount | DECIMAL(38,18) | 端到端通过率（按额度） |

### 加权利率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 56 | loan_application_weighted_daily_rate | DECIMAL(38,18) | 借款申请加权日利率 |
| 57 | loan_application_weighted_annual_rate | DECIMAL(38,18) | 借款申请加权年利率 |
| 58 | loan_pass_weighted_daily_rate | DECIMAL(38,18) | 借款通过加权日利率 |
| 59 | loan_pass_weighted_annual_rate | DECIMAL(38,18) | 借款通过加权年利率 |
| 60 | loan_repayment_application_weighted_daily_rate | DECIMAL(38,18) | 复借申请加权日利率 |
| 61 | loan_repayment_application_weighted_annual_rate | DECIMAL(38,18) | 复借申请加权年利率 |
| 62 | loan_repayment_pass_weighted_daily_rate | DECIMAL(38,18) | 复借通过加权日利率 |
| 63 | loan_repayment_pass_weighted_annual_rate | DECIMAL(38,18) | 复借通过加权年利率 |

### 环比（MoM）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 64 | loan_pass_amount_mom | DECIMAL(38,18) | 借款通过金额环比增长率 = (当月 - 上月) / 上月 |
| 65 | loan_pass_amount_mom_delta | DECIMAL(38,18) | 借款通过金额环比变化量（元） |
| 66 | loan_pass_num_mom | DECIMAL(38,18) | 借款通过笔数环比增长率 |
| 67 | loan_pass_num_mom_delta | BIGINT | 借款通过笔数环比变化量 |
| 68 | loan_repayment_pass_amount_mom | DECIMAL(38,18) | 复借通过金额环比增长率 |
| 69 | loan_repayment_pass_amount_mom_delta | DECIMAL(38,18) | 复借通过金额环比变化量（元） |
| 70 | loan_repayment_pass_num_mom | DECIMAL(38,18) | 复借通过笔数环比增长率 |
| 71 | loan_repayment_pass_num_mom_delta | BIGINT | 复借通过笔数环比变化量 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 72 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 与 ads_loan_application_daily_count_di 的关系

本表为月维汇总表，与日维表字段结构一致，区别在于：

| 维度 | ads_loan_application_daily_count_di | ads_loan_application_monthly_count_df |
|------|-------------------------------------|---------------------------------------|
| 时间维度 | 借款申请日期 | 借款申请月（month_start_date / month_end_date） |
| 环比类型 | DoD（日环比） | MoM（月环比） |
| 回刷窗口 | [T-3, T-1] | [month_start(T-3), T-1] |

### 历史继承 + 窗口重算机制

- 历史月数据从 ds=T-2 分区继承（month_start_date < win_start_ds 的月份）
- 窗口内月份由上游日维数据重算，并叠加月环比
- 最终写入 ds=T-1 分区

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
