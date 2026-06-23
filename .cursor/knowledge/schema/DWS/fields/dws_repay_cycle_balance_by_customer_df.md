# dws_repay_cycle_balance_by_customer_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_repay_cycle_balance_by_customer_df` |
| **描述** | Y 宽表-余额逾期率（客户维度 Vintage 余额分析） |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (credit_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 切片累积型（Vintage 余额分析） |
| **时间维度** | 日维（ds = 数据截止时间分区） |
| **金额单位** | 分 |

---

## 字段定义

### 基础维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | customer_id | VARCHAR | 客户号，customer_id + product_code_sk + diversion_type 组合使用 |
| 2 | credit_date | VARCHAR | 授信时间，yyyyMMdd，使用授信申请时间 |
| 3 | product_code_sk | VARCHAR | 产品编码 |
| 4 | diversion_type | VARCHAR | 分流类型，1=晋商/华通；2=嵩海 |
| 5 | ds | VARCHAR | 业务日期分区，yyyymmdd |

### 授信到各 Cycle 天数（仅看首支）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | diff_days_to_cycle1 | BIGINT | 授信日期到 cycle1 天数 |
| 7 | diff_days_to_cycle2 | BIGINT | 授信日期到 cycle2 天数 |
| 8 | diff_days_to_cycle3 | BIGINT | 授信日期到 cycle3 天数 |
| 9 | diff_days_to_cycle4 | BIGINT | 授信日期到 cycle4 天数 |
| 10 | diff_days_to_cycle5 | BIGINT | 授信日期到 cycle5 天数 |
| 11 | diff_days_to_cycle6 | BIGINT | 授信日期到 cycle6 天数 |

### 余额累加值（所有借据）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | bal_cusum_cycle1 | BIGINT | 授信日期到 cycle1 余额累加值，SUM(每日余额) WHERE ds IN [credit_date, cycle1_date] |
| 13 | bal_cusum_cycle2 | BIGINT | 授信日期到 cycle2 余额累加值，SUM(每日余额) WHERE ds IN [credit_date, cycle2_date] |
| 14 | bal_cusum_cycle3 | BIGINT | 授信日期到 cycle3 余额累加值 |
| 15 | bal_cusum_cycle4 | BIGINT | 授信日期到 cycle4 余额累加值 |
| 16 | bal_cusum_cycle5 | BIGINT | 授信日期到 cycle5 余额累加值 |
| 17 | bal_cusum_cycle6 | BIGINT | 授信日期到 cycle6 余额累加值 |

### 时点逾期 30+ 标识（所有借据，1 或 0）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 18 | cur_ovd_30_cycle1 | BIGINT | cycle1 时点逾期 30+ 标识，1=逾期，0=未逾期，NULL=未到时点 |
| 19 | cur_ovd_30_cycle2 | BIGINT | cycle2 时点逾期 30+ 标识 |
| 20 | cur_ovd_30_cycle3 | BIGINT | cycle3 时点逾期 30+ 标识 |
| 21 | cur_ovd_30_cycle4 | BIGINT | cycle4 时点逾期 30+ 标识 |
| 22 | cur_ovd_30_cycle5 | BIGINT | cycle5 时点逾期 30+ 标识 |
| 23 | cur_ovd_30_cycle6 | BIGINT | cycle6 时点逾期 30+ 标识 |

### Cycle 还款日 30+ 时点余额（与逾期情况无关）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 24 | bal_add_30_cycle1 | BIGINT | cycle1 还款日 30+ 的时点余额 |
| 25 | bal_add_30_cycle2 | BIGINT | cycle2 还款日 30+ 的时点余额 |
| 26 | bal_add_30_cycle3 | BIGINT | cycle3 还款日 30+ 的时点余额 |
| 27 | bal_add_30_cycle4 | BIGINT | cycle4 还款日 30+ 的时点余额 |
| 28 | bal_add_30_cycle5 | BIGINT | cycle5 还款日 30+ 的时点余额 |
| 29 | bal_add_30_cycle6 | BIGINT | cycle6 还款日 30+ 的时点余额 |

---

## 关键口径说明

### 切片维度

以 `customer_id + product_code_sk + diversion_type` 为切片维度，按客户维度做 Vintage 余额分析。

### diff_days_to_cycleN

仅看**首支**借据，计算授信日期到各 cycle 天数。

### bal_cusum_cycleN

基于授信 ID 的**所有借据**的每日余额累加：`SUM(每日余额) WHERE ds IN [credit_date, cycleN_date]`。

### cur_ovd_30_cycleN

基于授信 ID 的**所有借据**，取最大逾期天数，在 cycleN 观测时点标记是否逾期 30+：1=逾期，0=未逾期，NULL=未到时点。

### bal_add_30_cycleN

在 cycleN 还款日 30+ 的时点余额，与实际逾期情况无关，纯粹记录该时点的存量余额。

### ds 分区语义

ds 为**数据截止时间分区**（上游最大业务日期），表示"截止到 T 日的 Vintage 余额快照"。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 基础维度 | 关联 dws_customer_daily_count_df 客户每日快照表 |
| diff_days | 基于授信日期和 cycle 时点日期计算 |
| bal_cusum | 关联客户每日余额快照，按周期区间求和 |
| cur_ovd_30 | 关联客户每日逾期标识，取 cycleN 观测日时点的最大值 |
| bal_add_30 | 关联 cycleN+30 日的余额快照 |
