---
name: doc-generator
description: Generate technical documentation for data warehouse projects. Use when creating documentation for tables, reports, ETL processes, or API specifications.
---

# Documentation Generator

## Document Types

| Type | Description | When to Use |
|------|-------------|-------------|
| Table Doc | 数据表说明文档 | 新建或修改表结构 |
| Report Doc | 报表说明文档 | 新建报表 |
| Process Doc | 流程说明文档 | ETL 流程变更 |
| API Doc | 接口说明文档 | 提供数据接口 |

## Table Documentation Template

```markdown
# {表名}

## 基本信息

| 属性 | 值 |
|------|-----|
| 中文名称 | {表中文名} |
| 数据层 | {ODS/DWD/DWS/ADS} |
| 更新频率 | {T+1/T+0/实时} |
| 分区字段 | {分区字段} |
| 数据延迟 | {延迟时间} |

## 表结构

| 字段名 | 中文名 | 数据类型 | 说明 |
|--------|--------|----------|------|
| col1 | 字段1 | STRING | 说明 |
| col2 | 字段2 | BIGINT | 说明 |

## 计算逻辑

{详细的计算逻辑说明}

## 数据来源

| 源表 | 源字段 | 映射关系 |
|------|--------|----------|
| ods_xxx | col_a | 直接映射 |
| dwd_xxx | col_b | 关联取值 |

## 生命周期

- 历史数据保留天数：{天数}
- 异常处理：{处理方式}

## 示例

```sql
-- 查询示例
SELECT * FROM {table_name} WHERE ds = '20260501' LIMIT 100;
```
```

## Report Documentation Template

```markdown
# {报表名称}

## 报表概述

{报表用途和业务背景}

## 指标定义

| 指标名称 | 计算公式 | 数据来源 | 说明 |
|----------|----------|----------|------|
| 指标1 | SUM(col) | dws_xxx | 说明 |
| 指标2 | COUNT(DISTINCT col) | dwd_xxx | 说明 |

## 维度说明

| 维度 | 说明 | 示例值 |
|------|------|--------|
| stat_date | 统计日期 | 2026-05-01 |
| product_id | 产品ID | P001 |

## 使用说明

- 访问方式：{数据平台/BI工具}
- 刷新时间：{时间}
- 查询限制：{限制条件}

## 更新日志

| 日期 | 版本 | 变更内容 | 作者 |
|------|------|----------|------|
| 2026-05-01 | v1.0 | 新建报表 | xxx |

## Q&A

**Q: 指标X 为什么和报表Y 不一致？**
A: {解释原因}
```

## ETL Process Documentation Template

```markdown
# {ETL 流程名称}

## 流程概述

{流程功能说明}

## 调度信息

| 属性 | 值 |
|------|-----|
| 调度周期 | {日/周/月} |
| 调度时间 | {时间} |
| 依赖任务 | {上游任务} |
| 运行超时 | {超时时间} |

## 数据流程

```
ODS 层
  ↓ {ods_xxx}
DWD 层
  ↓ {dwd_xxx}
DWS 层
  ↓ {dws_xxx}
ADS 层
  ↓ {ads_xxx}
报表输出
```

## 关键逻辑

### 1. {逻辑1}

{详细说明}

### 2. {逻辑2}

{详细说明}

## 异常处理

- 数据异常：{处理方式}
- 任务失败：{处理方式}
- 数据回溯：{回溯方式}
```

## Best Practices

1. **及时更新**：表结构变更后立即更新文档
2. **版本控制**：记录文档变更历史
3. **示例代码**：提供可运行的查询示例
4. **指标定义**：明确定义每个指标的计算口径
5. **职责明确**：记录表的 Owner 和维护人

## File Naming Convention

| Document Type | Naming Pattern |
|---------------|----------------|
| Table Doc | `表名_doc.md` |
| Report Doc | `报表名_doc.md` |
| Process Doc | `流程名_doc.md` |
| API Doc | `接口名_api.md` |
