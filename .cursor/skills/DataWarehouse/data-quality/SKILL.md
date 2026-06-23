---
name: data-quality
description: Implement data quality checks and monitoring for data warehouse tables. Use when building data validation rules, creating quality monitoring reports, or investigating data anomalies.
---

# Data Quality

## Quality Dimensions

| Dimension | Description | Examples |
|-----------|-------------|----------|
| Completeness | 数据完整性 | 非空检查、主键唯一性 |
| Accuracy | 数据准确性 | 值域检查、格式校验 |
| Consistency | 数据一致性 | 跨表一致性、指标对齐 |
| Timeliness | 数据时效性 | 延迟监控、完整率 |
| Uniqueness | 数据唯一性 | 主键重复、冗余检查 |

## Check Types

### 1. Completeness Checks

```sql
-- 非空检查
SELECT
    '${table_name}' AS table_name,
    '${column_name}' AS column_name,
    COUNT(*) AS total_rows,
    COUNT(${column_name}) AS non_null_rows,
    (COUNT(*) - COUNT(${column_name})) AS null_rows,
    ROUND((COUNT(*) - COUNT(${column_name})) * 100.0 / COUNT(*), 2) AS null_rate
FROM ${table_name}
WHERE ds = '${biz_date}';
```

### 2. Uniqueness Checks

```sql
-- 主键唯一性检查
SELECT
    '${table_name}' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ${primary_key}) AS distinct_keys,
    (COUNT(*) - COUNT(DISTINCT ${primary_key})) AS duplicate_keys
FROM ${table_name}
WHERE ds = '${biz_date}';
```

### 3. Value Range Checks

```sql
-- 值域检查
SELECT
    '${table_name}' AS table_name,
    '${column_name}' AS column_name,
    MIN(${column_name}) AS min_value,
    MAX(${column_name}) AS max_value,
    COUNT(*) AS total_rows
FROM ${table_name}
WHERE ds = '${biz_date}';
```

### 4. Cross-table Consistency

```sql
-- 跨表一致性检查
SELECT
    a.stat_date,
    a.product_id,
    a.loan_cnt AS dws_cnt,
    b.loan_cnt AS ads_cnt,
    (a.loan_cnt - b.loan_cnt) AS diff
FROM dws_loan_stats a
LEFT JOIN ads_loan_report b
    ON a.stat_date = b.stat_date
    AND a.product_id = b.product_id
WHERE a.ds = '${biz_date}'
    AND b.ds = '${biz_date}'
    AND a.loan_cnt <> b.loan_cnt;
```

## Quality Monitoring Template

```sql
-- 数据质量监控报告
WITH quality_checks AS (
    -- 非空率检查
    SELECT 'non_null_rate' AS check_type,
           'col1' AS column_name,
           COUNT(*) * 100.0 / SUM(1) OVER() AS check_value
    FROM dwd_loan_di
    WHERE ds = '${biz_date}' AND col1 IS NOT NULL

    UNION ALL

    -- 重复率检查
    SELECT 'duplicate_rate' AS check_type,
           'loan_id' AS column_name,
           (1 - COUNT(DISTINCT loan_id) * 1.0 / COUNT(*)) * 100 AS check_value
    FROM dwd_loan_di
    WHERE ds = '${biz_date}'
)
SELECT * FROM quality_checks;
```

## Alert Thresholds

| Check Type | Warning | Critical |
|------------|---------|----------|
| 非空率 | < 99% | < 95% |
| 主键重复率 | > 0.1% | > 1% |
| 数据增长率 | ±50% | ±100% |
| 与昨日差异 | ±30% | ±50% |
| T+1 延迟 | > 2小时 | > 6小时 |

## Common Quality Rules

```sql
-- 规则 1: 主键唯一性
SELECT
    'primary_key_unique' AS rule,
    COUNT(DISTINCT loan_id) = COUNT(*) AS is_passed
FROM dwd_loan_di
WHERE ds = '${biz_date}';

-- 规则 2: 金额合理性
SELECT
    'amount_reasonable' AS rule,
    SUM(CASE WHEN amount <= 0 OR amount > 10000000 THEN 1 ELSE 0 END) = 0 AS is_passed
FROM dwd_loan_di
WHERE ds = '${biz_date}';

-- 规则 3: 日期有效性
SELECT
    'date_valid' AS rule,
    SUM(CASE WHEN loan_date > CURRENT_DATE THEN 1 ELSE 0 END) = 0 AS is_passed
FROM dwd_loan_di
WHERE ds = '${biz_date}';

-- 规则 4: 枚举值有效性
SELECT
    'status_valid' AS rule,
    SUM(CASE WHEN status NOT IN ('01','02','03','04') THEN 1 ELSE 0 END) = 0 AS is_passed
FROM dwd_loan_di
WHERE ds = '${biz_date}';
```

## Daily Quality Report

```sql
-- 每日数据质量报告
CREATE TABLE IF NOT EXISTS dwd_data_quality_daily (
    stat_date STRING,
    table_name STRING,
    check_type STRING,
    check_value DECIMAL(10,4),
    threshold DECIMAL(10,4),
    is_passed STRING,
    remark STRING
) PARTITIONED BY (ds STRING);

INSERT OVERWRITE TABLE dwd_data_quality_daily PARTITION (ds = '${biz_date}')
SELECT
    '${biz_date}' AS stat_date,
    t.table_name,
    c.check_type,
    c.check_value,
    c.threshold,
    CASE WHEN c.check_value >= c.threshold THEN 'PASS' ELSE 'FAIL' END AS is_passed,
    '' AS remark
FROM (
    -- 汇总各表检查结果
    SELECT 'dwd_loan_di' AS table_name, 'row_count' AS check_type, COUNT(*) AS check_value FROM dwd_loan_di WHERE ds = '${biz_date}'
    UNION ALL
    SELECT 'dwd_loan_di', 'non_null_rate', COUNT(loan_id) * 100.0 / COUNT(*) FROM dwd_loan_di WHERE ds = '${biz_date}'
    -- 更多检查项...
) t
LEFT JOIN quality_threshold c ON t.table_name = c.table_name AND t.check_type = c.check_type;
```

## Quality Dashboard Metrics

| Metric | Description | Good | Warning | Bad |
|--------|-------------|------|---------|-----|
| 记录数 | 当日数据量 | 昨日±20% | ±50% | >100% |
| 非空率 | 字段完整性 | >99% | 95-99% | <95% |
| 重复率 | 主键重复 | 0% | <0.1% | >0.1% |
| 延迟 | 加工延迟 | <1h | 1-3h | >3h |

## Troubleshooting Guide

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| 数据量突增 | 上游数据问题 | 检查 ODS 层 |
| 数据量突降 | 任务执行失败 | 检查调度日志 |
| 非空率下降 | 数据源异常 | 联系上游修复 |
| 重复数据 | 去重逻辑问题 | 检查 DISTINCT |
| 延迟增大 | SQL 性能问题 | 优化 JOIN |

## Best Practices

1. **每个表都有质量检查**：至少检查主键唯一性和非空率
2. **设置合理的阈值**：根据业务特点设置报警阈值
3. **记录异常历史**：保留历史质量问题便于追溯
4. **自动化监控**：将质量检查集成到调度流程
5. **及时响应告警**：建立告警响应机制
