# ADS 层表索引

本文档为 ADS 层 27 张表的表级别入口索引，提供表归属主题、表类型、时间维度、表粒度等概览信息，便于快速检索目标表。

---

## 主题分布总览

|| 主题 | 表数量 | 表名 |
|------|:------:|------|
| 授信申请 | 3 | `ads_credit_application_daily_count_di`、`ads_credit_application_weekly_count_df`、`ads_credit_application_monthly_count_df` |
| 客户分层 | 6 | `ads_customer_by_level_daily_di`、`ads_customer_by_level_weekly_df`、`ads_customer_by_level_monthly_df`、`ads_customer_by_annual_rate_daily_di`、`ads_customer_by_annual_rate_weekly_df`、`ads_customer_by_annual_rate_monthly_df` |
| 决策节点 | 2 | `ads_node_credit_daily_count_di`、`ads_node_loan_daily_count_di` |
| 决策规则 | 6 | `ads_decision_rule_credit_daily_count_di`、`ads_decision_rule_credit_weekly_count_df`、`ads_decision_rule_credit_monthly_count_df`、`ads_decision_rule_loan_daily_count_di`、`ads_decision_rule_loan_weekly_count_df`、`ads_decision_rule_loan_monthly_count_df` |
| 决策拒绝码 | 3 | `ads_decision_reject_code_daily_di`、`ads_decision_reject_code_weekly_df`、`ads_decision_reject_code_monthly_df` |
| 借款申请 | 3 | `ads_loan_application_daily_count_di`、`ads_loan_application_weekly_count_df`、`ads_loan_application_monthly_count_df` |
| 账龄/结清 | 2 | `ads_loan_vintage_cycle_daily_df`、`ads_loan_advance_settle_daily_df` |
| 催收回款 | 2 | `ads_repay_collection_weekly_df`、`ads_repay_collection_monthly_df` |

---

## 表索引

### 授信申请

#### ads_credit_application_daily_count_di

|| 属性 | 值 |
|------|-----|
| **描述** | 授信申请日维统计表，按【授信申请日期 + 分流类型 + 产品】维度聚合授信申请、审批、决策、规则命中及环比等全链路指标 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = credit_application_date，yyyymmdd） |
| **表粒度** | 授信申请日期 + 分流类型 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [T-2, T] |
| **字段数** | 48（含 ds） |
| **字段级文档** | [ads_credit_application_daily_count_di.md](./fields/ads_credit_application_daily_count_di.md) |

---

#### ads_credit_application_weekly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 授信申请周维统计表，按【统计周 + 分流类型 + 产品】维度聚合授信申请、审批、决策、规则命中及环比等全链路指标 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 分流类型 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [week_start(T-2), T] |
| **字段数** | 与日维表一致（环比为 WoW） |
| **字段级文档** | [ads_credit_application_weekly_count_df.md](./fields/ads_credit_application_weekly_count_df.md) |

---

#### ads_credit_application_monthly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 授信申请月维统计表，按【统计月 + 分流类型 + 产品】维度聚合授信申请、审批、决策、规则命中及环比等全链路指标 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T） |
| **表粒度** | 统计月 + 分流类型 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [month_start(T-2), T] |
| **字段数** | 与日维表一致（环比为 MoM） |
| **字段级文档** | [ads_credit_application_monthly_count_df.md](./fields/ads_credit_application_monthly_count_df.md) |

---

### 客户分层

#### ads_customer_by_level_daily_di

|| 属性 | 值 |
|------|-----|
| **描述** | 客户分层日维表，按【申请日期 + 分流类型 + 客户等级 + 产品】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = application_date，yyyymmdd） |
| **表粒度** | 申请日期 + 分流类型 + 客户等级 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [T-2, T] |
| **字段数** | 74（含 ds） |
| **字段级文档** | [ads_customer_by_level_daily_di.md](./fields/ads_customer_by_level_daily_di.md) |

---

#### ads_customer_by_level_weekly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 客户分层周维表，按【统计周 + 分流类型 + 客户等级 + 产品】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 分流类型 + 客户等级 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [week_start(T-2), T] |
| **字段数** | 与月维表一致 |
| **字段级文档** | [ads_customer_by_level_weekly_df.md](./fields/ads_customer_by_level_weekly_df.md) |

---

#### ads_customer_by_level_monthly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 客户分层月维表，按【统计月 + 分流类型 + 客户等级 + 产品】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T） |
| **表粒度** | 统计月 + 分流类型 + 客户等级 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [month_start(T-2), T] |
| **字段数** | 74（含 ds） |
| **字段级文档** | [ads_customer_by_level_monthly_df.md](./fields/ads_customer_by_level_monthly_df.md) |

---

#### ads_customer_by_annual_rate_daily_di

|| 属性 | 值 |
|------|-----|
| **描述** | 客户定价日维表，按【申请日期 + 分流类型 + 产品 + 年利率】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = application_date，yyyymmdd） |
| **表粒度** | 申请日期 + 分流类型 + 产品 + 年利率 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [T-2, T] |
| **字段数** | 74（含 ds） |
| **字段级文档** | [ads_customer_by_annual_rate_daily_di.md](./fields/ads_customer_by_annual_rate_daily_di.md) |

---

#### ads_customer_by_annual_rate_weekly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 客户定价周维表，按【统计周 + 分流类型 + 产品 + 年利率】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 分流类型 + 产品 + 年利率 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [week_start(T-2), T] |
| **字段数** | 与月维表一致 |
| **字段级文档** | [ads_customer_by_annual_rate_weekly_df.md](./fields/ads_customer_by_annual_rate_weekly_df.md) |

---

#### ads_customer_by_annual_rate_monthly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 客户定价月维表，按【统计月 + 分流类型 + 产品 + 年利率】维度统计授信/借款的客户数、笔数、金额及各类比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T） |
| **表粒度** | 统计月 + 分流类型 + 产品 + 年利率 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [month_start(T-2), T] |
| **字段数** | 74（含 ds） |
| **字段级文档** | [ads_customer_by_annual_rate_monthly_df.md](./fields/ads_customer_by_annual_rate_monthly_df.md) |

---

### 决策节点

#### ads_node_credit_daily_count_di

|| 属性 | 值 |
|------|-----|
| **描述** | 授信节点统计表，按【授信申请日期 + 产品 + 分流类型 + 陪跑标记】维度统计各决策阶段的申请/通过/拒绝数据 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = credit_application_date，yyyymmdd） |
| **表粒度** | 授信申请日期 + 产品 + 分流类型 + 陪跑标记 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [T-2, T] |
| **字段数** | 15（含 ds） |
| **字段级文档** | [ads_node_credit_daily_count_di.md](./fields/ads_node_credit_daily_count_di.md) |

---

#### ads_node_loan_daily_count_di

|| 属性 | 值 |
|------|-----|
| **描述** | 借款节点统计表，按【借款申请日期 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记】维度统计各决策阶段的申请/通过/拒绝数据 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = loan_application_date，yyyymmdd） |
| **表粒度** | 借款申请日期 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [T-2, T] |
| **字段数** | 16（含 ds） |
| **字段级文档** | [ads_node_loan_daily_count_di.md](./fields/ads_node_loan_daily_count_di.md) |

---

### 决策规则

#### ads_decision_rule_credit_daily_count_di

|| 属性 | 值 |
|------|-----|
| **描述** | 授信决策规则日维统计表，按【授信申请日期 + 分流类型 + 是否嵩海 + 产品】维度统计决策申请基数及各规则命中笔数及比率 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = credit_application_date，yyyymmdd） |
| **表粒度** | 授信申请日期 + 分流类型 + 是否嵩海 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [T-2, T] |
| **字段数** | 14（含 ds） |
| **字段级文档** | [ads_decision_rule_credit_daily_count_di.md](./fields/ads_decision_rule_credit_daily_count_di.md) |

---

#### ads_decision_rule_credit_weekly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 授信决策规则周维统计表，按【统计周 + 分流类型 + 是否嵩海 + 产品】维度统计决策申请基数及各规则累计命中笔数及比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 分流类型 + 是否嵩海 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [week_start(T-2), T] |
| **字段数** | 16（含 ds） |
| **字段级文档** | [ads_decision_rule_credit_weekly_count_df.md](./fields/ads_decision_rule_credit_weekly_count_df.md) |

---

#### ads_decision_rule_credit_monthly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 授信决策规则月维统计表，按【统计月 + 分流类型 + 是否嵩海 + 产品】维度统计决策申请基数及各规则累计命中笔数及比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T） |
| **表粒度** | 统计月 + 分流类型 + 是否嵩海 + 产品 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [month_start(T-2), T] |
| **字段数** | 16（含 ds） |
| **字段级文档** | [ads_decision_rule_credit_monthly_count_df.md](./fields/ads_decision_rule_credit_monthly_count_df.md) |

---

#### ads_decision_rule_loan_daily_count_di

|| 属性 | 值 |
|------|-----|
| **描述** | 借款决策规则日维统计表，按【借款申请日期 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记】维度统计决策申请基数及各规则命中笔数及比率 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = loan_application_date，yyyymmdd） |
| **表粒度** | 借款申请日期 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [T-2, T] |
| **字段数** | 15（含 ds） |
| **字段级文档** | [ads_decision_rule_loan_daily_count_di.md](./fields/ads_decision_rule_loan_daily_count_di.md) |

---

#### ads_decision_rule_loan_weekly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 借款决策规则周维统计表，按【统计周 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记】维度统计决策申请基数及各规则累计命中笔数及比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [week_start(T-2), T-1] |
| **字段数** | 17（含 ds） |
| **字段级文档** | [ads_decision_rule_loan_weekly_count_df.md](./fields/ads_decision_rule_loan_weekly_count_df.md) |

---

#### ads_decision_rule_loan_monthly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 借款决策规则月维统计表，按【统计月 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记】维度统计决策申请基数及各规则累计命中笔数及比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T） |
| **表粒度** | 统计月 + 是否首次支用 + 产品 + 分流类型 + 陪跑标记 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [month_start(T-2), T-1] |
| **字段数** | 17（含 ds） |
| **字段级文档** | [ads_decision_rule_loan_monthly_count_df.md](./fields/ads_decision_rule_loan_monthly_count_df.md) |

---

### 决策拒绝码

#### ads_decision_reject_code_daily_di

|| 属性 | 值 |
|------|-----|
| **描述** | 决策拒绝码日维表，按【决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码】维度统计拒绝码命中笔数及决策通过率 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = data_date，yyyymmdd） |
| **表粒度** | data_date + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [T-2, T] |
| **字段数** | 12（含 ds） |
| **字段级文档** | [ads_decision_reject_code_daily_di.md](./fields/ads_decision_reject_code_daily_di.md) |

---

#### ads_decision_reject_code_weekly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 决策拒绝码周维表，按【统计周 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码】维度统计拒绝码累计命中笔数及决策通过率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [week_start(T-2), T] |
| **字段数** | 14（含 ds） |
| **字段级文档** | [ads_decision_reject_code_weekly_df.md](./fields/ads_decision_reject_code_weekly_df.md) |

---

#### ads_decision_reject_code_monthly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 决策拒绝码月维表，按【统计月 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码】维度统计拒绝码累计命中笔数及决策通过率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T） |
| **表粒度** | 统计月 + 决策类型 + 产品 + 是否首支 + 分流类型 + 陪跑标记 + 规则编码 + 拒绝码 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 无金额字段 |
| **回刷窗口** | [month_start(T-2), T] |
| **字段数** | 14（含 ds） |
| **字段级文档** | [ads_decision_reject_code_monthly_df.md](./fields/ads_decision_reject_code_monthly_df.md) |

---

### 借款申请

#### ads_loan_application_daily_count_di

|| 属性 | 值 |
|------|-----|
| **描述** | 借款申请日维统计表，按【借款申请日期 + 分流类型 + 产品 + 是否首次支用】维度聚合借款申请、复借、决策、规则命中等全链路指标 |
| **表类型** | 汇总表（ADS/DI） |
| **时间维度** | 日维（ds = loan_application_date，yyyymmdd） |
| **表粒度** | 借款申请日期 + 分流类型 + 产品 + 是否首次支用 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [T-3, T-1] |
| **字段数** | 71（含 ds） |
| **字段级文档** | [ads_loan_application_daily_count_di.md](./fields/ads_loan_application_daily_count_di.md) |

---

#### ads_loan_application_weekly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 借款申请周维统计表，按【统计周 + 分流类型 + 产品 + 是否首次支用】维度聚合借款申请、复借、决策、规则命中等全链路指标 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T） |
| **表粒度** | 统计周 + 分流类型 + 产品 + 是否首次支用 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [week_start(T-3), T] |
| **字段数** | 72（含 ds，环比为 WoW） |
| **字段级文档** | [ads_loan_application_weekly_count_df.md](./fields/ads_loan_application_weekly_count_df.md) |

---

#### ads_loan_application_monthly_count_df

|| 属性 | 值 |
|------|-----|
| **描述** | 借款申请月维统计表，按【统计月 + 分流类型 + 产品 + 是否首次支用】维度聚合借款申请、复借、决策、规则命中等全链路指标 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T-1） |
| **表粒度** | 统计月 + 分流类型 + 产品 + 是否首次支用 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T-1） |
| **存储格式** | 待确认 |
| **金额单位** | 元（上游分转元） |
| **回刷窗口** | [month_start(T-3), T-1] |
| **字段数** | 72（含 ds，环比为 MoM） |
| **字段级文档** | [ads_loan_application_monthly_count_df.md](./fields/ads_loan_application_monthly_count_df.md) |

---

### 账龄/结清

#### ads_loan_vintage_cycle_daily_df

|| 属性 | 值 |
|------|-----|
| **描述** | 借据 Vintage 账龄周期表，按【放款月 + 产品 + 分流类型 + 支用拒绝标记 + 末次放款成功标记 + 分期数 + 表现期】维度统计各期次下的到期/逾期状态及剩余本金 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T，按放款月聚合） |
| **表粒度** | 放款月 + 产品 + 分流类型 + 支用拒绝标记 + 末次放款成功标记 + 分期数（3/6/9/12/99）+ 表现期 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **字段数** | 57（含 ds） |
| **字段级文档** | [ads_loan_vintage_cycle_daily_df.md](./fields/ads_loan_vintage_cycle_daily_df.md) |

---

#### ads_loan_advance_settle_daily_df

|| 属性 | 值 |
|------|-----|
| **描述** | 提前结清统计表，按【放款月 + 产品 + 分流类型 + 分期数】维度统计各期次下的提前结清金额及比率 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T，按放款月聚合） |
| **表粒度** | 放款月 + 产品 + 分流类型 + 分期数（3/6/9/12/99） |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T） |
| **存储格式** | 待确认 |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **字段数** | 31（含 ds） |
| **字段级文档** | [ads_loan_advance_settle_daily_df.md](./fields/ads_loan_advance_settle_daily_df.md) |

---

### 催收回款

#### ads_repay_collection_weekly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 入催催回统计表，按【应还款周 + 产品 + 分流类型 + 客户等级】维度统计催收回收数据 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 周维（ds = T-1） |
| **表粒度** | 应还款周 + 产品 + 分流类型 + 客户等级 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T-1） |
| **存储格式** | 待确认 |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **字段数** | 23（含 ds） |
| **字段级文档** | [ads_repay_collection_weekly_df.md](./fields/ads_repay_collection_weekly_df.md) |

---

#### ads_repay_collection_monthly_df

|| 属性 | 值 |
|------|-----|
| **描述** | 入催催回统计表，按【应还款月 + 产品 + 分流类型 + 客户等级】维度统计催收回收数据 |
| **表类型** | 汇总表（ADS/DF） |
| **时间维度** | 月维（ds = T-1） |
| **表粒度** | 应还款月 + 产品 + 分流类型 + 客户等级 |
| **分布键** | 待确认 |
| **分区策略** | VALUES 分区（ds = T-1） |
| **存储格式** | 待确认 |
| **金额单位** | 元（DECIMAL(38,18)，上游分转元） |
| **字段数** | 22（含 ds） |
| **字段级文档** | [ads_repay_collection_monthly_df.md](./fields/ads_repay_collection_monthly_df.md) |

---

## 表属性速查

### 按时间维度分类

|| 时间维度 | 表 |
|---------|-----|
| **日维（DI）** | ads_credit_application_daily_count_di、ads_customer_by_level_daily_di、ads_customer_by_annual_rate_daily_di、ads_decision_rule_credit_daily_count_di、ads_decision_rule_loan_daily_count_di、ads_decision_reject_code_daily_di、ads_node_credit_daily_count_di、ads_node_loan_daily_count_di、ads_loan_application_daily_count_di |
| **周维（DF）** | ads_credit_application_weekly_count_df、ads_customer_by_level_weekly_df、ads_customer_by_annual_rate_weekly_df、ads_decision_rule_credit_weekly_count_df、ads_decision_rule_loan_weekly_count_df、ads_decision_reject_code_weekly_df、ads_loan_application_weekly_count_df、ads_repay_collection_weekly_df |
| **月维（DF）** | ads_credit_application_monthly_count_df、ads_customer_by_level_monthly_df、ads_customer_by_annual_rate_monthly_df、ads_decision_rule_credit_monthly_count_df、ads_decision_rule_loan_monthly_count_df、ads_decision_reject_code_monthly_df、ads_loan_application_monthly_count_df、ads_loan_vintage_cycle_daily_df、ads_loan_advance_settle_daily_df、ads_repay_collection_monthly_df |

### 按金额字段分类

|| 类型 | 表 |
|--------|-----|
| **含金额字段（元）** | ads_credit_application_*、ads_customer_by_level_*、ads_customer_by_annual_rate_*、ads_node_credit_daily_count_di、ads_node_loan_daily_count_di、ads_loan_application_*、ads_loan_vintage_cycle_daily_df、ads_loan_advance_settle_daily_df、ads_repay_collection_* |
| **无金额字段** | ads_decision_rule_*、ads_decision_reject_code_* |

### 按业务主题分类

|| 业务主题 | 表 |
|----------|-----|
| **授信申请** | ads_credit_application_daily_count_di、ads_credit_application_weekly_count_df、ads_credit_application_monthly_count_df |
| **客户分层/定价** | ads_customer_by_level_daily_di、ads_customer_by_level_weekly_df、ads_customer_by_level_monthly_df、ads_customer_by_annual_rate_daily_di、ads_customer_by_annual_rate_weekly_df、ads_customer_by_annual_rate_monthly_df |
| **决策节点** | ads_node_credit_daily_count_di、ads_node_loan_daily_count_di |
| **决策规则** | ads_decision_rule_credit_daily_count_di、ads_decision_rule_credit_weekly_count_df、ads_decision_rule_credit_monthly_count_df、ads_decision_rule_loan_daily_count_di、ads_decision_rule_loan_weekly_count_df、ads_decision_rule_loan_monthly_count_df |
| **决策拒绝码** | ads_decision_reject_code_daily_di、ads_decision_reject_code_weekly_df、ads_decision_reject_code_monthly_df |
| **借款申请** | ads_loan_application_daily_count_di、ads_loan_application_weekly_count_df、ads_loan_application_monthly_count_df |
| **账龄/结清** | ads_loan_vintage_cycle_daily_df、ads_loan_advance_settle_daily_df |
| **催收回款** | ads_repay_collection_weekly_df、ads_repay_collection_monthly_df |

### 按回刷窗口分类

|| 回刷窗口 | 表 |
|---------|-----|
| [T-2, T] | ads_credit_application_daily_count_di、ads_customer_by_level_daily_di、ads_customer_by_annual_rate_daily_di、ads_decision_rule_credit_daily_count_di、ads_decision_rule_loan_daily_count_di、ads_decision_reject_code_daily_di、ads_node_credit_daily_count_di、ads_node_loan_daily_count_di |
| [T-3, T-1] | ads_loan_application_daily_count_di |
| [week_start(T-2), T] | ads_credit_application_weekly_count_df、ads_customer_by_level_weekly_df、ads_customer_by_annual_rate_weekly_df、ads_decision_rule_credit_weekly_count_df、ads_decision_rule_loan_weekly_count_df（[T-1]）、ads_decision_reject_code_weekly_df、ads_loan_application_weekly_count_df（[T-3]）、ads_repay_collection_weekly_df |
| [week_start(T-2), T-1] | ads_decision_rule_loan_weekly_count_df |
| [month_start(T-2), T] | ads_credit_application_monthly_count_df、ads_customer_by_level_monthly_df、ads_customer_by_annual_rate_monthly_df、ads_decision_rule_credit_monthly_count_df、ads_decision_rule_loan_monthly_count_df（[T-1]）、ads_decision_reject_code_monthly_df、ads_loan_application_monthly_count_df（[T-3, T-1]）、ads_repay_collection_monthly_df |
| [month_start(T-2), T-1] | ads_decision_rule_loan_monthly_count_df |
| 无回刷（定期覆盖） | ads_loan_vintage_cycle_daily_df、ads_loan_advance_settle_daily_df |

### 上游依赖关系

|| 上游层 | 依赖的 ADS 表 |
|--------|------------|
| **DWS 层** | dws_credit_application_daily_count_di、dws_loan_application_daily_count_di、dws_customer_by_level_daily_di、dws_customer_by_annual_rate_daily_di、dws_node_credit_daily_count_di、dws_node_loan_daily_count_di、dws_decision_rule_credit_daily_count_di、dws_decision_rule_loan_daily_count_di、dws_decision_reject_code_daily_di、dws_repay_loan_period_snapshot_df |
| **ADS 层内部** | ads_node_credit_daily_count_di、ads_node_loan_daily_count_di、ads_decision_rule_credit_daily_count_di、ads_decision_rule_loan_daily_count_di（被授信/借款申请汇总表依赖） |
| **DIM 层** | dim_application_classification_mapping_di（催收回款表依赖分流类型维度） |
