---
name: to_issues
description: Guide through SQL syntax translation between PostgreSQL and Hive. Use when translating/migrating SQL scripts from one database to another.
---

# SQL Syntax Translation

> **使用说明**：本 skill 由 skill-selector 编排。文件加载由 skill-selector 统一管理，本 skill 仅负责转译逻辑。

---

## 术语对照

| 概念 | PostgreSQL | Hive |
|------|-----------|------|
| 物理分区 | 逻辑分区（无物理目录） | 物理分区（目录结构） |
| 幂等写入 | DELETE + INSERT（事务包裹） | INSERT OVERWRITE PARTITION |
| 字符串函数 | `TO_CHAR`、`TO_DATE` | `DATE_FORMAT`、`FROM_UNIXTIME` |
| 日期加减 | `+ INTERVAL 'N day'` | `DATE_ADD`、`DATE_SUB` |
| 月份加减 | `+ INTERVAL 'N month'` | `ADD_MONTHS` |
| 字符串截断 | `SUBSTR(col, 1, 10)` | `SUBSTR(col, 1, 10)` |
| 类型转换 | `col::VARCHAR` 或 `CAST(col AS VARCHAR)` | `CAST(col AS STRING)` |
| 注释语法 | `-- 单行注释` | `-- 单行注释` |
| NULL 判断 | `COALESCE(col, '')` | `NVL(col, '')` |
| 条件表达式 | `CASE WHEN ... THEN ... END` | `CASE WHEN ... THEN ... END` |
| DDL 注释 | `COMMENT ON COLUMN ... IS '...'` | `COMMENT '...'`（内联） |
| DDL 分区 | `PARTITION BY RANGE (ds)` | `PARTITIONED BY (ds)` |
| DDL 存储 | 无（逻辑分区） | `STORED AS ORC` |

---

## PGSQL → Hive 转译规则

### 1. 幂等性实现

**PGSQL（DELETE + INSERT）**：

```sql
DELETE FROM target_table WHERE ds = '{prebizdate}';
INSERT INTO target_table (col1, col2, ds)
SELECT col1, col2, '{prebizdate}' AS ds
FROM source_table
WHERE ds = '{prebizdate}';
```

**Hive（INSERT OVERWRITE PARTITION）**：

```sql
INSERT OVERWRITE TABLE target_table PARTITION (ds = '{prebizdate}')
SELECT col1, col2
FROM source_table
WHERE ds = '{prebizdate}'
;
```

> **关键差异**：Hive 无 DELETE，通过 `INSERT OVERWRITE PARTITION` 实现幂等覆盖。

---

### 2. 字符串函数

| 场景 | PostgreSQL | Hive |
|------|-----------|------|
| 日期转字符串 | `TO_CHAR(TO_DATE(col, 'yyyyMMdd'), 'yyyy-MM-dd')` | `DATE_FORMAT(FROM_UNIXTIME(UNIX_TIMESTAMP(col, 'yyyyMMdd')), 'yyyy-MM-dd')` |
| 字符串转日期 | `TO_DATE(col, 'yyyyMMdd')` | `TO_DATE(col, 'yyyyMMdd')` |
| 截取子串 | `SUBSTR(col, 1, 10)` | `SUBSTR(col, 1, 10)` |
| 大小写 | `UPPER(col)` / `LOWER(col)` | `UPPER(col)` / `LOWER(col)` |
| 拼接 | `col1 \|\| col2` | `CONCAT(col1, col2)` |
| 去空格 | `TRIM(col)` | `TRIM(col)` |

---

### 3. 日期函数

| 场景 | PostgreSQL | Hive |
|------|-----------|------|
| 加 N 天 | `+ INTERVAL 'N day'` | `DATE_ADD(col, N)` |
| 减 N 天 | `- INTERVAL 'N day'` | `DATE_SUB(col, N)` |
| 加 N 月 | `+ INTERVAL 'N month'` | `ADD_MONTHS(col, N)` |
| 月初 | `DATE_TRUNC('month', col)` | `TRUNC(col, 'MM')` |
| 季初 | `DATE_TRUNC('quarter', col)` | `TRUNC(col, 'Q')` |
| 周初 | `DATE_TRUNC('week', col)` | `TRUNC(col, 'WW')` 或自定义 UDF |
| 当前日期 | `CURRENT_DATE` | `CURRENT_DATE` 或 `TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP()), 'yyyy-MM-dd')` |

---

### 4. 类型转换

| 场景 | PostgreSQL | Hive |
|------|-----------|------|
| 转字符串 | `col::VARCHAR` | `CAST(col AS STRING)` |
| 转整数 | `col::INTEGER` | `CAST(col AS INT)` |
| 转大整数 | `col::BIGINT` | `CAST(col AS BIGINT)` |
| 转小数 | `col::DECIMAL(18,2)` | `CAST(col AS DECIMAL(18,2))` |
| 转日期 | `TO_DATE(col, 'yyyyMMdd')` | `TO_DATE(col, 'yyyyMMdd')` |

---

### 5. 分区处理

| 场景 | PostgreSQL | Hive |
|------|-----------|------|
| 分区字段 | `ds` 作为普通列，WHERE 过滤 | `ds` 在 `PARTITIONED BY` 中声明，不在 SELECT 中 |
| 静态分区写入 | `INSERT INTO ... ds='{prebizdate}'` | `INSERT OVERWRITE ... PARTITION (ds='{prebizdate}')` |
| 动态分区写入 | 不支持 | `INSERT OVERWRITE ... PARTITION (ds)`，SELECT 最后一列为 ds |
| 分区过滤 | `WHERE ds = '{prebizdate}'` | `WHERE ds = '{prebizdate}'` |

---

### 6. 聚合与窗口函数

| 场景 | PostgreSQL | Hive |
|------|-----------|------|
| 分组聚合 | `GROUP BY col` | `GROUP BY col` |
| 去重计数 | `COUNT(DISTINCT col)` | `COUNT(DISTINCT col)` |
| 窗口求和 | `SUM(col) OVER (PARTITION BY ...)` | `SUM(col) OVER (PARTITION BY ...)` |
| 窗口行号 | `ROW_NUMBER() OVER (...)` | `ROW_NUMBER() OVER (...)` |
| LEAD/LAG | `LEAD(col) OVER (...)` | `LEAD(col) OVER (...)` |

---

## Hive → PostgreSQL 转译规则

### 1. DDL 语法转换

Hive DDL 迁移到 PostgreSQL 时，必须删除以下 Hive 特有语法：

| Hive 语法 | PostgreSQL 处理 | 说明 |
|-----------|----------------|------|
| `COMMENT '字段描述'` | **必须删除** | PostgreSQL 不支持内联注释，使用 `COMMENT ON` 语句 |
| `STORED AS ORC/Parquet` | **必须删除** | PostgreSQL 无此语法 |
| `PARTITIONED BY (ds)` | 改为 `PARTITION BY RANGE (ds)` | PostgreSQL 分区语法不同 |
| `STRING` 类型 | 改为 `VARCHAR` | 类型映射 |

**转换示例：**

```sql
-- ❌ Hive DDL（PostgreSQL 不支持）
CREATE TABLE IF NOT EXISTS schema.table_name (
    customer_id VARCHAR   COMMENT '客户号'
    ,credit_date TIMESTAMP COMMENT '授信时间'
    ,ds         VARCHAR   COMMENT '分区键'
)
PARTITIONED BY (ds)
STORED AS ORC
;

-- ✅ PostgreSQL DDL（正确）
CREATE TABLE IF NOT EXISTS schema.table_name (
    customer_id         VARCHAR
    ,credit_date        TIMESTAMP
    ,ds                 VARCHAR
)
PARTITION BY RANGE (ds)
;

COMMENT ON TABLE schema.table_name IS '表描述';
COMMENT ON COLUMN schema.table_name.customer_id IS '客户号';
COMMENT ON COLUMN schema.table_name.credit_date IS '授信时间';
COMMENT ON COLUMN schema.table_name.ds IS '分区键';
```

### 2. 类型映射

| Hive 类型 | PostgreSQL 类型 |
|-----------|----------------|
| STRING | VARCHAR |
| BIGINT | BIGINT |
| DECIMAL(p,s) | DECIMAL(p,s) |
| TIMESTAMP | TIMESTAMP |
| DATE | DATE |
| TINYINT / SMALLINT / INT | SMALLINT / INT / BIGINT |

### 3. 幂等性实现

Hive 使用 `INSERT OVERWRITE PARTITION`，PostgreSQL 使用 `DELETE + INSERT`：

```sql
-- Hive
INSERT OVERWRITE TABLE target_table PARTITION (ds = '{prebizdate}')
SELECT col1, col2 FROM source_table WHERE ds = '{prebizdate}';

-- PostgreSQL
DELETE FROM target_table WHERE ds = '{prebizdate}';

WITH cte1_source_data AS (
    SELECT col1, col2, '{prebizdate}' AS ds
    FROM source_table
    WHERE ds = '{prebizdate}'
)
INSERT INTO target_table (col1, col2, ds)
SELECT col1, col2, ds FROM cte1_source_data;
```

### 4. DDL 转换完整性检查

审查 Hive → PostgreSQL DDL 转换时，检测以下禁止项：

| 禁止项 | 检测关键词 |
|--------|-----------|
| 内联注释 | `COMMENT '` 或 `COMMENT '` 在字段定义行内 |
| Hive 分区语法 | `PARTITIONED BY` |
| 存储格式 | `STORED AS` |
| STRING 类型 | `STRING`（应改为 VARCHAR） |

**判定逻辑**：
- 无任何禁止项 → ✅
- 任一禁止项存在 → ❌（列出具体残留项）

---

### 7. 常见陷阱

| 陷阱 | PostgreSQL | Hive | 说明 |
|------|-----------|------|------|
| 除法精度 | `col / 100` | `col / 100.0` | Hive 整数除法需转浮点 |
| NULL 处理 | `col IS NULL` | `col IS NULL` | 语法一致 |
| 空字符串 | `col = ''` | `col = ''` | Hive 空串与 NULL 不同 |
| IN 子句限制 | 无限制 | 少量数据用 IN，大量用 LEFT JOIN | Hive IN 有性能问题 |
| 子查询限制 | 支持相关子查询 | 相关子查询支持有限 | 尽量改写为 JOIN |

---

## 执行步骤

### Step 1: 识别源数据库语法

根据脚本特征判断来源：

| 特征 | 来源 |
|------|------|
| 包含 `INSERT OVERWRITE` | Hive |
| 包含 `TO_CHAR(...INTERVAL...)` | PostgreSQL |
| 包含 `PARTITIONED BY` 且有 `INSERT OVERWRITE PARTITION` | Hive |
| 使用 `DELETE FROM` 做幂等 | PostgreSQL |

### Step 2: 逐 CTE 转译

按顺序处理每个 CTE：

1. 替换字符串函数
2. 替换日期函数
3. 替换类型转换
4. 调整分区相关逻辑
5. 替换幂等写入方式

### Step 3: 验证转译完整性

- 检查所有字段别名是否保留
- 检查所有 WHERE 条件是否迁移
- 检查 INSERT/SELECT 列顺序是否对齐
- 检查分区字段是否正确处理

---

## 常见问题

### Q1: PGSQL 的 `DELETE + INSERT` 在 Hive 中如何等价实现？

A: 使用 `INSERT OVERWRITE PARTITION`。对于静态分区表：

```sql
-- PGSQL
DELETE FROM table WHERE ds = '{prebizdate}';
INSERT INTO table (col1, col2, ds) VALUES (v1, v2, '{prebizdate}');

-- Hive
INSERT OVERWRITE TABLE table PARTITION (ds = '{prebizdate}')
SELECT col1, col2 FROM source WHERE ds = '{prebizdate}';
```

### Q2: PGSQL 的 `UNION ALL` 历史继承在 Hive 中如何实现？

A: Hive 的历史继承同样使用 `UNION ALL`，逻辑一致，无需特殊转换。

### Q3: PGSQL 的 `DATE_TRUNC` 在 Hive 中如何实现？

A: 使用 `TRUNC` 函数：

```sql
-- PGSQL
DATE_TRUNC('month', col)
DATE_TRUNC('quarter', col)

-- Hive
TRUNC(col, 'MM')
TRUNC(col, 'Q')
```

### Q4: PGSQL 的字符串拼接 `||` 在 Hive 中如何实现？

A: 使用 `CONCAT` 函数：

```sql
-- PGSQL
col1 || col2 || 'suffix'

-- Hive
CONCAT(col1, col2, 'suffix')
```

### Q5: PGSQL 的 `COALESCE` 在 Hive 中如何实现？

A: Hive 推荐使用 `NVL`，功能等价：

```sql
-- PGSQL
COALESCE(col, default_value)

-- Hive
NVL(col, default_value)
```
