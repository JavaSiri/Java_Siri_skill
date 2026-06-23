# ads_decision_reject_code_weekly_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_decision_reject_code_weekly_df` |
| **描述** | 决策拒绝码周维表，按【统计周 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码】维度统计拒绝码累计命中笔数及决策通过率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 周维（统计周） |
| **金额单位** | 无金额字段 |
| **表粒度** | 统计周 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码 |
| **回刷窗口** | [week_start(T-2), T] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | week_start_date | VARCHAR(8) | 【分组维度】统计周起始日（周一），格式 yyyyMMdd |
| 3 | week_end_date | VARCHAR(8) | 【分组维度】统计周结束日（周日），格式 yyyyMMdd |
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
| 11 | reject_code_hit_num | BIGINT | 当周该拒绝码累计命中笔数 |
| 12 | decision_application_num | BIGINT | 当周进入决策的累计申请笔数 |
| 13 | decision_pass_rate_by_reject_code | DECIMAL(18,8) | 当周该拒绝码下的决策通过率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 14 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 与 ads_decision_reject_code_daily_di / monthly 的关系

三表粒度一致，区别仅在时间维度：

| 维度 | daily | weekly | monthly |
|------|-------|--------|---------|
| 时间维度 | data_date | week_start/end_date | month_start/end_date |
| 回刷窗口 | [T-2, T] | [week_start(T-2), T] | [month_start(T-2), T] |
| 写入分区 | ds=data_date | ds=T | ds=T |

### 除零保护

decision_pass_rate_by_reject_code 使用 `CASE WHEN decision_application_num=0 THEN NULL ELSE ...` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 拒绝码命中与决策申请 | dws_decision_reject_code_daily_di | reject_code_hit_num / decision_application_num |
