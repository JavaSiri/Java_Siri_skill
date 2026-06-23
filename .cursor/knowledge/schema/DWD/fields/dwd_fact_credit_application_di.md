# dwd_fact_credit_application_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dwd_fact_credit_application_di` |
| **描述** | 授信申请事实表 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | HASH (credit_sk) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 日维（ds = data_date） |
| **金额单位** | 分 |
| **表粒度** | 授信申请级（credit_sk 为业务主键） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | credit_sk | VARCHAR(64) | 【维度外键】授信流水号（字节的授信流水号，唯一确定一笔授信申请） |
| 2 | customer_sk | VARCHAR(64) | 【维度外键】用户ID |
| 3 | product_code_sk | VARCHAR(64) | 【维度外键】产品编码 |
| 4 | credit_contract_no | VARCHAR(64) | 【维度外键】授信合同号 |
| 5 | bank_credit_apply_seq | VARCHAR(64) | 【维度外键】行方内部授信申请流水号 |
| 6 | tp_no | VARCHAR(64) | 【维度外键】授信ID（字节透传的 account_id，不唯一，不做关联使用） |

### 维度属性-时间

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | system_processing_time | TIMESTAMP | 【维度属性-时间】系统处理时间：系统接收到用户申请的授信的时间 |
| 8 | apply_time | TIMESTAMP | 【维度属性-时间】授信申请时间：用户申请授信的时间 |
| 9 | data_date | VARCHAR(8) | 【维度属性-时间】数据业务日期，格式：yyyyMMdd |
| 10 | credit_effective_time | TIMESTAMP | 【维度属性-时间】授信生效时间 |
| 11 | credit_expiry_time | TIMESTAMP | 【维度属性-时间】授信失效时间 |

### 度量-当笔授信

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | credit_amount | BIGINT | 【度量-当笔授信】授信预估额度 |
| 13 | actual_amount | BIGINT | 【度量-当笔授信】实际额度 |
| 14 | credit_daily_rate | DECIMAL(38,18) | 【度量-当笔授信】授信日利率 |
| 15 | credit_annual_rate | DECIMAL(38,18) | 【度量-当笔授信】授信年利率 |

### 维度属性-状态

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 16 | credit_status | VARCHAR(2) | 【维度属性-状态】申请状态: 1=通过；0=拒绝；2=失败；3=其他（处理中等中间态） |

### 备注

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 17 | remark | VARCHAR(64) | 【备注】授信通过或拒绝的原因 |

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

### 主键与粒度

`credit_sk`（授信流水号）为业务主键，每行代表一笔授信申请的一次快照记录。

### credit_status 状态枚举

| 状态码 | 含义 |
|--------|------|
| 1 | 通过 |
| 0 | 拒绝 |
| 2 | 失败 |
| 3 | 其他（处理中等中间态） |

### 额度关系

- `credit_amount`：系统风控预估额度
- `actual_amount`：最终实际授信额度

### ETL 字段说明

- `is_active = 'Y'` 表示当前有效记录；历史变更后 `is_active = 'N'`，实现拉链效果
- `ds` 分区字段与 `data_date` 保持一致

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 维度外键字段 | ODS 层入湖后的授信申请原始数据 |
| 额度/利率字段 | 来自字节透传或行方核心系统的授信数据 |
| 状态字段 | 决策引擎执行结果 |
