# ads_loan_advance_settle_daily_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_loan_advance_settle_daily_df` |
| **描述** | 提前结清统计表，按【放款月 + 分流类型 + 产品 + 分期数】维度统计各期次下的提前结清金额及比率 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（放款月） |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **表粒度** | 放款月 + 产品 + 分流类型 + 分期数（3/6/9/12/99） |
| **写入策略** | DELETE + INSERT 幂等，按 T 日（当前业务日）分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_month | VARCHAR | 【分组维度】放款月，格式 yyyy/MM |
| 2 | product_code_sk | VARCHAR(64) | 【分组维度】产品主键 |
| 3 | diversion_type | VARCHAR(2) | 【分组维度】分流类型：1=晋商/华通；2=嵩海 |
| 4 | period | INTEGER | 【分组维度】分期数：3/6/9/12 为分期明细；99 为全分期汇总 |

### 核心指标-金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 5 | loan_amt | DECIMAL(38,18) | 放款金额（元）= 首期放款金额 / 100 |
| 6 | advance_repay_amt | DECIMAL(38,18) | 提前结清总金额（元）= 最大提前结清金额 / 100 |

### 各期次提前结清金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 7 | term1_advance_settle_amt | DECIMAL(38,18) | 第1期提前结清金额（元） |
| 8 | term2_advance_settle_amt | DECIMAL(38,18) | 第2期提前结清金额（元） |
| 9 | term3_advance_settle_amt | DECIMAL(38,18) | 第3期提前结清金额（元） |
| 10 | term4_advance_settle_amt | DECIMAL(38,18) | 第4期提前结清金额（元） |
| 11 | term5_advance_settle_amt | DECIMAL(38,18) | 第5期提前结清金额（元） |
| 12 | term6_advance_settle_amt | DECIMAL(38,18) | 第6期提前结清金额（元） |
| 13 | term7_advance_settle_amt | DECIMAL(38,18) | 第7期提前结清金额（元） |
| 14 | term8_advance_settle_amt | DECIMAL(38,18) | 第8期提前结清金额（元） |
| 15 | term9_advance_settle_amt | DECIMAL(38,18) | 第9期提前结清金额（元） |
| 16 | term10_advance_settle_amt | DECIMAL(38,18) | 第10期提前结清金额（元） |
| 17 | term11_advance_settle_amt | DECIMAL(38,18) | 第11期提前结清金额（元） |
| 18 | term12_advance_settle_amt | DECIMAL(38,18) | 第12期提前结清金额（元） |

### 各期次提前结清率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 19 | term1_advance_settle_amt_rate | DECIMAL(38,18) | 第1期提前结清率 = term1_advance_settle_amt / 首期放款金额 |
| 20 | term2_advance_settle_amt_rate | DECIMAL(38,18) | 第2期提前结清率 |
| 21 | term3_advance_settle_amt_rate | DECIMAL(38,18) | 第3期提前结清率 |
| 22 | term4_advance_settle_amt_rate | DECIMAL(38,18) | 第4期提前结清率 |
| 23 | term5_advance_settle_amt_rate | DECIMAL(38,18) | 第5期提前结清率 |
| 24 | term6_advance_settle_amt_rate | DECIMAL(38,18) | 第6期提前结清率 |
| 25 | term7_advance_settle_amt_rate | DECIMAL(38,18) | 第7期提前结清率 |
| 26 | term8_advance_settle_amt_rate | DECIMAL(38,18) | 第8期提前结清率 |
| 27 | term9_advance_settle_amt_rate | DECIMAL(38,18) | 第9期提前结清率 |
| 28 | term10_advance_settle_amt_rate | DECIMAL(38,18) | 第10期提前结清率 |
| 29 | term11_advance_settle_amt_rate | DECIMAL(38,18) | 第11期提前结清率 |
| 30 | term12_advance_settle_amt_rate | DECIMAL(38,18) | 第12期提前结清率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 31 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 分期数展开逻辑

每个维度组合同时输出【分期明细】和【全分期汇总】两行：

- 明进行：period 保留原值（3/6/9/12）
- 汇总行：period = 99，跨所有分期数聚合

### 提前结清金额口径

- 仅 `term = 1` 的记录参与聚合，透传 `MAX(advance_settle_amt) OVER (PARTITION BY loan_id)` 作为该借据最大提前结清金额
- 提前结清金额 = `MAX(advance_settle_amt)`，对应借据一次性结清的全部金额
- 各期次提前结清金额 = `SUM(CASE WHEN term = N THEN advance_settle_amt ELSE 0 END)`

### 除零保护

各期次结清率计算时，分母为 `SUM(sta_loan_amt)`（首期放款金额），未使用 NULLIF，当分母为 0 时结果为 NULL。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 放款金额 / 提前结清金额 | dws_loan_advance_settle_daily_df | loan_amt / advance_settle_amt |
| 分流类型 / 产品 | dws_loan_advance_settle_daily_df | diversion_type / product_code_sk |
| 分期数 / 期次 | dws_loan_advance_settle_daily_df | period / term |
