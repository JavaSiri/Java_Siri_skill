# ads_decision_rule_loan_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_rule_loan_daily_count_di` |
| **描述** | 借款决策规则日维统计表，按【借款申请日期 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记】维度统计决策申请基数及各规则命中笔数及比率 |
| **分区键** | `ds`（yyyymmdd），按借款申请日期动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（借款申请日期） |
| **金额单位** | 无金额字段 |
| **表粒度** | 借款申请日期 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记 |
| **回刷窗口** | [T-2, T] |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_application_date | VARCHAR(8) | 【分组维度】借款申请日期，格式 yyyyMMdd |
| 2 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 3 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 4 | if_sh_flag | VARCHAR | 【分组维度】陪跑标记：1=陪跑；0=非陪跑 |
| 5 | is_first_loan | VARCHAR | 【分组维度】是否首次支用：Y=是；N=否 |

### 核心指标-决策申请基数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | decision_application_num | BIGINT | 决策申请笔数（来自 ads_node_loan_daily_count_di） |

### 核心指标-规则命中笔数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（历史逾期）命中笔数 |
| 8 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（历史未逾期）命中笔数 |
| 9 | soft_rule_num | BIGINT | 柔性规则命中笔数 |
| 10 | customer_level_num | BIGINT | 客户等级命中笔数 |

### 核心指标-规则命中率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | global_hard_rule_ovd_rate | DECIMAL | 全局硬规则（历史逾期）命中率 = global_hard_rule_ovd_num / decision_application_num |
| 12 | global_hard_rule_noovd_rate | DECIMAL | 全局硬规则（历史未逾期）命中率 |
| 13 | soft_rule_rate | DECIMAL | 柔性规则命中率 |
| 14 | customer_level_rate | DECIMAL | 客户等级命中率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 15 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd，等于 loan_application_date） |

---

## 关键口径说明

### 与 ads_decision_rule_credit_daily_count_di 的关系

两表结构完全一致，区别在于：

| 维度 | ads_decision_rule_credit_daily_count_di | ads_decision_rule_loan_daily_count_di |
|------|-------------------------------------|-------------------------------------|
| 业务类型 | 授信 | 借款 |
| 日期维度 | credit_application_date | loan_application_date |
| 额外分组维度 | 无 | is_first_loan（是否首次支用） |

### 规则拆分逻辑

上游 DWS 层 `dws_decision_rule_loan_daily_count_di` 按 `rule_code` 横向拆分为四个规则命中字段：

| rule_code | 本表字段 |
|-----------|---------|
| global_hard_rule_ovd | global_hard_rule_ovd_num |
| global_hard_rule_noovd | global_hard_rule_noovd_num |
| soft_rule | soft_rule_num |
| customer_level | customer_level_num |

### 除零保护

所有命中率使用 `NULLIF(decision_application_num, 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 决策申请基数 | ads_node_loan_daily_count_di | decision_application_num |
| 规则命中明细 | dws_decision_rule_loan_daily_count_di | rule_code / rule_hit_num |
