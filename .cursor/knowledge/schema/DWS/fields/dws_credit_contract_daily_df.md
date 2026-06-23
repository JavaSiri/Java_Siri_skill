# dws_credit_contract_daily_df

## 表基本信息

| 属性 | 值 |
|------|---|
| **表名** | `ttsp_it.dws_credit_contract_daily_df` |
| **描述** | DWS授信合同主题-授信合同每日快照表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 每日快照型（授信合同维度，授信合同级粒度） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |
| **参考表** | `dws_customer_daily_count_df` |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 【分区/索引键】数据业务日期 |
| 2 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 3 | diversion_type | VARCHAR | 【维度属性-类别】分流类型，1=晋商/华通，2=嵩海 |
| 4 | credit_sk | VARCHAR | 【维度外键】授信编号 |
| 5 | credit_contract_no | VARCHAR | 【维度属性-类别】授信合同号 |
| 6 | first_credit_application_date | VARCHAR | 【维度属性-时间】合同下首次授信申请日期 |
| 7 | if_overdue_flag | VARCHAR | 【维度属性-类型】合同下借据是否发生过逾期行为，Y=是，N=否 |
| 8 | loan_application_reject_flag | VARCHAR | 【维度属性-类型】合同下支用申请是否被拒绝过，Y=是，N=否 |
| 9 | first_credit_month_reloan_flag | VARCHAR | 【维度属性-类型】合同在授信月是否发生过复支行为，Y=是，N=否 |
| 10 | credit_application_time | VARCHAR | 【维度属性-时间】合同下首次授信申请时间 |
| 11 | first_loan_date | VARCHAR | 【维度属性-时间】合同下发起的首次支用时间 |
| 12 | first_loan_due_day | VARCHAR | 【维度属性-时间】合同下首次支用的每月还款日 |
| 13 | first_loan_cycle1_end_date | VARCHAR | 【维度属性-时间】合同下首次支用的第1期到期日 |
| 14 | first_loan_cycle2_end_date | VARCHAR | 【维度属性-时间】合同下首次支用的第2期到期日 |
| 15 | first_loan_cycle3_end_date | VARCHAR | 【维度属性-时间】合同下首次支用的第3期到期日 |
| 16 | first_loan_cycle4_end_date | VARCHAR | 【维度属性-时间】合同下首次支用的第4期到期日 |
| 17 | first_loan_cycle5_end_date | VARCHAR | 【维度属性-时间】合同下首次支用的第5期到期日 |
| 18 | first_loan_cycle6_end_date | VARCHAR | 【维度属性-时间】合同下首次支用的第6期到期日 |

### 累积频次度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 19 | loan_application_num | BIGINT | 【度量-观察点】合同下累积借款申请次数 |
| 20 | loan_pass_num | BIGINT | 【度量-观察点】合同下累积借款通过次数 |
| 21 | loan_repayment_pass_num | BIGINT | 【度量-观察点】合同下累积放款成功次数 |
| 22 | overdue_loan_num | BIGINT | 【度量-观察点】合同下累积发生过逾期的借据数量 |
| 23 | overdue_num | BIGINT | 【度量-观察点】合同下累积逾期次数 |

### 逾期度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 24 | max_overdue_days_cur | BIGINT | 【度量-观察点】合同下当前最大逾期天数 |
| 25 | max_overdue_days_hist | BIGINT | 【度量-观察点】合同下历史最大逾期天数 |

### 授信额度度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 26 | credit_amount_cur | BIGINT | 【度量-观察点】当前授信额度 |
| 27 | credit_amount_used | BIGINT | 【度量-观察点】已用额度（暂空，待关联额度快照表填充） |
| 28 | credit_amount_available | BIGINT | 【度量-观察点】可用额度（暂空，待关联额度快照表填充） |

### 在贷状态度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 29 | onloan_loan_num | BIGINT | 【度量-观察点】在贷借据数量 |
| 30 | onloan_principal_bal | BIGINT | 【度量-观察点】在贷借据剩余本金 |
| 31 | onloan_principal_total | BIGINT | 【度量-观察点】在贷借据借款总本金 |

### 逾期在贷度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 32 | overdue_onloan_cnt | BIGINT | 【度量-观察点】逾期在贷借据数量 |
| 33 | overdue_onloan_principal_bal | BIGINT | 【度量-观察点】逾期在贷借据剩余本金 |
| 34 | overdue_onloan_principal_total | BIGINT | 【度量-观察点】逾期在贷借据借款总本金 |

### 逾期日期与金额度量（观察点）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 35 | first_overdue_date | VARCHAR | 【维度属性-时间】合同下首次逾期日期 |
| 36 | overdue_penalty_amt_cur | BIGINT | 【度量-观察点】当前逾期罚息 |
| 37 | overdue_interest_amt_cur | BIGINT | 【度量-观察点】当前逾期利息 |
| 38 | overdue_total_amt_cur | BIGINT | 【度量-观察点】当前逾期总额 |
| 39 | last_overdue_date | VARCHAR | 【维度属性-时间】合同下最近一次逾期日期 |
| 40 | ds | VARCHAR | 【分区键】数据分区字段，按天分区，格式 yyyyMMdd |

---

## 关键口径说明

### 表粒度

每行代表某一授信合同在某一 `data_date` 的完整画像快照，每个授信合同每天一条记录，以授信合同为主体（`credit_contract_no + credit_sk`）聚合合同下所有借据的度量。

### 与参考表的差异

| 对比维度 | 参考表 dws_customer_daily_count_df | 本表 dws_credit_contract_daily_df |
|---------|-----------------------------------|----------------------------------|
| 统计粒度 | 客户维度（customer_sk） | 授信合同维度（credit_contract_no + credit_sk） |
| 主键 | data_date + customer_sk | data_date + credit_contract_no + credit_sk |
| 维度外键 | customer_sk | credit_sk + credit_contract_no |
| 口径差异 | 口径按客户聚合 | 口径按授信合同聚合 |
| 字段数量 | 39 个字段 | 40 个字段（新增 credit_contract_no） |

### 额度关系

`credit_amount_available = credit_amount_cur - credit_amount_used`

注：当前版本 credit_amount_used / credit_amount_available 暂为 NULL，待后续关联授信额度快照事实表填充。

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
| 授信维度字段 | 关联 `dwd_fact_credit_application_di` |
| 借据维度字段 | 关联 `dwd_fact_loan_application_di` |
| 在贷/逾期状态字段 | 关联 `dws_repay_loan_snapshot_df` |
| 分期逾期金额字段 | 关联 `dws_repay_loan_period_snapshot_df` |
| 分流类型字段 | 关联 `dim_application_classification_mapping_di` |

---

## ETL 说明

### 分区策略

- **日维度快照**：每日全量快照，授信相关延迟 T-1
- **回刷窗口**：`[T-2, T]`
- **幂等写入**：DELETE + INSERT，覆盖 `ds >= T-2 AND ds <= T` 三个分区

### 与参考表的主要适配

1. **主键替换**：`customer_sk` → `credit_contract_no + credit_sk`
2. **分流映射**：客户表通过借据侧关联获取 diversion_type；授信合同表通过 credit_sk 关联获取授信口径（type='1'）的 diversion_type
3. **基座关联**：以授信合同为主体（credit_contract_no + credit_sk），LEFT JOIN 借据侧 CTE
4. **贷后快照关联**：借据快照按 credit_sk 聚合后关联到授信合同基座
