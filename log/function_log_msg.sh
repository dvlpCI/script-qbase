#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 14:33:30
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-13 16:13:49
 # @Description: 检查指定Json文件的有效性，是不是合法
 # @example: 
###

# 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。
# 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。
# 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 延迟20毫秒的函数
function delay() {
  local delay=1
  sleep "$delay"
}

# 背景：当变量含有特殊字符（如反斜杠 \n、\\）时，echo 会错误解释它们。
function logResultValueToConsole() {
    delay # 延迟,避免其他地方调用该方法，导致输出到同文件名上

    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"

    printf "%s" $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath}

    # 删除文件temp_file_abspath
    rm -rf ${temp_file_abspath}

    # TODO: 将以上代码全去掉，直接用 printf "%s" "$1" 应该就能正确输出原始值，不需要临时文件。临时文件的方式确实有点过度。
    # printf "%s" "$1"
}



# 用途：将结果信息【覆盖方式的】写到执行脚本同级目录下的一个新建json文件（当前时间.json）里，然后输出文件内容，并打印文件路径到控制台
# 参数：
# - 要输入要文件的信息参数: 需要
# - 文件参数:             不需要，统一为（当前时间.json）
# 引用该方法的正式脚本文件目前有: 暂无
# TODO: 因为 > 是覆盖，>> 是追加，且日志文件写入方式一般是追加而不是覆盖，所以建议改为 >>  ${temp_file_abspath}。
function logResultValueToFile() {
    delay # 延迟,避免其他地方调用该方法，导致输出到同文件名上

    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"

    printf "%s" $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath}

    echo "${YELLOW}\n要更多详情请可点击查看文件:${BLUE}${temp_file_abspath}${NC}"
}

function logResultValueToJsonFile() {
    delay # 延迟,避免其他地方调用该方法，导致输出到同文件名上
    
    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="
    
    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"


    printf "%s" '{"testResultValue":"'"$1"'"}' > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    # echo $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath} | jq '.'

    echo "${YELLOW}更多详情请可点击查看文件:${BLUE} ${temp_file_abspath} ${YELLOW}。${NC}"
}

function logResultObjectStringToJsonFile() {
    delay # 延迟,避免其他地方调用该方法，导致输出到同文件名上

    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"


    printf "%s" '{"testResultValue":'$1'}' > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    # # echo $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath} | jq '.'

    echo "${YELLOW}更多详情请可点击查看文件:${BLUE}${temp_file_abspath}${NC}"
}


function logResultObjectStringToJsonFile_byJQ() {
    delay # 延迟,避免其他地方调用该方法，导致输出到同文件名上
    
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"

    
    printf "%s" "{}" | jq  --argjson jsonString "$1" \
        '.testResultValue_jq = $jsonString' >> ${temp_file_abspath}   # 这是覆盖，用=，不用+=
    cat ${temp_file_abspath}

    echo "${YELLOW}更多详情请可点击查看文件:${BLUE}${temp_file_abspath}${NC}"
}