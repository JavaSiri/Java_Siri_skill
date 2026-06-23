# ads_node_credit_daily_count_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_node_credit_daily_count_di` |
| **描述** | 授信节点统计表，按【授信申请日期 + 产品 + 分流类型 + 陪跑标记】维度统计各决策阶段的申请/通过/拒绝数据 |
| **分区键** | `ds`（yyyymmdd），按授信申请日期动态分区 |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 日维（授信申请日期） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 授信申请日期 + 产品 + 分流类型 + 陪跑标记 |
| **回刷窗口** | [T-2, T]，支持最近3天数据回刷 |
| **写入策略** | DELETE + INSERT 幂等，动态分区覆盖 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据日期（与授信申请日期相同） |
| 2 | credit_application_date | VARCHAR(8) | 【分组维度】授信申请日期，格式 yyyyMMdd |
| 3 | product_code_sk | VARCHAR(64) | 【分组维度】产品主键 |
| 4 | diversion_type | VARCHAR(2) | 【分组维度】分流类型：1=晋商/华通；2=嵩海 |
| 5 | if_sh_flag | VARCHAR(2) | 【分组维度】陪跑标记：1=陪跑；0=非陪跑 |

### 核心指标-决策中（type=2）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | decision_application_num | BIGINT | 决策中申请笔数 |
| 7 | decision_pass_num | BIGINT | 决策中通过笔数 |
| 8 | decision_deny_num | BIGINT | 决策中拒绝笔数 |
| 9 | decision_application_amount | DECIMAL(38,18) | 决策中申请额度（元） |
| 10 | decision_pass_amount | DECIMAL(38,18) | 决策中通过额度（元） |

### 核心指标-决策前（type=1）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | decision_pre_deny_num | BIGINT | 决策前拒绝笔数 |

### 核心指标-决策后（type=3）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 12 | decision_suf_deny_num | BIGINT | 决策后拒绝笔数 |

### 核心指标-比率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 13 | decision_pass_rate_by_amount | DECIMAL(38,18) | 决策通过率（按额度）= 通过额度 / 申请额度 |
| 14 | decision_pass_rate_by_num | DECIMAL(38,18) | 决策通过率（按笔数）= 通过笔数 / 申请笔数 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 15 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd，等于 credit_application_date） |

---

## 关键口径说明

### 决策阶段拆解逻辑

上游 DWS 层按 `node_type_by_decision` 区分三个阶段，本表通过 CASE WHEN 拆分：

| 上游字段值 | 阶段含义 | 本表字段映射 |
|-----------|---------|------------|
| type=1（决策前） | 初筛拒绝 | decision_pre_deny_num |
| type=2（决策中） | 决策节点 | decision_application_num/pass_num/deny_num/application_amount/pass_amount |
| type=3（决策后） | 终审拒绝 | decision_suf_deny_num |

### 回刷机制

- 每次运行覆盖 [T-2, T] 三天分区，确保数据修正
- ds 分区值取自 `credit_application_date`

### 除零保护

通过率字段使用 `NULLIF(申请额度/申请笔数, 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 各决策阶段指标 | dws_node_credit_daily_count_di | node_application_num/pass_num/deny_num/application_amount/pass_amount |
| 授信申请日期 | dws_node_credit_daily_count_di | credit_application_date |
| 分流类型 / 陪跑标记 / 产品 | dws_node_credit_daily_count_di | diversion_type / if_sh_flag / product_code_sk |
