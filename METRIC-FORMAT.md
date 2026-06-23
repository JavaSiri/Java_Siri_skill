# 指标卡片格式

指标卡片以指标为最小单元，独立文件存储在 `.cursor/knowledge/metrics/` 目录下。

> **指标 ≠ 粒度**：粒度是承载指标的表的属性（同一指标可同时存在于 customer 粒度表、credit_contract 粒度表、产品粒度表中），不属于指标本身。指标卡片只定义"指标是什么、怎么算"，粒度由具体承载表（DWS/ADS）自行声明。

## 文件命名

```
{三位序号}_{度量主语}_{业务动作}_{度量词}.md
```

- 序号从 `001` 开始，按澄清顺序递增
- 示例：`001_credit_application_count.md`、`002_loan_application_count.md`

## Frontmatter

```yaml
---
id: 001
name: credit_application_count      # {度量主语}_{业务动作}_{度量词}
display_name: 授信申请数
category: 授信
created: 2026-01-15
deprecated: false
---
```

| 字段 | 说明 |
|------|------|
| `id` | 三位序号，与文件名序号一致 |
| `name` | 指标技术名（英文，用于代码引用），格式 `{度量主语}_{动作}_{度量}` |
| `display_name` | 指标中文展示名，禁止裸词，必须体现度量主语 |
| `category` | 主题分类（授信 / 贷款 / 资产 / 催收 等） |
| `created` | 创建日期 |
| `deprecated` | 是否已废弃（布尔值） |

## 正文模板

```markdown
# {指标名称}

## 指标名称
{技术名}

---

## 业务定义
{一句话描述这个指标统计什么业务现象}

---

## 度量主语
{Loan / Credit / Customer / Repayment 等被度量的业务对象}

---

## 计算口径
{该指标本身的聚合逻辑，与粒度无关。例如：`count(distinct credit_apply_id)`}

---

## 过滤条件
{该指标本身的通用筛选，与粒度无关。例如：`status = '已支用'`。粒度专属的过滤条件（如 `where credit_contract_no = ?`）由承载表声明，不写在本卡片中}

---

## 常见维度
- {维度 1，如申请日期}
- {维度 2，如渠道}
- {维度 3，如产品}
- {维度 4，如地区}
- {维度 N，如客户等级}

---

## 数据来源

| 承载表 | 粒度 |
|--------|------|
| {DWS/ADS 表名} | {该表的粒度，如 customer + day} |
| {另一张承载表} | {另一粒度，如 credit_contract + day} |

---

## 变更历史

| 日期 | 变更内容 | 变更人 |
|------|---------|--------|
| {YYYY-MM-DD} | {首次创建} | {变更人} |
```