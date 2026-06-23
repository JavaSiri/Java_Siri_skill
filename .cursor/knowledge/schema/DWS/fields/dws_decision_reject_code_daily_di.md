# dws_decision_reject_code_daily_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_decision_reject_code_daily_di` |
| **描述** | 节点主题-决策日维度统计表 |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 自然周期型（决策相关） |
| **时间维度** | 日维（ds = 业务日期字段） |
| **金额单位** | 无金额字段 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 数据业务日期，yyyyMMdd |
| 2 | type | VARCHAR | 决策类型，1=授信，2=借据号，3=调额调价 |
| 3 | is_first_loan | VARCHAR | 是否为首次支用，Y=首次支用，N=非首次支用，按用户申请时间 |
| 4 | diversion_type | VARCHAR | 分流类型，1=华通/晋商，2=嵩海 |
| 5 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 6 | if_sh_flag | VARCHAR | 陪跑标记，1=陪跑，0=非陪跑 |
| 7 | rule_code | VARCHAR | 规则码 |
| 8 | reject_code | VARCHAR | 拒绝码 |

### 度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 9 | reject_code_hit_num | BIGINT | 当日被该拒绝码打中的申请笔数 |
| 10 | decision_application_num | BIGINT | 当日进入决策的申请笔数 |
| 11 | ds | VARCHAR | 数据分区字段，yyyymmdd |

---

## 关键口径说明

### type 维度说明

| type 值 | 含义 | 说明 |
|:-------:|------|------|
| 1 | 授信 | 授信申请进入决策流程 |
| 2 | 借据号 | 支用申请进入决策流程 |
| 3 | 调额调价 | 额度/利率调整进入决策流程 |

### 拒绝码口径

- `rule_code`：命中的前置规则码
- `reject_code`：最终拒绝码，每行代表某一拒绝码在某维度组合下的当日统计
- `reject_code_hit_num`：当日被该拒绝码打中的申请笔数（去重计数）
- `decision_application_num`：当日进入决策的申请笔数（作为分母计算拒绝率）

### 使用场景

本表用于分析决策拒绝原因分布，按拒绝码维度下钻，辅助风控规则调优。

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，读上游 `[T-2, T]`，写入 ds 取 `data_date`。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 维度字段 | 关联 ODS 入湖后的决策结果事实表 |
| rule_code / reject_code | 关联 DWD 决策规则维表，映射规则名称与拒绝码 |
| 度量字段 | 关联决策事实表，按 rule_code + reject_code 分组聚合 |
