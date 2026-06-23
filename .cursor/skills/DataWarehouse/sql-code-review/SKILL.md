---
name: sql-code-review
description: Review code for data warehouse SQL scripts following team standards. Use when reviewing SQL scripts, pull requests, or when the user asks for a code review.
---

# SQL Code Review

> **使用说明**：本 skill 由 skill-selector 编排。文件加载由 skill-selector 统一管理，本 skill 仅负责审查执行。

---

## 审查执行

### Step 1: 确定审查范围

```
审查范围由用户请求决定：
  - 单个文件 → 审查该文件
  - 多个文件 → 按依赖顺序逐个审查
  - PR/变更集 → 审查变更文件
```

### Step 2: 读取目标代码

```
读取目标 .sql 文件完整内容。
```

### Step 3: 执行检查清单

> **执行纪律**：完成 Step 2（读取完整文件内容）之前，禁止进入 Step 4 输出任何审查结论。检查清单必须覆盖文件中的每一个 CTE、每一个 JOIN、每一个 WHERE 条件，禁止只检查部分内容就出结论。

按照下方「审查清单」逐项执行。对每条检查项标记：✅ / ❌ / N/A。对 N/A 项注明原因（如"本文件无 JOIN，跳过 JOIN 相关检查"）。

### Step 4: 输出审查报告

按照「审查报告格式」输出。

---

## 审查清单

### 数据正确性

- [ ] 数据源表和字段是否正确
- [ ] 字段来源是否符合优先级规范（事实表优先，维度表兜底）
- [ ] JOIN 条件是否完整、无遗漏
- [ ] 维度表 JOIN 是否包含 `product_code_sk` 匹配条件（防止跨产品错误关联）
- [ ] 跨产品关联数据膨胀风险：维度表 JOIN 是否存在笛卡尔积放大风险？
- [ ] WHERE 条件是否覆盖所有分区字段
- [ ] GROUP BY 是否包含所有非聚合字段
- [ ] UNION/UNION ALL 使用是否正确
- [ ] NULL 处理是否符合预期

### 业务逻辑

- [ ] 指标计算口径是否正确
- [ ] 日期分区使用是否正确
- [ ] 状态枚举值是否完整
- [ ] 业务规则是否与文档一致

### 数据库特有规范

- [ ] 语法使用是否符合对应数据库的规范

### 基础语法

> 以下检查项用于发现 SQL 执行前的低级错误，无需连接数据库即可检查。

- [ ] 括号匹配：`(` 和 `)` 是否成对、嵌套正确
- [ ] 引号匹配：单引号 `'` 和双引号 `"` 是否成对
- [ ] 逗号检查：SELECT 列表中是否有漏写或多写的逗号
- [ ] 关键字拼写：`SELECT` / `FROM` / `WHERE` / `JOIN` / `ON` / `GROUP BY` / `HAVING` / `ORDER BY` 等是否拼写正确
- [ ] INSERT INTO 显式字段列表：`INSERT INTO table` 后必须有 `(` 包裹的字段列表，禁止 `INSERT INTO table WITH ... SELECT ...`
- [ ] INSERT 列数 vs SELECT 列数：INSERT INTO (...) 的字段数是否与 SELECT 列表一致
- [ ] CTE 别名一致性：CTE 定义的别名是否与引用处一致
- [ ] 字段引用一致性：SELECT/WHERE/JOIN 中引用的字段是否在对应的 CTE SELECT 列表中存在
- [ ] 聚合函数 + GROUP BY：所有非聚合字段是否都出现在 GROUP BY 中
- [ ] 窗口函数语法：`OVER(PARTITION BY ... ORDER BY ...)` 语法是否正确
- [ ] NULL 处理：聚合函数（MIN/MAX/SUM/COUNT）结果为 NULL 的列是否做了 COALESCE 保护

### 死代码检测

> **警告：判定某字段为"死代码"前，必须完成全链路引用检查。禁止仅因"不被 SELECT 引用"就删除该字段。**

**死代码全链路引用检查清单：**

```
判定字段为"死代码"前，必须确认以下位置均无引用：
  1. Final SELECT 列表 → 是否引用该字段
  2. Final JOIN ... ON 条件 → 是否引用该字段（用于过滤/匹配）
  3. Final WHERE 条件 → 是否引用该字段
  4. Final GROUP BY / HAVING / ORDER BY → 是否引用该字段
  5. Final 窗口函数 → PARTITION BY / ORDER BY 中是否引用该字段
  6. 其他 CTE 的 SELECT 列表 → 是否引用该字段
  7. 其他 CTE 的 JOIN / WHERE / GROUP BY → 是否引用该字段

⚠️ 特别注意：JOIN ... ON 条件中引用的字段，即使不在 SELECT 列表中，也必须保留在 CTE 的 SELECT 中。
```

**常见误判场景：**

```sql
-- CTE 定义
,cte1_dim AS (
    SELECT  id AS credit_sk
            ,diversion_type
            ,product_code_sk          -- ❌ 错误判定：认为未被 SELECT 引用，删除
    FROM    dim_table
    WHERE   ...
)

-- Final 引用
SELECT  cr.product_code_sk               -- 引用事实表字段
FROM    cte1_dim cr
LEFT JOIN cte1_dim_map dm
ON      cr.credit_sk = dm.credit_sk
AND     dm.product_code_sk = cr.product_code_sk   -- ⚠️ 引用了 cte1_dim_map 的 product_code_sk
-- 如果 cte1_dim_map 中也删除了 product_code_sk，此处报错！
```

### 性能

- [ ] 是否有多余的 JOIN
- [ ] 是否使用了合适的分区裁剪
- [ ] 大表是否有过滤条件
- [ ] 子查询是否可优化
- [ ] 是否缺少必要的索引（Hive/PostgreSQL）

### 代码质量

- [ ] 表名/字段名是否有意义
- [ ] 是否有必要的注释
- [ ] 代码缩进是否规范
- [ ] 是否避免了对大表的 SELECT *

---

## 常见问题示例

### 必须修复（Critical）

```sql
-- ❌ 全表扫描
SELECT * FROM large_table WHERE ds = '${biz_date}'

-- ❌ 笛卡尔积
SELECT * FROM table_a, table_b WHERE a.id = b.id(+)

-- ❌ 缺少分区条件
INSERT OVERWRITE TABLE target_table
SELECT * FROM source_table  -- 缺少 WHERE ds = '${biz_date}'

-- ❌ 字段来源优先级错误
-- product_code_sk 应从事实表获取，而非从维度表获取
SELECT  t1.credit_sk
        ,d.product_code_sk              -- ❌ 来自维度表（不应优先）
FROM    ttsp_it.dwd_fact_credit_application_di t1
LEFT JOIN ttsp_it.dim_application_classification_mapping_di d
ON      t1.credit_sk = d.id
...

-- ❌ 维度表 JOIN 缺少 product_code_sk 匹配
-- 存在跨产品错误关联风险
LEFT JOIN ttsp_it.dim_application_classification_mapping_di d
ON      t1.credit_sk = d.id
AND     d.type = '1'
AND     d.is_active = 'Y'
AND     d.ds BETWEEN ...                -- ❌ 缺少 AND d.product_code_sk = t1.product_code_sk

-- ❌ 跨产品关联导致数据膨胀
-- dim_application_classification_mapping_di 中同一 credit_sk 存在多条 product_code_sk 记录
-- 不加 product_code_sk 匹配条件会导致笛卡尔积放大
SELECT COUNT(*) FROM (
    SELECT  cr.credit_sk
            ,dm.diversion_type
    FROM    cte6_credit_info cr
    LEFT JOIN cte1_diversion_map dm
    ON      cr.credit_sk = dm.credit_sk
    -- ❌ 缺少 AND dm.product_code_sk = cr.product_code_sk
    -- 假设同一 credit_sk 有 3 个 product_code_sk，则每条记录膨胀 3 倍
) t
-- 结果：正常应该 1000 条，实际输出 3000 条（数据膨胀）

-- ❌ 死代码误删：JOIN ON 引用的字段被删除
-- CTE1 定义
,cte1_diversion_map AS (
    SELECT  id AS credit_sk
            ,diversion_type
            ,product_code_sk          -- ❌ 误删：认为未被 SELECT 引用
    FROM    dim_application_classification_mapping_di
    WHERE   type = '1'
    AND     is_active = 'Y'
)

-- Final JOIN
LEFT JOIN cte1_diversion_map dm
ON      cr.credit_sk = dm.credit_sk
AND     dm.product_code_sk = cr.product_code_sk   -- ❌ 报错：product_code_sk 不存在！
```

### 建议优化（Suggestion）

```sql
-- ✅ 指定需要的字段
SELECT loan_id, customer_id, amount, status FROM large_table WHERE ds = '${biz_date}'

-- ✅ 显式 LEFT JOIN
SELECT a.*, b.col1
FROM table_a a
LEFT JOIN table_b b ON a.id = b.id

-- ✅ 添加分区条件
INSERT OVERWRITE TABLE target_table
SELECT * FROM source_table WHERE ds = '${biz_date}'

-- ✅ 字段来源优先级：product_code_sk 从事实表获取
SELECT  t1.credit_sk
        ,t1.product_code_sk              -- ✅ 来自事实表（优先）
        ,d.diversion_type              -- 来自维度表（属性字段）
FROM    ttsp_it.dwd_fact_credit_application_di t1
LEFT JOIN ttsp_it.dim_application_classification_mapping_di d
ON      t1.credit_sk = d.id
AND     d.type = '1'
AND     d.is_active = 'Y'
AND     d.ds BETWEEN ...
AND     d.product_code_sk = t1.product_code_sk   -- ✅ 防止跨产品关联

-- ✅ 维度表 JOIN 包含 product_code_sk 匹配条件
LEFT JOIN ttsp_it.dim_application_classification_mapping_di d
ON      t1.credit_sk = d.id
AND     d.type = '1'
AND     d.is_active = 'Y'
AND     d.ds BETWEEN ...
AND     d.product_code_sk = t1.product_code_sk   -- ✅ 匹配条件

-- ✅ 跨产品关联防止数据膨胀
-- 维度表同一主键对应多条产品记录时，必须用 product_code_sk 精确匹配
SELECT  cr.credit_sk
        ,dm.diversion_type
FROM    cte6_credit_info cr
LEFT JOIN cte1_diversion_map dm
ON      cr.credit_sk = dm.credit_sk
AND     dm.product_code_sk = cr.product_code_sk   -- ✅ 防止跨产品关联导致数据膨胀
```

---

## 审查报告格式

审查报告的「检查清单摘要」必须按以下顺序分三个板块输出，不得合并或遗漏：

```
## 审查结果

- **文件**：xxx.sql
- **语法类型**：PostgreSQL / Hive
- **审查日期**：YYYY-MM-DD

### 必须修复（Critical）

[🔴 Critical] 问题描述
原因：解释为什么需要修改
建议：给出修改建议

### 建议优化（Suggestion）

[🟡 Suggestion] 问题描述
原因：解释优化价值
可选方案：提供其他方案

### 非必须项（Nit）

[🟢 Nit] 问题描述
说明：非必须修改的建议

### 检查清单摘要

#### Step 1：sql-standards.mdc（快速验收清单）

| 检查项 | 结果 |
|--------|------|
| SQL-1：窗口范围 | ✅/❌/N/A |
| SQL-2：金额口径 | ✅/❌/N/A |
| SQL-3：历史继承 | ✅/❌/N/A |
| SQL-4：关联过滤位置 | ✅/❌/N/A |
| SQL-5：CTE 注释位置 | ✅/❌/N/A |
| SQL-6：CTE 注释格式 | ✅/❌/N/A |
| SQL-7：分区裁剪硬编码常量 | ✅/❌/N/A |
| SQL-8：INSERT 列列表字段格式 | ✅/❌/N/A |

#### Step 2：{db}-skill/SKILL.md（数据库特有规范）

| 检查项 | 结果 |
|--------|------|
| PG-1 / Hive-1：幂等模式 | ✅/❌/N/A |
| PG-2 / Hive-2：字段列表 | ✅/❌/N/A |
| PG-3 / Hive-3：关联过滤 | ✅/❌/N/A |
| PG-4 / Hive-4：分区裁剪 | ✅/❌/N/A |
| PG-5 / Hive-5：注释完整性 | ✅/❌/N/A |
| PG-6 / Hive-6：语法转换 | ✅/❌/N/A |

#### Step 3：sql-code-review/SKILL.md（综合审查清单）

| 分类 | 检查项 | 结果 |
|------|--------|------|
| **数据正确性** | 数据源表和字段是否正确 | ✅/❌/N/A |
| | 字段来源是否符合优先级规范 | ✅/❌/N/A |
| | JOIN 条件是否完整、无遗漏 | ✅/❌/N/A |
| | 维度表 JOIN 是否包含 product_code_sk 匹配条件 | ✅/❌/N/A |
| | 跨产品关联数据膨胀风险 | ✅/❌/N/A |
| | WHERE 条件是否覆盖所有分区字段 | ✅/❌/N/A |
| | GROUP BY 是否包含所有非聚合字段 | ✅/❌/N/A |
| | UNION/UNION ALL 使用是否正确 | ✅/❌/N/A |
| | NULL 处理是否符合预期 | ✅/❌/N/A |
| **业务逻辑** | 指标计算口径是否正确 | ✅/❌/N/A |
| | 日期分区使用是否正确 | ✅/❌/N/A |
| | 状态枚举值是否完整 | ✅/❌/N/A |
| | 业务规则是否与文档一致 | ✅/❌/N/A |
| **数据库特有规范** | 语法使用是否符合对应数据库的规范 | ✅/❌/N/A |
| **基础语法** | 括号匹配 | ✅/❌/N/A |
| | 引号匹配 | ✅/❌/N/A |
| | 逗号检查 | ✅/❌/N/A |
| | 关键字拼写 | ✅/❌/N/A |
| | INSERT INTO 显式字段列表 | ✅/❌/N/A |
| | INSERT 列数 vs SELECT 列数 | ✅/❌/N/A |
| | CTE 别名一致性 | ✅/❌/N/A |
| | 字段引用一致性 | ✅/❌/N/A |
| | 聚合函数 + GROUP BY | ✅/❌/N/A |
| | 窗口函数语法 | ✅/❌/N/A |
| | NULL 处理保护 | ✅/❌/N/A |
| **死代码检测** | 全链路引用检查 | ✅/❌/N/A |
| **性能** | 是否有多余的 JOIN | ✅/❌/N/A |
| | 是否使用了合适的分区裁剪 | ✅/❌/N/A |
| | 大表是否有过滤条件 | ✅/❌/N/A |
| | 子查询是否可优化 | ✅/❌/N/A |
| | 是否缺少必要的索引 | ✅/❌/N/A |
| **代码质量** | 表名/字段名是否有意义 | ✅/❌/N/A |
| | 是否有必要的注释 | ✅/❌/N/A |
| | 代码缩进是否规范 | ✅/❌/N/A |
| | 是否避免了对大表的 SELECT * | ✅/❌/N/A |
```

---

## 审查流程纪律

> **以下章节是审查流程的硬性约束，用于防止认知偏差导致的漏检。**

### 纪律 1: 先加载规范，再读代码

```
禁止：先读代码形成印象 → 再拿规范验证
必须：先加载规范清单 → 再读代码执行检查
```

- **原因**：先读代码会形成初步判断（锚定效应），后续倾向于寻找支持该判断的证据，忽视否定性发现
- **正确顺序**：按照 skill-selector 编排的步骤加载规范 → 读取代码 → 执行清单检查

### 纪律 2: 清单必须逐条执行，不得跳过

```
禁止：清单作为"参考"，有印象才检查
必须：清单作为"执行清单"，逐条过一遍
```

- **原因**：审查时容易对"显眼问题"投入过多认知资源，导致清单后半段被忽略
- **正确做法**：`Standards Compliance` 检查项是硬性检查步骤，不是可选项
- **执行要求**：每条检查项都应有明确的"✅ / ❌ / N/A"标记，N/A 需注明原因

### 纪律 3: 对"显眼问题"保持克制

```
禁止：发现 Critical 问题后急于给出结论
必须：先完整走查所有检查项，再输出结论
```

- **原因**：发现重大问题会激发"问题已解决"的心理暗示，缩短后续检查
- **正确做法**：
  1. 记录发现的问题（不输出）
  2. 继续完整走查清单剩余项
  3. 所有检查完成后，统一输出结论
- **警惕信号**：如果审查过程中已经"确信发现了所有问题"，这是漏检的预警

---

## 最佳实践

1. **先看整体**：了解改动的影响范围
2. **再看细节**：检查具体的实现逻辑
3. **提供方案**：发现问题时要给出修改建议
4. **保持礼貌**：Review 是帮助，不是批评
5. **及时响应**：Review 意见应在 24 小时内响应
