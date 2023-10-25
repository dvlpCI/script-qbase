#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-24 14:21:59
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-25 12:02:26
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

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)" # 当前脚本所在目录
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
# test_python_path=$(qbase -path excel_row_data_compare)
test_python_path="${CurrentDIR_Script_Absolute}/excel_row_data_compare.py"
if [ $? != 0 ]; then
    echo "-path 路径获取失败"
    exit 1
fi


# echo "$@"

allArgArray=($@)
# _verbose_log "😄😄😄哈哈哈 ${allArgArray[*]}"
allArgCount=${#allArgArray[@]}
for ((i=0;i<allArgCount;i+=1))
{
    currentArg=${allArgArray[i]}
    

    # 使用正则表达式匹配数值模式
    isNumber=$(echo "$currentArg" | grep -E "^-?[0-9]+(\.[0-9]+)?$")
    if [[ $currentArg =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        isNumber="true"
    else
        isNumber="false"
    fi
    
    if [[ "${currentArg:0:1}" == "-" ]]; then
        isMayBeArgKey="true"
    else
        isMayBeArgKey="false"
    fi
    echo "======isMayBeArgKey:${isMayBeArgKey}----isNumber:${isNumber}============${currentArg}"
    

    # if [[ "${isMayBeArgKey}" == "true" ]] && [[ "${isNumber}" != "true" ]]; then
    #     # 是 argKey 的时候，直接使用自身
    #     quickCmdArgs[${#quickCmdArgs[@]}]="${currentArg}"
    # else
        quickCmdArgs[${#quickCmdArgs[@]}]=${currentArg}
    # fi
}
# echo "脚本所附带的参数如下: ${quickCmdArgs[*]}"

echo "${YELLOW}正在执行脚本(比较excel行数据):《${BLUE} python3.9 \"$test_python_path\" ${quickCmdArgs[*]} ${YELLOW}》${NC}"
python3.9 "$test_python_path" ${quickCmdArgs[*]} # 不能使用 "${quickCmdArgs[*]}" 否则会多出一对双引号
# python3.9 "$test_script_path" -filePath "$filePath" -startRowNo "$startRowNo" -idColumnNo "$idColumnNo" -valueColumnNo "$valueColumnNo" -valueDiffColumnNo "$valueDiffColumnNo" -successMS "$successMS" -failureMS "$failureMS" -resultSaveToFilePath "$resultSaveToFilePath"