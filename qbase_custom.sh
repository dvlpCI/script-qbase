#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-09 22:56:13
# @Description: 执行自定义的命令菜单（若不存在会引导添加）
# @Exampel: sh qbase_custom.sh
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

# 日志信息输出到终端（规范 2.2：日志输出用 >&2，保持返回值干净）
log_color_info() { printf "%b\n" "$1" >&2; }

# 检查jq是否安装
if ! command -v jq &> /dev/null; then
    echo ""
    echo "${RED}Error:jq is not installed. Please install it with command:${BLUE} brew install jq${NC}"
    exit 1
fi

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CurrentDIR_Script_Absolute} # 使用 %/* 方法可以避免路径上有..

# 快速检查是否已设置环境变量
# log_color_info "正在执行命令《 sh $qbase_homedir_abspath/env_variables/env_file_check_and_set.sh --env-name QBASE_CUSTOM_MENU --env-descript "自定义命令菜单" --env-var-placeholder "your_custom_menu_json_file" --env-reference-json-file-example "$qbase_homedir_abspath/menu/example/custom_command_menu_example.json" --output-filename-if-copy "qbase_custom_menu.json" 》 "
checkResult=$(sh $qbase_homedir_abspath/env_variables/env_file_check_and_set.sh \
    --env-name QBASE_CUSTOM_MENU \
    --env-descript "自定义命令菜单" \
    --env-var-placeholder "your_custom_menu_json_file" \
    --env-reference-json-file-example "$qbase_homedir_abspath/menu/example/custom_command_menu_example.json" \
    --output-filename-if-copy "qbase_custom_menu.json"
)
if [ $? -ne 0 ]; then
    echo "${checkResult}"
    exit 2
fi
QBASE_CUSTOM_MENU_VALUE=${checkResult} # 注意：此处一定要获取更新后的值，不然一定是执行 env_file_check_and_set.sh 前的旧值
log_color_info "${GREEN}您的环境变量及其值 QBASE_CUSTOM_MENU : \"${QBASE_CUSTOM_MENU_VALUE}\" ${NC}"

# echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file \"${QBASE_CUSTOM_MENU_VALUE}\" -categoryType custom -execChoosed "true"》"
sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file "${QBASE_CUSTOM_MENU_VALUE}" -categoryType "custom" -execChoosed "true"



