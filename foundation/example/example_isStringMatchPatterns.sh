#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:43:04
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-12-05 14:02:39
 # @Description: 测试中文转拼音
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

qbase_isStringMatchPatterns_scriptPath=${CategoryFun_HomeDir_Absolute}/isStringMatchPatterns.sh

inputString="v1.2.0_0811"
patternsJson='[
    "v1.2.0_0811",
    "version/*",
    "v2*"
]'

inputString="pack"
patternsJson='[
    "df*"
]'
patternsString=$(echo "${patternsJson}" | jq -r ".[]")
echo "patternsString=${patternsString}"
matchPattern=$(sh "$qbase_isStringMatchPatterns_scriptPath" -inputString ${inputString} -patternsString "${patternsString}")
if [ $? != 0 ]; then
    echo "${matchPattern}"
    exit 1
fi
echo "${GREEN}恭喜您的${BLUE} ${inputString} ${GREEN}符合:${BLUE} ${matchPattern} ${GREEN}.${NC}"