# dws_customer_first_credit_month_vintage_df

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dws_customer_first_credit_month_vintage_df` |
| **描述** | 客户维度Vintage（按【客户+产品+分流】下首次成功授信月，粒度③，统计借据侧放款/余额） |
| **分区键** | `ds`（业务日期，yyyymmdd） |
| **分布策略** | HASH (first_credit_month) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWS |
| **统计视角** | 每日快照型（Vintage维度，MobMonth透视图） |
| **时间维度** | 月维（first_credit_month = yyyy-MM）+ 日维（ds = 业务日期） |
| **金额单位** | 分 |

---

## 字段定义

### 维度属性

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | first_credit_month | VARCHAR(7) | 首次成功授信月，格式 yyyy-MM |
| 2 | diversion_type | VARCHAR(10) | 分流类型，1=华通/晋商，2=嵩海 |
| 3 | product_code_sk | VARCHAR(10) | 产品编码 |
| 4 | overdue_level | VARCHAR(10) | 逾期层次，0+/7+/30+ 等 |
| 5 | ds | VARCHAR(8) | 分区键，按天分区 |

### 基础金额度量

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 6 | total_loan_amount | BIGINT | 放款金额 |
| 7 | total_outstanding_principal | BIGINT | 时点在贷余额（全部借据剩余本金） |

### Mob1-Mob24 逾期比例度量

每 Mob（Month on Book，支用后第 N 个自然月）包含一对字段，格式一致：

| Mob | 逾期借据剩余本金（分子） | 全部借据剩余本金（分母） |
|:---:|:----------------------:|:----------------------:|
| mob1 | mob1_overdue_prin | mob1_total_prin |
| mob2 | mob2_overdue_prin | mob2_total_prin |
| mob3 | mob3_overdue_prin | mob3_total_prin |
| mob4 | mob4_overdue_prin | mob4_total_prin |
| mob5 | mob5_overdue_prin | mob5_total_prin |
| mob6 | mob6_overdue_prin | mob6_total_prin |
| mob7 | mob7_overdue_prin | mob7_total_prin |
| mob8 | mob8_overdue_prin | mob8_total_prin |
| mob9 | mob9_overdue_prin | mob9_total_prin |
| mob10 | mob10_overdue_prin | mob10_total_prin |
| mob11 | mob11_overdue_prin | mob11_total_prin |
| mob12 | mob12_overdue_prin | mob12_total_prin |
| mob13 | mob13_overdue_prin | mob13_total_prin |
| mob14 | mob14_overdue_prin | mob14_total_prin |
| mob15 | mob15_overdue_prin | mob15_total_prin |
| mob16 | mob16_overdue_prin | mob16_total_prin |
| mob17 | mob17_overdue_prin | mob17_total_prin |
| mob18 | mob18_overdue_prin | mob18_total_prin |
| mob19 | mob19_overdue_prin | mob19_total_prin |
| mob20 | mob20_overdue_prin | mob20_total_prin |
| mob21 | mob21_overdue_prin | mob21_total_prin |
| mob22 | mob22_overdue_prin | mob22_total_prin |
| mob23 | mob23_overdue_prin | mob23_total_prin |
| mob24 | mob24_overdue_prin | mob24_total_prin |

（共 48 个字段，mob1-mob24 各含 overdue_prin 和 total_prin）

---

## 关键口径说明

### Vintage 分析法

Vintage（账龄分析）以**【客户+产品+分流】下的首次成功授信月**为基准（粒度③），按 Mob（Month on Book）跟踪资产质量。每个 Mob 代表**授信后第 N 个自然月**月末的逾期情况。

### overdue_level 逾期层次

| 值 | 含义 | 说明 |
|---:|------|------|
| 0+ | M0+ | 所有在贷（含正常+逾期） |
| 7+ | M1+ | 逾期 7 天及以上的借据 |
| 30+ | M3+ | 逾期 30 天及以上的借据 |

每个 overdue_level 对应一行独立记录。

### Mob 口径

- `mob*N*_total_prin`：截至**授信后**第 N 个自然月月末，该 Vintage 下全部在贷借据的剩余本金（分母）
- `mob*N*_overdue_prin`：截至**授信后**第 N 个自然月月末，该 Vintage 下逾期借据的剩余本金（分子）

逾期率计算公式：`mob*N*_overdue_prin / mob*N*_total_prin`

### 切片维度

按 `first_credit_month + diversion_type + product_code_sk + overdue_level` 切片，每日快照刷新所有 Vintage 的所有 Mob 数值。

### ds 分区语义

ds 取自业务日期字段，属于**业务时间分区**，每日快照全量刷新，写入 ds 取 `data_date`。

### 金额单位

DWS 层为分，ADS 层引用需 `/100.0` 转为元。

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| first_credit_month | 关联 DWD 授信申请事实表（`dwd_fact_credit_application_di`），按 `is_active='Y' AND credit_status='1'` 取【客户+产品+分流】下首次成功授信的自然月 |
| diversion_type / product_code_sk | 关联 ODS 支用事实表 |
| overdue_level | 根据逾期天数断层切分 |
| mob_*_total_prin | 关联 DWD 借据余额快照，按首次成功授信月 + Mob 月聚合 |
| mob_*_overdue_prin | 关联 DWD 逾期快照，按首次成功授信月 + Mob 月 + 逾期层级聚合 |
