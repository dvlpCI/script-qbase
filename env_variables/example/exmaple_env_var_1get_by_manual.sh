#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:19:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:48:11
 # @Description: 通过人工交互方式对指定环境变量进行修改(方式 ①从文件中选择[如果有传文件的话]或者 ②从终端输入）
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qbase_env_var_1get_by_manual_scriptPath=${qbase_homedir_abspath}/env_variables/env_var_1get_by_manual.sh

log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

ENV_NAME="QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH"
ENV_KEY_FILE=$qbase_homedir_abspath/example_env_keys_menu.json

checkResult=$(sh $qbase_env_var_1get_by_manual_scriptPath --env-name "${ENV_NAME}" --env-keys-file "${ENV_KEY_FILE}")
if [ $? -ne 0 ]; then
    echo "${checkResult}"
    exit 1
fi
jsonData=$(printf "%s" "${checkResult}" | jq -r '.')
log_color_info "${YELLOW}${jsonData}${NC}"

status_type=$(echo "${checkResult}" | jq -r '.status_type')
message=$(echo "${checkResult}" | jq -r '.message')
if [ "${status_type}" != "env_val_get_success" ]; then
    log_color_info "${message}"
    exit 0
fi
response=$(echo "${checkResult}" | jq -r '.response')
selected_env_key=$(echo "${response}" | jq -r '.env_key')
selected_env_value=$(echo "${response}" | jq -r '.env_value')
log_color_info "${PURPLE}\n============== 对为环境变量 key 选中的值，进行结构检查 ==================${NC}"
log_color_info "${GREEN}选中的环境变量及其值为${BLUE} ${selected_env_key}:${selected_env_value} ${GREEN}。${NC}"

log_color_info "${PURPLE}\n============== 对为环境变量 key 选中的值，进行更新 ==================${NC}"
# log_color_info "正在执行命令《 sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey \"${selected_env_key}\" -envVariableValue \"${selected_env_value}\" --environment-file-auto-open false 》"
# sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "${selected_env_key}" -envVariableValue "${selected_env_value}" --environment-file-auto-open false
# if [ $? != 0 ]; then
#     open_sysenv_file
#     exit 1
# fi
# log_color_info "已更新环境变量 ${selected_env_key} = ${YELLOW}${selected_env_value}${NC}"

# open_sysenv_file
# sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh effective