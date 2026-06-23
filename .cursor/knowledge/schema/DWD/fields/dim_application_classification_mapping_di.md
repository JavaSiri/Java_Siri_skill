# dim_application_classification_mapping_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dim_application_classification_mapping_di` |
| **描述** | 申请分类映射维度表 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | HASH (id) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 日维（ds） |
| **金额单位** | 无金额字段 |
| **表粒度** | 授信/借据级（id = 授信ID/借据号） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | id | VARCHAR(64) | 【维度外键】授信ID/借据号 |
| 2 | product_code_sk | VARCHAR(64) | 【维度外键】产品编码 |

### 维度属性-类型

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 3 | type | VARCHAR(2) | 【维度属性-类型】业务类型：1=授信；2=借款 |
| 4 | is_first_credit | VARCHAR(2) | 【维度属性-类型】是否首次授信：Y=首次授信；N=非首次授信 |
| 5 | is_first_loan | VARCHAR(2) | 【维度属性-类型】是否首次支用：Y=首次支用；N=非首次支用 |
| 6 | diversion_type | VARCHAR(2) | 【维度属性-类型】分流类型：1=晋商/华通；2=嵩海 |
| 7 | if_sh_flag | VARCHAR(2) | 【维度属性-类型】陪跑标记：1=陪跑；0=非陪跑 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | created_time | TIMESTAMP | 【ETL字段】创建时间 |
| 9 | updated_time | TIMESTAMP | 【ETL字段】更新时间 |
| 10 | effective_date | TIMESTAMP | 【ETL字段】生效日期 |
| 11 | expiry_date | TIMESTAMP | 【ETL字段】失效日期 |
| 12 | is_active | VARCHAR(2) | 【ETL字段】是否有效 (Y/N) |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 13 | ds | VARCHAR(8) | 数据分区字段 |

---

## 关键口径说明

### 核心分类维度

本表是 DWD 层最重要的分类映射表，提供以下核心维度组合：

| 维度字段 | 枚举值 | 含义 |
|----------|--------|------|
| `diversion_type` | 1=晋商/华通；2=嵩海 | 分流通道 |
| `is_first_credit` | Y/N | 是否首次授信（新客/老客） |
| `is_first_loan` | Y/N | 是否首次支用（新支/复支） |
| `if_sh_flag` | 1=陪跑；0=非陪跑 | 陪跑标记 |
| `product_code_sk` | - | 产品维度 |

### 与其他表的关系

- 通过 `id` 关联 `dwd_fact_credit_application_di`（授信场景）或 `dwd_fact_loan_application_di`（借款场景）
- 通过 `product_code_sk` 可关联产品维表

### ETL 字段说明

- `effective_date` / `expiry_date`：有效期间，支持拉链
- `is_active = 'Y'` 表示当前有效记录

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| id / type | 关联授信/借款申请记录 |
| is_first_* / diversion_type / if_sh_flag | 业务规则加工生成 |
