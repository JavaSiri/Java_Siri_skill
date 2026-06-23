---
name: sql-modify-skill
description: Guide through SQL field addition/removal/modification for existing tables. Use when adding, deleting, or modifying fields in an existing SQL script.
---

# SQL Field Modification

> **使用说明**：本 skill 由 skill-selector 编排。文件加载由 skill-selector 统一管理，本 skill 仅负责修改逻辑。

---

## 修改步骤

### Step 1: 读取目标表代码

```
必须读取：目标表的 .sql 文件（完整读取）
目的：
  - 确认目标表的语法类型（PostgreSQL / Hive）
  - 确认字段命名风格、CTE 结构、注释风格
  - 确认分区策略、回刷窗口（是否与标准有差异）
  - 确认金额字段处理方式
```

> 读取目标表后，其语法类型已确定，据此确定加载哪个数据库规范。

---

## 删除字段流程

### Step 2: 删除字段溯源

> **关键约束：删除或修改某字段前，必须完成全链路引用检查。禁止仅因"不被 SELECT 引用"就判定为死代码。**

#### 全链路引用检查清单（强制）

```
必须检查的位置清单：
  1. Final SELECT 列表 → 是否引用该字段（作为输出列）
  2. Final JOIN ... ON 条件 → 是否引用该字段（用于过滤/匹配）
  3. Final WHERE 条件 → 是否引用该字段（用于过滤）
  4. Final GROUP BY / HAVING / ORDER BY → 是否引用该字段
  5. Final 窗口函数 → PARTITION BY / ORDER BY 中是否引用该字段
  6. 其他 CTE 的 SELECT 列表 → 是否引用该字段（中间计算）
  7. 其他 CTE 的 JOIN / WHERE / GROUP BY → 是否引用该字段

溯源结论必须包含：
  - 该字段在哪些位置被引用？（列出每个引用位置）
  - 哪些引用需要同步修改？
  - 哪些引用不受影响？
  - 最终判定：能否删除/修改？如能，如何处理每个引用？
```

#### 执行流程

```
从 final CTE 开始，定位目标字段
  └── 逐层向上溯源：
        ├── 字段是否来自中间 CTE？→ 追踪该 CTE 的定义
        ├── 字段是否来自上游表？→ 确认上游表来源
        └── 字段是否是派生字段（如 SUM、COUNT）？→ 确认聚合逻辑

确认影响范围：
  - 该字段是否在其他 CTE 中被引用？
  - 删除后是否影响其他字段的计算？
  - 是否需要在 final 的 SELECT 列表中移除？

执行删除：
  1. 从字段来源处开始删除
  2. 清理因此空缺的中间 CTE 字段
  3. 同步更新 final CTE 的 SELECT 列表
  4. 同步更新 final CTE 的 JOIN / WHERE 等引用该字段的子句
```

---

## 新增字段流程

### Step 2: 新增字段溯源

> **关键约束：新增字段时，必须先完成枚举，再确定修改策略。禁止在枚举完成前凭业务判断决定"哪个 CTE 需要/不需要修改"。**

#### Step 2.1：枚举所有 CTE（前置必做）

```
枚举和判断必须严格分离。枚举阶段仅做客观记录，不做修改决策。

读取完整 SQL 文件后，按出现顺序列出所有 CTE：
  - cte0_refresh_date_scope
  - cte1_xxx
  - cte2_xxx
  - ...
  - cteN_xxx
  - FINAL（DELETE + INSERT 段）

对每个 CTE 记录以下客观信息：
  - CTE 名称
  - CTE 类型（参数型 / 静态序列型 / 源表读取型 / 聚合型（FROM 源表）/ 聚合型（FROM CTE）/ 派生/中转型）
  - SELECT 列表中是否已包含该字段（是/否）
  - GROUP BY 中是否包含该字段（聚合型 CTE 适用）
  - FROM 来源（聚合型 CTE 适用，标注 FROM 的是源表还是上游 CTE）
```

#### Step 2.2：判断字段性质

```
新增字段按性质分为三类，不同类型决定了不同的修改策略：

  1. 分组维度字段
     - 定义：作为 GROUP BY 维度出现的字段，新增后会改变目标表的粒度
     - 示例：product_code_sk（产品维度）、channel_sk（渠道维度）
     - 特征：字段值会分裂现有组合，同一组合可能对应多个不同值
     - 修改策略：透传到所有业务传递型 CTE，同步扩展 GROUP BY

  2. 指标类字段
     - 定义：由底层字段计算/聚合得出的派生字段，不独立存在
     - 示例：repayment_rate = 已还金额 / 放款金额、SUM(amount) AS total_amount
     - 特征：字段值由计算产生，不存在于任何单条原始记录中
     - 修改策略：仅在计算来源的 CTE 中添加，不透传

  3. 属性字段
     - 定义：描述粒度实例的属性值，粒度本身不变
     - 示例：customer_name（客户姓名）、first_loan_time（首笔支用时间）
     - 特征：同一粒度实例的属性值是唯一的或不参与分组聚合
     - 修改策略：透传到需要的 CTE，不修改 GROUP BY（不影响粒度）

判断规则（根据源表结构和新增字段的业务含义判断，不依赖枚举结果）：
  - 问题 1：该字段是否可以由其他字段计算得出？
    - 是 → 指标类字段（字段值由计算产生，不独立存在）
  - 问题 2：同一粒度组合下，该字段是否可能有多个不同值？
    - 是 → 分组维度字段（字段值会分裂现有组合）
    - 否 → 属性字段（字段值描述粒度实例的属性，粒度不变）
```

#### Step 2.3：输出结论声明（强制）

```
完成 Step 2.2 后，必须以如下格式输出结论声明，不得跳过或省略：

  结论：<字段名> 为「<字段类型>」
  依据：<判断依据>

  <字段类型>的修改约束：
  <逐条列出该类型对应的所有修改约束，与 Step 2.4 中的禁止行为一一对应>

  示例输出：

  结论：product_code_sk 为「分组维度字段」
  依据：同一 (first_loan_month, diversion_type) 组合下，product_code_sk 存在多个不同值

  分组维度字段的修改约束：
  1. 所有聚合型 CTE 必须扩展 GROUP BY，扩展后的 GROUP BY 必须显式包含 product_code_sk
  2. 业务传递型 CTE 必须透传该字段，不得跳过
  3. JOIN 条件必须包含 product_code_sk 匹配条件
  4. 所有 JOIN（包括 INNER JOIN 和 LEFT JOIN）的 ON 条件必须包含该分组维度字段的等值匹配，以避免笛卡尔膨胀导致数据膨胀
  5. FINAL 的 INNER JOIN 必须包含 product_code_sk 匹配条件
```

> **强制链接约束：Step 2.4 中的每一步执行，必须显式引用 Step 2.3 结论声明中的对应约束，并在该步下方注明"约束验证：<约束编号> ✓"。违反即为规范错误。**

#### Step 2.4：根据字段性质和 CTE 类型执行修改

**分组维度字段：**

```
处理顺序：从 cte1 到 cteN，按出现顺序逐一处理。上游 CTE 先处理完毕，下游 CTE 检查上游结果。

判断逻辑（对每个 CTE 逐一执行）：
  1. CTE 类型为参数型或静态序列型？
     - 是 → 不添加（无业务字段）
  2. CTE 类型为源表读取型？
     - 是 → 检查该 CTE 的 FROM/JOIN 中的所有表是否包含该字段
       - 源表包含该字段 → 添加到 SELECT 列表
         - 同时检查所有 JOIN 的目标表是否也包含该字段
           - 若包含 → JOIN ON 条件中必须包含该字段的等值匹配，否则会产生笛卡尔膨胀
           约束验证：约束 4 ✓
           - 若不包含 → 正常处理
       - 源表不包含该字段 → 从上游维度表关联获取（LEFT JOIN 维度表，补充 product_code_sk 匹配条件），添加到 SELECT 列表
  3. CTE 类型为聚合型（FROM 源表）？
     - 是 → 检查源表是否包含该字段
       - 源表包含该字段 → 添加到 SELECT 列表，同步扩展 GROUP BY
       - 源表不包含该字段 → 报告阻塞点（需回溯确认源表字段）
  4. CTE 类型为聚合型（FROM CTE）或派生/中转型？
     - 是 → 检查上游 CTE（该 CTE 的 FROM 子句中引用的 CTE）是否已添加该字段
       - 上游已添加 → 从上游继承，添加到 SELECT 列表，不扩展 GROUP BY（上游已按正确粒度产出）
       - 上游未添加 → 当前 CTE 无法添加，报告阻塞点（需回溯上游）

禁止行为（括号内为对应的约束编号）：
  - ❌ 禁止凭业务判断跳过任何业务传递型 CTE（约束 2）
  - ❌ 禁止跳过 Step 2.3 结论声明或不在 Step 2.4 中显式引用（全部约束均失效）
  - ❌ 聚合型（FROM CTE）或派生/中转型不得通过扩展 GROUP BY 来获取分组维度字段（约束 1）
  - ❌ 源表读取型不得跳过源表直接假设下游能补字段（约束 1）
  - ❌ 源表读取型在 JOIN 目标表也包含该字段时，JOIN ON 中未包含该字段的等值匹配（约束 4）
```

**指标类字段：**

```
仅在计算来源的 CTE 中添加该字段，其他 CTE 不修改。

判断逻辑：
  1. 该字段在哪一个 CTE 中首次被计算？
     - 在该 CTE 的 SELECT 列表中添加字段定义
     约束验证：约束 1 ✓
  2. 其他业务传递型 CTE 不需要透传该字段
     约束验证：约束 1 ✓
```

**属性字段：**

```
透传到需要的 CTE，不修改 GROUP BY（不影响粒度）。

判断逻辑（对每个业务传递型 CTE 逐一执行）：
  1. 该字段是否需要被添加？（检查下游是否需要）
     - 该字段是否参与该 CTE 的 JOIN 条件、WHERE 条件？
       - 是 → 添加到 SELECT 列表
       约束验证：约束 3 ✓
       - 否 → 检查下游是否需要该字段（若下游需要，该 CTE 仍需透传）
     约束验证：约束 1 ✓
  2. 如果是聚合型，无需修改 GROUP BY（不影响粒度）
     约束验证：约束 2 ✓
```

#### Step 2.5：同步 JOIN 条件

```
对所有 JOIN（包括 INNER JOIN 和 LEFT JOIN），当被关联的 CTE 新增了维度字段时：
  - 检查 JOIN ... ON 中是否已有该字段的等值条件
  - 若没有，补充 `AND <alias>.<field> = <other_alias>.<field>`
  - 典型位置：
    - cte1_diversion_map 被 LEFT JOIN 时（cte3 中的 LEFT JOIN）
    - cte1_diversion_map 被用于 lookup 时（cte8 中的 LEFT JOIN）
  - 禁止遗漏：cte8 中可能同时有多个 JOIN，每个都需要检查
  约束验证：约束 4 ✓
```

#### Step 2.6：FINAL 段修改清单

```
FINAL 段需要同步修改以下 4 个位置：

  1. INSERT 列名列表：
     - 在 diversion_type 之后、total_loan_amount 之前插入 product_code_sk

  2. SELECT 列表：
     - 在 bm.diversion_type 之后添加 bm.product_code_sk
     - 同时检查 mw（cte10 别名）是否需要该字段（行转列 CTE 已在 GROUP BY 中处理，无需在 SELECT 中单独引用）

  3. INNER JOIN ... ON 条件：
     - 除已有的 first_loan_month 和 diversion_type 匹配条件外
     - 补充 product_code_sk 的匹配：AND bm.product_code_sk = mw.product_code_sk
     - 使用 COALESCE 处理 NULL：AND COALESCE(bm.product_code_sk, '') = COALESCE(mw.product_code_sk, '')

  4. ORDER BY：
     - 在 diversion_type 之后添加 product_code_sk 排序
```

#### Step 2.7：更新文件头部字段说明

```
在文件头部的 DML 注释块"字段格式说明"中：
  - 在 diversion_type 字段说明之后，添加：
    product_code_sk             VARCHAR，产品主键
```

### 禁止行为

- ❌ 不枚举所有 CTE 就开始改代码
- ❌ 在 Step 2.1（枚举）完成前就开始判断或修改
- ❌ 跳过 Step 2.1 直接假设字段属于哪一类
- ❌ 在枚举完成前，凭业务判断决定"哪个 CTE 需要/不需要修改"（无论是否影响粒度）
- ❌ 分组维度字段跳过任何业务传递型 CTE
- ❌ 聚合型（FROM CTE）或派生/中转型通过扩展 GROUP BY 获取分组维度字段
- ❌ 业务传递型 CTE 漏加字段导致下游 CTE 无法继承
- ❌ 漏掉 JOIN 条件中的字段匹配条件
- ❌ FINAL 的 INNER JOIN 缺少维度字段的匹配条件
- ❌ FINAL 的 ORDER BY 缺少维度字段排序
- ❌ 漏掉文件头部字段说明的同步更新

---

## 修改完成后

```
1. 输出最终 SQL 代码
2. 提示用户：代码修改完成，是否需要代码审查？
3. 若用户确认 → 返回 skill-selector，由 skill-selector 编排进入 [代码审查] 流程
```

> 注意：审查环节由 skill-selector 统一编排，sql-modify-skill 不直接跳转。
