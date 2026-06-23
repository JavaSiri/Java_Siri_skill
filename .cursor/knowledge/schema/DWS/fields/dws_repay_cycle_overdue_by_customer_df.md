# dws_repay_cycle_overdue_by_customer_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_repay_cycle_overdue_by_customer_df` |
| **描述** | Y 宽表-人头逾期率（客户维度 Vintage 逾期率分析） |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (first_start_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 切片累积型（Vintage 逾期率分析） |
| **时间维度** | 日维（ds = 数据截止时间分区） |
| **金额单位** | 无金额字段（人头维度） |

---

## 字段定义

### 基础维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | customer_id | VARCHAR | 客户号，用于准入 Y 模型 |
| 2 | credit_date | VARCHAR | 授信时间，yyyyMMdd |
| 3 | first_start_date | TIMESTAMP | 首支时间，放款通过时间（切片表，7 个月后不会变） |
| 4 | due_date | BIGINT | 每月还款日 |
| 5 | product_code_sk | VARCHAR | 产品编码 |
| 6 | diversion_type | VARCHAR | 分流类型，1=晋商/华通；2=嵩海 |
| 7 | ds | VARCHAR | 业务日期分区，yyyymmdd |

### Cycle 时点日期（仅看首支）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | cycle1_date | VARCHAR | cycle1 时点日期，YYYY-MM-DD 格式 |
| 9 | cycle2_date | VARCHAR | cycle2 时点日期 |
| 10 | cycle3_date | VARCHAR | cycle3 时点日期 |
| 11 | cycle4_date | VARCHAR | cycle4 时点日期 |
| 12 | cycle5_date | VARCHAR | cycle5 时点日期 |
| 13 | cycle6_date | VARCHAR | cycle6 时点日期 |

### 观测日期（各 Cycle）

每个 Cycle 有三个观测日期字段（add_3 / add_7 / add_30），格式为 YYYY-MM-DD：

| Cycle | add_3 字段 | add_7 字段 | add_30 字段 |
|:-----:|-----------|-----------|------------|
| cycle1 | add_3_cycle1_date | add_7_cycle1_date | add_30_cycle1_date |
| cycle2 | add_3_cycle2_date | add_7_cycle2_date | add_30_cycle2_date |
| cycle3 | add_3_cycle3_date | add_7_cycle3_date | add_30_cycle3_date |
| cycle4 | add_3_cycle4_date | add_7_cycle4_date | add_30_cycle4_date |
| cycle5 | add_3_cycle5_date | add_7_cycle5_date | add_30_cycle5_date |
| cycle6 | add_3_cycle6_date | add_7_cycle6_date | add_30_cycle6_date |

> 含义：cycleN 还款日后延 N 天的观测日期（add_3=逾期 3 天+观测，add_7=逾期 7 天+观测，add_30=逾期 30 天+观测）

### 逾期标识（各 Cycle）

每个 Cycle 有三个逾期标识字段（ovd_3 / ovd_7 / ovd_30），取值：1=逾期，0=未逾期，NULL=未到期：

| Cycle | ovd_3 字段 | ovd_7 字段 | ovd_30 字段 |
|:-----:|-----------|-----------|------------|
| cycle1 | ovd_3_cycle1 | ovd_7_cycle1 | ovd_30_cycle1 |
| cycle2 | ovd_3_cycle2 | ovd_7_cycle2 | ovd_30_cycle2 |
| cycle3 | ovd_3_cycle3 | ovd_7_cycle3 | ovd_30_cycle3 |
| cycle4 | ovd_3_cycle4 | ovd_7_cycle4 | ovd_30_cycle4 |
| cycle5 | ovd_3_cycle5 | ovd_7_cycle5 | ovd_30_cycle5 |
| cycle6 | ovd_3_cycle6 | ovd_7_cycle6 | ovd_30_cycle6 |

> 含义：在 add_N_cycleN_date 观测日期下，最大逾期天数 >= N 的标识

---

## 关键口径说明

### 切片维度

以 `customer_id + product_code_sk + diversion_type` 为切片维度，按客户维度做 Vintage 逾期率分析。

### first_start_date

**首支时间**（放款通过时间），作为切片起点。切片表性质确定后不再变更，用于追踪同一批客户从首支开始的 Vintage 表现。

### cycle1_date ~ cycle6_date

基于首支时间预计算的各 Cycle 时点日期（仅看首支），用于关联快照分区获取对应时点的逾期状态。

### ovd_N_cycleM 语义

在 `add_N_cycleM_date` 观测日期下，判断该客户所有借据的最大逾期天数是否 >= N：

- 1：>= N 天逾期
- 0：< N 天逾期（已还款或未达到 N 天）
- NULL：观测日期未到（add_N_cycleM_date > 当前业务日）

### ds 分区语义

ds 为**数据截止时间分区**，表示截止到 T 日的 Vintage 逾期率快照。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 基础维度 | 关联 dws_customer_daily_count_df 客户每日快照表 |
| cycle 日期字段 | 基于 first_start_date + due_date 预计算 |
| add_N_cycleN_date | cycleN_date + N 天推算 |
| ovd_N_cycleN | 关联客户每日逾期快照，取 add_N_cycleN_date 观测日时点的最大逾期天数 |
