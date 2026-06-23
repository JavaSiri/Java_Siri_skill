# dws_loan_advance_settle_daily_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_loan_advance_settle_daily_df` |
| **描述** | DWS 借据提前结清-日维度统计表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (loan_id) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 切片累积型（借据维度 + 期次维度） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分（上游 ODS 层原始数据单位） |

---

## 字段定义

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_id | VARCHAR | 借据号，主键维度 |
| 2 | diversion_type | VARCHAR | 分流类型：1=晋商/华通；2=嵩海 |
| 3 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 4 | loan_date | TIMESTAMP | 放款时间 |
| 5 | period | INT | 分期数（3/6/9/12 期） |
| 6 | term | INT | 期次（1,2...12），当前处于第几期 |
| 7 | repay_amt | NUMERIC(38,18) | 已还总金额（含本金+利息） |
| 8 | advance_settle_amt | NUMERIC(38,18) | 提前结清总金额（提前还款本金+利息） |
| 9 | loan_amt | NUMERIC(38,18) | 放款金额（本金） |
| 10 | ds | VARCHAR | 业务日期分区，yyyymmdd |

---

## 关键口径说明

### repay_amt vs advance_settle_amt

- `repay_amt`：历史累计已还金额，包含正常还分期和提前结清
- `advance_settle_amt`：提前结清时的还款金额，独立统计
- 两者存在重叠区间：提前结清当期，`advance_settle_amt` 会计入当期还款，`repay_amt` 也会累加

### ds 分区语义

ds 取自 `业务日期字段`（非上游 ds），表示**该行数据归属于哪一天的统计**，属于**业务时间分区**。

分区覆盖范围：借款/贷后相关，读上游 `[T-3, T-1]`，写入 ds 取各业务日期值。

### 金额单位

上游 ODS 层为分，DWS 层**不处理**金额单位转换（保持分），ADS 层引用时需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 借据维度 | ODS 入湖后关联 DWD 借据事实表 |
| 产品维度 | 关联 DWD 产品维表获取 product_code_sk |
| 分期字段 | 来自借款合同的分期配置 |
| 金额字段 | 来自还款流水，按 loan_id 累计求和 |
