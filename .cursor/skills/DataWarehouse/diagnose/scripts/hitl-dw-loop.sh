#!/usr/bin/env bash
# Human-in-the-loop DW 诊断循环。
# 复制此文件，编辑下方的步骤，然后运行它。
# Agent 执行脚本，人类在终端按提示操作。
#
# 用法：
#   bash hitl-dw-loop.sh
#
# 两个辅助函数：
#   step "<instruction>"          → 显示操作指令，等待 Enter
#   capture VAR "<question>"      → 显示问题，读取回答写入 VAR
#
# 结束时，捕获的值以 KEY=VALUE 格式打印，供 Agent 解析。

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [完成后按 Enter] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- 在此编辑 ---------------------------------------------------------

step "在调度平台（Airflow / DolphinScheduler / 自研）找到出问题的任务，记录任务名和失败时间。"

capture TASK_NAME "任务名称是什么？"
capture TASK_DATE "出问题的业务日期（ds）是多少？如：20250609"
capture ERROR_MSG "任务的错误日志关键内容是什么？（直接粘贴最后 10 行，或填 '无日志'）"

step "在数据平台执行以下 SQL，确认当日分区是否存在（替换表名和日期）：\n  SHOW PARTITIONS dwd_xxx_di PARTITION(ds=20250609);\n  SHOW PARTITIONS dws_xxx_di PARTITION(ds=20250609);\n  SHOW PARTITIONS ads_xxx_di PARTITION(ds=20250609);"

capture PARTITION_CHECK "各层分区是否都存在？哪个分区缺失？（填：全部存在 / 缺失 XXX 表的 ds=XXX）"

step "执行以下 SQL 采样，检查数据量级和空值情况：\n  SELECT COUNT(*) AS total, COUNT(col1) AS non_null, COUNT(DISTINCT id) AS uniq\n  FROM dwd_xxx_di WHERE ds='20250609';"

capture DATA_SAMPLE "数据采样结果如何？（粘贴 COUNT 结果）"

step "对比正常分区（前一天或上周同期）：\n  SELECT COUNT(*) FROM dwd_xxx_di WHERE ds='20250608';\n  SELECT COUNT(*) FROM dwd_xxx_di WHERE ds='20250602';"

capture NORMAL_COMPARE "对比结果正常吗？差异多大？（填：正常 / 异常，差异描述）"

# --- 在此之上编辑 ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'TASK_NAME=%s\n' "$TASK_NAME"
printf 'TASK_DATE=%s\n' "$TASK_DATE"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
printf 'PARTITION_CHECK=%s\n' "$PARTITION_CHECK"
printf 'DATA_SAMPLE=%s\n' "$DATA_SAMPLE"
printf 'NORMAL_COMPARE=%s\n' "$NORMAL_COMPARE"
