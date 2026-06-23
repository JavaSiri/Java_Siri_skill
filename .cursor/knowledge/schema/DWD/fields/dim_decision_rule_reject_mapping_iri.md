# dim_decision_rule_reject_mapping_iri

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dim_decision_rule_reject_mapping_iri` |
| **描述** | 拒绝码映射维度表 |
| **分区键** | 无（全局表） |
| **分布策略** | HASH (reject_code) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 无分区 |
| **金额单位** | 无金额字段 |
| **表粒度** | 拒绝码级（reject_code） |
| **表类型** | Irf（镜像表/维表快照） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | reject_code | VARCHAR(32) | 【维度外键】拒绝码 |
| 2 | rule_code | VARCHAR(32) | 【维度外键】规则码 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 3 | created_time | TIMESTAMP | 【ETL字段】创建时间 |
| 4 | updated_time | TIMESTAMP | 【ETL字段】更新时间 |
| 5 | is_active | VARCHAR(2) | 【ETL字段】是否有效 (Y/N) |

---

## 关键口径说明

### Irf 表特性

本表为 Irf（镜像表），全量存储拒绝码与规则码的映射关系，不按日期分区。

### 与其他表的关系

- 通过 `reject_code` 关联 `dwd_fact_decision_result_reject_code_di`，将拒绝码映射到触发该拒绝的规则码
- 支持拒绝原因下钻：从 `reject_code` 追溯到 `rule_code`，了解触发拒绝的具体风控规则

### 使用场景

一次决策执行可能命中多个规则，产生多个拒绝码，通过本维表可建立"拒绝码 → 规则码 → 规则名称"的追溯链路。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| reject_code / rule_code | 合作方（字节/行方）提供的拒绝码与规则码映射配置 |
