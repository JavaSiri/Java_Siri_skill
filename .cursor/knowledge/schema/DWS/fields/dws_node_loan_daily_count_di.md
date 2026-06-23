# dws_node_loan_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_node_loan_daily_count_di` |
| **描述** | 借款节点统计表 |
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
| 3 | is_first_loan | VARCHAR | 是否为首次支用，Y=首次支用，N=非首次支用，按用户申请时间 |
| 4 | diversion_type | VARCHAR | 分流类型，1=华通/晋商，2=嵩海 |
| 5 | if_sh_flag | VARCHAR | 陪跑标记，1=陪跑，0=非陪跑 |
| 6 | product_code_sk | VARCHAR | 【维度属性-类别】产品编码 |
| 7 | node_type_by_decision | VARCHAR | 【维度外键】节点类型，1=决策前节点，2=决策中节点，3=决策后节点 |

### 度量（当日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | node_application_num | BIGINT | 节点申请笔数 |
| 9 | node_pass_num | BIGINT | 节点通过笔数 |
| 10 | node_deny_num | BIGINT | 节点拒绝笔数 |
| 11 | node_fail_num | BIGINT | 节点失败笔数 |
| 12 | node_other_num | BIGINT | 节点其他笔数 |
| 13 | node_application_amount | BIGINT | 节点申请额度 |
| 14 | node_pass_amount | BIGINT | 节点通过额度 |
| 15 | node_deny_amount | BIGINT | 节点拒绝额度 |
| 16 | node_fail_amount | BIGINT | 节点失败额度 |
| 17 | node_other_amount | BIGINT | 节点其他额度 |
| 18 | ds | VARCHAR | 数据分区字段，yyyymmdd |

---

## 关键口径说明

### 维度说明

- `data_date`：数据截止的业务日期，用于报表查询的时间条件
- `loan_application_date`：借款申请发生的自然日期，按申请日期切片统计
- `is_first_loan`：是否首次支用，用于区分新客与老客的漏斗分析
- `node_type_by_decision`：按决策流程阶段划分的节点类型，用于多阶段漏斗分析

### 度量口径

笔数与额度一一对应，五个状态（申请/通过/拒绝/失败/其他）互斥，当日同节点维度下笔数之和 = 申请笔数。

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，借款/贷后相关，读上游 `[T-3, T-1]`，写入 ds 取 `loan_application_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 维度字段 | 关联 ODS 入湖后的支用申请事实表 |
| 是否首支 | 基于授信 ID 的历史支用记录判断 |
| 节点类型 | 关联 DWD 节点维表，映射决策流程阶段 |
| 度量字段 | 关联支用申请事实表，按节点维度聚合 |
