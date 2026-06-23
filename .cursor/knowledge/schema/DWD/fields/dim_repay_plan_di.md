# dim_repay_plan_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dim_repay_plan_di` |
| **描述** | 还款计划维度表 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | HASH (loan_id, term_no) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 日维（ds = data_date） |
| **金额单位** | 分 |
| **表粒度** | 借据+期次级（loan_id + term_no） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_id | VARCHAR(64) | 【维度外键】借据号（字节提供的借据号，唯一标注一笔借据） |
| 2 | product_code_sk | VARCHAR(64) | 【维度外键】产品编码 |

### 维度属性-类型

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 3 | term_no | INT | 【维度属性-类型】期次 |

### 维度属性-时间

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 4 | term_start_date | VARCHAR(8) | 【维度属性-时间】开始日期，该期次起息日 |
| 5 | term_end_date | VARCHAR(8) | 【维度属性-时间】到期日期，该期次应还日 |
| 6 | bill_due_date | VARCHAR(8) | 【维度属性-时间】账单日 |
| 7 | data_date | VARCHAR(8) | 【维度属性-时间】数据日期，指数据的截止日期 |
| 8 | grace_date | INT | 【维度属性-时间】宽限天数 |
| 9 | clear_date | VARCHAR(8) | 【维度属性-时间】结清日期，该期次结清日期 |

### 维度属性-状态

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | term_status | VARCHAR(2) | 【维度属性-状态】期次状态：01=正常；02=逾期；03=已冲正；04=已撤销；05=已结清；06=延期结清 |

### 度量-当期

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | term_overdue_days | INT | 【度量-当期】逾期天数，期次的逾期天数 |
| 12 | term_due_principal | BIGINT | 【度量-当期】应还本金 |
| 13 | term_plan_interest | BIGINT | 【度量-当期】计划利息 |
| 14 | term_due_interest | BIGINT | 【度量-当期】应还利息 |
| 15 | term_reduction_interest | BIGINT | 【度量-当期】减免利息 |
| 16 | term_due_penalty | BIGINT | 【度量-当期】应还罚息 |
| 17 | term_reduction_penalty | BIGINT | 【度量-当期】减免罚息 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 18 | created_time | TIMESTAMP | 【ETL字段】创建时间 |
| 19 | updated_time | TIMESTAMP | 【ETL字段】更新时间 |
| 20 | is_active | VARCHAR(2) | 【ETL字段】是否有效 (Y/N) |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 21 | ds | VARCHAR(8) | 数据分区字段 |

---

## 关键口径说明

### 粒度说明

`loan_id + term_no` 构成唯一主键，每行代表一笔借据某一期次的还款计划快照。

### 与 dim_repay_plan_latest_df 的关系

- `dim_repay_plan_di`：每日全量快照，包含历史所有期次状态变更记录
- `dim_repay_plan_latest_df`：最新快照表，仅保留每个 loan_id + term_no 的最新一条

### term_status 期次状态枚举

| 状态码 | 含义 |
|--------|------|
| 01 | 正常 |
| 02 | 逾期 |
| 03 | 已冲正 |
| 04 | 已撤销 |
| 05 | 已结清 |
| 06 | 延期结清 |

### 金额关系

- 本金关系：`term_due_principal`（应还本金）
- 利息关系：`term_plan_interest`（计划利息）→ `term_due_interest`（应还）→ `term_reduction_interest`（减免）
- 罚息关系：`term_due_penalty`（应还罚息）→ `term_reduction_penalty`（减免）

### 与其他表的关系

- 通过 `loan_id` 关联 `dwd_fact_loan_application_di` 获取借据申请详情
- 通过 `loan_id` 关联 `dwd_fact_repayment_di` 关联还款流水
- 通过 `product_code_sk` 关联产品维表

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| loan_id / term_no | 行方核心系统还款计划数据 |
| 金额/状态字段 | 行方核心系统生成 |
| data_date | 业务日期 |
