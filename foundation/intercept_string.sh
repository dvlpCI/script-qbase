#!/bin/bash

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -string|--string) originString=$2; shift 2;;
        -maxLength|--maxLength) maxLength=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done


function truncate_string() {
    local str="$1"                # 输入的字符串
    local maxLength="$2"          # 最大长度

    local length=${#str}        # 获取字符串的长度

    local suffixString=".........【您的文本太长，已为你截断】" # 超过最大长度时要添加的后缀
    local suffixLength=${#suffixString}
    
    if (( length > maxLength && maxLength > suffixLength )); then
        local lastTruncationLength=$maxLength-$suffixLength
        local truncated_str=${str:0:lastTruncationLength}
        result_str="$truncated_str$suffixString" # 添加后缀 
    else
        result_str="$str"
    fi
    echo "$result_str"
}

if [ -z "${originString}" ]; then
    echo "${RED} intercept_string 缺少${BLUE} -string ${RED}参数，请检查${NC}"
    exit_script
fi

if [ -z "${maxLength}" ]; then
    echo "${RED}缺少${BLUE} -maxLength ${RED}参数，请检查${NC}"
    exit_script
fi

truncate_string "$originString" "$maxLength"

