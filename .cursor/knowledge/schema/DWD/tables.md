# DWD 层表索引

本文档为 DWD 层 10 张表的表级别入口索引，提供表归属主题、表类型、分区策略、表粒度等概览信息，便于快速检索目标表。

---

## 主题分布总览

| 主题 | 表数量 | 表名 |
|------|:------:|------|
| 授信事实 | 1 | `dwd_fact_credit_application_di` |
| 借款事实 | 1 | `dwd_fact_loan_application_di` |
| 决策事实 | 2 | `dwd_fact_decision_execution_di`、`dwd_fact_decision_result_reject_code_di` |
| 还款事实 | 1 | `dwd_fact_repayment_di` |
| 分类维度 | 1 | `dim_application_classification_mapping_di` |
| 节点维度 | 3 | `dim_node_decision_mapping_iri`、`dim_credit_node_di`、`dim_loan_node_di` |
| 还款维度 | 2 | `dim_repay_plan_di`、`dim_repay_plan_latest_df` |
| 规则维度 | 1 | `dim_decision_rule_reject_mapping_iri` |
| 公共维度 | 1 | `dim_date_irf` |

---

## 表索引

### 授信事实

#### dwd_fact_credit_application_di

| 属性 | 值 |
|------|-----|
| **描述** | 授信申请事实表 |
| **表类型** | 事实表（Fact） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | 授信申请级（credit_sk 为业务主键） |
| **分布键** | HASH (credit_sk) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 分 |
| **字段数** | 22 |
| **字段级文档** | [dwd_fact_credit_application_di.md](./fields/dwd_fact_credit_application_di.md) |

---

### 借款事实

#### dwd_fact_loan_application_di

| 属性 | 值 |
|------|-----|
| **描述** | 借款申请事实表 |
| **表类型** | 事实表（Fact） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | 借款申请/借据级（loan_id 为业务主键） |
| **分布键** | HASH (loan_id) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 分 |
| **字段数** | 38 |
| **字段级文档** | [dwd_fact_loan_application_di.md](./fields/dwd_fact_loan_application_di.md) |

---

### 决策事实

#### dwd_fact_decision_execution_di

| 属性 | 值 |
|------|-----|
| **描述** | 决策执行事实表 |
| **表类型** | 事实表（Fact） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | 决策事件级（id = 授信ID/借据号/调额调价ID） |
| **分布键** | HASH (id) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 分（application_amount） |
| **字段数** | 19 |
| **字段级文档** | [dwd_fact_decision_execution_di.md](./fields/dwd_fact_decision_execution_di.md) |

---

#### dwd_fact_decision_result_reject_code_di

| 属性 | 值 |
|------|-----|
| **描述** | 决策结果拒绝码事实表 |
| **表类型** | 事实表（Fact） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | 拒绝码事件级（id + reject_code） |
| **分布键** | HASH (id) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 无金额字段 |
| **字段数** | 11 |
| **字段级文档** | [dwd_fact_decision_result_reject_code_di.md](./fields/dwd_fact_decision_result_reject_code_di.md) |

---

### 还款事实

#### dwd_fact_repayment_di

| 属性 | 值 |
|------|-----|
| **描述** | 还款流水事实表 |
| **表类型** | 事实表（Fact） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | 还款流水级（repay_sk 为业务主键） |
| **分布键** | HASH (repay_sk) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 分 |
| **字段数** | 40 |
| **字段级文档** | [dwd_fact_repayment_di.md](./fields/dwd_fact_repayment_di.md) |

---

### 分类维度

#### dim_application_classification_mapping_di

| 属性 | 值 |
|------|-----|
| **描述** | 申请分类映射维度表 |
| **表类型** | 维度表（Dim） |
| **时间维度** | 日维（ds，yyyymmdd） |
| **表粒度** | 授信/借据级（id = 授信ID/借据号） |
| **分布键** | HASH (id) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 无金额字段 |
| **字段数** | 13 |
| **字段级文档** | [dim_application_classification_mapping_di.md](./fields/dim_application_classification_mapping_di.md) |

---

### 节点维度

#### dim_node_decision_mapping_iri

| 属性 | 值 |
|------|-----|
| **描述** | 节点映射维度表 |
| **表类型** | 维度表（Dim，Irf/镜像表） |
| **时间维度** | 无分区（全局表） |
| **表粒度** | 节点级（node_id） |
| **分布键** | HASH (node_id) |
| **分区策略** | 无分区 |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 无金额字段 |
| **字段数** | 7 |
| **字段级文档** | [dim_node_decision_mapping_iri.md](./fields/dim_node_decision_mapping_iri.md) |

---

#### dim_credit_node_di

| 属性 | 值 |
|------|-----|
| **描述** | 授信节点维度表 |
| **表类型** | 维度表（Dim） |
| **时间维度** | 日维（ds，yyyymmdd） |
| **表粒度** | 授信+节点级（credit_sk + node_id） |
| **分布键** | HASH (credit_sk) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 秒（duration_seconds） |
| **字段数** | 13 |
| **字段级文档** | [dim_credit_node_di.md](./fields/dim_credit_node_di.md) |

---

#### dim_loan_node_di

| 属性 | 值 |
|------|-----|
| **描述** | 借款节点维度表 |
| **表类型** | 维度表（Dim） |
| **时间维度** | 日维（ds，yyyymmdd） |
| **表粒度** | 借据+节点级（loan_id + node_id） |
| **分布键** | HASH (loan_id) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 秒（duration_seconds） |
| **字段数** | 13 |
| **字段级文档** | [dim_loan_node_di.md](./fields/dim_loan_node_di.md) |

---

### 还款维度

#### dim_repay_plan_di

| 属性 | 值 |
|------|-----|
| **描述** | 还款计划维度表 |
| **表类型** | 维度表（Dim） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | 借据+期次级（loan_id + term_no） |
| **分布键** | HASH (loan_id, term_no) |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 分 |
| **字段数** | 23 |
| **字段级文档** | [dim_repay_plan_di.md](./fields/dim_repay_plan_di.md) |

---

#### dim_repay_plan_latest_df

| 属性 | 值 |
|------|-----|
| **描述** | 还款计划最新快照表（增量维护，每日合并） |
| **表类型** | 维度表（Dim，每日合并） |
| **时间维度** | 无独立分区（每日合并覆盖写入） |
| **表粒度** | 借据+期次级（loan_id + term_no） |
| **分布键** | HASH (loan_id) |
| **分区策略** | 无分区（每日合并全局表） |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 分 |
| **字段数** | 19 |
| **字段级文档** | [dim_repay_plan_latest_df.md](./fields/dim_repay_plan_latest_df.md) |

---

### 规则维度

#### dim_decision_rule_reject_mapping_iri

| 属性 | 值 |
|------|-----|
| **描述** | 拒绝码映射维度表 |
| **表类型** | 维度表（Dim，Irf/镜像表） |
| **时间维度** | 无分区（全局表） |
| **表粒度** | 拒绝码级（reject_code） |
| **分布键** | HASH (reject_code) |
| **分区策略** | 无分区 |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 无金额字段 |
| **字段数** | 6 |
| **字段级文档** | [dim_decision_rule_reject_mapping_iri.md](./fields/dim_decision_rule_reject_mapping_iri.md) |

---

### 公共维度

#### dim_date_irf

| 属性 | 值 |
|------|-----|
| **描述** | 通用日期维度表 |
| **表类型** | 维度表（Dim，Irf/镜像表） |
| **时间维度** | 无分区（全局表） |
| **表粒度** | 日期级（data_date） |
| **分布键** | HASH (data_date) |
| **分区策略** | 无分区 |
| **存储格式** | ORC / compression=zlib |
| **金额单位** | 无金额字段 |
| **字段数** | 39 |
| **字段级文档** | [dim_date_irf.md](./fields/dim_date_irf.md) |

---

## 表属性速查

### 按表类型分类

| 表类型 | 表 |
|--------|-----|
| **事实表（Fact）** | dwd_fact_credit_application_di、dwd_fact_loan_application_di、dwd_fact_decision_execution_di、dwd_fact_decision_result_reject_code_di |
| **维度表（Dim，日分区）** | dim_application_classification_mapping_di、dim_credit_node_di、dim_loan_node_di |
| **维度表（Dim，无分区/Irf）** | dim_node_decision_mapping_iri、dim_decision_rule_reject_mapping_iri、dim_date_irf |

### 按分区策略分类

| 分区策略 | 表 |
|---------|-----|
| VALUES 分区（ds） | dwd_fact_credit_application_di、dwd_fact_loan_application_di、dwd_fact_decision_execution_di、dwd_fact_decision_result_reject_code_di、dwd_fact_repayment_di、dim_application_classification_mapping_di、dim_credit_node_di、dim_loan_node_di、dim_repay_plan_di |
| 无分区（每日合并全局表） | dim_repay_plan_latest_df |
| 无分区（全局表） | dim_node_decision_mapping_iri、dim_decision_rule_reject_mapping_iri、dim_date_irf |

### 按业务主题分类

| 业务主题 | 表 |
|----------|-----|
| **授信** | dwd_fact_credit_application_di、dim_credit_node_di |
| **借款/借据** | dwd_fact_loan_application_di、dim_loan_node_di |
| **还款** | dwd_fact_repayment_di、dim_repay_plan_di、dim_repay_plan_latest_df |
| **决策** | dwd_fact_decision_execution_di、dwd_fact_decision_result_reject_code_di、dim_node_decision_mapping_iri、dim_decision_rule_reject_mapping_iri |
| **分类/分流** | dim_application_classification_mapping_di |
| **公共** | dim_date_irf |
