# dws_credit_application_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_credit_application_daily_count_di` |
| **描述** | 授信申请统计表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 自然周期型（授信相关） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 分 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 数据业务日期，yyyyMMdd |
| 2 | credit_application_date | VARCHAR | 授信申请日期 |
| 3 | diversion_type | VARCHAR | 分流类型，1=华通/晋商，2=嵩海 |
| 4 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |

### 授信笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 5 | credit_application_num | BIGINT | 授信申请笔数 |
| 6 | credit_pass_num | BIGINT | 授信通过笔数 |
| 7 | credit_deny_num | BIGINT | 授信拒绝笔数 |
| 8 | credit_fail_num | BIGINT | 授信失败笔数 |
| 9 | credit_other_num | BIGINT | 授信其他状态笔数 |

### 决策规则命中笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | global_hard_rule_ovd_num | BIGINT | global hard rule 逾期类命中笔数 |
| 11 | global_hard_rule_noovd_num | BIGINT | global hard rule 非逾期类命中笔数 |
| 12 | soft_rule_num | BIGINT | soft rule 命中笔数 |
| 13 | customer_level_num | BIGINT | 客户等级命中笔数 |
| 14 | estimate_above_actual_num | BIGINT | 授信预估额度超过实际额度总笔数 |

### 授信额度度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 15 | credit_application_all_amount | BIGINT | 授信申请总额度 |
| 16 | credit_application_max_amount | BIGINT | 授信申请单笔最大额度 |
| 17 | credit_application_min_amount | BIGINT | 授信申请单笔最小额度 |
| 18 | credit_pass_all_amount | BIGINT | 授信通过总额度 |
| 19 | credit_pass_max_amount | BIGINT | 授信通过单笔最大额度 |
| 20 | credit_pass_min_amount | BIGINT | 授信通过单笔最小额度 |

### 复合金额度量（当日，NUMERIC(38,18)）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 21 | credit_application_amount_daily_rate_sum | NUMERIC(38,18) | 每笔授信申请额度 × 授信日利率 加总 |
| 22 | credit_application_amount_annual_rate_sum | NUMERIC(38,18) | 每笔授信申请额度 × 授信年利率 加总 |
| 23 | credit_pass_amount_daily_rate_sum | NUMERIC(38,18) | 每笔授信通过额度 × 授信日利率 加总 |
| 24 | credit_pass_amount_annual_rate_sum | NUMERIC(38,18) | 每笔授信通过额度 × 授信年利率 加总 |

### 决策笔数度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 25 | decision_application_num | BIGINT | 决策申请笔数 |
| 26 | decision_pass_num | BIGINT | 决策通过笔数 |
| 27 | decision_deny_num | BIGINT | 决策拒绝笔数 |
| 28 | decision_pre_deny_num | BIGINT | 决策前拒绝笔数 |
| 29 | ds | VARCHAR | 数据分区字段，yyyymmdd |

---

## 关键口径说明

### 切片维度

按 `data_date + credit_application_date + diversion_type + product_code_sk` 切片，每日按授信申请日期聚合统计。

### 与借款表的对比

| 对比项 | dws_credit_application_daily_count_di | dws_loan_application_daily_count_di |
|--------|--------------------------|------------------------|
| 业务场景 | 授信环节 | 支用环节 |
| 时间字段 | credit_application_date | loan_application_date |
| 额度字段 | 授信额度 | 借款额度 |
| 共同字段 | diversion_type / product_code_sk / 决策规则 / 决策笔数 | 同 |

### 决策规则命中

- `global_hard_rule_ovd_num`：命中全局硬规则中的逾期类规则笔数
- `global_hard_rule_noovd_num`：命中全局硬规则中的非逾期类规则笔数
- `soft_rule_num`：命中软规则笔数
- `customer_level_num`：命中客户分层策略笔数

### estimate_above_actual_num

统计授信申请中，系统预估额度 > 风控实际授信额度的笔数，用于分析额度模型偏差。

### 决策流程

- `decision_pre_deny_num`：进入决策引擎前被前置规则拒绝的笔数
- `decision_application_num`：进入决策的申请笔数
- `decision_deny_num`：决策结果为拒绝的笔数
- `decision_pass_num`：决策结果为通过的笔数

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，授信相关，读上游 `[T-2, T]`，写入 ds 取 `credit_application_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 维度字段 | 关联 ODS 入湖后的授信申请事实表 |
| 笔数字段 | 关联授信申请事实表，按维度分组聚合 |
| 规则命中字段 | 关联决策引擎结果表，按规则类型聚合 |
| 额度字段 | 来自授信申请事实表中的额度字段 |
| 利率字段 | 来自产品定价维表 |
