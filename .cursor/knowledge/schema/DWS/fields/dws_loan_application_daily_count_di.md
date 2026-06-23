# dws_loan_application_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_loan_application_daily_count_di` |
| **描述** | 借款申请及放款统计日汇总表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 自然周期型（借款/贷后相关） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 数据业务日期，yyyyMMdd |
| 2 | loan_application_date | VARCHAR | 借款申请日期 |
| 3 | diversion_type | VARCHAR | 分流类型，1=华通/晋商，2=嵩海 |
| 4 | is_first_loan | VARCHAR | 是否为首次支用，Y=首次支用，N=非首次支用，按用户申请时间 |
| 5 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 6 | ds | VARCHAR | 数据分区字段，yyyymmdd |

### 借款申请笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | loan_application_num | BIGINT | 借款申请笔数 |
| 8 | loan_pass_num | BIGINT | 借款申请通过笔数 |
| 9 | loan_deny_num | BIGINT | 借款申请拒绝笔数 |
| 10 | loan_fail_num | BIGINT | 借款申请失败笔数 |
| 11 | loan_other_num | BIGINT | 借款申请其他状态笔数 |

### 放款申请笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | loan_repayment_application_num | BIGINT | 放款申请笔数 |
| 13 | loan_repayment_pass_num | BIGINT | 放款申请通过笔数 |
| 14 | loan_repayment_deny_num | BIGINT | 放款申请拒绝笔数 |
| 15 | loan_repayment_fail_num | BIGINT | 放款申请失败笔数 |
| 16 | loan_repayment_other_num | BIGINT | 放款申请其他状态笔数 |

### 决策规则命中笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 17 | global_hard_rule_ovd_num | BIGINT | global hard rule 逾期类命中笔数 |
| 18 | global_hard_rule_noovd_num | BIGINT | global hard rule 非逾期类命中笔数 |
| 19 | soft_rule_num | BIGINT | soft rule 命中笔数 |
| 20 | customer_level_num | BIGINT | 客户分层命中笔数 |

### 借款申请额度度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 21 | loan_application_all_amount | BIGINT | 当日借款申请总额度 |
| 22 | loan_application_max_amount | BIGINT | 当日借款申请最大额度 |
| 23 | loan_application_min_amount | BIGINT | 当日借款申请最小额度 |
| 24 | loan_pass_all_amount | BIGINT | 当日借款通过总额度 |
| 25 | loan_pass_max_amount | BIGINT | 当日借款通过最大额度 |
| 26 | loan_pass_min_amount | BIGINT | 当日借款通过最小额度 |

### 放款申请额度度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 27 | loan_repayment_application_all_amount | BIGINT | 当日放款申请总额度 |
| 28 | loan_repayment_application_max_amount | BIGINT | 当日放款申请最大额度 |
| 29 | loan_repayment_application_min_amount | BIGINT | 当日放款申请最小额度 |
| 30 | loan_repayment_pass_all_amount | BIGINT | 当日放款通过总额度 |
| 31 | loan_repayment_pass_max_amount | BIGINT | 当日放款通过最大额度 |
| 32 | loan_repayment_pass_min_amount | BIGINT | 当日放款通过最小额度 |

### 期数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 33 | loan_application_all_period | BIGINT | 当日借款申请总期数 |
| 34 | loan_pass_all_period | BIGINT | 当日借款通过总期数 |
| 35 | loan_repayment_application_all_period | BIGINT | 当日放款申请总期数 |
| 36 | loan_repayment_pass_all_period | BIGINT | 当日放款通过总期数 |

### 复合金额度量（当日，NUMERIC(38,18)）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 37 | loan_application_amount_period_sum | NUMERIC(38,18) | 借款申请额度 × 借款期数 加总 |
| 38 | loan_application_amount_daily_rate_sum | NUMERIC(38,18) | 借款申请额度 × 借款日利率 加总 |
| 39 | loan_application_amount_annual_rate_sum | NUMERIC(38,18) | 借款申请额度 × 借款年利率 加总 |
| 40 | loan_pass_amount_period_sum | NUMERIC(38,18) | 借款通过额度 × 借款期数 加总 |
| 41 | loan_pass_amount_daily_rate_sum | NUMERIC(38,18) | 借款通过额度 × 借款日利率 加总 |
| 42 | loan_pass_amount_annual_rate_sum | NUMERIC(38,18) | 借款通过额度 × 借款年利率 加总 |
| 43 | loan_repayment_application_amount_period_sum | NUMERIC(38,18) | 放款申请额度 × 放款期数 加总 |
| 44 | loan_repayment_application_amount_daily_rate_sum | NUMERIC(38,18) | 放款申请额度 × 放款日利率 加总 |
| 45 | loan_repayment_application_amount_annual_rate_sum | NUMERIC(38,18) | 放款申请额度 × 放款年利率 加总 |
| 46 | loan_repayment_pass_amount_period_sum | NUMERIC(38,18) | 放款通过额度 × 放款期数 加总 |
| 47 | loan_repayment_pass_amount_daily_rate_sum | NUMERIC(38,18) | 放款通过额度 × 放款日利率 加总 |
| 48 | loan_repayment_pass_amount_annual_rate_sum | NUMERIC(38,18) | 放款通过额度 × 放款年利率 加总 |

### 决策笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 49 | decision_application_num | BIGINT | 决策申请笔数 |
| 50 | decision_pass_num | BIGINT | 决策通过笔数 |
| 51 | decision_deny_num | BIGINT | 决策拒绝笔数 |
| 52 | decision_pre_deny_num | BIGINT | 决策前拒绝笔数 |

---

## 关键口径说明

### 维度说明

- `data_date`：数据截止的业务日期，用于报表查询的时间条件
- `loan_application_date`：借款申请发生的自然日期，按申请日期切片统计
- `is_first_loan`：是否首次支用，区分新客与老客

### 度量层级

本表度量按流程阶段分为两层：

1. **借款申请层**（loan_application_*）：从用户发起借款申请 → 审批结果
2. **放款层**（loan_repayment_*）：从放款审批通过 → 放款结果

### 决策规则命中

- `global_hard_rule_ovd_num`：命中全局硬规则中的逾期类规则笔数
- `global_hard_rule_noovd_num`：命中全局硬规则中的非逾期类规则笔数
- `soft_rule_num`：命中软规则笔数
- `customer_level_num`：命中客户分层策略笔数

### 复合金额字段

amount × period/daily_rate/annual_rate 的 SUM，用于分析加权后的金额分布，NUMERIC(38,18) 精度保留。

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，借款/贷后相关，读上游 `[T-3, T-1]`，写入 ds 取 `loan_application_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 维度字段 | 关联 ODS 入湖后的借款申请事实表 |
| 笔数/额度字段 | 关联借款申请事实表，按维度分组聚合 |
| 规则命中字段 | 关联决策引擎结果表，按规则类型聚合 |
| 期数字段 | 来自借款合同分期配置 |
| 利率字段 | 来自产品定价维表 |
