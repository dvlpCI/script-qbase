#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-09 23:01:35
# @FilePath: env_variables/env_var_effective_or_open.sh
# @Description: 环境变量文件的操作(生效环境变量文件、打开环境变量文件)
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
log_color_info() {
    printf "%b\n" "$1" >&2
}


# 打开环境变量的那个文件（本方法只负责打开，省去用户自己找）
function open_env_file() {
    local envFile=$1
    if [ -z "${envFile}" ]; then
        echo "环境变量文件参数一定不能为空，请去底层修改" >&2
        return 1
    fi

    open "${envFile}"
    if [ $? -ne 0 ]; then
        log_color_info "${YELLOW}WARNING：执行《${BLUE} open \"${envFile}\" ${GREEN}》失败，环境变量文件打开失败，请可手动执行。${NC}"
    fi
}

function effectiveEnvironmentVariables() {
    # 获取调用者的信息
    # local caller_func=${FUNCNAME[1]}  # 调用者的函数名
    # local caller_script=${BASH_SOURCE[1]}   # 调用者的脚本路径
    # local caller_name="${caller_script##*/}"  # 调用者的脚本名（不含路径）：删除最后一个 / 之前的所有内容
    # local caller_line=${BASH_LINENO[0]}  # 调用行号
    # echo "调用信息: 函数[$caller_func] 脚本[$caller_script] 行[$caller_line]" >&2

    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        envFile=$HOME/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        envFile=$HOME/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    if [ "${env_file_action}" == "open" ]; then
        open_env_file "${envFile}"
    elif [ "${env_file_action}" == "effective_open" ]; then
        # 生效所有环境变量（subprocess 中 source，只影响子进程，不影响父 shell）
        source "${envFile}"
        open_env_file "${envFile}"
    else
        # 生效所有环境变量（subprocess 中 source，只影响子进程，不影响父 shell）
        source "${envFile}"
        log_color_info "${GREEN}恭喜您：执行《${BLUE} source \"${envFile}\" ${GREEN}》成功，环境变量已重新生效，请关闭当前终端窗口后重新打开。${NC}"
    fi
}

env_file_action="$1"
effectiveEnvironmentVariables