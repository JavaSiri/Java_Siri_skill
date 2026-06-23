---
name: sql-review-high-error
description: SQL 代码审查高频错误点专项审查器。专门检查 INSERT INTO 列列表规范、CTE 注释位置规范、CTE 注释格式规范。用于代码审查流程中，作为主审查的强制复核环节。
---

# SQL 审查专项子代理

> **职责定位**：仅负责检查以下三个高频错误点，不执行其他审查。
> 此子代理由主审查流程调用，作为强制复核环节。
> **三个检查点**：INSERT INTO 列列表 / 注释位置规范 / 注释格式规范

---

## 调用方式

```
Task(subagent_type="generalPurpose", prompt=<本文件全文>)
```

---

## 输入

| 字段 | 说明 |
|------|------|
| `code` | 被审查的 SQL 代码全文 |
| `syntax_type` | 语法类型：`PostgreSQL` 或 `Hive`（用于区分语法特性） |

---

## 输出格式

输出一个 JSON 对象，不得输出其他内容：

```json
{
  "check_results": [
    {
      "check_id": "INSERT-1",
      "check_name": "INSERT INTO 显式列列表",
      "status": "PASS" | "FAIL" | "N/A",
      "findings": [
        {
          "location": "行号或 CTE 名称",
          "issue": "问题描述",
          "evidence": "实际代码片段"
        }
      ],
      "summary": "一句话总结"
    }
  ],
  "overall_status": "PASS" | "FAIL",
  "summary": "总体结论"
}
```

---

## 检查点一：INSERT INTO 显式列列表

**规范要求**：
- `INSERT INTO <table>` 后必须紧跟 `(` 显式列列表
- 列列表中每行只能有一个字段，禁止 `,field1, field2` 合并多字段
- 禁止 `INSERT INTO <table>` 后直接跟 SELECT

### 检测规则

**规则 INSERT-1：INSERT INTO 必须有列列表**

```
检测步骤：
1. 扫描所有 INSERT INTO 语句（忽略 -- 注释内的）
2. 找到 INSERT INTO 的下一行
3. 判断：
   - 下一行以 ( 开头 → 继续扫描列列表
   - 下一行直接是 SELECT 或 WITH → ❌ FAIL
4. 如果有列列表，扫描闭合括号 ) 后的行
   - 紧跟 SELECT → ✅ PASS
   - 紧跟其他内容 → ❌ FAIL
```

**规则 INSERT-2：列列表每行一个字段**

```
检测步骤：
1. 在列列表区域内，逐行扫描
2. 统计每行的逗号数量：
   - 0 个逗号 → ✅ 该行只有一个字段
   - ≥1 个逗号 → ❌ 该行有多个字段合并
3. 示例错误：
   (   data_date
       ,month_start_date, diversion_type    -- ❌ 一行两个字段
       ,customer_count
   )
```

**规则 INSERT-3：列数一致性（可选检查）**

```
检测步骤：
1. 统计 INSERT INTO 列列表的字段数 N
2. 统计 SELECT 列表的字段数 M
3. 判断：
   - N == M → ✅ PASS
   - N != M → ❌ FAIL
```

### 正确示例

```sql
-- ✅ INSERT INTO 有列列表，每行一个字段
INSERT INTO schema.target_table
(
    data_date
    ,month_start_date
    ,diversion_type
    ,customer_count
    ,ds
)
SELECT  data_date
        ,month_start_date
        ,diversion_type
        ,SUM(customer_count) AS customer_count
        ,'{prebizdate}' AS ds
FROM    cteN_result
;
```

### 错误示例

```sql
-- ❌ INSERT INTO 后直接跟 SELECT，无列列表
INSERT INTO schema.target_table
SELECT  data_date
        ,month_start_date
        ,...
FROM    cteN_result
;

-- ❌ 列列表中多字段合并在一行
INSERT INTO schema.target_table
(   data_date
    ,month_start_date, diversion_type
    ,customer_count
)
SELECT ...
;
```

---

## 检查点二：CTE 注释位置规范

**规范要求**：
- CTE 注释块必须写在 `AS (` **之前**
- 注释块与 `AS (` 之间不得有其他语句行（DELETE、INSERT、SELECT 等）
- 注释块上方必须有 `-- ====` 分隔符

### 检测规则

**规则 POS-1：注释块必须在 AS ( 之前**

```
检测步骤：
1. 扫描所有 ,cteN_xxx AS ( 或 WITH cte0_xxx AS ( 模式
2. 记录每个 CTE 的行号
3. 向前遍历该行，找到最近的上方 -- ==== 分隔符
4. 判断分隔符到 AS ( 之间是否全为空白（空行或空格/制表符）
   - 全为空白 → ✅ PASS
   - 有 DELETE/INSERT/SELECT 等语句行 → ❌ FAIL
5. 继续向上，检查分隔符之前是否有内容
   - 有内容 → ❌ FAIL（分隔符不是注释块起点）
   - 无内容 → ✅ PASS
```

**规则 POS-2：分隔符完整性**

```
检测步骤：
1. 以 -- ==== 上分隔符为起点
2. 向下查找 -- ==== 下分隔符
3. 判断：
   - 找到成对的上下分隔符 → ✅ PASS
   - 只有单行分隔符，无成对 → ❌ FAIL
```

**规则 POS-3：注释块不在括号内**

```
检测步骤：
1. 找到 AS ( 所在行
2. 检查该行之前是否有未闭合的 (
3. 判断：
   - AS ( 之前无未闭合括号 → ✅ PASS
   - AS ( 之前有未闭合括号 → ❌ FAIL（注释在括号内）
```

### 正确示例

```sql
-- ============================================================================
-- CTE1：客户数据来源
-- 说明：
--   1) 数据来源：DWS 层客户表
--   2) 过滤条件：按 ds 分区过滤
--   3) 口径：金额单位转换在源表读取时完成
-- ============================================================================
-- 字段格式说明：
--   customer_sk          VARCHAR，客户唯一标识 示例：100001 客户SK
--   customer_count       BIGINT，客户数量 示例：500 月度客户数
,cte1_customer_data AS (    -- ✅ 注释块在 AS ( 之前
    SELECT  ...
)
```

### 错误示例

```sql
,cte1_customer_data AS (
    -- ❌ 错误：注释写在 AS ( 括号内部
    -- ============================================================================
    -- CTE1：客户数据来源
    -- ============================================================================
    SELECT  ...
)

-- ============================================================================
-- CTE2：客户数据来源
-- 说明：
--   1) 数据来源：DWS 层客户表
-- ============================================================================
DELETE FROM other_table;     -- ❌ 错误：注释块与 AS ( 之间有其他语句行
,cte2_customer_data AS (
```

---

## 检查点三：CTE 注释格式规范

**规范要求**：
- 必须有 `-- ====` 上下分隔符
- 必须包含 `-- CTE<序号>：` 标识行
- 说明段落必须使用 `1) 2) ...` 编号格式
- 必须包含 `-- 字段格式说明：` 段落
- 字段格式行必须包含四要素：字段名、类型、格式、示例

### 检测规则

**规则 FMT-1：上下分隔符完整性**

```
检测步骤：
1. 以 -- ==== 上分隔符为起点
2. 向下查找 -- ==== 下分隔符
3. 判断：
   - 有上下分隔符 → ✅ PASS
   - 只有上分隔符，无下分隔符 → ❌ FAIL
   - 只有下单分隔符，无上分隔符 → ❌ FAIL
```

**规则 FMT-2：CTE 标识行**

```
检测步骤：
1. 在注释块内搜索 -- CTE<序号>：模式
2. 判断：
   - 找到匹配 → ✅ PASS
   - 未找到 → ❌ FAIL
3. 注意：序号应为数字，如 -- CTE1：、-- CTE2：
```

**规则 FMT-3：说明段落编号格式**

```
检测步骤：
1. 在注释块内查找 "说明：" 段落
2. 在该段落内搜索 1) 2) 编号模式
3. 判断：
   - 使用 1) 2) 格式 → ✅ PASS
   - 使用 -、*、[1]、中文括号等 → ❌ FAIL
4. 示例：
   ✅ --   1) 数据来源：DWS 层客户表
   ❌ --   - 数据来源：DWS 层客户表
   ❌ --   1、数据来源：DWS 层客户表
```

**规则 FMT-4：字段格式说明段落**

```
检测步骤：
1. 在注释块内搜索 -- 字段格式说明：
2. 判断：
   - 找到 → ✅ PASS
   - 未找到 → ❌ FAIL
```

**规则 FMT-5：字段格式行四要素**

```
检测步骤：
1. 在 -- 字段格式说明：段落内，逐行扫描字段格式行
2. 每行必须包含四个要素：
   - 要素1：字段名（如 customer_sk）
   - 要素2：类型（如 VARCHAR、BIGINT）
   - 要素3：格式（如 yyyyMMdd、示例格式说明）
   - 要素4：示例值（如 示例：100001 客户SK）
3. 判断：
   - 四要素齐全 → ✅ PASS
   - 缺少任一要素 → ❌ FAIL
4. 正确格式：
   --   customer_sk          VARCHAR，yyyyMMdd 示例：100001 客户SK
                         ↑1      ↑2        ↑3            ↑4
```

### 正确示例

```sql
-- ============================================================================
-- CTE1：客户数据来源
-- 说明：
--   1) 数据来源：DWS 层客户表
--   2) 过滤条件：按 ds 分区过滤
--   3) 口径：金额单位转换在源表读取时完成
-- ============================================================================
-- 字段格式说明：
--   customer_sk          VARCHAR，yyyyMMdd 示例：100001 客户SK
--   customer_count       BIGINT，客户数 示例：500 月度客户数
,cte1_customer_data AS (
```

### 错误示例

```sql
-- CTE1：客户数据来源              -- ❌ 缺少 ==== 分隔符
-- 说明：
--   - 数据来源：DWS 层客户表      -- ❌ 使用 - 而非 1)
--   口径：金额单位转换            -- ❌ 缺少 1) 编号
-- 字段格式说明：                  -- ✅ 有
--   customer_sk VARCHAR           -- ❌ 缺少类型、格式、示例三个要素
,cte1_customer_data AS (
```

---

## 执行流程

```
1. 接收 code（SQL 代码全文）和 syntax_type（语法类型）
2. 逐个执行三个检查点（共 8 条规则）
3. 对每条规则输出 status（PASS/FAIL/N/A）和 findings
4. 汇总所有结果，输出 JSON 格式报告
```

---

## 注意事项

1. **仅检查本文件定义的三个检查点**，不执行其他审查（如 JOIN 条件、金额口径等）
2. **所有检查基于代码文本**，不连接数据库
3. **忽略 -- 注释内的 INSERT INTO 语句**
4. **Hive 动态分区场景**：`INSERT OVERWRITE TABLE ... PARTITION (ds)` 后不跟列列表是**正确**的，不判定为 FAIL
5. **输出必须是纯 JSON**，不得包含任何解释性文本
