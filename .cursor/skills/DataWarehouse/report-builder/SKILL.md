---
name: report-builder
description: Guide through data warehouse ETL development. Use when developing new ADS/DWS/DWD SQL scripts.
---

# Report Builder

> **使用说明**：本 skill 由 skill-selector 编排。文件加载由 skill-selector 统一管理，本 skill 仅负责开发逻辑。

---

## 开发步骤

### Step 1: 确定开发范围

```
根据需求分析结果确定需要开发的表：
  - ADS 层（应用服务层）：面向业务的最终报表
  - DWS 层（主题汇总层）：按业务主题聚合
  - DWD 层（业务明细层）：明细事实表

开发顺序：DWD → DWS → ADS
```

### Step 2: DWD 层开发

```
根据业务需求设计并开发 DWD 层 SQL。
  - 明细事实表，记录业务事件
  - 字段：业务主键 + 业务属性 + 分区字段
  - 分区策略：按业务日期分区
```

### Step 3: DWS 层开发

```
根据业务主题设计并开发 DWS 层 SQL。
  - 按业务主题聚合
  - 字段：维度字段 + 汇总指标
  - 分区策略：日维（每日快照）/ 月维（累积型快照）/ 周维（累积型快照）
  - 注意回刷窗口设置
```

### Step 4: ADS 层开发

```
根据报表需求设计并开发 ADS 层 SQL。
  - 面向业务的最终输出
  - 字段：日期维度 + 业务维度 + 指标
  - 分区策略：根据需求类型确定
```

### Step 5: 规范自检

```
开发完成后，按照 sql-standards.mdc 的「快速验收清单」逐项自检。
对每条检查项标记：✅ / ❌
若有 ❌ 项，先修复再进入审查环节。
```

---

## DWD 层设计原则

### 表结构规范

```
- 表名：dwd_<业务主题>_<事实描述>_di
- 分区键：ds（业务日期）
- 字段命名：小写下划线
```

### 字段类型规范

| 业务字段类型 | PostgreSQL | Hive |
|-------------|-----------|------|
| 字符串 | VARCHAR | STRING |
| 整数 | BIGINT | BIGINT |
| 金额 | DECIMAL(18,2) | DECIMAL(18,2) |
| 时间戳 | TIMESTAMP | TIMESTAMP |

---

## DWS 层设计原则

### 分区策略

| 维度类型 | 分区策略 | 说明 |
|---------|---------|------|
| 日维 | 每日快照 | DELETE 指定分区 + INSERT 当日数据 |
| 月维 | 累积型快照 | DELETE 当前分区 + INSERT 月度全量 |
| 周维 | 累积型快照 | DELETE 当前分区 + INSERT 周度全量 |

### 字段命名规范

```
- 时间维度：stat_date / stat_month / stat_week
- 业务维度：xxx_sk / xxx_name / xxx_type
- 指标字段：cnt / amt / rate / balance
```

---

## ADS 层设计原则

### 报表表命名

```
ads_<业务主题>_<指标主题>_<更新频率>
├── ads_loan_vintage_cycle_daily_df    -- 账龄周期日报
├── ads_customer_portrait_monthly_df     -- 客户画像月报
└── ads_repay_performance_daily_df     -- 还款表现日报
```

### 字段设计

| 字段类型 | 说明 | 示例 |
|---------|------|------|
| 日期字段 | 统计周期 | `stat_date`, `stat_month` |
| 维度字段 | 分析角度 | `product_type`, `channel` |
| 指标字段 | 统计数值 | `apply_cnt`, `approve_rate` |
| 关联字段 | 关联信息 | `customer_id`, `loan_id` |

---

## 常见报表类型

### 1. 账龄报表 (Vintage Report)

```
用途：追踪不同月份放款的资产质量
维度：放款月份、账龄月数、产品、渠道
指标：放款金额、余额、逾期率、坏账率
```

### 2. 漏斗报表 (Funnel Report)

```
用途：分析各环节转化情况
维度：环节、时间、产品、渠道
指标：各环节数量、转化率
```

### 3. 监控报表 (Monitoring Report)

```
用途：日常运营监控
维度：日期、产品、机构
指标：T+1 加工完成率、数据量波动
```

---

## 开发检查清单

开发完成后自检：

- [ ] 需求分析已完成（需求类型、数据类型、数据延迟已确定）
- [ ] DWD 层脚本已开发
- [ ] DWS 层脚本已开发
- [ ] ADS 层脚本已开发
- [ ] 指标定义已文档化
- [ ] 字段血缘已梳理
- [ ] sql-standards.mdc 快速验收清单已通过
- [ ] {db}-skill 快速验收清单已通过

---

## 开发完成后

```
1. 输出最终 SQL 代码
2. 输出各表依赖关系说明
3. 提示用户：开发完成，是否需要代码审查？
4. 若用户确认 → 返回 skill-selector，由 skill-selector 编排进入 [代码审查] 流程

> 注意：审查环节由 skill-selector 统一编排，report-builder 不直接跳转。
