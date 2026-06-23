# ads_decision_reject_code_daily_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_reject_code_daily_di` |
| **描述** | 决策拒绝码日维表，按【决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码】维度统计拒绝码命中笔数及决策通过率 |
| **分区键** | `ds`（yyyymmdd），按 data_date 动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（data_date） |
| **金额单位** | 无金额字段 |
| **表粒度** | data_date + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码 |
| **回刷窗口** | [T-2, T] |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 【分组维度】数据业务日期，格式 yyyyMMdd |
| 2 | type | VARCHAR | 【分组维度】决策类型：1=授信；2=借款 |
| 3 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 4 | is_first_loan | VARCHAR | 【分组维度】是否首次支用：Y=是；N=否 |
| 5 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 6 | if_sh_flag | VARCHAR | 【分组维度】陪跑标记：1=陪跑；0=非陪跑 |
| 7 | rule_code | VARCHAR | 【分组维度】决策规则编码 |
| 8 | reject_code | VARCHAR | 【分组维度】拒绝码 |

### 核心指标

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 9 | reject_code_hit_num | BIGINT | 当日被该拒绝码打中的申请笔数 |
| 10 | decision_application_num | BIGINT | 当日进入决策的申请笔数 |
| 11 | decision_pass_rate_by_reject_code | NUMERIC(38,18) | 当日该拒绝码下的决策通过率 = reject_code_hit_num / decision_application_num |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd，等于 data_date） |

---

## 关键口径说明

### 与 ads_decision_rule_* 的关系

本表与 decision_rule 系列表的区别：

| 维度 | decision_rule_* | decision_reject_code_* |
|------|----------------|----------------------|
| 粒度 | 按规则大类聚合 | 按规则编码 + 拒绝码明细聚合 |
| 指标 | 各规则命中笔数 | 各拒绝码命中笔数 |
| 数据来源 | dws_decision_rule_*_daily_count_di | dws_decision_reject_code_daily_di |

### 除零保护

decision_pass_rate_by_reject_code 使用 `NULLIF(decision_application_num, 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 拒绝码命中与决策申请 | dws_decision_reject_code_daily_di | reject_code_hit_num / decision_application_num |
