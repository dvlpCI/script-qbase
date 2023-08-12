#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 14:33:30
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-13 02:40:12
 # @Description: 检查指定Json文件的有效性，是不是合法
 # @example: sh ./json_file_check.sh -checkedJsonF "${Checked_JSON_FILE_PATH}" -scriptResultJsonF "${SCRIPT_RESULT_JSON_FILE}"
###

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function logResultValueToConsole() {
    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"

    echo $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath}

    # 删除文件temp_file_abspath
    rm -rf ${temp_file_abspath}
}


function logResultValueToFile() {
    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"

    echo $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath}

    echo "${YELLOW}更多详情请可点击查看文件:${BLUE}${temp_file_abspath}${NC}"
}

function logResultValueToJsonFile() {
    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    local temp_file_abspath="${TempDir_Absolute}/${now_time}.json"


    echo '{"testResultValue":"'"$1"'"}' > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    # echo $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath}

    echo "${YELLOW}更多详情请可点击查看文件:${BLUE}${temp_file_abspath}${NC}"
}