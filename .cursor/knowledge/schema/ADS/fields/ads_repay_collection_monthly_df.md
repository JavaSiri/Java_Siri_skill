# ads_repay_collection_monthly_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_repay_collection_monthly_df` |
| **描述** | 入催催回统计表，按【应还款月 + 产品 + 分流类型 + 客户等级】维度统计催收回收数据 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（应还款月） |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **表粒度** | 应还款月 + 产品 + 分流类型 + 客户等级 |
| **写入策略** | DELETE + INSERT 幂等，按 T-1 日期分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_month | VARCHAR | 【分组维度】应还款月，格式 yyyy-MM |
| 2 | product_code_sk | VARCHAR(64) | 【分组维度】产品主键 |
| 3 | diversion_type | VARCHAR(2) | 【分组维度】分流类型：1=华通/晋商；2=嵩海 |
| 4 | customer_level | VARCHAR | 【分组维度】客户等级：A/B/C/F/未知/全部 |

### 核心指标-金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 5 | due_principal | DECIMAL(38,18) | 应还本金（元） |
| 6 | overdue_amt | DECIMAL(38,18) | 逾期金额（元）= 逾期本金 / 100 |

### 核心指标-逾期率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | overdue_rate | DECIMAL(38,18) | 逾期率 = 逾期金额 / 应还本金 |

### 核心指标-催回金额与催回率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | recovery_amt_0to3 | DECIMAL(38,18) | 逾期回款金额_0to3（元），逾期>=3天时计入 |
| 9 | recovery_rate_0to3 | DECIMAL(38,18) | 逾期回款率_0to3 = recovery_amt_0to3 / 逾期金额 |
| 10 | recovery_amt_0to7 | DECIMAL(38,18) | 逾期回款金额_0to7（元），逾期>=7天时计入 |
| 11 | recovery_rate_0to7 | DECIMAL(38,18) | 逾期回款率_0to7 = recovery_amt_0to7 / 逾期金额 |
| 12 | recovery_amt_0to30 | DECIMAL(38,18) | 逾期回款金额_0to30（元），逾期>=30天时计入 |
| 13 | recovery_rate_0to30 | DECIMAL(38,18) | 逾期回款率_0to30 = recovery_amt_0to30 / 逾期金额 |
| 14 | recovery_amt_0to60 | DECIMAL(38,18) | 逾期回款金额_0to60（元），逾期>=60天时计入 |
| 15 | recovery_rate_0to60 | DECIMAL(38,18) | 逾期回款率_0to60 = recovery_amt_0to60 / 逾期金额 |
| 16 | recovery_amt_0to90 | DECIMAL(38,18) | 逾期回款金额_0to90（元），逾期>=90天时计入 |
| 17 | recovery_rate_0to90 | DECIMAL(38,18) | 逾期回款率_0to90 = recovery_amt_0to90 / 逾期金额 |
| 18 | recovery_amt_0to180 | DECIMAL(38,18) | 逾期回款金额_0to180（元），逾期>=180天时计入 |
| 19 | recovery_rate_0to180 | DECIMAL(38,18) | 逾期回款率_0to180 = recovery_amt_0to180 / 逾期金额 |
| 20 | recovery_amt_over180 | DECIMAL(38,18) | 逾期回款金额_over180（元），逾期>180天时计入 |
| 21 | recovery_rate_over180 | DECIMAL(38,18) | 逾期回款率_over180 = recovery_amt_over180 / 逾期金额 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 22 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 客户等级展开逻辑

每个维度组合同时输出【按等级明细】和【全部汇总】两行：

- 等级明细行：`COALESCE(customer_level, '未知')`
- 汇总行：`customer_level = '全部'`

### 逾期回款金额计算条件

各逾期区间的回款金额计入条件由 `days_since_due`（当前业务日 - 应还日期）决定：

| 字段 | 条件 |
|------|------|
| recovery_amt_0to3 | days_since_due >= 3 |
| recovery_amt_0to7 | days_since_due >= 7 |
| recovery_amt_0to30 | days_since_due >= 30 |
| recovery_amt_0to60 | days_since_due >= 60 |
| recovery_amt_0to90 | days_since_due >= 90 |
| recovery_amt_0to180 | days_since_due >= 180 |
| recovery_amt_over180 | days_since_due > 180 |

### 除零保护

所有比率字段使用 `NULLIF(被除数, 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 应还本金 / 逾期本金 | dws_repay_loan_period_snapshot_df | term_due_principal / overdue_principal |
| 各逾期区间回款金额 | dws_repay_loan_period_snapshot_df | recovery_0to3/7/30/60/90/180/over180 |
| 分流类型 | dim_application_classification_mapping_di | diversion_type（type='2'，借据级） |
| 客户等级 | dws_repay_loan_period_snapshot_df | customer_level |
