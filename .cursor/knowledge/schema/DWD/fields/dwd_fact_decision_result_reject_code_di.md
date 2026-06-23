# dwd_fact_decision_result_reject_code_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dwd_fact_decision_result_reject_code_di` |
| **描述** | 决策结果拒绝码事实表 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | HASH (id) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 日维（ds = data_date） |
| **金额单位** | 无金额字段 |
| **表粒度** | 拒绝码事件级（id + reject_code） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | id | VARCHAR(64) | 【维度外键】授信ID/借据号/调额调价ID |
| 2 | product_code_sk | VARCHAR(64) | 【维度外键】产品编码 |
| 3 | reject_code | VARCHAR(32) | 【维度外键】拒绝码 |

### 维度属性-类型

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 4 | type | VARCHAR(2) | 【维度属性-类型】业务类型：1=授信；2=借款；3=调额调价 |

### 维度属性-时间

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 5 | data_date | VARCHAR(8) | 【维度属性-时间】数据业务日期，格式：yyyyMMdd |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | created_time | TIMESTAMP | 【ETL字段】创建时间 |
| 7 | updated_time | TIMESTAMP | 【ETL字段】更新时间 |
| 8 | is_active | VARCHAR(2) | 【ETL字段】是否有效 (Y/N) |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 9 | ds | VARCHAR(8) | 数据分区字段 |

---

## 关键口径说明

### 粒度说明

与 `dwd_fact_decision_execution_di` 的关系：
- `dwd_fact_decision_execution_di` 按 `id` 粒度记录每次决策执行事件
- 本表按 `id + reject_code` 粒度记录每次决策拒绝码命中事件
- 一次决策可能命中多个拒绝码，因此本表可能存在一条申请对应多条拒绝码记录的情况

### 与 dim_decision_rule_reject_mapping_iri 的关联

拒绝码（reject_code）可通过 `dim_decision_rule_reject_mapping_iri` 映射到具体规则码（rule_code），实现拒绝原因下钻分析。

### ETL 字段说明

- `is_active = 'Y'` 表示当前有效记录
- `ds` 分区字段与 `data_date` 保持一致

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 拒绝码字段 | 决策引擎执行结果中的拒绝码 |
| 业务类型字段 | 决策引擎执行上下文 |
