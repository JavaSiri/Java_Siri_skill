# dws_customer_daily_count_balance_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_customer_daily_count_balance_df` |
| **描述** | Y宽表-客户每日余额 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (credit_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 每日快照型（客户维度） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 日期切片 |
| 2 | credit_date | TIMESTAMP | 授信时间（授信第二笔则两笔） |
| 3 | customer_id | VARCHAR | 客户ID |
| 4 | product_code_sk | VARCHAR | 产品编码 |
| 5 | diversion_type | VARCHAR | 分流类型 |

### 度量（观察点，截至 data_date 当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | bal | BIGINT | 截止观察点该客户所有在贷借据的剩余本金 |
| 7 | cur_ovd_days | BIGINT | 当前逾期天数 |
| 8 | top_ovd_days | BIGINT | 历史最大逾期天数 |
| 9 | ds | VARCHAR | 数据日期分区，格式 yyyyMMdd |

---

## 关键口径说明

### 分布键选择

本表以 `credit_date`（授信时间戳）作为分布键，而非 `data_date`，目的是将同一客户的授信记录打散到不同节点，避免数据倾斜。

### 快照粒度

每行代表某一客户在某一 `data_date` 的余额及逾期快照，每个客户每天一条记录，按 `customer_id` 维度存储全部在贷借据汇总。

### bal 口径

`bal` = 客户所有在贷借据的剩余本金之和，不包含已结清借据。

### 逾期口径

- `cur_ovd_days`：当前（截至 data_date）仍在逾期的天数，取所有在贷借据的最大值
- `top_ovd_days`：该客户历史所有借据的最大逾期天数（终身累计）

### ds 分区语义

ds 取自 `data_date`，属于**业务时间分区**，读上游 `[T-2, T]`，写入 ds 取 `data_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| customer_id / credit_date | 关联 ODS 入湖后的授信事实表 |
| bal | 关联 DWD 借据余额快照事实表 |
| cur_ovd_days / top_ovd_days | 关联 DWD 逾期维表 |
