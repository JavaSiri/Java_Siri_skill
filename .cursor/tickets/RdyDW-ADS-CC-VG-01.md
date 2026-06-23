---
id: RdyDW-ADS-CC-VG-01
parent: clarification-record-20260623
title: ADS授信合同维度Month Vintage表新建
task_type: 新建开发
status: done
layers:
  - ADS
layer_task_types:
  ods: 无变更
  dwd: 无变更
  dws: 无变更
  ads: 新建开发
hitl: false
blocked_by: []
created_at: 2026-06-23T14:42:00+08:00
updated_at: 2026-06-23T14:42:00+08:00
---

## 父需求

来源：clarification-record-20260623（table-requirement-analyzer 澄清结论）

## 做什么

基于 `ads_customer_first_credit_month_vintage_df`（客户维度 Vintage 表）进行粒度升级，开发 **ADS 授信合同维度 Month Vintage 表**（`ads_credit_contract_month_vintage_df`）。

粒度从「客户+产品+分流」升级为「授信合同号+授信流水号+产品+分流+vintage_month+stat_month+mob」，其他口径与参考表保持完全一致。

## 按层任务类型

| 层级 | 任务类型 | 说明 |
|------|---------|------|
| ODS | 无变更 | |
| DWD | 无变更 | |
| DWS | 无变更 | |
| ADS | 新建开发 | 参照参考表逻辑新建 ads_credit_contract_month_vintage_df |

## 覆盖的层级

- [ ] ODS（如有 DDL 变更或新表入湖）
- [ ] DWD（如有 DDL 变更或新建事实表）
- [ ] DWS（如有 DDL 变更或新建汇总表）
- [x] ADS（ads_credit_contract_month_vintage_df 新建）

## 表需求卡

| 维度 | 内容 |
|---|---|
| 表名 | `ads_credit_contract_month_vintage_df` |
| 主题 | 授信主题 |
| 用途 | 授信合同级 Vintage 滚动率分析，统计各放款月（vintage_month）在各账龄（mob）的月末逾期率与余额口径 |
| 粒度 | 授信合同号 + 授信流水号 + 产品 + 分流 + vintage_month + stat_month + mob |
| 主键 | `{credit_contract_no, credit_sk, product_code_sk, channel_cd, vintage_month, stat_month, mob}` |
| 时间范围 | vintage_month: 从 `dws_credit_contract_daily_df` 的 `first_credit_application_date` 开始；stat_month: 月末切片 |
| Mob 范围 | Mob1 ~ Mob24 |
| 逾期层次 | 0+/7+/30+ 三档 |
| 基础度量 | `total_loan_amount`（放款本金）、`total_outstanding_principal`（在贷余额） |
| 切片时点 | 月末（T+1 出当月数据），来源 `dws_repay_loan_period_snapshot_df` |
| 回溯历史 | 从 `dws_credit_contract_daily_df` 上线月开始，Vintage 全量计算 |

## 参考表与差异分析

| 维度 | 参考表 `ads_customer_first_credit_month_vintage_df` | 本表 `ads_credit_contract_month_vintage_df` |
|---|---|---|
| 粒度 | 客户+产品+分流 | 授信合同号+授信流水号+产品+分流 |
| vintage_month 来源 | `dws_customer_daily_count_df.first_credit_application_date` | `dws_credit_contract_daily_df.first_credit_application_date` |
| 借据关联键 | `customer_sk + product_code_sk + diversion_type` | `credit_sk + product_code_sk + diversion_type` |
| stat_month 切片 | 月末，T-1 快照 | 月末，T-1 快照（来源 period 快照） |
| 基础度量 | `total_loan_amount`, `total_outstanding_principal` | 一致 |
| 逾期层次 | 0+/7+/30+ | 一致 |
| Mob 范围 | Mob1~24 | 一致 |
| 数据来源 | `dws_repay_loan_snapshot_df` | `dws_repay_loan_snapshot_df`（period 快照） |

## 指标定义

| 指标名称 | 计算口径 | 数据类型 |
|---------|---------|---------|
| total_loan_amount | 合同下所有借据的放款本金 SUM | BIGINT |
| total_outstanding_principal | 合同下所有借据的在贷余额 SUM | BIGINT |
| overdue_prin_0 | Mob 月末逾期天数>0 的借据剩余本金 SUM | BIGINT |
| overdue_prin_7 | Mob 月末逾期天数>7 的借据剩余本金 SUM | BIGINT |
| overdue_prin_30 | Mob 月末逾期天数>30 的借据剩余本金 SUM | BIGINT |
| total_prin | Mob 月末全部借据剩余本金 SUM | BIGINT |

## 字段定义（ADS 层）

| 字段名 | 类型 | 说明 |
|-------|------|------|
| credit_contract_no | VARCHAR | 授信合同号 |
| credit_sk | VARCHAR | 授信流水号 |
| product_code_sk | VARCHAR | 产品编码 |
| channel_cd | VARCHAR | 分流类型 |
| vintage_month | VARCHAR | 放款月（yyyy-MM） |
| stat_month | VARCHAR | 统计月（yyyy-MM） |
| mob | INT | 账龄月次 |
| overdue_level | VARCHAR | 逾期层次 0+/7+/30+ |
| total_loan_amount | BIGINT | 放款本金汇总（元） |
| total_outstanding_principal | BIGINT | 在贷余额汇总（元） |
| overdue_prin | BIGINT | 对应档位逾期剩余本金 |
| total_prin | BIGINT | 全部剩余本金 |
| ds | VARCHAR | 数据分区（yyyyMMdd） |

## 数据质量检查

- [ ] 数据量波动检查（与参考表同口径对比，阈值 ±20%）
- [ ] 空值检查（关键字段无 NULL）
- [ ] 去重检查（主键无重复）
- [ ] mob 覆盖完整性（Mob1~24 每档均有数据）
- [ ] vintage_month 历史覆盖率（确保无断档）

## 验收标准

- [ ] DDL 建表成功，分区策略正确
- [ ] ETL 任务成功执行，无报错
- [ ] 数据可查询，ds=T-1 分区可见
- [ ] 数据质量检查全部通过
- [ ] 与参考表 `ads_customer_first_credit_month_vintage_df` 同口径数据对比一致

## 阻塞条件

无 — 可立即开始

## 备注

- 参考表 `ads_customer_first_credit_month_vintage_df` 逻辑已完整复用，仅替换关联键和 vintage_month 来源
- vintage_month 取自 `dws_credit_contract_daily_df.first_credit_application_date`，而非客户维度
- stat_month 通过月末切片逻辑确定，每行代表某 stat_month 月末的快照
- 数据来源 `dws_repay_loan_period_snapshot_df` 的 period 快照，而非普通快照
