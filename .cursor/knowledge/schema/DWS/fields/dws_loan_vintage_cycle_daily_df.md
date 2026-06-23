# dws_loan_vintage_cycle_daily_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_loan_vintage_cycle_daily_df` |
| **描述** | DWS 借据 Vintage 表-日维度统计表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (loan_id) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 切片累积型（Vintage 账龄分析） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |

---

## 字段定义

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_id | VARCHAR | 借据号，主键维度 |
| 2 | diversion_type | VARCHAR | 分流类型：1=晋商/华通；2=嵩海 |
| 3 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 4 | loan_application_reject_flag | VARCHAR | 支用申请是否被拒绝过，Y=是，N=否 |
| 5 | is_final_loan_suc | VARCHAR | 是否为末次放款成功，Y=是，N=否 |
| 6 | loan_date | TIMESTAMP | 放款时间 |
| 7 | period | INT | 分期数 |
| 8 | performance_period | INT | 表现期 0/3/7/15/30/60/90/180 |
| 9 | loan_age | INT | 账龄（单位：月） |
| 10 | term_amt | NUMERIC(38,18) | 期次金额 |
| 11 | loan_outstanding_principal | NUMERIC(38,18) | 借据未还本金 |
| 12 | loan_amt | NUMERIC(38,18) | 放款金额 |
| 13 | overdue_flag | VARCHAR | 是否逾期，Y=是，N=否 |
| 14 | due_flag | VARCHAR | 是否到期/是否已到表现期，Y=是，N=否 |
| 15 | ds | VARCHAR | 业务日期分区，yyyymmdd |

---

## 关键口径说明

### Vintage 账龄口径

- `loan_age`：账龄月数，从放款日开始计算
- `performance_period`：表现期等级（0/3/7/15/30/60/90/180 天），表示在哪个观测时点
- `overdue_flag`：当前观测时点是否处于逾期状态
- `due_flag`：当前观测时点是否已到达该表现期

### 切片维度

以 `loan_id`（借据）为切片，每行代表某借据在某业务日期下的 Vintage 快照状态。

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，借款/贷后相关，读上游 `[T-3, T-1]`。

### 金额单位

DWS 层保持分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 借据维度 | ODS 入湖后关联 DWD 借据事实表 |
| 账龄字段 | 基于 loan_date + ds 计算得出 |
| 逾期/到期标识 | 关联还款计划表与实际还款流水，判断是否逾期 |
| 金额字段 | 关联 DWD 借据表及还款流水表 |
