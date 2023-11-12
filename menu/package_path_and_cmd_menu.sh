#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-12 19:19:53
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-12 22:07:13
 # @FilePath: package_path_and_cmd_menu.sh
 # @Description: 获取 package 的指定 path 或者 cmd 的脚本文件路径
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -file|--file-path) qpackageJsonF=$2; shift 2;;
        -keyType|--keyType) keyType=$2; shift 2;; # path 、 cmd
        -key|--key) specified_value=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done


function get_path_quickCmd() {
    specified_value=$1
    map=$(cat "$qpackageJsonF" | jq --arg value "$specified_value" '.quickCmd[].values[] | select(.cmd == $value)')
    # echo "${YELLOW}1.查找 quickCmd 的 cmd 的结果是:${BLUE} ${map} ${YELLOW}。${NC}"
    if [ -n "${map}" ] && [ "${map}" != "null" ]; then
        relpath=$(echo "${map}" | jq -r '.cmd_script')
    else
        map=$(cat "$qpackageJsonF" | jq --arg value "$specified_value" '.support_script_path[].values[] | select(.cmd == $value)')
        # echo "${YELLOW}2.查找 support_script_path 的 cmd 的结果是:${BLUE} ${map} ${YELLOW}。${NC}"
        if [ -n "${map}" ] && [ "${map}" != "null" ]; then
            relpath=$(echo "${map}" | jq -r '.value')
        else
            map=$(cat "$qpackageJsonF" | jq --arg value "$specified_value" '.support_script_path[].values[] | select(.key == $value)')
            # echo "${YELLOW}3.查找 support_script_path 的 value 的结果是:${BLUE} ${map} ${YELLOW}。${NC}"
             if [ -n "${map}" ] && [ "${map}" != "null" ]; then
                relpath=$(echo "${map}" | jq -r '.value')
            fi
        fi
    fi

    if [ -z "${relpath}" ]; then
        echo "${RED}error: not found specified_value:${BLUE} $specified_value ${NC}"
        # cat "$qpackageJsonF" | jq '.quickCmd'
        # cat "$qpackageJsonF" | jq '.'
        return 1
    fi

    printf "%s" "${relpath}"
}


if [ ! -f "${qpackageJsonF}" ]; then
    echo "${RED}您的${BLUE} -file ${RED}参数值${BLUE} $qpackageJsonF ${RED}指向的文件不存在，请检查。${NC}"
    exit 1
fi

if [ "${keyType}" != "path" ] && [ "${keyType}" != "cmd" ]; then
    echo "${RED}您的${BLUE} -keyType ${RED}参数值${BLUE} ${keyType} ${RED}不是${BLUE} path ${RED}或${BLUE} cmd ${RED}，请检查。${NC}"
    exit 1
fi

relpath=$(get_path_quickCmd "${specified_value}")
if [ $? != 0 ]; then
    echo "$relpath" # 此时此值是错误信息
    exit 1
fi
printf "%s" "${relpath}"