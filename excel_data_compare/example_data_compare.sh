#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-24 14:21:59
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-24 20:02:55
 # @Description: 
### 

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)" # 当前脚本所在目录
test_script_path="${CurrentDIR_Script_Absolute}/data_compare.py"

projectAbsRootPath="$CurrentDIR_Script_Absolute"

filePath="${projectAbsRootPath}/APP加载时长.xlsx"
startRowNo="2"
idColumnNo="1"
valueColumnNo="5"
valueDiffColumnNo="7"
successMS="-20" # 新版本数值降低了20
failureMS="50" # 新版本数值增加了100

cd "$projectAbsRootPath" || exit

python3.9 "$test_script_path" -filePath "$filePath" -startRowNo "$startRowNo" -idColumnNo "$idColumnNo" -valueColumnNo "$valueColumnNo" -valueDiffColumnNo "$valueDiffColumnNo" -successMS "$successMS" -failureMS "$failureMS"