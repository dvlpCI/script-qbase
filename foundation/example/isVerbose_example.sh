#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-15 21:11:32
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-16 01:44:54
 # @FilePath: ./foundation/isVerbose_example.sh
 # @Description: 测试字符串是否符合 verbose
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



function isVerbose() {
    last_arg=$1
    verboseStrings=("verbose" "-verbose" "--verbose") # 输入哪些字符串算是想要日志
    # 判断最后一个参数是否是 verbose
    if [[ " ${verboseStrings[*]} " == *" $last_arg "* ]]; then
        echo "verbose✅:${last_arg}"
    else
        echo "verbose❌:${last_arg}"
    fi
}

logTitle "1.测试字符串是否符合 verbose"
isVerbose "aaa"
isVerbose "verbose"
isVerbose "-verbose"
isVerbose "--verbose"