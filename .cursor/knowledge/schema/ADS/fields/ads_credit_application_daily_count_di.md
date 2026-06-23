# ads_credit_application_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_credit_application_daily_count_di` |
| **描述** | 授信申请日维统计表，按【授信申请日期 + 分流类型 + 产品】维度聚合授信申请、审批、决策、规则命中及环比等全链路指标 |
| **分区键** | `ds`（yyyymmdd），按授信申请日期动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（授信申请日期） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 授信申请日期 + 分流类型 + 产品 |
| **回刷窗口** | [T-2, T] |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期（等于授信申请日期） |
| 2 | credit_application_date | VARCHAR(8) | 【分组维度】授信申请日期，格式 yyyyMMdd |
| 3 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 4 | product_code_sk | VARCHAR | 【分组维度】产品主键 |

### 授信申请与审批

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 5 | credit_application_num | BIGINT | 授信申请笔数 |
| 6 | credit_pass_num | BIGINT | 授信通过笔数 |
| 7 | credit_deny_num | BIGINT | 授信拒绝笔数 |
| 8 | credit_fail_num | BIGINT | 授信失败笔数 |
| 9 | credit_other_num | BIGINT | 授信其他笔数 |

### 决策指标

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | decision_application_num | BIGINT | 决策申请笔数 |
| 11 | decision_pass_num | BIGINT | 决策通过笔数 |
| 12 | decision_deny_num | BIGINT | 决策拒绝笔数 |
| 13 | decision_pre_deny_num | BIGINT | 决策前拒绝笔数（系统漏出） |
| 14 | decision_suf_deny_num | BIGINT | 决策后拒绝笔数 |
| 15 | decision_application_amount | DECIMAL | 决策申请额度（元） |
| 16 | decision_pass_amount | DECIMAL | 决策通过额度（元） |
| 17 | decision_pass_rate_by_amount | DECIMAL | 决策通过率（按额度） |
| 18 | decision_pass_rate_by_num | DECIMAL | 决策通过率（按笔数） |

### 规则命中

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 19 | system_leakage_num | BIGINT | 系统漏出笔数 = decision_pre_deny_num |
| 20 | system_leakage_rate | DECIMAL | 系统漏出率 |
| 21 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（历史逾期）命中笔数 |
| 22 | global_hard_rule_ovd_rate | DECIMAL | 全局硬规则（历史逾期）命中率 |
| 23 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（历史未逾期）命中笔数 |
| 24 | global_hard_rule_noovd_rate | DECIMAL | 全局硬规则（历史未逾期）命中率 |
| 25 | soft_rule_num | BIGINT | 柔性规则命中笔数 |
| 26 | soft_rule_rate | DECIMAL | 柔性规则命中率 |
| 27 | customer_level_num | BIGINT | 客群等级命中笔数 |
| 28 | customer_level_rate | DECIMAL | 客群等级命中率 |

### 其他指标

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 29 | estimate_above_actual_num | BIGINT | 预估高于实际笔数 |

### 授信申请金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 30 | credit_application_all_amount | DECIMAL | 授信申请总金额（元） |
| 31 | credit_application_max_amount | DECIMAL | 授信申请最大金额（元） |
| 32 | credit_application_min_amount | DECIMAL | 授信申请最小金额（元） |
| 33 | credit_application_avg_amount | DECIMAL | 授信申请平均金额（元） |

### 授信通过金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 34 | credit_pass_all_amount | DECIMAL | 授信通过总金额（元） |
| 35 | credit_pass_max_amount | DECIMAL | 授信通过最大金额（元） |
| 36 | credit_pass_min_amount | DECIMAL | 授信通过最小金额（元） |
| 37 | credit_pass_avg_amount | DECIMAL | 授信通过平均金额（元） |

### 通过率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 38 | credit_pass_rate_by_num | DECIMAL | 授信通过率（按笔数） |
| 39 | credit_pass_rate_by_amount | DECIMAL | 授信通过率（按额度） |

### 加权利率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 40 | credit_application_weighted_daily_rate | DECIMAL | 授信申请加权日利率 |
| 41 | credit_application_weighted_annual_rate | DECIMAL | 授信申请加权年利率 |
| 42 | credit_pass_weighted_daily_rate | DECIMAL | 授信通过加权日利率 |
| 43 | credit_pass_weighted_annual_rate | DECIMAL | 授信通过加权年利率 |

### 环比（DoD）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 44 | credit_pass_amount_dod | DECIMAL | 授信通过金额环比增长率 = (当日 - 前日) / 前日 |
| 45 | credit_pass_amount_dod_delta | DECIMAL | 授信通过金额环比变化量（元） |
| 46 | credit_pass_num_dod | DECIMAL | 授信通过笔数环比增长率 |
| 47 | credit_pass_num_dod_delta | DECIMAL | 授信通过笔数环比变化量 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 48 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd，等于 credit_application_date） |

---

## 关键口径说明

### 与 ads_loan_application_daily_count_di 的关系

本表与借款申请日维表结构高度一致，区别在于：

| 维度 | 授信 | 借款 |
|------|------|------|
| 申请日期 | credit_application_date | loan_application_date |
| 申请/通过指标 | credit_application_num/pass_num | loan_application_num/pass_num |
| 金额字段 | credit_application/pass | loan_application/pass |

### 数据来源链路

| 上游表 | 提供指标 |
|--------|---------|
| dws_credit_application_daily_count_di | 授信申请/通过数量与金额、加权利率 |
| ads_node_credit_daily_count_di | 决策申请/通过/拒绝/前后拒绝数量与金额 |
| ads_decision_rule_credit_daily_count_di | 各类规则命中笔数 |

### 金额转换规则

- DWS 层来源：分转元（/100.0），在 CTE1 读取时统一完成
- ADS 层来源（节点/规则）：已为元，透传不做转换

### 除零保护

所有比率字段使用 `NULLIF(..., 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 授信申请/通过数量与金额 | dws_credit_application_daily_count_di | credit_application_num/pass_num 等 |
| 决策指标 | ads_node_credit_daily_count_di | decision_application_num/pass_num 等 |
| 规则命中 | ads_decision_rule_credit_daily_count_di | global_hard_rule_ovd_num/noovd_num 等 |
| 加权利率 | dws_credit_application_daily_count_di | *_amount_daily/annual_rate_sum |
