#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-27 09:49:03
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-12-18 10:45:11
 # @Description: 
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

# 获取当前脚本所在目录
# current_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# qbase_homedir_abspath=$(dirname $(dirname "$current_dir"))
# echo "qbase_homedir_abspath=${qbase_homedir_abspath}"
# exit 0

# 执行过程中要求输入的《您输入的分支map数组所在的json文件路径》值，一般为版本json文件，如本example中的 v1.7.2_1114.json 完整路径
input_params_from_file_path=${Example_HomeDir_Absolute}/example_input_getBranchMapsInfoAndNotifiction.json
qbase_execScript_by_configJsonFile_scriptPath=$($qbase_homedir_abspath/qbase.sh -path execScript_by_configJsonFile)
# qbase_execScript_by_configJsonFile_scriptPath=$(qbase -path execScript_by_configJsonFile)
# echo "======================${qbase_execScript_by_configJsonFile_scriptPath}======================"
python3 $qbase_execScript_by_configJsonFile_scriptPath  $input_params_from_file_path