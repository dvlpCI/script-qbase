#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-28 21:16:57
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 00:21:27
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

function logTitle() {
    printf "${PURPLE}$1${NC}\n"
}



# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..


update_text_variable_scriptPath=${CommonFun_HomeDir_Absolute}/update_text_variable.sh


function logString() {
    printf "${GREEN}替换的结果(printf)是:${BLUE} \n%s \n${NC}" "$1"
    echo "${GREEN}替换的结果(echo)是:${BLUE} \n$1 ${NC}"
}




function updateText_base() {
    logTitle "1.直接使用原始命令"
    WillUpdateText="第1.1行n第1.1行\n第1.2行n第1.2行\n\n第2.1行n第2.1行\n第2.2行n第2.2行"
    echo "-------------1.1.①直接使用原始命令，直接输出(替换所有)"
    logString ${WillUpdateText//\\n/\\\\n}
    echo "-------------1.1.②直接使用原始命令，赋值变量后输出(替换所有)"
    result112=${WillUpdateText//\\n/\\\\n}
    logString "${result112}"
}


updateText_base


echo "            --------           "
logTitle "2.使用封装的方法"
WillUpdateText="第1.1行n第1.1行\n第1.2行n第1.2行\n\n第2.1行n第2.1行\n第2.2行n第2.2行"
SpecialCharacterType="EscapeCharacter" # NewlineCharacter / EscapeCharacter
OnlyEscapeFirst="false"
result113=$(sh ${update_text_variable_scriptPath} -willUpdateText "${WillUpdateText}" -specialCharType "${SpecialCharacterType}" -onlyEscapeFirst "${OnlyEscapeFirst}")
logString "${result113}"


