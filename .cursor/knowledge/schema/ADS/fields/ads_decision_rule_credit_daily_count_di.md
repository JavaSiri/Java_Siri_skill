# ads_decision_rule_credit_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_rule_credit_daily_count_di` |
| **描述** | 授信决策规则日维统计表，按【授信申请日期 + 分流类型 + 是否嵩海 + 产品】维度统计决策申请基数及各规则命中笔数及比率 |
| **分区键** | `ds`（yyyymmdd），按授信申请日期动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（授信申请日期） |
| **金额单位** | 无金额字段 |
| **表粒度** | 授信申请日期 + 分流类型 + 是否嵩海 + 产品 |
| **回刷窗口** | [T-2, T] |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | credit_application_date | VARCHAR(8) | 【分组维度】授信申请日期，格式 yyyyMMdd |
| 2 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 3 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 4 | if_sh_flag | VARCHAR | 【分组维度】是否嵩海：Y/N |

### 核心指标-决策申请基数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 5 | decision_application_num | BIGINT | 决策申请笔数（来自 ads_node_credit_daily_count_di） |

### 核心指标-规则命中笔数

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | global_hard_rule_ovd_num | BIGINT | 全局硬规则（有历史逾期）命中笔数 |
| 7 | global_hard_rule_noovd_num | BIGINT | 全局硬规则（无历史逾期）命中笔数 |
| 8 | soft_rule_num | BIGINT | 柔性规则命中笔数 |
| 9 | customer_level_num | BIGINT | 客户评级命中笔数 |

### 核心指标-规则命中率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | global_hard_rule_ovd_rate | DECIMAL | 全局硬规则（有历史逾期）命中率 = global_hard_rule_ovd_num / decision_application_num |
| 11 | global_hard_rule_noovd_rate | DECIMAL | 全局硬规则（无历史逾期）命中率 |
| 12 | soft_rule_rate | DECIMAL | 柔性规则命中率 |
| 13 | customer_level_rate | DECIMAL | 客户评级命中率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 14 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd，等于 credit_application_date） |

---

## 关键口径说明

### 规则拆分逻辑

上游 DWS 层 `dws_decision_rule_credit_daily_count_di` 按 `rule_code` 横向拆分为四个规则命中字段：

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
| 决策申请基数 | ads_node_credit_daily_count_di | decision_application_num |
| 规则命中明细 | dws_decision_rule_credit_daily_count_di | rule_code / rule_hit_num |
