#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-15 21:11:32
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-16 00:19:07
 # @FilePath: ./foundation/json2array.sh
 # @Description: 将 json 字符串转为 array 数组
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function logTitle() {
    printf "${PURPLE}$1${NC}\n"
}

logTitle "1.字符串中有多个空格"
arrayString="element1   element3"

# 使用括号解析方法
array=($arrayString)
printf "()方法打印的结果：%s\n" "${array[*]}"

# 使用IFS分割方法
IFS='  ' read -r -a array <<< "$arrayString"
printf "IFS方法打印的结果：%s\n" "${array[@]}"

echo "\n"
logTitle "2"
array=("element1" " " "element3")
printf "第一次打印的结果:%s\n" "${array[*]}"
arrayString=$(printf "%s" "${array[*]}")
printf "第二次打印的结果:%s\n" "${arrayString}"
array=($arrayString)
printf "第三次打印的结果:%s\n" "${array[*]}"