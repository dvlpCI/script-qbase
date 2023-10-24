#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-24 14:21:59
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-10-24 22:20:14
 # @Description: 
### 

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)" # 当前脚本所在目录
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
test_script_path="${CommonFun_HomeDir_Absolute}/excel_row_data_compare.py"

projectAbsRootPath="$CurrentDIR_Script_Absolute"

filePath="${projectAbsRootPath}/APP加载时长.xlsx"
startRowNo="2"
idColumnNo="1"
valueColumnNo="5"
valueDiffColumnNo="7"
successMS="-20" # 新版本数值降低了20
failureMS="50" # 新版本数值增加了100
resultSaveToFilePath="${projectAbsRootPath}/APP加载时长.xlsx"

cd "$projectAbsRootPath" || exit

python3.9 "$test_script_path" -filePath "$filePath" -startRowNo "$startRowNo" -idColumnNo "$idColumnNo" -valueColumnNo "$valueColumnNo" -valueDiffColumnNo "$valueDiffColumnNo" -successMS "$successMS" -failureMS "$failureMS" -resultSaveToFilePath "$resultSaveToFilePath"