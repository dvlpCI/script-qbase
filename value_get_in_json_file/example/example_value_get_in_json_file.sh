#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-28 19:52:28
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-28 23:21:26
 # @Description: 
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
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
BaseFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute%/*}

qbase_function_log_msg_script_path="${BaseFun_HomeDir_Absolute}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultObjectStringToJsonFile
# echo "${YELLOW}引入文件： ${BLUE}${qbase_function_log_msg_script_path}${NC}"

get_script_file_path=${CommonFun_HomeDir_Absolute}/value_get_in_json_file.sh
valueEscape_get_in_json_file_scriptPath=${CommonFun_HomeDir_Absolute}/valueEscape_get_in_json_file.sh

TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/example_value_get_in_json_file.json

function logTitle() {
    printf "${PURPLE}$1${NC}\n"
}


logTitle "1.get1"
echo $(sh ${get_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_string")

logTitle "2.get2"
echo $(sh ${get_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_array_1_new")

logTitle "3.get3"
echo $(sh ${get_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_result")



logTitle "4.获取json值并转义"
# sh ${valueEscape_get_in_json_file_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "data2"
result213=$(sh ${valueEscape_get_in_json_file_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "data2")
if [ $? != 0 ]; then
    echo "错误❌..3"
fi
logResultValueToFile "${result213}"



