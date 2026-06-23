# DWS 层表索引

本文档为 DWS 层 16 张表的表级别入口索引，提供表归属主题、统计视角、表粒度、时间维度等概览信息，便于快速检索目标表。

---

## 主题分布总览

| 主题 | 表数量 | 表名 |
|------|:------:|------|
| 客户主题 | 5 | `dws_customer_by_annual_rate_daily_di`、`dws_customer_by_level_daily_di`、`dws_customer_daily_count_balance_df`、`dws_customer_daily_count_df`、`dws_customer_first_credit_month_vintage_df` |
| 决策主题 | 3 | `dws_decision_reject_code_daily_di`、`dws_decision_rule_credit_daily_count_di`、`dws_decision_rule_loan_daily_count_di` |
| 节点主题 | 2 | `dws_node_credit_daily_count_di`、`dws_node_loan_daily_count_di` |
| 授信主题 | 1 | `dws_credit_application_daily_count_di` |
| 借款主题 | 1 | `dws_loan_application_daily_count_di` |
| 还款主题 | 4 | `dws_repay_cycle_overdue_by_customer_df`、`dws_repay_cycle_balance_by_customer_df`、`dws_loan_advance_settle_daily_df`、`dws_loan_vintage_cycle_daily_df` |

---

## 表索引

### 客户主题

#### dws_customer_by_annual_rate_daily_di

| 属性 | 值 |
|------|-----|
| **描述** | DWS客户主题-按年利率分层的日维度统计宽表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 维度聚合粒度（data_date + application_date + diversion_type + product_code_sk + annual_rate） |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 授信笔数+额度、借款笔数+额度、逾期/提前还款/优质客户观察点评判 |
| **字段数** | 37 |
| **字段级文档** | [dws_customer_by_annual_rate_daily_di.md](./fields/dws_customer_by_annual_rate_daily_di.md) |

---

#### dws_customer_by_level_daily_di

| 属性 | 值 |
|------|-----|
| **描述** | 客户主题-分层日维度统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 维度聚合粒度（data_date + application_date + diversion_type + product_code_sk + customer_level） |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 与 dws_customer_by_annual_rate_daily_di 结构镜像，按客户等级切片 |
| **字段数** | 37 |
| **字段级文档** | [dws_customer_by_level_daily_di.md](./fields/dws_customer_by_level_daily_di.md) |

---

#### dws_customer_daily_count_balance_df

| 属性 | 值 |
|------|-----|
| **描述** | Y宽表-客户每日余额 |
| **统计视角** | 每日快照型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 客户级粒度（data_date + customer_id），每日一条 |
| **分布键** | HASH (credit_date)，按授信时间戳打散避免倾斜 |
| **金额单位** | 分 |
| **核心度量** | 余额 bal、当前逾期天数 cur_ovd_days、历史最大逾期天数 top_ovd_days |
| **字段数** | 9 |
| **字段级文档** | [dws_customer_daily_count_balance_df.md](./fields/dws_customer_daily_count_balance_df.md) |

---

#### dws_customer_daily_count_df

| 属性 | 值 |
|------|-----|
| **描述** | DWS客户主题-客户每日快照表 |
| **统计视角** | 每日快照型（客户维度，客户级粒度） |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 客户级粒度（data_date + customer_sk），每日一条，最完整的客户画像宽表 |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 累积借款次数、逾期次数、最大逾期天数、授信额度、在贷余额、逾期在贷余额、逾期罚息/利息 |
| **字段数** | 39 |
| **字段级文档** | [dws_customer_daily_count_df.md](./fields/dws_customer_daily_count_df.md) |

---

#### dws_customer_first_credit_month_vintage_df

| 属性 | 值 |
|------|-----|
| **描述** | 客户维度Vintage（放款金额&在贷余额）-每日快照 |
| **统计视角** | 每日快照型 |
| **时间维度** | 月维（first_credit_month）+ 日维（ds） |
| **表粒度** | Vintage 粒度（first_credit_month + diversion_type + product_code_sk + overdue_level） |
| **分布键** | HASH (first_credit_month) |
| **金额单位** | 分 |
| **核心度量** | mob1-mob24 各期逾期借据剩余本金 / 全部借据剩余本金，支持 24 期账龄分析 |
| **字段数** | 58 |
| **字段级文档** | [dws_customer_first_credit_month_vintage_df.md](./fields/dws_customer_first_credit_month_vintage_df.md) |

---

### 决策主题

#### dws_decision_reject_code_daily_di

| 属性 | 值 |
|------|-----|
| **描述** | 节点主题-决策日维度统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 拒绝码维度聚合粒度（data_date + type + is_first_loan + diversion_type + product_code_sk + if_sh_flag + rule_code + reject_code） |
| **分布键** | HASH (data_date) |
| **金额单位** | 无金额字段 |
| **核心度量** | reject_code_hit_num（拒绝码命中笔数）、decision_application_num（决策申请笔数），支持拒绝原因下钻 |
| **字段数** | 19 |
| **字段级文档** | [dws_decision_reject_code_daily_di.md](./fields/dws_decision_reject_code_daily_di.md) |

---

#### dws_decision_rule_credit_daily_count_di

| 属性 | 值 |
|------|-----|
| **描述** | 授信申请规则命中统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 规则维度聚合粒度（credit_application_date + diversion_type + product_code_sk + if_sh_flag + rule_code） |
| **分布键** | HASH (credit_application_date) |
| **金额单位** | 无金额字段 |
| **核心度量** | rule_hit_num（规则码命中笔数），支持授信环节规则命中频率分析 |
| **字段数** | 7 |
| **字段级文档** | [dws_decision_rule_credit_daily_count_di.md](./fields/dws_decision_rule_credit_daily_count_di.md) |

---

#### dws_decision_rule_loan_daily_count_di

| 属性 | 值 |
|------|-----|
| **描述** | 借款申请规则命中统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 规则维度聚合粒度（loan_application_date + diversion_type + product_code_sk + is_first_loan + if_sh_flag + rule_code） |
| **分布键** | HASH (loan_application_date) |
| **金额单位** | 无金额字段 |
| **核心度量** | rule_hit_num（规则码命中笔数），支持支用环节规则命中频率分析，按首支维度区分新客/老客 |
| **字段数** | 8 |
| **字段级文档** | [dws_decision_rule_loan_daily_count_di.md](./fields/dws_decision_rule_loan_daily_count_di.md) |

---

### 节点主题

#### dws_node_credit_daily_count_di

| 属性 | 值 |
|------|-----|
| **描述** | 授信节点统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 节点维度聚合粒度（data_date + credit_application_date + diversion_type + if_sh_flag + product_code_sk + node_type_by_decision） |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 节点申请/通过/拒绝/失败/其他笔数 + 对应额度，支持授信决策流各节点漏斗分析 |
| **字段数** | 25 |
| **字段级文档** | [dws_node_credit_daily_count_di.md](./fields/dws_node_credit_daily_count_di.md) |

---

#### dws_node_loan_daily_count_di

| 属性 | 值 |
|------|-----|
| **描述** | 借款节点统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 节点维度聚合粒度（data_date + loan_application_date + is_first_loan + diversion_type + if_sh_flag + product_code_sk + node_type_by_decision） |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 节点申请/通过/拒绝/失败/其他笔数 + 对应额度，支持支用决策流各节点漏斗分析，按首支维度区分新客/老客 |
| **字段数** | 26 |
| **字段级文档** | [dws_node_loan_daily_count_di.md](./fields/dws_node_loan_daily_count_di.md) |

---

### 授信主题

#### dws_credit_application_daily_count_di

| 属性 | 值 |
|------|-----|
| **描述** | 授信申请统计表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 维度聚合粒度（data_date + credit_application_date + diversion_type + product_code_sk） |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 授信笔数+额度、规则命中笔数、复合利率金额、决策漏斗（决策前拒绝→决策申请→通过/拒绝） |
| **字段数** | 29 |
| **字段级文档** | [dws_credit_application_daily_count_di.md](./fields/dws_credit_application_daily_count_di.md) |

---

### 借款主题

#### dws_loan_application_daily_count_di

| 属性 | 值 |
|------|-----|
| **描述** | 借款申请及放款统计日汇总表 |
| **统计视角** | 自然周期型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 维度聚合粒度（data_date + loan_application_date + diversion_type + is_first_loan + product_code_sk） |
| **分布键** | HASH (data_date) |
| **金额单位** | 分 |
| **核心度量** | 借款申请笔数+额度、放款笔数+额度、期数度量、复合利率金额、决策漏斗，按首支维度区分新客/老客 |
| **字段数** | 60 |
| **字段级文档** | [dws_loan_application_daily_count_di.md](./fields/dws_loan_application_daily_count_di.md) |

---

### 还款主题

#### dws_repay_cycle_overdue_by_customer_df

| 属性 | 值 |
|------|-----|
| **描述** | Y宽表-人头逾期率 |
| **统计视角** | 每日快照型（Vintage维度，人头粒度） |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 借据粒度（customer_id + credit_date），按授信ID只跟踪首支 |
| **分布键** | HASH (first_start_date) |
| **金额单位** | 分 |
| **核心度量** | cycle1-6 各期 3+/7+/30+ 逾期标识（1逾期/0未逾期/NULL未到期），支持客户维度 Vintage 逾期率分析 |
| **字段数** | 65 |
| **字段级文档** | [dws_repay_cycle_overdue_by_customer_df.md](./fields/dws_repay_cycle_overdue_by_customer_df.md) |

---

#### dws_repay_cycle_balance_by_customer_df

| 属性 | 值 |
|------|-----|
| **描述** | Y宽表-余额逾期率 |
| **统计视角** | 每日快照型（Vintage维度，余额粒度） |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 客户粒度（customer_id + credit_date），按授信ID跟踪所有借据 |
| **分布键** | HASH (credit_date) |
| **金额单位** | 分 |
| **核心度量** | cycle1-6 各期余额累加值 bal_cusum、时点逾期 30+ 标识 cur_ovd_30、时点余额 bal_add_30，支持余额口径 Vintage 分析 |
| **字段数** | 31 |
| **字段级文档** | [dws_repay_cycle_balance_by_customer_df.md](./fields/dws_repay_cycle_balance_by_customer_df.md) |

---

#### dws_loan_advance_settle_daily_df

| 属性 | 值 |
|------|-----|
| **描述** | DWS借据提前结清-日维度统计表 |
| **统计视角** | 每日快照型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 借据粒度（loan_id），每笔借据一条 |
| **分布键** | HASH (loan_id) |
| **金额单位** | 分（repay_amt/advance_settle_amt/loan_amt 为 NUMERIC(38,18)） |
| **核心度量** | repay_amt（已还总金额）、advance_settle_amt（提前结清总金额）、loan_amt（放款金额），支持提前结清行为分析 |
| **字段数** | 18 |
| **字段级文档** | [dws_loan_advance_settle_daily_df.md](./fields/dws_loan_advance_settle_daily_df.md) |

---

#### dws_loan_vintage_cycle_daily_df

| 属性 | 值 |
|------|-----|
| **描述** | DWS借据vintage表-日维度统计表 |
| **统计视角** | 每日快照型 |
| **时间维度** | 日维（ds = 业务日期） |
| **表粒度** | 借据粒度（loan_id），每笔借据一条 |
| **分布键** | HASH (loan_id) |
| **金额单位** | 分（term_amt/loan_outstanding_principal/loan_amt 为 NUMERIC(38,18)） |
| **核心度量** | loan_age（账龄月数）、performance_period（表现期 0/3/7/15/30/60/90/180）、overdue_flag/due_flag，支持借据级 Vintage 表现分析 |
| **字段数** | 23 |
| **字段级文档** | [dws_loan_vintage_cycle_daily_df.md](./fields/dws_loan_vintage_cycle_daily_df.md) |

---

## 表属性速查

### 按统计视角分类

| 视角 | 表 |
|------|-----|
| **自然周期型**（按申请/业务日期聚合） | dws_credit_application_daily_count_di、dws_loan_application_daily_count_di、dws_node_credit_daily_count_di、dws_node_loan_daily_count_di、dws_customer_by_annual_rate_daily_di、dws_customer_by_level_daily_di、dws_decision_reject_code_daily_di、dws_decision_rule_credit_daily_count_di、dws_decision_rule_loan_daily_count_di |
| **每日快照型**（客户/借据维度，每日一条） | dws_customer_daily_count_balance_df、dws_customer_daily_count_df、dws_loan_advance_settle_daily_df、dws_loan_vintage_cycle_daily_df |
| **每日快照型**（Vintage维度） | dws_customer_first_credit_month_vintage_df（mob1-mob24）、dws_repay_cycle_overdue_by_customer_df（cycle1-6，3+/7+/30+）、dws_repay_cycle_balance_by_customer_df（cycle1-6，余额口径） |

### 按分布键分类

| 分布键 | 表 |
|--------|-----|
| HASH (data_date) | dws_credit_application_daily_count_di、dws_loan_application_daily_count_di、dws_node_credit_daily_count_di、dws_node_loan_daily_count_di、dws_customer_by_annual_rate_daily_di、dws_customer_by_level_daily_di、dws_decision_reject_code_daily_di |
| HASH (credit_date) | dws_customer_daily_count_balance_df、dws_repay_cycle_balance_by_customer_df |
| HASH (credit_application_date) | dws_decision_rule_credit_daily_count_di |
| HASH (loan_application_date) | dws_decision_rule_loan_daily_count_di |
| HASH (first_start_date) | dws_repay_cycle_overdue_by_customer_df |
| HASH (first_credit_month) | dws_customer_first_credit_month_vintage_df |
| HASH (loan_id) | dws_loan_advance_settle_daily_df、dws_loan_vintage_cycle_daily_df |

### 按表粒度分类

| 表粒度 | 表 |
|--------|-----|
| **维度聚合粒度**（日+产品+分流+其他维度） | dws_credit_application_daily_count_di、dws_loan_application_daily_count_di、dws_node_credit_daily_count_di、dws_node_loan_daily_count_di、dws_customer_by_annual_rate_daily_di、dws_customer_by_level_daily_di、dws_decision_* |
| **客户级粒度**（每日每客户一条） | dws_customer_daily_count_balance_df、dws_customer_daily_count_df |
| **借据级粒度**（每笔借据一条） | dws_loan_advance_settle_daily_df、dws_loan_vintage_cycle_daily_df、dws_repay_cycle_overdue_by_customer_df |
| **Vintage粒度**（首次成功授信月+产品+分流+逾期层级） | dws_customer_first_credit_month_vintage_df、dws_repay_cycle_balance_by_customer_df |
