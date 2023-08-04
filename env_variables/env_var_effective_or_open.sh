#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 02:35:25
# @FilePath: env_variables/env_var_effective_or_open.sh
# @Description: 环境变量文件的操作(生效环境变量文件、打开环境变量文件)
###


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
    fi
}

effectiveEnvironmentVariables "$1"