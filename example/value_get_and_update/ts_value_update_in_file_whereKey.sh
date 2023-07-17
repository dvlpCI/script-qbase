#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-27 22:37:52
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-07-17 22:57:43
 # @FilePath: example/value_get_and_update/ts_value_update_in_file_whereKey.sh
 # @Description: 测试文本更改
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function logTitle() {
    printf "${PURPLE}------- $1 -------${NC}\n"
}




# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
Base_HomeDir_Absolute=${Example_HomeDir_Absolute%/*}

TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/data/tsdata_update_text_variable.json
get_script_file_path=${Base_HomeDir_Absolute}/value_get_in_json_file/value_get_in_json_file.sh
update_script_file_path=${Base_HomeDir_Absolute}/value_update_in_file/update_json_file_singleString.sh

logTitle "get1"
echo $(sh ${get_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_string")

logTitle "get2"
echo $(sh ${get_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_array")

logTitle "get3"
echo $(sh ${get_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_result")


# logTitle "update1"
# sh ${update_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_string" -v "这是新的更新说明"

logTitle "update2"
sh ${update_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_array" -v "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]" -verbose "true"


# logTitle "update3"
# sh ${update_script_file_path} -jsonF "${TEST_JSON_FILE_PATH}" -k "data_result.local_backup_dir" -v "本地备份路径"