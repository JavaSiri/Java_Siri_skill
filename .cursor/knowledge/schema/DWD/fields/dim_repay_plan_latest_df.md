# dim_repay_plan_latest_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dim_repay_plan_latest_df` |
| **描述** | 还款计划最新快照表（增量维护，每日合并） |
| **分区键** | 无（每日合并全局表） |
| **分布策略** | HASH (loan_id) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 无独立分区（每日合并覆盖写入） |
| **金额单位** | 分 |
| **表粒度** | 借据+期次级（loan_id + term_no） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_id | VARCHAR | 【维度外键】借据号 |
| 2 | product_code_sk | VARCHAR | 【维度外键】产品编码 |

### 维度属性-类型

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 3 | term_no | BIGINT | 【维度属性-类型】期次 |

### 维度属性-时间

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 4 | term_start_date | VARCHAR | 【维度属性-时间】开始日期，该期次起息日 |
| 5 | term_end_date | VARCHAR | 【维度属性-时间】到期日期，该期次应还日 |
| 6 | bill_due_date | VARCHAR | 【维度属性-时间】账单日 |
| 7 | data_date | VARCHAR | 【维度属性-时间】数据日期 |
| 8 | grace_date | BIGINT | 【维度属性-时间】宽限天数 |
| 9 | clear_date | VARCHAR | 【维度属性-时间】结清日期 |

### 维度属性-状态

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | term_status | VARCHAR | 【维度属性-状态】期次状态：01=正常；02=逾期；03=已冲正；04=已撤销；05=已结清；06=延期结清 |

### 度量-当期

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | term_overdue_days | BIGINT | 【度量-当期】逾期天数 |
| 12 | term_due_principal | BIGINT | 【度量-当期】应还本金 |
| 13 | term_plan_interest | BIGINT | 【度量-当期】计划利息 |
| 14 | term_due_interest | BIGINT | 【度量-当期】应还利息 |
| 15 | term_reduction_interest | BIGINT | 【度量-当期】减免利息 |
| 16 | term_due_penalty | BIGINT | 【度量-当期】应还罚息 |
| 17 | term_reduction_penalty | BIGINT | 【度量-当期】减免罚息 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 18 | source_ds | VARCHAR | 【ETL字段】来源记录的原始 ds，格式：yyyyMMdd |

---

## 关键口径说明

### 与 dim_repay_plan_di 的关系

| 对比项 | dim_repay_plan_di | dim_repay_plan_latest_df |
|--------|-------------------|-------------------------|
| 数据范围 | 每日全量快照，历史所有记录 | 每日合并，仅保留最新一条 |
| 更新方式 | INSERT OVERWRITE 全量覆盖 | 增量 MERGE，每日合并 |
| 用途 | 分析期次状态变更历史 | 快速查询当前最新状态 |
| source_ds | 无 | 记录该条记录来源的原始日期 |

### term_status 期次状态枚举

| 状态码 | 含义 |
|--------|------|
| 01 | 正常 |
| 02 | 逾期 |
| 03 | 已冲正 |
| 04 | 已撤销 |
| 05 | 已结清 |
| 06 | 延期结清 |

### 典型使用场景

- 实时查询某笔借据各期次的最新状态
- 快速计算当前待还本金/利息/罚息
- 与 `dwd_fact_repayment_di` 联合分析计划与实际还款差异

### 与其他表的关系

- 通过 `loan_id` 关联 `dwd_fact_loan_application_di` 获取借据详情
- 通过 `loan_id` 关联 `dwd_fact_repayment_di` 分析实际还款流水

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 所有字段 | 由 `dim_repay_plan_di` 每日合并生成 |
| source_ds | 记录每条数据来自 dim_repay_plan_di 的哪个分区 |
