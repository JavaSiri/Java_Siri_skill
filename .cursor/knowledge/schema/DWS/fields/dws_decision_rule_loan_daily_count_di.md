# dws_decision_rule_loan_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_decision_rule_loan_daily_count_di` |
| **描述** | 借款申请规则命中统计表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (loan_application_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 自然周期型（借款/贷后相关） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 无金额字段 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_application_date | VARCHAR | 借款申请日期 |
| 2 | diversion_type | VARCHAR | 分流类型，1=华通/晋商，2=嵩海 |
| 3 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 4 | is_first_loan | VARCHAR | 是否为首次支用，Y=首次支用，N=非首次支用，按用户申请时间 |
| 5 | if_sh_flag | VARCHAR | 陪跑标记，1=陪跑，0=非陪跑 |
| 6 | rule_code | VARCHAR | 规则码 |

### 度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | rule_hit_num | BIGINT | 规则码命中笔数 |
| 8 | ds | VARCHAR | 数据分区字段，yyyymmdd |

---

## 关键口径说明

### 切片维度

按 `loan_application_date + diversion_type + product_code_sk + is_first_loan + if_sh_flag + rule_code` 切片，每行代表某借款申请日期下某一规则码的当日命中笔数。

### 与授信规则表的区别

| 对比项 | dws_decision_rule_credit_daily_count_di | dws_decision_rule_loan_daily_count_di |
|--------|---------------------------------------|---------------------------------------|
| 业务场景 | 授信申请环节 | 支用申请环节 |
| 是否首支 | 无 | is_first_loan 维度 |
| 时间字段 | credit_application_date | loan_application_date |

### rule_hit_num

当日借款申请中命中该规则码的笔数（去重计数），用于分析规则命中频率和效果。

### 使用场景

- 分析各规则在支用环节的命中量分布
- 结合 `dws_decision_reject_code_daily_di` 分析拒绝原因
- 按 is_first_loan 区分新客/老客规则效果
- 支持风控规则调优的漏斗分析

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，借款/贷后相关，读上游 `[T-3, T-1]`，写入 ds 取 `loan_application_date`。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 维度字段 | 关联 ODS 入湖后的支用申请事实表 |
| is_first_loan | 基于授信 ID 的历史支用记录判断 |
| rule_code | 关联 DWD 决策规则维表 |
| rule_hit_num | 关联决策引擎结果表，按 rule_code 分组聚合 |
