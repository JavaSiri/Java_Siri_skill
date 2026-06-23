---
id: RdyDW-DWS-CC-01
parent: ""
title: DWS授信合同维度每日快照表新建
task_type: 新建开发
status: done
layers:
  - DWS
layer_task_types:
  ods: 无变更
  dwd: 无变更
  dws: 新建开发
  ads: 无变更
hitl: false
blocked_by: []
created_at: 2026-06-23T10:10:00+08:00
updated_at: 2026-06-23T10:10:00+08:00
---

## 父需求

参考表需求澄清结果（无独立 PRD）

## 做什么

在 DWS 层新建一张授信合同维度的每日快照表，以授信合同为主体（`credit_contract_no + credit_sk`），聚合合同下所有借据的度量，结构完全沿用参考表 `dws_customer_daily_count_df` 的字段体系，将客户维度替换为授信合同维度。

## 按层任务类型

| 层级 | 任务类型 | 说明 |
|------|---------|------|
| ODS | 无变更 | 不涉及原始数据层 |
| DWD | 无变更 | 不涉及明细层变更 |
| DWS | 新建开发 | 新建 `dws_credit_contract_daily_df` 表 |
| ADS | 无变更 | 不涉及应用层 |

## 覆盖的层级

- [x] DWS：新建 `dws_credit_contract_daily_df`

## 指标定义

参考表 `dws_customer_daily_count_df` 全部指标口径，粒度从客户替换为授信合同：

| 指标名称 | 计算口径 | 数据类型 |
|---------|---------|---------|
| loan_application_num | 合同下累积借款申请次数 | BIGINT |
| loan_pass_num | 合同下累积借款通过次数 | BIGINT |
| loan_repayment_pass_num | 合同下累积放款成功次数 | BIGINT |
| overdue_loan_num | 合同下累积发生过逾期的借据数量 | BIGINT |
| max_overdue_days_cur | 合同下当前最大逾期天数 | BIGINT |
| max_overdue_days_hist | 合同下历史最大逾期天数 | BIGINT |
| overdue_num | 合同下累积逾期次数 | BIGINT |
| credit_amount_cur | 当前授信额度 | BIGINT |
| credit_amount_used | 已用额度 | BIGINT |
| credit_amount_available | 可用额度 | BIGINT |
| onloan_loan_num | 在贷借据数量 | BIGINT |
| onloan_principal_bal | 在贷借据剩余本金 | BIGINT |
| onloan_principal_total | 在贷借据借款总本金 | BIGINT |
| overdue_onloan_cnt | 逾期在贷借据数量 | BIGINT |
| overdue_onloan_principal_bal | 逾期在贷借据剩余本金 | BIGINT |
| overdue_onloan_principal_total | 逾期在贷借据借款总本金 | BIGINT |
| overdue_penalty_amt_cur | 当前逾期罚息 | BIGINT |
| overdue_interest_amt_cur | 当前逾期利息 | BIGINT |
| overdue_total_amt_cur | 当前逾期总额 | BIGINT |

## 字段定义

### 主键

`data_date + credit_contract_no + credit_sk`

### 维度属性（沿用参考表，替换客户维度）

| 字段名 | 来源 | 说明 |
|-------|------|------|
| data_date | 派生 | 数据业务日期 |
| product_code_sk | dwd_fact_credit_application_di | 产品编码 |
| diversion_type | dim_application_classification_mapping_di | 分流类型 |
| credit_sk | dwd_fact_credit_application_di | 授信编号（维度外键） |
| credit_contract_no | dwd_fact_credit_application_di | 授信合同号 |
| first_credit_application_date | dwd_fact_credit_application_di | 首次授信申请日期（合同下首笔） |
| if_overdue_flag | dwd_fact_loan_application_di | 是否发生过逾期 |
| loan_application_reject_flag | dwd_fact_loan_application_di | 支用申请是否被拒绝过 |
| first_credit_month_reloan_flag | 派生 | 合同授信月是否发生过复支 |
| credit_application_time | dwd_fact_credit_application_di | 首次授信申请时间 |
| first_loan_date | dwd_fact_loan_application_di | 合同下首笔支用时间 |
| first_loan_due_day | 派生 | 合同下首笔支用每月还款日 |
| first_loan_cycle1~6_end_date | 派生 | 合同下首笔支用第1~6期到期日 |
| first_overdue_date | 派生 | 合同下首次逾期日期 |
| last_overdue_date | 派生 | 合同下最近一次逾期日期 |

### 度量（沿用参考表）

同参考表 `dws_customer_daily_count_df` 全部度量字段，口径以授信合同为聚合主体。

## 数据来源

| 来源表 | 用途 |
|--------|------|
| dwd_fact_credit_application_di | 授信信息、合同号、授信额度 |
| dwd_fact_loan_application_di | 借据信息、借款申请次数 |
| dws_repay_loan_snapshot_df | 在贷状态、逾期状态 |
| dws_repay_loan_period_snapshot_df | 分期逾期金额 |
| dim_application_classification_mapping_di | 分流类型映射 |

## ETL 逻辑

- 以授信合同为主体（`credit_contract_no + credit_sk`），LEFT JOIN 借据事实表
- 聚合合同下所有借据的度量
- 每日全量快照（T+1）
- 读上游 `[T-2, T]`，写入 ds 取业务日期字段值

## 数据质量检查

- [ ] 数据量波动检查（与 T-1 对比，阈值 ±20%）
- [ ] 主键去重检查（`data_date + credit_contract_no + credit_sk` 无重复）
- [ ] 空值检查（credit_sk / credit_contract_no 无 NULL）
- [ ] credit_amount_available = credit_amount_cur - credit_amount_used 逻辑校验
- [ ] onloan_principal_bal >= overdue_onloan_principal_bal 逻辑校验

## 验收标准

- [ ] DDL 脚本写入 `21-字节晋消/09-晋消上线/DDL/DWS/` 目录
- [ ] ETL 脚本写入 `21-字节晋消/05-code_scripts/` 目录
- [ ] 知识库字段文档写入 `.cursor/knowledge/schema/DWS/fields/` 目录
- [ ] 代码审查通过
- [ ] ETL 任务可执行（语法校验通过）

## 阻塞条件

无 — 可立即开始

## 参考表

`dws_customer_daily_count_df`（客户维度每日快照表），结构完全复用，粒度从客户替换为授信合同

## 技术选型

- 数据库：PostgreSQL（沿用参考表技术栈）
- 分区：物理分区 `PARTITION BY VALUES (ds)`
- 幂等：DELETE + INSERT
- 存储：ORC / compression=zlib
