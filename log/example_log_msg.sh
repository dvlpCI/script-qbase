#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 14:33:30
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-13 16:12:48
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


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..


source ${CurrentDIR_Script_Absolute}/function_log_msg.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}


str1="❓【33天<font color=warning>@test1</font>】<font color=warning>dev_login_err</font>:<font color=comment>[02.09已提测]</font><font color=comment>@producter1</font><font color=comment>@test1</font>"
str2="<font color=warning>①登录失败错误提示</font>"


log_title "1------------singleString------------"
log_title "logResultValueToConsole"
logResultValueToConsole "${str1}\n${str2}"
if [ $? != 0 ]; then
  exit 1
fi



log_title "logResultValueToFile"
logResultValueToFile "${str1}\n${str2}"
if [ $? != 0 ]; then
  exit 1
fi


log_title "logResultValueToJsonFile ✅"
logResultValueToJsonFile "${str1}\n${str2}"
if [ $? != 0 ]; then
  exit 1
fi


log_title "logResultValueToJsonFile ✅"
logResultValueToJsonFile "${str1}\n${str2}"
if [ $? != 0 ]; then
  exit 1
fi



echo "\n\n"
log_title "4------------objectString------------"
objectString="{\"a\":\"${str1}\n${str2}\"}"

log_title "logResultObjectStringToJsonFile"
logResultObjectStringToJsonFile "${objectString}"
if [ $? != 0 ]; then
  exit 1
fi



log_title "logResultObjectStringToJsonFile_byJQ"
logResultObjectStringToJsonFile_byJQ "${objectString}"
if [ $? != 0 ]; then
  exit 1
fi

