# dim_node_decision_mapping_iri

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dim_node_decision_mapping_iri` |
| **描述** | 节点映射维度表 |
| **分区键** | 无（全局表） |
| **分布策略** | HASH (node_id) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 无分区 |
| **金额单位** | 无金额字段 |
| **表粒度** | 节点级（node_id） |
| **表类型** | Irf（镜像表/维表快照） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | node_id | VARCHAR(32) | 【维度外键】节点编码 |
| 2 | node_name | VARCHAR(64) | 【维度外键】节点名称：以合作方节点列表为准 |
| 3 | node_type_by_decision | VARCHAR(2) | 【维度外键】节点类型：1=决策前节点；2=决策中节点；3=决策后节点 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 4 | created_time | TIMESTAMP | 【ETL字段】创建时间 |
| 5 | updated_time | TIMESTAMP | 【ETL字段】更新时间 |
| 6 | is_active | VARCHAR(2) | 【ETL字段】是否有效 (Y/N) |

---

## 关键口径说明

### Irf 表特性

本表为 Irf（镜像表），全量存储合作方提供的节点列表，不按日期分区，所有记录存在于全局命名空间。

### 节点类型枚举

| 节点类型 | 含义 |
|----------|------|
| 1 | 决策前节点 |
| 2 | 决策中节点 |
| 3 | 决策后节点 |

### 与其他表的关系

- 可通过 `node_id` 关联 `dwd_fact_decision_execution_di` 查看每个节点的执行情况
- 可通过 `node_id` 关联 `dim_credit_node_di` / `dim_loan_node_di` 查看节点耗时明细

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| node_id / node_name / node_type_by_decision | 合作方（字节/行方）提供的节点配置列表 |
