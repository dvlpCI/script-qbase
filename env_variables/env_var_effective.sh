#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 02:13:43
# @FilePath: env_variables/env_var_effective.sh
# @Description: 生效环境变量的值
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

    # 应用新的环境变量
    source "$envFile"
}

effectiveEnvironmentVariables