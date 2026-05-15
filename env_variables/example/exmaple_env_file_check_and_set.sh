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

qbase_env_file_check_and_set_scriptPath=${qbase_homedir_abspath}/env_variables/env_file_check_and_set.sh


function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

log_title "1"
sh ${qbase_env_file_check_and_set_scriptPath} \
    --env-name "QTOOL_DEAL_PROJECT_CHOICES_PATH" \
    --env-descript qtool可操作的项目列表 \
    --env-var-placeholder "your_project_choices_json_file" \
    --env-reference-json-file-example /Users/qian/Project/Github/script-branch-json-file/test/tool_choice.json \
    --output-filename-if-copy tool_choice.json