#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 14:33:30
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-10 18:31:11
 # @Description: 检查指定Json文件的有效性，是不是合法
 # @example: sh ./json_file_check.sh -checkedJsonF "${Checked_JSON_FILE_PATH}"
###

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


while [ -n "$1" ]
do
        case "$1" in
                -checkedJsonF|--checked-json-file-path) Checked_JSON_FILE_PATH=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done


#[在shell脚本中验证JSON文件的语法](https://qa.1r1g.com/sf/ask/2966952551/)
function check_jsonFile_valid() {
    Check_Json_FILE_PATH=$1
    
    if [ -z "${Check_Json_FILE_PATH}" ]; then
        echo "执行命令时缺失填写要检查文件的入参，请检查！"
        return 1
    fi
    
    if [ ! -f "${Check_Json_FILE_PATH}" ]; then
        echo "您的 ${Check_Json_FILE_PATH} 文件不存在，请检查！"
        return 1
    fi
    
    if [ -z "$(cat "${Check_Json_FILE_PATH}")" ]; then
        echo "您的 ${Check_Json_FILE_PATH} 文件内容为空，请检查！"
        return 1 # 为空是失败
    fi

    JsonPPString=$(cat "${Check_Json_FILE_PATH}" | json_pp)
    if [ $? != 0 ]; then
        echo "您的 ${Check_Json_FILE_PATH} 文件不是标准的json格式，请检查！"
        return 1
    fi
    JsonPPLength=${#JsonPPString}
    #echo "JsonPPLength=${JsonPPLength}"
    if [ "${JsonPPLength}" == 0 ]; then
        echo "您的 ${Check_Json_FILE_PATH} 文件不是标准的json格式，请检查！"
        return 1
    fi

    return 0
}



check_jsonFile_valid "${Checked_JSON_FILE_PATH}"