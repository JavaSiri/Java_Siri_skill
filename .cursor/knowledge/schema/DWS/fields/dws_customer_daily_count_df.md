# dws_customer_daily_count_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_customer_daily_count_df` |
| **描述** | DWS客户主题-客户每日快照表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 每日快照型（客户维度，客户级粒度） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 【分区/索引键】数据业务日期 |
| 2 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 3 | diversion_type | VARCHAR | 【维度属性-类别】分流类型，1=晋商/华通，2=嵩海 |
| 4 | customer_sk | VARCHAR | 【维度外键】客户号 |
| 5 | first_credit_application_date | VARCHAR | 【维度属性-时间】首次授信申请日期 |
| 6 | if_overdue_flag | VARCHAR | 【维度属性-类型】是否发生过逾期行为，Y=是，N=否 |
| 7 | loan_application_reject_flag | VARCHAR | 【维度属性-类型】支用申请是否被拒绝过，Y=是，N=否 |
| 8 | first_credit_month_reloan_flag | VARCHAR | 【维度属性-类型】客户在授信月是否发生过复支行为，Y=是，N=否 |
| 9 | credit_application_time | VARCHAR | 【维度属性-时间】首次授信申请时间 |
| 10 | first_loan_date | VARCHAR | 【维度属性-时间】客户发起首次支用的时间 |
| 11 | first_loan_due_day | VARCHAR | 【维度属性-时间】客户首次支用的每月还款日 |
| 12 | first_loan_cycle1_end_date | VARCHAR | 【维度属性-时间】客户首次支用的第1期到期日 |
| 13 | first_loan_cycle2_end_date | VARCHAR | 【维度属性-时间】客户首次支用的第2期到期日 |
| 14 | first_loan_cycle3_end_date | VARCHAR | 【维度属性-时间】客户首次支用的第3期到期日 |
| 15 | first_loan_cycle4_end_date | VARCHAR | 【维度属性-时间】客户首次支用的第4期到期日 |
| 16 | first_loan_cycle5_end_date | VARCHAR | 【维度属性-时间】客户首次支用的第5期到期日 |
| 17 | first_loan_cycle6_end_date | VARCHAR | 【维度属性-时间】客户首次支用的第6期到期日 |

### 累积频次度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 18 | loan_application_num | BIGINT | 【度量-观察点】累积借款申请次数 |
| 19 | loan_pass_num | BIGINT | 【度量-观察点】累积借款通过次数 |
| 20 | loan_repayment_pass_num | BIGINT | 【度量-观察点】累积放款成功次数 |
| 21 | overdue_loan_num | BIGINT | 【度量-观察点】累积发生过逾期的借据数量 |
| 22 | overdue_num | BIGINT | 【度量-观察点】累积逾期次数 |

### 逾期度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 23 | max_overdue_days_cur | BIGINT | 【度量-观察点】当前最大逾期天数 |
| 24 | max_overdue_days_hist | BIGINT | 【度量-观察点】历史最大逾期天数 |

### 授信额度度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 25 | credit_amount_cur | BIGINT | 【度量-观察点】当前授信额度 |
| 26 | credit_amount_used | BIGINT | 【度量-观察点】已用额度 |
| 27 | credit_amount_available | BIGINT | 【度量-观察点】可用额度 |

### 在贷状态度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 28 | onloan_loan_num | BIGINT | 【度量-观察点】在贷借据数量 |
| 29 | onloan_principal_bal | BIGINT | 【度量-观察点】在贷借据剩余本金 |
| 30 | onloan_principal_total | BIGINT | 【度量-观察点】在贷借据借款总本金 |

### 逾期在贷度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 31 | overdue_onloan_cnt | BIGINT | 【度量-观察点】逾期在贷借据数量 |
| 32 | overdue_onloan_principal_bal | BIGINT | 【度量-观察点】逾期在贷借据剩余本金 |
| 33 | overdue_onloan_principal_total | BIGINT | 【度量-观察点】逾期在贷借据借款总本金 |

### 逾期日期与金额度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 34 | first_overdue_date | VARCHAR | 【维度属性-时间】首次逾期日期 |
| 35 | overdue_penalty_amt_cur | BIGINT | 【度量-观察点】当前逾期罚息 |
| 36 | overdue_interest_amt_cur | BIGINT | 【度量-观察点】当前逾期利息 |
| 37 | overdue_total_amt_cur | BIGINT | 【度量-观察点】当前逾期总额 |
| 38 | last_overdue_date | VARCHAR | 【维度属性-时间】最近一次逾期日期 |
| 39 | ds | VARCHAR | 【分区键】数据分区字段，按天分区，格式 yyyyMMdd |

---

## 关键口径说明

### 表粒度

每行代表某一客户在某一 `data_date` 的完整画像快照，每个客户每天一条记录，是客户维度最完整的 DWS 快照宽表。

### 维度属性说明

- `if_overdue_flag`：客户历史上是否产生过借据逾期行为（不含已结清借据的过期记录）
- `loan_application_reject_flag`：支用申请是否曾被拒绝过
- `first_credit_month_reloan_flag`：在首次授信当月是否有复支（再次支用）行为

### 额度关系

`credit_amount_available = credit_amount_cur - credit_amount_used`

### 在贷与逾期在贷关系

- `onloan_*` 统计所有在贷借据（含正常和逾期）
- `overdue_onloan_*` 仅统计在贷且逾期的借据
- `onloan_principal_bal >= overdue_onloan_principal_bal`

### 逾期金额构成

`overdue_total_amt_cur = overdue_penalty_amt_cur + overdue_interest_amt_cur + 逾期本金`

### ds 分区语义

ds 取自 `data_date`，属于**业务时间分区**，读上游 `[T-2, T]`，写入 ds 取 `data_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 客户维度字段 | 关联 ODS 入湖后的客户事实表 |
| 授信额度字段 | 关联 DWD 授信额度快照事实表 |
| 在贷/逾期字段 | 关联 DWD 借据余额快照事实表 |
| 逾期日期字段 | 关联 DWD 逾期维表 |
