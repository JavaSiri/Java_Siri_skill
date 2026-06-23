# dws_customer_by_annual_rate_daily_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_customer_by_annual_rate_daily_di` |
| **描述** | DWS客户主题-按年利率分层的日维度统计宽表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 自然周期型（客户主题） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 数据业务日期，yyyyMMdd |
| 2 | application_date | VARCHAR | 申请日期 |
| 3 | diversion_type | VARCHAR | 分流类型，1=华通/晋商，2=嵩海 |
| 4 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 5 | annual_rate | NUMERIC(38,18) | 年利率 |

### 授信度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | credit_customer_num | BIGINT | 当日该年利率下授信申请的去重客户数 |
| 7 | credit_pass_customer_num | BIGINT | 当日该年利率下授信申请通过的去重客户数 |
| 8 | credit_application_num | BIGINT | 当日该年利率下授信申请笔数 |
| 9 | credit_pass_num | BIGINT | 当日该年利率下授信通过笔数 |
| 10 | credit_deny_num | BIGINT | 当日该年利率下授信拒绝笔数 |
| 11 | credit_fail_num | BIGINT | 当日该年利率下授信失败笔数 |
| 12 | credit_other_num | BIGINT | 当日该年利率下授信其他状态笔数 |
| 13 | credit_application_total_amount | BIGINT | 当日该年利率下授信申请总额度 |
| 14 | credit_pass_total_amount | BIGINT | 当日该年利率下授信通过总额度 |

### 借款度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 15 | loan_customer_num | BIGINT | 当日该年利率下借款申请的去重客户数 |
| 16 | loan_pass_customer_num | BIGINT | 当日该年利率下借款申请通过的去重客户数 |
| 17 | loan_application_num | BIGINT | 当日该年利率下借款申请笔数 |
| 18 | loan_pass_num | BIGINT | 当日该年利率下借款通过笔数 |
| 19 | loan_deny_num | BIGINT | 当日该年利率下借款拒绝笔数 |
| 20 | loan_fail_num | BIGINT | 当日该年利率下借款失败笔数 |
| 21 | loan_other_num | BIGINT | 当日该年利率下借款其他状态笔数 |
| 22 | loan_application_total_amount | BIGINT | 当日该年利率下借款申请总额度 |
| 23 | loan_pass_total_amount | BIGINT | 当日该年利率下借款通过总额度 |

### 逾期/提前还款/优质客户度量（观察点，截至当前ds）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 24 | total_customer_num | BIGINT | 截至当前观察点，该年利率下的客户总数 |
| 25 | overdue_customer_num | BIGINT | 截至当前观察点，该年利率下产生过借据逾期行为的客户数量 |
| 26 | overdue_loan_num | BIGINT | 截至当前观察点，该年利率下的客户逾期借据数 |
| 27 | overdue_times | BIGINT | 截至当前观察点，该年利率下的借据逾期总次数 |
| 28 | overdue_max_period | BIGINT | 截至当前观察点，该年利率下的借据逾期的最大期次数 |
| 29 | overdue_min_period | BIGINT | 截至当前观察点，该年利率下的借据逾期的最小期次数 |
| 30 | early_customer_num | BIGINT | 截至当前观察点，该年利率下产生过提前还款行为的客户数量 |
| 31 | early_loan_num | BIGINT | 截至当前观察点，该年利率下的客户提前还款借据数 |
| 32 | early_times | BIGINT | 截至当前观察点，该年利率下的借据提前还款总次数 |
| 33 | early_max_period | BIGINT | 截至当前观察点，该年利率下的借据提前还款的最大期次数 |
| 34 | early_min_period | BIGINT | 截至当前观察点，该年利率下的借据提前还款的最小期次数 |
| 35 | nice_customer_num | BIGINT | 截至当前观察点，该年利率下从未发生过逾期行为的客户数量 |
| 36 | nice_application_times | BIGINT | 截至当前观察点，该年利率下从未发生过逾期行为的客户借款次数 |
| 37 | ds | VARCHAR | 数据分区字段，yyyymmdd |

---

## 关键口径说明

### 切片维度

按 `data_date + application_date + diversion_type + product_code_sk + annual_rate` 切片，年利率为连续值维度。

### 度量分类

- **当日度量**：统计当日发生的事件（授信/借款笔数、额度）
- **观察点度量**：累积截至当前 ds 的客户行为状态（逾期/提前还款/优质）

### 逾期层级

逾期按 `cur_ovd_days` 判定，nice_customer_num 指从未产生过逾期的优质客户。

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，读上游 `[T-2, T]`，写入 ds 取 `data_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 年利率维度 | 关联产品定价维表，取实际执行的年利率 |
| 授信度量 | 关联 ODS 授信申请事实表 |
| 借款度量 | 关联 ODS 支用申请事实表 |
| 逾期/提前还款度量 | 关联 DWD 还款事实表，按年利率切片聚合 |
