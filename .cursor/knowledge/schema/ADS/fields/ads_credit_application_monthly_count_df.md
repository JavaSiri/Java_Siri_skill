# ads_credit_application_monthly_count_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.ads_credit_application_monthly_count_df` |
| **描述** | 授信申请月维统计表，按【统计月 + 分流类型 + 产品】维度聚合授信申请、审批、决策、规则命中及环比等全链路指标 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | 待确认 |
| **存储格式** | 待确认 |
| **分层** | ADS |
| **时间维度** | 月维（统计月） |
| **金额单位** | 元（上游分转元） |
| **表粒度** | 统计月 + 分流类型 + 产品 |
| **回刷窗口** | [month_start(T-2), T] |
| **写入策略** | DELETE + INSERT 幂等，写入 ds=T 分区 |

---

## 字段定义

月维表字段与日维表 `ads_credit_application_daily_count_di` 结构一致，共 72 个字段，区别在于时间维度和环比类型。

### 时间维度字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR(8) | 数据截止日期 |
| 2 | month_start_date | VARCHAR(8) | 【分组维度】统计月起始日，格式 yyyyMMdd |
| 3 | month_end_date | VARCHAR(8) | 【分组维度】统计月结束日，格式 yyyyMMdd |

（其余字段与日维表一致，字段序号顺延）

### 环比（MoM）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| — | credit_pass_amount_mom | DECIMAL | 授信通过金额环比增长率 = (当月 - 上月) / 上月 |
| — | credit_pass_amount_mom_delta | DECIMAL | 授信通过金额环比变化量（元） |
| — | credit_pass_num_mom | DECIMAL | 授信通过笔数环比增长率 |
| — | credit_pass_num_mom_delta | DECIMAL | 授信通过笔数环比变化量 |

---

## 关键口径说明

### 与 ads_credit_application_daily_count_di 的关系

本表为月维汇总表，与日维表字段结构一致，区别在于：

| 维度 | 日维 | 月维 |
|------|------|------|
| 时间维度 | credit_application_date | month_start_date / month_end_date |
| 环比类型 | DoD（日环比） | MoM（月环比） |
| 回刷窗口 | [T-2, T] | [month_start(T-2), T] |
| 写入分区 | ds=credit_application_date | ds=T |

### 历史继承 + 窗口重算机制

- 历史月数据从 ds=T-1 分区继承（month_start_date < win_start_ds 的月份）
- 窗口内月份由上游日维数据重算，并叠加月环比
- 最终写入 ds=T 分区

### 除零保护

所有比率字段使用 `NULLIF(..., 0)` 防止除零。

---

## 数据来源

| 字段类型 | 来源表 | 来源字段 |
|---------|--------|---------|
| 授信申请/通过数量与金额 | dws_credit_application_daily_count_di | credit_application_num/pass_num 等 |
| 决策指标 | ads_node_credit_daily_count_di | decision_application_num/pass_num 等 |
| 规则命中 | ads_decision_rule_credit_daily_count_di | global_hard_rule_ovd_num/noovd_num 等 |
| 加权利率 | dws_credit_application_daily_count_di | *_amount_daily/annual_rate_sum |
