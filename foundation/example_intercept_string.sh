#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-09-09 12:59:37
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-14 01:24:40
 # @FilePath: /example_intercept_string.sh
 # @Description: 测试字符串长度截取
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

# 延迟20毫秒的函数
function delay() {
  local delay=1
  sleep "$delay"
}


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# parent_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
interceptString_script_path=${CurrentDIR_Script_Absolute}/intercept_string.sh


log_title "1.获取字符串的长度"
string1="1234567890一二三四五六七八九十"
length=${#string1}

echo "截取前字符串长度为: $length"
if (( length > 12 )); then
    # 截取前20个字符
    truncated_str=${string1:0:12}
    # 获取截取后字符串的长度
    truncated_length=${#truncated_str}
    echo "截取后字符串长度为: $truncated_length"
else
    echo "字符串长度不大于12，无需截取"
fi


echo "\n"
log_title "2.截取字符串"
function test_truncate_string() {
    local str="1234567890一二三四五六七八九十1234567890一二三四五六七八九十1234567890一二三四五六七八九十"
    local maxLength=30          # 最大长度

    local length=${#str}        # 获取字符串的长度

    local suffixString=".........【您的文本太长，已为你截断】" # 超过最大长度时要添加的后缀
    local suffixLength=${#suffixString}
    
    local result_str=""
    echo "🚗🚗🚗 截取前，您的长度是$length"
    if (( length > maxLength && maxLength > suffixLength )); then
        local lastTruncationLength=$maxLength-$suffixLength
        local truncated_str=${str:0:lastTruncationLength}
        result_str="$truncated_str$suffixString" # 添加后缀    
    else
        result_str="$str"
    fi

    local resultLength=${#result_str}        # 获取字符串的长度
    echo "🚗🚗🚗 截取并拼接后，您的长度是 $resultLength\n$result_str"
}
test_truncate_string
if [ $? -ne 0 ]; then
    error_exit_script
fi



echo "\n"
log_title "3.截取字符串(使用本地function方法)"
function truncate_string() {
    local str="$1"                # 输入的字符串
    local maxLength="$2"          # 最大长度

    local length=${#str}        # 获取字符串的长度

    local suffixString=".........【您的文本太长，已为你截断】" # 超过最大长度时要添加的后缀
    local suffixLength=${#suffixString}
    
    if (( length > maxLength && maxLength > suffixLength )); then
        local lastTruncationLength=$maxLength-$suffixLength
        local truncated_str=${str:0:lastTruncationLength}
        result_str="$truncated_str$suffixString" # 添加后缀 
    else
        result_str="$str"
    fi
    echo "$result_str"

}
string3="1234567890一二三四五六七八九十1234567890一二三四五六七八九十1234567890一二三四五六七八九十"
echo "🚗🚗🚗 截取前，您的长度是$length"
result_str=$(truncate_string "$string3" 30)
resultLength=${#result_str}        # 获取字符串的长度
echo "🚗🚗🚗 截取并拼接后，您的长度是 $resultLength\n$result_str"
if [ $? -ne 0 ]; then
    error_exit_script
fi


echo "\n"
log_title "4.截取字符串(使用shell文件)"
echo "🚗🚗🚗 截取前，您的长度是$length"
result_str=$(sh $interceptString_script_path -string "$string3" -maxLength 30)
resultLength=${#result_str}        # 获取字符串的长度
echo "🚗🚗🚗 截取并拼接后，您的长度是 $resultLength\n$result_str"
if [ $? -ne 0 ]; then
    error_exit_script
fi

