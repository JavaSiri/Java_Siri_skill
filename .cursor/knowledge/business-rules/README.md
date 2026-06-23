# 业务规则索引（Business Rules）

> **用途**：业务术语、业务认定、业务策略的**唯一权威定义库**。
> **与 schema/ 的区别**：本目录下的内容**不与某个字段强绑定**，而是定义"业务上怎么认定"。
> **与 metrics/ 的区别**：本目录定义"业务术语"；具体指标的计算公式（涉及 SQL 算法）放 metrics/。

---

## 决策准则：什么内容应该放这里？

| 满足以下任一条件 → 放这里 | 反例（不要放这里） |
|---|---|
| ✅ 跨多张表都适用 | ❌ 某个字段的字典值 → 放 `schema/<层>/fields/<表名>.md` |
| ✅ 业务方需要签字认可 | ❌ SQL 算法公式 → 放 `metrics/` |
| ✅ 改它会改变"我们对业务的理解" | ❌ 临时性需求 → 放 ADS 表注释 |
| ✅ 涉及业务策略判断 | ❌ 表结构本身 → 放 `schema/` |

---

## 目录结构

```
business-rules/
├── README.md                # 本文件（索引 + 决策准则 + 横向对比）
├── credit-rules.md          # 授信环节：3 个状态规则 + 1 个分流类型（授信侧）
├── loan-rules.md            # 支用环节：3 个状态规则 + 1 个分流类型（支用侧）+ 1 个陪跑标记
└── analytics.md             # 跨环节度量：Vintage 逾期率 + 4 个待补充度量
```

> 📌 **设计哲学**：**按业务环节分文件** + **跨环节度量抽离**。
>
> - 主索引按授信/支用两个环节组织，与业务方对话自然
> - `diversion_type` 跨两个环节，**适度重复**（授信/支用判定逻辑不同，避免跨文件跳转）
> - `analytics.md` 只收**无法单一归类**的派生指标（必须同时满足 3 个条件，详见该文件）

---

## 10 个核心业务术语索引

### 状态认定类（业务环节内部）

| # | 业务术语 | 英文标识 | 所属文件 | 一句话定义 |
|---|---------|---------|---------|-----------|
| 1 | 授信通过 | `credit_passed` | [credit-rules.md §1](./credit-rules.md#1-授信通过credit-passed) | 授信状态 = 通过 + 数据有效 |
| 2 | 支用通过 | `loan_passed` | [loan-rules.md §1](./loan-rules.md#1-支用通过loan-passed) | 支用状态 = 通过 + 数据有效 |
| 3 | 首次成功授信 | `first_successful_credit` | [credit-rules.md §2](./credit-rules.md#2-首次成功授信first-successful-credit) | 客户首笔通过授信（按申请时间） |
| 4 | 首次成功支用 | `first_successful_loan` | [loan-rules.md §2](./loan-rules.md#2-首次成功支用first-successful-loan) | 客户首笔通过支用（按申请时间，3 粒度） |
| 5 | 首次授信申请 | `first_credit_application` | [credit-rules.md §3](./credit-rules.md#3-首次授信申请first-credit-application) | 客户首笔授信申请（不论结果，3 粒度） |
| 6 | 首次支用申请 | `first_loan_application` | [loan-rules.md §3](./loan-rules.md#3-首次支用申请first-loan-application) | 客户首笔支用申请（不论结果，3 粒度） |

### 分流维度类（跨环节）

| # | 业务术语 | 英文标识 | 所属文件 | 一句话定义 |
|---|---------|---------|---------|-----------|
| 7 | 分流类型（授信侧） | `diversion_type` (type=1) | [credit-rules.md §4](./credit-rules.md#4-分流类型授信场景diversion-type) | 1=晋商/华通；2=嵩海 |
| 7' | 分流类型（支用侧） | `diversion_type` (type=2) | [loan-rules.md §4](./loan-rules.md#4-分流类型支用场景diversion-type) | 1=晋商/华通；2=嵩海 |
| 8 | 陪跑标记 | `if_sh_flag` | [loan-rules.md §5](./loan-rules.md#5-陪跑标记accompany-flag) | 1=陪跑；0=非陪跑（仅嵩海分流有效） |

### 跨环节度量类

| # | 业务术语 | 英文标识 | 所属文件 | 一句话定义 |
|---|---------|---------|---------|-----------|
| 9 | Vintage 逾期率 | `vintage_delinquency_rate` | [analytics.md §1](./analytics.md#1-vintage-逾期率vintage-delinquency-rate) | 按批次月分群、MOB 跟踪的逾期本金率 |

> 💡 **为什么 Vintage 单独算一类？** 它必须**串联授信 + 支用 + 还款**三表才能算出，无法归类到任一环节。

---

## 横向对比：分流类型（两场景）

| 维度 | 授信场景（type='1'） | 支用场景（type='2'） |
|------|---------------------|---------------------|
| **章节位置** | [credit-rules.md §4](./credit-rules.md#4-分流类型授信场景diversion-type) | [loan-rules.md §4](./loan-rules.md#4-分流类型支用场景diversion-type) |
| **判定逻辑 1（最高优先级）** | 命中"内部最新"白名单 → 嵩海 | 关联授信表已标嵩海 → 嵩海（**上下游一致**） |
| **判定逻辑 2** | 申请时间 ≥ `20251203` → 嵩海 | 客户在 `o_ttsp_t_white_infos` 白名单 + 关联 `seqnum` → 嵩海 |
| **判定逻辑 3（默认）** | 晋商/华通 | 晋商/华通 |
| **代码出处** | `mid/dim_application_classification_mapping_di.sql` 第 25-27 行 | `mid/dim_application_classification_mapping_di.sql` 第 85-110 行（fenliu CTE） |
| **关键差异** | **时间切分**是主策略（硬编码日期） | **白名单**是主策略，**无时间切分** |

> ⚠️ **重要**：两个场景的判定逻辑**不一致**，但**业务上要求上下游一致**（支用沿用授信的分流）。代码实现通过 `LEFT JOIN` + `COALESCE` 兜底保证。

---

## 横向对比：4 个"首次"类术语

| 维度 | 首次授信申请 | 首次成功授信 | 首次支用申请 | 首次成功支用 |
|------|-------------|-------------|-------------|-------------|
| **章节位置** | [credit-rules.md §3](./credit-rules.md#3-首次授信申请first-credit-application) | [credit-rules.md §2](./credit-rules.md#2-首次成功授信first-successful-credit) | [loan-rules.md §3](./loan-rules.md#3-首次支用申请first-loan-application) | [loan-rules.md §2](./loan-rules.md#2-首次成功支用first-successful-loan) |
| **看结果？** | ❌ 不看 | ✅ 仅通过 | ❌ 不看 | ✅ 仅通过 |
| **partition by（粒度 ①）** | `customer_sk` | `customer_sk` | `customer_sk` | `customer_sk` |
| **partition by（粒度 ②）** | `customer_sk, product_code_sk` | `customer_sk, product_code_sk` | `customer_sk, product_code_sk` | `customer_sk, product_code_sk` |
| **partition by（粒度 ③）** | `customer_sk, product_code_sk, diversion_type` | `customer_sk, product_code_sk, diversion_type` | `customer_sk, product_code_sk, diversion_type` | `customer_sk, product_code_sk, diversion_type` |
| **业务口径** | 行为起点 | 结果起点 | 行为起点 | 结果起点 |
| **典型应用** | 漏斗分析起点 | 新客分层、新客风险 | 漏斗分析起点 | 新支分层、新支风险 |

> 💡 **关键洞察**：
> 1. **授信 / 支用 4 个术语的 partition 列表完全平行**——都是 3 粒度结构
> 2. 粒度 ① ⊇ 粒度 ② ⊇ 粒度 ③（粗 ⊇ 细，换产品/换分流后又算一次"首次"）
> 3. **"看结果？❌/✅" 决定了 `where status='1'` 是否需要加**——4 个术语中，"首次申请"不加、"首次成功"加
> 4. ⚠️ 4 个术语都**不绑定 DWD 字段**——`is_first_credit='Y'` / `is_first_loan='Y'` 在不同实现里可能对应不同粒度，需在 SQL 中显式声明

---

## 关键关系图

```
                 ┌─→ 首次授信申请（行为起点）──┐
                 │     · 粒度① 客户历史         partition by customer_sk
                 │     · 粒度② 产品下客户       partition by customer_sk, product_code_sk
                 │     · 粒度③ 产品+分流下客户  partition by customer_sk, product_code_sk, diversion_type
                 │                            │
                 │                            ▼
                 │                     授信通过 ──→ 首次成功授信
                 │                     （status=1）  （结果起点 · 同样的 3 粒度）
                 │                            │
客户（customer）──┤                            ▼
                 │                     分流类型（授信）
                 │                      ├─ 1=晋商/华通
                 │                      └─ 2=嵩海
                 │
                 └─→ 首次支用申请（行为起点）──┐
                      · 粒度① 客户历史         partition by customer_sk
                      · 粒度② 产品下客户       partition by customer_sk, product_code_sk
                      · 粒度③ 产品+分流下客户  partition by customer_sk, product_code_sk, diversion_type
                      │                      │
                      │                      ▼
                      │               支用通过 ──→ 首次成功支用
                      │               （status=1）  （结果起点 · 同样的 3 粒度）
                      │                      │
                      │                      ▼
                      │               分流类型（支用）
                      │                ├─ 1=晋商/华通
                      │                └─ 2=嵩海
                      │                  └─ 陪跑标记（仅嵩海）
                      │
                      ▼
              ┌─────────────────────────────────┐
              │  跨环节度量（Vintage 逾期率）     │
              │  串联授信 + 支用 + 还款三表       │
              │  必带 diversion_type 切片        │
              └─────────────────────────────────┘
```

**关键约束**：
- **4 个"首次"术语都按 3 粒度划分**（粒度 ① ⊇ ② ⊇ ③）
- **"申请" ⊇ "成功"**（行为 ⊇ 结果）—— 客户申请了但没通过时，"申请"算"成功"不算
- **partition 列表只决定粒度**，不影响"看结果不看"的判定

---

## 与现有 DWD 表的参考关系

> ⚠️ **本节是参考信息，不是绑定关系**。业务规则的核心是 **3 粒度的 partition 口径**，具体落表到 DWD 维表的哪个字段（`is_first_credit='Y'` / `is_first_loan='Y'`）是**实现细节**——不同实现的粒度可能不同。

| 业务术语 | DWD 维表参考字段 | 备注 |
|---------|----------------|------|
| 首次成功授信 | `is_first_credit = 'Y'` (type=1) | 具体粒度由实现方决定 |
| 首次成功支用 | `is_first_loan = 'Y'` (type=2) | 具体粒度由实现方决定 |
| 分流类型 | `diversion_type` | type=1/2 都有 |
| 陪跑标记 | `if_sh_flag` | **仅 type=2 有值** |
| 首次授信申请 | ⚠️ **不绑定** | 需 DWS/ADS 实时计算（3 粒度） |
| 首次支用申请 | ⚠️ **不绑定** | 需 DWS/ADS 实时计算（3 粒度） |

> 💡 **使用建议**：
> - 业务上需要某粒度时，**在 SQL 中显式声明** `partition by` 列表
> - 不直接依赖 `is_first_credit='Y'` / `is_first_loan='Y'` 的具体含义
> - 3 粒度的 SQL 模板见 [credit-rules.md SQL 模板汇总](./credit-rules.md#sql-模板汇总授信环节)

---

## 维护说明

- **新增术语**：判断属于哪个环节（授信/支用/跨环节），在对应文件新增章节，并更新本文档的"10 个核心业务术语索引"
- **修改术语**：保留修改历史，必要时在文件中加 `## 变更历史` 章节
- **废弃术语**：不要直接删除文件，将文件改名为 `*.deprecated.md` 并加废弃说明
- **跨文件引用**：使用相对路径 `./credit-rules.md#1-授信通过credit-passed` 格式（GitHub/IDE 都支持跳转）

---

## 文件演进历史

| 日期 | 变更内容 | 变更人 |
|------|---------|--------|
| 2026-06-16 | **结构重组**：从 11 文件（8 规则 + 3 README）合并为 3 文件（按业务环节 + analytics 抽离） | - |
| 2026-06-16 | 新增 `analytics.md` 收录跨环节度量（Vintage 逾期率） | - |
| 2026-06-16 | **"首次"类术语结构升级**：4 个术语（首次授信申请 / 首次成功授信 / 首次支用申请 / 首次成功支用）统一拆为 3 粒度（客户历史 / 产品下客户 / 产品+分流下客户），partition by 列表显式化 | - |
