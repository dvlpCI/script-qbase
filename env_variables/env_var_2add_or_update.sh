#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 02:16:30
# @FilePath: env_variables/env_var_2add_or_update.sh
# @Description: 环境变量值的更新(没有该key则创建，已有该key则是更新，来避免重复多行)
# @Example: sh env_variables/env_var_2add_or_update.sh -envVariableKey TEST_KEY -envVariableValue test_value
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
show_usage="args: [-envVariableKey, -envVariableValue, -envFileAutoOpen]\
                                  [--environment-variable-key=, --environment-variable-value=, --environment-file-auto-open]"

ENVIRONMENT_AUTO_OPEN=true
while [ -n "$1" ]
do
        case "$1" in
                -envVariableKey|--environment-variable-key) ENVIRONMENT_Variable_KEY=$2; shift 2;;
                -envVariableValue|--environment-variable-value) ENVIRONMENT_Variable_VALUE=$2; shift 2;;
                -envFileAutoOpen|--environment-file-auto-open) 
                    # 抑制 open（打开编辑器）：避免多次打开的时候，看不到最后一次的最新内容，而是第一次打开时候的内容
                    # 如添加前会先添加占位，然后才修改占位，如果占位时候就打开，则修改完占位后打开的看到还是旧值，因为根本没再打开
                    ENVIRONMENT_AUTO_OPEN=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

if [ "$ENVIRONMENT_AUTO_OPEN" != false ]; then
    ENVIRONMENT_AUTO_OPEN=true
fi

log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

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

        # 关键：添加环境变量前，确保有换行
        # 检查文件是否为空
        if [ -s "$envFile" ]; then
            # 获取文件最后一个字符
            last_char=$(tail -c 1 "$envFile")
            # 如果最后一个字符不是换行符，就添加一个
            if [ "$last_char" != "" ] && [ "$last_char" != "\n" ]; then
                echo "" >> "$envFile"
            fi
        fi
        echo "" >> "$envFile"
        echo "# ============== qbase 插入的环境变量 =============" >> "$envFile"
        
        # 添加新的环境变量
        # echo "正在执行命令(添加环境变量值):《 echo \"export $var_name=\"$var_value\"\" >> \"$envFile\" 》"
        echo "export $var_name=\"$var_value\"" >> "$envFile"
    fi

    # 应用新的环境变量
    source "$envFile"

    # 抑制 open（打开编辑器）：避免多次打开的时候，看不到最后一次的最新内容，而是第一次打开时候的内容
    # 如添加前会先添加占位，然后才修改占位，如果占位时候就打开，则修改完占位后打开的看到还是旧值，因为根本没再打开
    if [ "${ENVIRONMENT_AUTO_OPEN}" == true ]; then
        sleep 1 #延迟1秒，避免数据还没写完
        open "$envFile"
        log_color_info "${NC}已为你自动打开 open ${envFile} ${NC}"
    fi
}

updateEnvValueWithKey "${ENVIRONMENT_Variable_KEY}" "${ENVIRONMENT_Variable_VALUE}"


