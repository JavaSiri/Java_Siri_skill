# .cursor 知识资产索引

> 所有 Agent 行为的权威文档索引。本目录下的 `.md`/`.mdc`/`.json` 文件构成完整的知识资产体系。

---

## 目录结构

```
.cursor/
├── rules/                  # 强制行为规则
│   ├── always/             # 全局生效
│   │   └── intent-router.mdc
│   └── Datawarehouse/      # 数仓领域专用
│       ├── think.mdc
│       ├── sql-standards.mdc
│       ├── pgsql-standards.mdc
│       └── hive-standards.mdc
├── skills/                 # Agent 技能库
│   ├── DataWarehouse/      # 数仓领域（18个技能）
│   ├── backend/            # 后端领域
│   └── productivity/       # 提效工具
├── workflows/              # 工作流编排
│   └── Datawarehouse/      # 数仓开发工作流（10个）
├── knowledge/               # 业务知识资产
│   ├── business-rules/     # 业务规则（按环节组织）
│   ├── schema/             # 数仓模型文档（ADS/DWD/DWS）
│   └── requirement/        # 需求文档
├── tickets/                # 开发工单（由 to_issues 生成）
└── ...
```

---

## 快速入口

### 新人首次使用

```
1. 读 intent-router.mdc          → 理解请求如何被路由
2. 读 think.mdc                  → 建立数仓建模思维
3. 读 sql-standards.mdc         → 掌握 SQL 开发通用规范
4. 读 dispatcher's SKILL.md     → 理解 Ticket 如何被分发
```

### 按任务类型找入口

| 任务 | 入口 |
|------|------|
| 新建表（有参考表） | `workflows/Datawarehouse/reuse-based-dev.mdc` |
| 新建表（全新设计） | `workflows/Datawarehouse/design-based-dev.mdc` |
| 修改已有表 | `workflows/Datawarehouse/modify-dev.mdc` |
| 报表/指标开发 | `workflows/Datawarehouse/report-pre-workflow.mdc` |
| 需求澄清（表） | `skills/DataWarehouse/table-requirement-analyzer/SKILL.md` |
| 指标口径追问 | `skills/DataWarehouse/grill-with-docs/SKILL.md` |
| 需求转 PRD | `skills/DataWarehouse/to-prd/SKILL.md` |
| 拆解为 Ticket | `skills/DataWarehouse/to_issues/SKILL.md` |
| 处理 Ticket | `skills/DataWarehouse/dispatcher/SKILL.md` |
| SQL 代码审查 | `workflows/Datawarehouse/code-review.mdc` |
| 语法转译（PG↔Hive） | `workflows/Datawarehouse/translate-dev.mdc` |
| 数据质量检查 | `skills/DataWarehouse/data-quality/SKILL.md` |
| 问题诊断 | `skills/DataWarehouse/diagnose/SKILL.md` |
| 血缘链路拉远 | `skills/DataWarehouse/zoom-out/SKILL.md` |

---

## 规则层（rules/）

### 全局路由规则

| 文件 | 说明 |
|------|------|
| `always/intent-router.mdc` | **强制入口**。所有请求的绝对起点，两层决策树（第一层：数仓/后端领域识别；第二层：需求类型分类） |

### 数仓领域规则

| 文件 | 说明 | 作用域 |
|------|------|--------|
| `Datawarehouse/think.mdc` | 业务视角建模原则（10条核心原则 + 需求分析9步顺序） | 全流程 |
| `Datawarehouse/sql-standards.mdc` | SQL 通用规范（CTE命名、金额处理、关联过滤、分区裁剪、窗口计算） | `**/*.sql` |
| `Datawarehouse/pgsql-standards.mdc` | PostgreSQL 特定实现（DELETE+INSERT幂等、四段式结构、历史继承） | `**/*.sql` |
| `Datawarehouse/hive-standards.mdc` | Hive 特定实现（INSERT OVERWRITE PARTITION、动态/静态分区） | `**/*.sql` |

---

## 技能层（skills/）

### 数仓技能（18个）

| 技能 | 触发时机 | 核心输出 |
|------|---------|---------|
| **dispatcher** | 用户说「处理 Ticket」 | Ticket 分发到对应 Workflow |
| **table-requirement-analyzer** | 新建表/修改表需求 | 表需求卡（5维度澄清） |
| **report-builder** | 开发 ADS/DWS/DWD SQL 脚本 | 目标表 DDL + ETL SQL |
| **sql-modify-skill** | 对已有表加/删/改字段 | 字段变更 ETL SQL |
| **sql-translate-skill** | PostgreSQL ↔ Hive 语法转译 | 目标语法 SQL |
| **grill-with-docs** | 任何新报表需求（无条件触发） | 指标卡片 + 口径澄清结论 |
| **metric-extractor** | 报表需求文本 | 指标列表 JSON |
| **requirement-analyzer** | 需求信息不足时 | 5维度结构化分析结论 |
| **to-prd** | 需求 → PRD | 发布到 issue tracker |
| **to_issues** | PRD/澄清结论 → 开发 Ticket | `.cursor/tickets/` 下的 .md 文件 |
| **sql-code-review** | SQL 脚本审查请求 | 审查报告 |
| **sql-review-high-error** | 代码审查强制复核 | INSERT/注释高频错误报告 |
| **data-quality** | 构建数据验证规则 | 质量检查规则 |
| **diagnose** | 报表数据问题/ETL失败/数据异常 | 诊断循环结论 |
| **doc-generator** | 生成表/报表/ETL/接口技术文档 | 文档 |
| **git-workflow** | 提交代码/分支/PR | 提交规范 |
| **zoom-out** | 理解表/主题域的全链路血缘 | 血缘视图 |
| **triage** | 创建/分类/审核数据 issue | issue 状态变更 |

### 业务规则（knowledge/business-rules/）

| 文件 | 内容 |
|------|------|
| `business-rules/README.md` | 索引 + 决策准则 + 横向对比 |
| `business-rules/credit-rules.md` | 授信环节：授信通过、首次成功授信、首次授信申请、分流类型（授信场景） |
| `business-rules/loan-rules.md` | 支用环节：支用通过、首次成功支用、首次支用申请、分流类型（支用场景）、陪跑标记 |
| `business-rules/analytics.md` | 跨环节度量：Vintage 逾期率等 |

### 数仓模型文档（knowledge/schema/）

```
schema/
├── ADS/fields/     # ADS 层各表字段定义（38个）
├── DWD/fields/     # DWD 层各表字段定义（10个）
├── DWS/fields/     # DWS 层各表字段定义（16个）
├── ADS/tables.md  # ADS 层表清单
├── DWD/tables.md  # DWD 层表清单
└── DWS/tables.md  # DWS 层表清单
```

---

## 工作流层（workflows/Datawarehouse/）

### 路由拓扑

```
用户请求
  │
  ├─ 数仓领域?
  │   ├─ 报表开发 ────────────────────────────────→ report-pre-workflow.mdc
  │   ├─ 非报表开发 ──→ dev-pre-workflow.mdc ──→ dispatcher ──┬─ 新建表 + 有参考表 → reuse-based-dev.mdc
  │   │                                                            ├─ 新建表 + 全新设计 → design-based-dev.mdc
  │   │                                                            ├─ 修改表           → modify-dev.mdc
  │   │                                                            └─ 语法转译        → translate-dev.mdc
  │   ├─ 需求分析 ────────────────────────────────→ requirement-analysis.mdc
  │   └─ 代码审查 ────────────────────────────────→ code-review.mdc
  └─ (其他领域 → 留白)
```

### 工作流清单

| 文件 | 用途 | 步骤数 |
|------|------|--------|
| `_shared.mdc` | 所有 Workflow 共享纪律（禁止行为 + 执行原则） | — |
| `intent-router.mdc` | 全局路由入口（见 rules/always/） | — |
| `report-pre-workflow.mdc` | 报表开发主流程（指标提取→口径追问→PRD→Ticket→分发） | 5步 |
| `dev-pre-workflow.mdc` | 非报表开发前置流程（澄清→Ticket→分发） | 3步 |
| `requirement-analysis.mdc` | 需求分析（结构化分析→结论→引导 to-prd） | 3步 |
| `reuse-based-dev.mdc` | 参考已有表新建开发（读参考表→AI分析→追问→生成Ticket→开发→审查） | 8步 |
| `design-based-dev.mdc` | 全新设计新建开发（追问澄清→生成Ticket→表结构设计→ETL→审查） | 7步 |
| `modify-dev.mdc` | 调整开发（加载规范→字段修改→审查） | 5步 |
| `translate-dev.mdc` | 转译开发（语法转译→审查） | 4步 |
| `code-review.mdc` | 代码审查（加载规范→执行审查→输出报告→更新Ticket） | 3步 |
| `new-dev.mdc` | 新建开发（加载规范→ETL开发→审查） | 4步 |

### 共享纪律（所有 Workflow 必须遵守）

> 来源：`_shared.mdc`

1. 禁止在没有读取规范文件的情况下假设自己"知道"规范
2. 禁止跳过任务类型检测直接进入流程
3. 禁止跳过任何一个 Step 就进入下一步
4. 禁止跳过"必须输出读取清单"这一步骤
5. 禁止以"上下文已加载"为由，读取了文件但未输出读取清单
6. 禁止在开发/调整/转译完成后跳过代码审查
7. 禁止仅根据表名风格（如 `_df`/`_di`）或文件扩展名（`.sql`）判断语法类型

---

## 工单层（tickets/）

| 文件 | 内容 |
|------|------|
| `tickets/RdyDW-ADS-CC-VG-01.md` | ADS 授信合同维度 Month Vintage 表新建 |
| `tickets/RdyDW-DWS-CC-01.md` | DWS 授信合同维度每日快照表新建 |

工单由 `to_issues` skill 生成，由 `dispatcher` skill 分发到对应 Workflow 处理。

---

## 维护指南

### 新增文件

| 类型 | 放置位置 | 要求 |
|------|---------|------|
| 路由规则 | `rules/always/` | frontmatter 必须含 `description` |
| 数仓规则 | `rules/Datawarehouse/` | frontmatter 必须含 `description` |
| 数仓 Skill | `skills/DataWarehouse/` | 必须含 `name` + `description` |
| Workflow | `workflows/Datawarehouse/` | frontmatter 必须含 `description` |
| 业务规则 | `knowledge/business-rules/` | 按环节分文件（授信/支用/跨环节） |
| 表文档 | `knowledge/schema/<层>/fields/` | 命名：`<表名>.md` |

### 新增 Skill 规范

Skill 文件命名：`SKILL.md`
frontmatter 必须包含：
```yaml
---
name: <skill-name>          # 唯一标识（路由用）
description: <用途描述>     # skill-selector 展示用
---
```

### 新增 Workflow 规范

Workflow 文件命名：`*.mdc`
frontmatter 必须包含：
```yaml
---
description: <流程描述>
---
```

### 废弃文件

不要直接删除文件。重命名为 `*.deprecated.md` 并加废弃说明。

---

## 版本历史

| 日期 | 变更内容 |
|------|---------|
| 2026-06-23 | 初始版本（基于现有文件结构生成） |
