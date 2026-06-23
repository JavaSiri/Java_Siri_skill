# ads_loan_vintage_cycle_daily_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_loan_vintage_cycle_daily_df` |
| **描述** | 借据Vintage账龄周期表，按【放款月 + 分流类型 + 分期数 + 表现期】维度统计各期次下的到期/逾期状态及剩余本金 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（放款月） |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **表粒度** | 放款月 + 产品 + 分流类型 + 支用拒绝标记 + 末次放款成功标记 + 分期数（3/6/9/12/99） + 表现期 |
| **写入策略** | DELETE + INSERT 幂等，按 T 日（当前业务日）分区 |

---

## 字段定义

### 分组维度

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | loan_month | VARCHAR | 【分组维度】放款月，格式 yyyy/MM |
| 2 | product_code_sk | VARCHAR(64) | 【分组维度】产品主键 |
| 3 | diversion_type | VARCHAR(2) | 【分组维度】分流类型：1=晋商/华通；2=嵩海 |
| 4 | loan_application_reject_flag | VARCHAR(1) | 【分组维度】支用申请是否被拒绝过：Y=是；N=否 |
| 5 | is_final_loan_suc | VARCHAR(1) | 【分组维度】是否为末次放款成功：Y=是；N=否 |
| 6 | period | INTEGER | 【分组维度】分期数：3/6/9/12 为分期明细；99 为全分期汇总 |
| 7 | performance_period | INTEGER | 【分组维度】表现期：0/7/30/60/90/180 |

### 核心指标-金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 8 | loan_amt | DECIMAL(38,18) | 放款金额（元）= 期次应还金额 / 100 |

### 各期次放款金额

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 9 | cycle1_loan_amt | DECIMAL(38,18) | 第1期到期放款金额（元），loan_age=1 且 due_flag='Y' |
| 10 | cycle2_loan_amt | DECIMAL(38,18) | 第2期到期放款金额（元），loan_age=2 且 due_flag='Y' |
| 11 | cycle3_loan_amt | DECIMAL(38,18) | 第3期到期放款金额（元），loan_age=3 且 due_flag='Y' |
| 12 | cycle4_loan_amt | DECIMAL(38,18) | 第4期到期放款金额（元），loan_age=4 且 due_flag='Y' |
| 13 | cycle5_loan_amt | DECIMAL(38,18) | 第5期到期放款金额（元），loan_age=5 且 due_flag='Y' |
| 14 | cycle6_loan_amt | DECIMAL(38,18) | 第6期到期放款金额（元），loan_age=6 且 due_flag='Y' |
| 15 | cycle7_loan_amt | DECIMAL(38,18) | 第7期到期放款金额（元），loan_age=7 且 due_flag='Y' |
| 16 | cycle8_loan_amt | DECIMAL(38,18) | 第8期到期放款金额（元），loan_age=8 且 due_flag='Y' |
| 17 | cycle9_loan_amt | DECIMAL(38,18) | 第9期到期放款金额（元），loan_age=9 且 due_flag='Y' |
| 18 | cycle10_loan_amt | DECIMAL(38,18) | 第10期到期放款金额（元），loan_age=10 且 due_flag='Y' |
| 19 | cycle11_loan_amt | DECIMAL(38,18) | 第11期到期放款金额（元），loan_age=11 且 due_flag='Y' |
| 20 | cycle12_loan_amt | DECIMAL(38,18) | 第12期到期放款金额（元），loan_age=12 且 due_flag='Y' |

### 各期次剩余未还本金

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 21 | cycle1_loan_outstanding_principal | DECIMAL(38,18) | 第1期剩余未还本金（元），loan_age=1 且 overdue_flag='Y' |
| 22 | cycle2_loan_outstanding_principal | DECIMAL(38,18) | 第2期剩余未还本金（元） |
| 23 | cycle3_loan_outstanding_principal | DECIMAL(38,18) | 第3期剩余未还本金（元） |
| 24 | cycle4_loan_outstanding_principal | DECIMAL(38,18) | 第4期剩余未还本金（元） |
| 25 | cycle5_loan_outstanding_principal | DECIMAL(38,18) | 第5期剩余未还本金（元） |
| 26 | cycle6_loan_outstanding_principal | DECIMAL(38,18) | 第6期剩余未还本金（元） |
| 27 | cycle7_loan_outstanding_principal | DECIMAL(38,18) | 第7期剩余未还本金（元） |
| 28 | cycle8_loan_outstanding_principal | DECIMAL(38,18) | 第8期剩余未还本金（元） |
| 29 | cycle9_loan_outstanding_principal | DECIMAL(38,18) | 第9期剩余未还本金（元） |
| 30 | cycle10_loan_outstanding_principal | DECIMAL(38,18) | 第10期剩余未还本金（元） |
| 31 | cycle11_loan_outstanding_principal | DECIMAL(38,18) | 第11期剩余未还本金（元） |
| 32 | cycle12_loan_outstanding_principal | DECIMAL(38,18) | 第12期剩余未还本金（元） |

### 各期次放款金额率

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 33 | cycle1_loan_amt_rate | DECIMAL(38,18) | 第1期放款金额率 = cycle1_loan_amt / loan_amt |
| 34 | cycle2_loan_amt_rate | DECIMAL(38,18) | 第2期放款金额率 |
| 35 | cycle3_loan_amt_rate | DECIMAL(38,18) | 第3期放款金额率 |
| 36 | cycle4_loan_amt_rate | DECIMAL(38,18) | 第4期放款金额率 |
| 37 | cycle5_loan_amt_rate | DECIMAL(38,18) | 第5期放款金额率 |
| 38 | cycle6_loan_amt_rate | DECIMAL(38,18) | 第6期放款金额率 |
| 39 | cycle7_loan_amt_rate | DECIMAL(38,18) | 第7期放款金额率 |
| 40 | cycle8_loan_amt_rate | DECIMAL(38,18) | 第8期放款金额率 |
| 41 | cycle9_loan_amt_rate | DECIMAL(38,18) | 第9期放款金额率 |
| 42 | cycle10_loan_amt_rate | DECIMAL(38,18) | 第10期放款金额率 |
| 43 | cycle11_loan_amt_rate | DECIMAL(38,18) | 第11期放款金额率 |
| 44 | cycle12_loan_amt_rate | DECIMAL(38,18) | 第12期放款金额率 |

### 各期次逾期率（剩余未还本金率）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 45 | cycle1_loan_outstanding_principal_rate | DECIMAL(38,18) | 第1期逾期率 = cycle1_loan_outstanding_principal / cycle1_loan_amt |
| 46 | cycle2_loan_outstanding_principal_rate | DECIMAL(38,18) | 第2期逾期率 |
| 47 | cycle3_loan_outstanding_principal_rate | DECIMAL(38,18) | 第3期逾期率 |
| 48 | cycle4_loan_outstanding_principal_rate | DECIMAL(38,18) | 第4期逾期率 |
| 49 | cycle5_loan_outstanding_principal_rate | DECIMAL(38,18) | 第5期逾期率 |
| 50 | cycle6_loan_outstanding_principal_rate | DECIMAL(38,18) | 第6期逾期率 |
| 51 | cycle7_loan_outstanding_principal_rate | DECIMAL(38,18) | 第7期逾期率 |
| 52 | cycle8_loan_outstanding_principal_rate | DECIMAL(38,18) | 第8期逾期率 |
| 53 | cycle9_loan_outstanding_principal_rate | DECIMAL(38,18) | 第9期逾期率 |
| 54 | cycle10_loan_outstanding_principal_rate | DECIMAL(38,18) | 第10期逾期率 |
| 55 | cycle11_loan_outstanding_principal_rate | DECIMAL(38,18) | 第11期逾期率 |
| 56 | cycle12_loan_outstanding_principal_rate | DECIMAL(38,18) | 第12期逾期率 |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 57 | ds | VARCHAR(8) | 数据分区字段（yyyyMMdd） |

---

## 关键口径说明

### 分期数展开逻辑

每个维度组合同时输出【分期明细】和【全分期汇总】两行：

- 明细行：period 保留原值（3/6/9/12）
- 汇总行：period = 99，跨所有分期数聚合

### cycle 字段计算逻辑

- cycleN_loan_amt：loan_age = N 且 due_flag = 'Y' 的放款金额
- cycleN_loan_outstanding_principal：loan_age = N 且 overdue_flag = 'Y' 的剩余未还本金
- 使用 NULLIF 防止除零

### 与 ads_loan_advance_settle_daily_df 的关系

两个表均按【放款月 + 分流类型 + 产品 + 分期数】聚合，但指标不同：

| 表 | 指标 |
|----|------|
| ads_loan_advance_settle_daily_df | 提前结清金额及比率 |
| ads_loan_vintage_cycle_daily_df | 到期状态及剩余本金 |

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 放款金额 / 剩余本金 | dws_loan_vintage_cycle_daily_df | term_amt / loan_outstanding_principal |
| 到期/逾期标记 | dws_loan_vintage_cycle_daily_df | due_flag / overdue_flag |
| 贷款账龄 | dws_loan_vintage_cycle_daily_df | loan_age |
| 分流类型 / 产品 / 分期数 | dws_loan_vintage_cycle_daily_df | diversion_type / product_code_sk / period |
| 支用拒绝 / 末次放款 | dws_loan_vintage_cycle_daily_df | loan_application_reject_flag / is_final_loan_suc |
