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

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -file|--file-path) qpackageJsonF=$2; shift 2;;
        -key|--key) specified_value=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done



if [ ! -f "${qpackageJsonF}" ]; then
    echo "${RED}您的${BLUE} -file ${RED}参数值${BLUE} $qpackageJsonF ${RED}指向的文件不存在，请检查。${NC}"
    exit 1
fi



map=$(cat "$qpackageJsonF" | jq --arg value "$specified_value" '.quickCmd[].values[], .support_script_path[].values[] | select(.key == $value)')
debug_log "${YELLOW}1.从 quickCmd 和 support_script_path 中查找 key 为 $specified_value 的结果是:${BLUE} ${map} ${YELLOW}。${NC}"
if [ -z "${map}" ] || [ "${map}" == "null" ]; then
    echo "${RED}Error:在 quickCmd 和 support_script_path 的 values 下都没有 key 为${BLUE} $specified_value ${RED}的map,请检查。 ${NC}"
    exit 1
fi

relpath=$(echo "${map}" | jq -r '.rel_path')
if [ -z "${relpath}" ] || [ "${relpath}" == "null" ]; then
    echo "${RED}Error:您的 ${map} 缺失描述脚本相对位置的 rel_path 属性值。请检查 ${NC}"
    # cat "$qpackageJsonF" | jq '.quickCmd'
    # cat "$qpackageJsonF" | jq '.'
    exit 1
fi


printf "%s" "${relpath}"