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



input_params_from_file_path=${Example_HomeDir_Absolute}/example_input_getBranchMapsInfoAndNotifiction.json
qbase_execScript_by_configJsonFile_scriptPath=$(qbase -path execScript_by_configJsonFile)
python3 $qbase_execScript_by_configJsonFile_scriptPath  $input_params_from_file_path