#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-19 15:19:16
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-19 15:49:29
 # @FilePath: example_git_info.sh
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

log_title "1"

currentBranchResult=$(git branch --show-current) # 获取当前分支
if [ $? != 0 ]; then
    echo "${currentBranchResult}"
    exit 1
fi
branch_name=${currentBranchResult}
# branch_name="origin/version/v1.6.0_0925"
branch_name=$(git branch -r | grep "${branch_name}")
if [ $? != 0 ]; then
    echo "${branch_name}"
    exit 1
fi
if [ -z "$branch_name" ]; then
    echo "温馨提示:您的 $branch_name 分支不存在"
    exit 1
fi




# 获取当前日期
current_date=$(date "+%Y-%m-%d")
start_date=$(date -v-1w -j -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
# end_date=${current_date}
# echo "今天前一周的日期: $start_date"



branch_info=$(git log -1 --pretty=format:'{"branch_name":"%s","author":"%an","last_committer":"%cn"}' "$branch_name" --since="$start_date")
if [ $? != 0 ]; then
    echo "${branch_info}"
    exit 1
fi
if [ -z "$branch_info" ]; then
    echo "温馨提示:您的 $branch_name 分支在 $start_date 之后没有提交记录"
    exit 1
fi
echo "branch_info : $branch_info"
exit
