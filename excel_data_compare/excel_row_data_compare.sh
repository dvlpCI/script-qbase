#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-24 14:21:59
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-25 17:28:06
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

# 从外部传入的值，用于决定使用哪个命令
pythonCommand="$1"
if [[ $pythonCommand != python* ]]; then
    echo "${RED}使用的 python 命令${BLUE} ${pythonCommand} ${RED}不能为空，请填写，一般为 python3.9。${NC}"
    exit 1
fi
shift 1 #第一个参数已提取，为后面正确取到 $@ ，这里需要跳过第一个参数

allArgArray=($@)
# _verbose_log "😄😄😄哈哈哈 ${allArgArray[*]}"
allArgCount=${#allArgArray[@]}
for ((i=0;i<allArgCount;i+=1))
{
    currentArg=${allArgArray[i]}
    quickCmdArgs[${#quickCmdArgs[@]}]=${currentArg}
    

    # 使用正则表达式匹配数值模式
    # isNumber=$(echo "$currentArg" | grep -E "^-?[0-9]+(\.[0-9]+)?$")
    # if [[ $currentArg =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    #     isNumber="true"
    # else
    #     isNumber="false"
    # fi
    
    # if [[ "${currentArg:0:1}" == "-" ]]; then
    #     isMayBeArgKey="true"
    # else
    #     isMayBeArgKey="false"
    # fi
    # echo "======isMayBeArgKey:${isMayBeArgKey}----isNumber:${isNumber}============${currentArg}"
    
    # if [[ "${isMayBeArgKey}" == "true" ]] && [[ "${isNumber}" != "true" ]]; then
    #     # 是 argKey 的时候，直接使用自身
    #     quickCmdArgs[${#quickCmdArgs[@]}]="${currentArg}"
    # else
    #     quickCmdArgs[${#quickCmdArgs[@]}]=${currentArg}
    # fi
}
# echo "脚本所附带的参数如下: ${quickCmdArgs[*]}"

# 使用选定的 Python 命令执行脚本
echo "${YELLOW}正在执行脚本(比较excel行数据):《${BLUE} $pythonCommand \"$test_python_path\" ${quickCmdArgs[*]} ${YELLOW}》${NC}"
# exit
$pythonCommand "$test_python_path" ${quickCmdArgs[*]} # 不能使用 "${quickCmdArgs[*]}" 否则会多出一对双引号
# python3.9 "$test_script_path" -filePath "$filePath" -startRowNo "$startRowNo" -idColumnNo "$idColumnNo" -valueColumnNo "$valueColumnNo" -valueDiffColumnNo "$valueDiffColumnNo" -successMS "$successMS" -failureMS "$failureMS" -resultSaveToFilePath "$resultSaveToFilePath"