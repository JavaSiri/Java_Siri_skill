# dim_date_irf

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dim_date_irf` |
| **描述** | 通用日期维度表 |
| **分区键** | 无（全局表） |
| **分布策略** | HASH (data_date) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 无分区（全局表） |
| **金额单位** | 无金额字段 |
| **表粒度** | 日期级（data_date） |
| **表类型** | Irf（镜像表/维表快照） |

---

## 字段定义

### 核心日期字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | data_date | VARCHAR | 日期 |
| 2 | data_date_yyyymmdd | BIGINT | 日期 yyyymmdd 格式 |
| 3 | data_year | BIGINT | 年 |
| 4 | data_month | BIGINT | 月 |
| 5 | data_day | BIGINT | 日 |
| 6 | data_week_num | BIGINT | 周数 |
| 7 | data_weekday | BIGINT | 星期 |
| 8 | data_quarter | BIGINT | 季度 |

### 日期标识

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 9 | is_first_d_of_m | VARCHAR(1) | 是否月初 |
| 10 | is_last_d_of_m | VARCHAR(1) | 是否月末 |

### 接口返回字段（节假日/工作日）

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 11 | r_year | BIGINT | 接口返回：年 |
| 12 | r_month | BIGINT | 接口返回：月 |
| 13 | r_date | BIGINT | 接口返回：日 |
| 14 | r_yearweek | BIGINT | 接口返回：一年中的第几周 |
| 15 | r_yearday | BIGINT | 接口返回：一年中的第几天 |
| 16 | r_holiday | BIGINT | 接口返回：节假日 |
| 17 | r_holiday_desc | VARCHAR(256) | 节假日描述 |
| 18 | r_holiday_overtime | BIGINT | 接口返回：节假日调休（加班） |
| 19 | r_holiday_overtime_desc | VARCHAR(256) | 节假日调休（加班）描述 |
| 20 | r_week | BIGINT | 接口返回：星期 |
| 21 | r_workday | BIGINT | 接口返回：是否为工作日（包含调休在内需要上班的日子） |
| 22 | r_workday_desc | VARCHAR(256) | 是否为工作日描述 |
| 23 | r_weekend | BIGINT | 接口返回：是否为周末（星期六和星期日） |
| 24 | r_weekend_desc | VARCHAR(256) | 是否为周末描述 |
| 25 | r_holiday_today | BIGINT | 接口返回：是否为节日当天 |
| 26 | r_holiday_today_desc | VARCHAR(256) | 是否为节日当天描述 |
| 27 | r_holiday_legal | BIGINT | 接口返回：是否为法定节假日（三倍工资） |
| 28 | r_holiday_legal_desc | VARCHAR(256) | 是否为法定节假日描述 |
| 29 | r_holiday_recess | BIGINT | 接口返回：是否为假期节假日（节日是否放假） |
| 30 | r_holiday_recess_desc | VARCHAR(256) | 是否为假期节假日描述 |

### 农历字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 31 | r_lunar_year | BIGINT | 接口返回：农历年 |
| 32 | r_lunar_month | BIGINT | 接口返回：农历月 |
| 33 | r_lunar_date | BIGINT | 接口返回：农历日 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 34 | created_time | TIMESTAMP | 创建时间 |
| 35 | updated_time | TIMESTAMP | 更新时间 |
| 36 | is_active | VARCHAR(2) | 是否有效 (Y/N) |

---

## 关键口径说明

### Irf 表特性

本表为 Irf（镜像表），全量存储历史和未来日期数据，不按日期分区，供所有层引用。

### r_* 字段来源

`r_` 前缀字段由外部日历接口返回，涵盖节假日、调休、工作日等日历信息，可用于业务筛选（如排除节假日计算工作日天数）。

### 典型使用场景

- 关联业务表中的日期字段，获取星期、季度等维度用于分组聚合
- 通过 `r_workday` / `r_holiday` 筛选工作日/节假日数据
- 通过 `is_first_d_of_m` / `is_last_d_of_m` 筛选月初/月末数据
- 通过农历字段支持节日敏感性业务分析

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| 基础日期字段 | 系统生成 |
| r_* 节假日字段 | 外部日历接口 |
| 农历字段 | 外部农历/阴历接口 |
