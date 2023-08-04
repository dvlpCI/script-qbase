#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 02:16:30
# @FilePath: env_variables/env_var_add_or_update.sh
# @Description: 更新环境变量的值(没有该key则创建，已有该key则是更新，来避免重复多行)
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出
versionCmdStrings=("--version" "-version" "-v" "version")


# shell 参数具名化
show_usage="args: [-envVariableKey, -envVariableValue]\
                                  [--environment-variable-key=, --environment-variable-value=]"

while [ -n "$1" ]
do
        case "$1" in
                -envVariableKey|--environment-variable-key) ENVIRONMENT_Variable_KEY=$2; shift 2;;
                -envVariableValue|--environment-variable-value) ENVIRONMENT_Variable_VALUE=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done


function updateEnvValueWithKey() {
    # 设置要添加或更新的环境变量
    var_name=$1
    var_value=$2


    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        envFile=$HOME/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        envFile=$HOME/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi


    # 使用 sed 命令更新或添加环境变量
    if grep -q "^export $var_name=" "$envFile"; then
        # 如果变量已经存在，则更新其值
        ReplaceText="^export $var_name=.*"
        ToText="export $var_name=$var_value"
        # echo "正在执行命令(更新环境变量值的文本):《 sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n}#g\" ${envFile} 》"
        sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n}#g" ${envFile} # 摘自之前已实现的 sed_text.sh
    else
        # 如果变量不存在，则添加新的环境变量
        # echo "正在执行命令(添加环境变量值):《 echo \"export $var_name=\"$var_value\"\" >> \"$envFile\" 》"
        echo "export $var_name=\"$var_value\"" >> "$envFile"
    fi

    # 应用新的环境变量
    source "$envFile"

    sleep 1 #延迟1秒，避免数据还没写完
    open "$envFile"
}

updateEnvValueWithKey "${ENVIRONMENT_Variable_KEY}" "${ENVIRONMENT_Variable_VALUE}"


