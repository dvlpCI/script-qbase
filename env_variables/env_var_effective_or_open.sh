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


function effectiveEnvironmentVariables() {
    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        envFile=$HOME/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        envFile=$HOME/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    if [ "$1" == "open" ]; then
        open "${envFile}"
    else
        source "${envFile}"
        log_color_info "${GREEN}恭喜您：执行《${BLUE} source \"${envFile}\" ${GREEN}》成功，环境变量已重新生效，请关闭当前终端窗口后重新打开。${NC}"
    fi
}

effectiveEnvironmentVariables "$1"