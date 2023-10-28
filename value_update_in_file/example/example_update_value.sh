#!/bin/bash
###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-02-27 21:38:10
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 00:47:38
# @FilePath: /AutoPackage-CommitInfo/bulidScriptCommon/upload/upload_result_log.sh
# @Description: 上传结束的各种log获取方法
###


JQ_EXEC=$(which jq)

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CategoryFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..

function add_json_value() {
    update_key=$1
    update_value=$2

    echo "${YELLOW}正在执行(添加操作)：《 ${BLUE}python3 ${CategoryFun_HomeDir_Absolute}/update_json_file.py -jsonF $json_file -k \"$update_key\" -v \"${update_value}\" ${YELLOW}》${NC}"
    python3 ${CategoryFun_HomeDir_Absolute}/update_json_file.py -jsonF $json_file -k "$update_key" -v "${update_value}" #-change-type "cover"
    if [ $? != 0 ]; then
        return 1
    fi
    echo "${GREEN}恭喜:《 ${PURPLE}cat ${json_file} | jq \".${update_key}\" | jq '.' ${GREEN}》如下:${NC}"
    cat ${json_file} | jq ".${update_key}" | jq '.'
}

function cover_json_value() {
    update_key=$1
    update_value=$2

    echo "${YELLOW}正在执行(覆盖操作)：《 ${BLUE}python3 ${CategoryFun_HomeDir_Absolute}/update_json_file.py -jsonF $json_file -k \"$update_key\" -v \"${update_value}\" -change-type \"cover\" ${YELLOW}》${NC}"
    python3 ${CategoryFun_HomeDir_Absolute}/update_json_file.py -jsonF $json_file -k "$update_key" -v "${update_value}" -change-type "cover"
    if [ $? != 0 ]; then
        return 1
    fi
    echo "${GREEN}恭喜:《 ${PURPLE}cat ${json_file} | jq \".${update_key}\" | jq '.' ${GREEN}》如下:${NC}"
    cat ${json_file} | jq ".${update_key}" | jq '.'
}


# 读取input.json文件内容
json_file=${CurrentDIR_Script_Absolute}/data/example_value_update_in_file.json

key1="branch_info_result.Notification.current.slice"
key2="branch_info_result.Notification.lastOnline.slice"
keyall=branch_info_result.Notification.all.slice

log_title "1.1.添加"
add_json_value "${key1}" "这是添加的字符串" 

log_title "1.2.覆盖（TODO:暂未实现）"
cover_json_value "${key2}" "这是覆盖的字符串" "cover"

log_title "2.往不存在的key中添加"
add_json_value "${keyall}" "12345"