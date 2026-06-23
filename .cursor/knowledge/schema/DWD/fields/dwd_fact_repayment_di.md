# dwd_fact_repayment_di

## 表基本信息

| 属性 | 值 |
|------|-----|
| **表名** | `ttsp_it.dwd_fact_repayment_di` |
| **描述** | 还款流水事实表 |
| **分区键** | `ds`（yyyymmdd） |
| **分布策略** | HASH (repay_sk) |
| **存储格式** | ORC / compression=zlib |
| **分层** | DWD |
| **时间维度** | 日维（ds = data_date） |
| **金额单位** | 分 |
| **表粒度** | 还款流水级（repay_sk 为业务主键） |

---

## 字段定义

### 维度外键

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 1 | repay_sk | VARCHAR(64) | 【维度外键】还款号（还款编码，唯一确定一笔还款流水） |
| 2 | seq_no | VARCHAR(64) | 【维度外键】还款流水号（字节提供的还款流水号，唯一确定一笔还款流水） |
| 3 | out_loan_channel_no | VARCHAR(64) | 【维度外键】平台订单号（还款平台订单号） |
| 4 | loan_id | VARCHAR(64) | 【维度外键】借据号（字节提供的借款号，唯一确定一笔借据） |
| 5 | tp_no | VARCHAR(64) | 【维度外键】借款流水号（字节提供的借款流水号，唯一确定一笔借款申请） |
| 6 | crd_cont_no | VARCHAR(64) | 【维度外键】授信合同编号 |
| 7 | customer_sk | VARCHAR(64) | 【维度外键】用户ID |
| 8 | bill_no | VARCHAR(64) | 【维度外键】借据编号 |
| 9 | product_code_sk | VARCHAR(64) | 【维度外键】产品编码 |

### 维度属性-时间

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 10 | term_no | INT | 【维度属性-时间】还款期次 |
| 11 | term_start_date | VARCHAR(8) | 【维度属性-时间】本期开始日期 |
| 12 | term_end_date | VARCHAR(8) | 【维度属性-时间】本期到期日期 |
| 13 | term_clear_date | VARCHAR(8) | 【维度属性-时间】本期还清日期 |
| 14 | customer_actual_repayment_time | TIMESTAMP | 【维度属性-时间】客户实际还款时间 |
| 15 | data_date | VARCHAR(8) | 【维度属性-时间】数据业务日期，格式：yyyyMMdd |
| 16 | funder_booking_time | TIMESTAMP | 【维度属性-时间】资方入账时间 |
| 17 | tran_time | TIMESTAMP | 【维度属性-时间】交易时间 |

### 维度属性-状态

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 18 | repay_status | VARCHAR(2) | 【维度属性-状态】还款状态：Y=还款成功；N=还款失败 |
| 19 | reverse_record | VARCHAR(2) | 【维度属性-状态】流水冲正状态：Y/N 是否冲正 |

### 维度属性-类型

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 20 | repay_type | VARCHAR(2) | 【维度属性-类型】还款类型：11=逾期还款；12=正常还款；13=提前还款；14=提前结清；15=延期还款 |
| 21 | repay_account_type | VARCHAR(2) | 【维度属性-类型】还款渠道：1=银行卡还款；2=支付机构账户还款 |
| 22 | repay_account_name | VARCHAR(64) | 【维度属性-类型】还款账户开户机构名称：银行卡账户对应银行卡开户行名称；支付机构账户对应支付机构名称 |
| 23 | repay_account_no | VARCHAR(64) | 【维度属性-类型】用户还款账户的对应编号：支付宝账号/抖音支付账号 |

### 度量-当笔流水

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 24 | real_repay_principle | BIGINT | 【度量-当笔流水】本次实还本金 |
| 25 | has_reduction_principle | BIGINT | 【度量-当笔流水】本次减免本金 |
| 26 | real_repay_interest | BIGINT | 【度量-当笔流水】本次实还利息 |
| 27 | has_overdue_interest | BIGINT | 【度量-当笔流水】本次逾期利息 |
| 28 | has_reduction_interest | BIGINT | 【度量-当笔流水】本次减免利息 |
| 29 | real_repay_penalty | BIGINT | 【度量-当笔流水】本次实还罚息 |
| 30 | has_reduction_penalty | BIGINT | 【度量-当笔流水】本次减免罚息 |
| 31 | pre_pmt_fee_repay | BIGINT | 【度量-当笔流水】本次已还提前还款手续费（分） |
| 32 | overdue_days_at_repay | INT | 【度量-当笔流水】还款时的逾期天数 |

### 备注

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 33 | reverse_reason | VARCHAR(64) | 【备注】流水冲正原因 |
| 34 | remark | VARCHAR(64) | 【备注】备注 |

### ETL 字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 35 | created_time | TIMESTAMP | 【ETL字段】创建时间 |
| 36 | updated_time | TIMESTAMP | 【ETL字段】更新时间 |
| 37 | is_active | VARCHAR(2) | 【ETL字段】是否有效 (Y/N) |

### 分区字段

| 序号 | 字段名 | 数据类型 | 描述 |
|:----:|--------|---------|------|
| 38 | ds | VARCHAR(8) | 数据分区字段 |

---

## 关键口径说明

### 主键与粒度

`repay_sk`（还款号）为业务主键，每行代表一笔实际还款流水事件（可能包含多期合并还款）。

### repay_type 还款类型枚举

| 类型码 | 含义 |
|--------|------|
| 11 | 逾期还款 |
| 12 | 正常还款 |
| 13 | 提前还款 |
| 14 | 提前结清 |
| 15 | 延期还款 |

### 时间线说明

一笔还款流水涉及多个时间节点：

1. `customer_actual_repayment_time`：客户实际发起还款的时间
2. `tran_time`：交易时间（支付通道记录）
3. `funder_booking_time`：资方实际入账时间

### 金额关系

| 字段 | 含义 |
|------|------|
| `real_repay_principle` | 实还本金 |
| `has_reduction_principle` | 减免本金 |
| `real_repay_interest` | 实还利息 |
| `has_overdue_interest` | 逾期利息 |
| `has_reduction_interest` | 减免利息 |
| `real_repay_penalty` | 实还罚息 |
| `has_reduction_penalty` | 减免罚息 |

### 冲正说明

- `reverse_record = 'Y'`：该笔流水已被冲正，需排除或关联核实
- 冲正后会产生一笔新的反向流水（repay_sk 不同）

### 与其他表的关系

- 通过 `loan_id` 关联 `dwd_fact_loan_application_di` 获取借据详情
- 通过 `loan_id` 关联 `dim_repay_plan_di` / `dim_repay_plan_latest_df` 对比计划与实际
- 通过 `product_code_sk` 关联产品维表

---

## 数据来源

| 字段类型 | 来源说明 |
|---------|---------|
| repay_sk / seq_no / out_loan_channel_no | 字节/行方还款系统 |
| 借据/客户/产品字段 | 行方核心系统 |
| 时间字段 | 支付通道 + 行方核心系统 |
| 金额字段 | 实际还款交易流水 |
