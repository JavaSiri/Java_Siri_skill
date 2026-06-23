# 业务主体关系图

本文档描述消费信贷业务核心实体的关联关系，作为数仓建模和口径对齐的基础参考。

---

## 一、核心实体概览

| 业务主体 | 英文名 | 数仓主键 | 说明 |
|---------|--------|---------|------|
| 客户 | Customer | `customer_sk` | 用户唯一标识，贯穿全生命周期 |
| 授信申请 | Credit Application | `credit_sk` | 用户发起授信额度的申请 |
| 授信合同 | Credit Contract | `credit_contract_no` | 授信申请通过后签署的合同，记录额度、期限等要素；`credit_contract_no` 为授信合同号，一份合同对应一个合同号 |
| 借款申请 / 借据 | Loan Application / Bill | `loan_id` / `bill_no` | 用户支用额度形成借据，`bill_no` 为银行侧唯一标识 |
| 还款计划 | Repayment Plan | `loan_id + term_no` | 借据的分期还款计划（维度表） |
| 还款流水 | Repayment Record | `repay_sk` | 实际发生的每笔还款事件（事实表） |
| 决策执行 | Decision Execution | `id` | 决策引擎的执行记录，`id` 可为授信ID、借据号、调额调价ID |
| 拒绝码命中 | Reject Code Hit | `id + reject_code` | 决策中命中的拒绝码事件 |
| 节点执行明细 | Node Execution | `loan_id/credit_sk + node_id` | 授信/借款在各决策节点的执行记录 |
| 节点定义 | Decision Node | `node_id` | 决策流程中的单个节点配置 |
| 拒绝码映射 | Reject Mapping | `reject_code + rule_code` | 拒绝码到规则码的映射关系 |
| 分类标签 | Classification | `id`（credit_sk 或 loan_id） | 授信/借款的维度标签（新客/老客、分流通道等） |

---

## 二、实体关系

### 2.1 授信生命周期

```
Customer  1:N  Credit Application
一个客户可以发起多个授信申请。

Credit Application  1:1  Credit Contract
一个授信申请通过后生成一个授信合同。

Credit Contract  1:N  Loan Application
一个授信合同可以产生多个借款借据。
```

> **说明**：授信合同是授信审批通过到实际支用之间的承上启下实体，记录额度、利率、期限等合同要素。一次授信对应一份合同，合同决定可支用的总额度。

### 2.2 借款与还款

```
Loan Application  1:N  Repayment Plan
一个借据对应多个还款计划（按期次展开）。

Loan Application  1:N  Repayment Record
一个借据对应多条还款流水（实际还款事件）。
```

### 2.3 决策链路

```
Credit Application  1:N  Decision Execution（授信决策）
Loan Application  1:N  Decision Execution（借款决策）
一次授信/借款申请可能触发多次决策重试。

Decision Execution  1:N  Reject Code Hit
一次决策执行可能命中多个拒绝码。

Reject Code Hit  N:1  Reject Mapping
拒绝码命中后，通过拒绝码映射表关联到具体规则。
```

### 2.4 节点执行明细

```
Credit Application  1:N  Credit Node Execution
Loan Application  1:N  Loan Node Execution
一笔授信/借款在决策流程中依次经过多个节点。

Node Execution  N:1  Decision Node
节点执行明细关联到节点定义表，获取节点配置信息。
```

### 2.5 分类维度

```
Credit Application  N:1  Classification
Loan Application  N:1  Classification
一笔授信/借款可能被打上多个分类标签（新客/老客、分流通道、陪跑标记等）。
```

---

## 三、关系汇总表

| 关联关系 | 从 | 关联键 | 到 | 说明 |
|---------|----|--------|----|------|
| 客户→授信 | `Customer` | `customer_sk` | `Credit Application` | 一对多 |
| 授信→授信合同 | `Credit Application` | `credit_sk` | `Credit Contract` | 一对一 |
| 授信合同→借款 | `Credit Contract` | `credit_sk` | `Loan Application` | 借款通过授信申请流水号关联授信；一个合同可多次支用 |
| 借款→还款计划 | `Loan Application` | `loan_id` | `Repayment Plan` | 按期次展开 |
| 借款→还款流水 | `Loan Application` | `loan_id` | `Repayment Record` | 实际还款事件 |
| 授信→授信决策 | `Credit Application` | `credit_sk` | `Decision Execution` | 授信决策重试 |
| 借款→借款决策 | `Loan Application` | `loan_id` | `Decision Execution` | 借款决策重试 |
| 决策→拒绝码 | `Decision Execution` | `id` | `Reject Code Hit` | 一次决策命中多码 |
| 拒绝码→映射 | `Reject Code Hit` | `reject_code` | `Reject Mapping` | 查表获取规则 |
| 授信→节点执行 | `Credit Application` | `credit_sk` | `Credit Node Execution` | 按节点展开 |
| 借款→节点执行 | `Loan Application` | `loan_id` | `Loan Node Execution` | 按节点展开 |
| 节点执行→节点定义 | `Node Execution` | `node_id` | `Decision Node` | 获取节点配置 |
| 授信→分类 | `Credit Application` | `credit_sk` | `Classification` | 维度标签 |
| 借款→分类 | `Loan Application` | `loan_id` | `Classification` | 维度标签 |

---

## 四、完整业务链路图

```
                    ┌─→ Decision Execution（授信）
                    │
Customer ──→ Credit Application ──┤
                    │             └─→ Credit Node Execution ──→ Decision Node
                    │
                    └─→ Credit Contract ──┬─→ Decision Execution（借款）
                                          │
                                          ├─→ Loan Node Execution ──→ Decision Node
                                          │
                                          ├─→ Repayment Plan
                                          │
                                          ├─→ Repayment Record
                                          │
                                          └─→ Classification
```

---

## 五、关联数仓表清单

| 关系端 | 数仓表（ttsp_it.） |
|--------|-------------------|
| Credit Application | `dwd_fact_credit_application_di` |
| Credit Contract | `dwd_fact_credit_application_di` |
| Loan Application | `dwd_fact_loan_application_di` |
| Repayment Plan | `dim_repay_plan_di` / `dim_repay_plan_latest_df` |
| Repayment Record | `dwd_fact_repayment_di` |
| Decision Execution | `dwd_fact_decision_execution_di` |
| Reject Code Hit | `dwd_fact_decision_result_reject_code_di` |
| Credit Node Execution | `dim_credit_node_di` |
| Loan Node Execution | `dim_loan_node_di` |
| Decision Node | `dim_node_decision_mapping_iri` |
| Reject Mapping | `dim_decision_rule_reject_mapping_iri` |
| Classification | `dim_application_classification_mapping_di` |
| Date Dimension | `dim_date_irf` |

---

## 六、业务分类维度说明

`dim_application_classification_mapping_di` 中与借贷决策强相关的分类字段：

| 字段 | 说明 |
|------|------|
| `is_first_credit` | 是否首次授信（新客 vs. 老客） |
| `is_first_loan` | 是否首次支用（新支 vs. 复支） |
| `diversion_type` | 分流通道：1=晋商/华通；2=嵩海 |
| `if_sh_flag` | 陪跑标记：1=陪跑；0=非陪跑 |

这些维度在授信申请和借款申请中通过 `id = credit_sk / loan_id` 关联，用于分析不同客群的风险表现。

---

> **维护说明**：本文件为业务主体关系的基础参考，各实体的详细口径（字段说明、口径定义）请参见 `.cursor/knowledge/schema/DWD/` 下对应表的文档。
