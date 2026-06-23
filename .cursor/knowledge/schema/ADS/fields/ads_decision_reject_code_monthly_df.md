# ads_decision_reject_code_monthly_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_reject_code_monthly_df` |
| **描述** | 决策拒绝码月维表，按【统计月 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码】维度统计拒绝码累计命中笔数及决策通过率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（统计月） |
| **金额单位** | 无金额字段 |
| **表粒度** | 统计月 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码 |
| **回刷窗口** | [month_start(T-2), T] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | month_start_date | VARCHAR(8) | 【分组维度】统计月起始日，格式 yyyyMMdd |
| 3 | month_end_date | VARCHAR(8) | 【分组维度】统计月结束日，格式 yyyyMMdd |
| 4 | type | VARCHAR | 【分组维度】决策类型：1=授信；2=借款 |
| 5 | product_code_sk | VARCHAR | 【分组维度】产品主键 |
| 6 | is_first_loan | VARCHAR | 【分组维度】是否首次支用：Y=是；N=否 |
| 7 | diversion_type | VARCHAR | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 8 | if_sh_flag | VARCHAR | 【分组维度】陪跑标记：1=陪跑；0=非陪跑 |
| 9 | rule_code | VARCHAR | 【分组维度】规则代码 |
| 10 | reject_code | VARCHAR | 【分组维度】拒绝码 |

### 核心指标

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | reject_code_hit_num | BIGINT | 当月该拒绝码累计命中笔数 |
| 12 | decision_application_num | BIGINT | 当月进入决策的累计申请笔数 |
| 13 | decision_pass_rate_by_reject_code | DECIMAL(18,8) | 当月该拒绝码下的决策通过率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 14 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 与 ads_decision_reject_code_daily_di 的关系

本表为月维汇总表，数据来源于日维表按月聚合：

- 历史月数据从 ds=T-1 分区继承（month_start_date < win_start_ds 的月份）
- 窗口内月份由 dws_decision_reject_code_daily_di 按月重算

### 除零保护

decision_pass_rate_by_reject_code 使用 `CASE WHEN decision_application_num=0 THEN NULL ELSE ...` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 拒绝码命中与决策申请 | dws_decision_reject_code_daily_di | reject_code_hit_num / decision_application_num |
