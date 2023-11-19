#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-06 01:42:06
 # @Description: 时间计算的demo
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}



log_title "1"
# 获取当前日期
current_date=$(date "+%Y-%m-%d")

# 计算前一周的起始日期和结束日期
start_date=$(date -v-1w -j -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
end_date=$(date -v-1d -j -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d")

# 打印前一周日期范围
echo "今天的上周日期: $start_date"
echo "今天的昨天日期: $end_date"


log_title "计算提测过程中的各个日期,与当前时间的天数间隔"
daysResult=$(sh ${CurrentDIR_Script_Absolute}/days_cur_to_MdDate.sh --Md_date "12.09")
if [ $? != 0 ]; then
    error_exit_script
fi
echo "时间相差天数: ${daysResult}"




log_title "获取新时间(通过旧时间的加减)"
oldDate=$(date "+%Y-%m-%d %H:%M:%S")
newDateResult=$(sh ${CurrentDIR_Script_Absolute}/calculate_newdate.sh --old-date "$oldDate" --add-value "10")
if [ $? != 0 ]; then
    error_exit_script
fi
echo "旧时间: ${oldDate}"
echo "新时间: ${newDateResult}"

function addOneSecond() {
    oldDate=$1
    newDateResult=$(sh ${CurrentDIR_Script_Absolute}/calculate_newdate.sh --old-date "$oldDate" --add-value "1")
    if [ $? != 0 ]; then
        error_exit_script
    fi
    echo "旧时间: ${oldDate}"
    echo "新时间: ${newDateResult}"
}

function test_addOneSecond() {
    echo "--------------- 有0的时候 ---------------"
    addOneSecond "2023-03-10 14:32:08"

    echo "\n"
    echo "--------------- 秒位+1不够60 ---------------"
    addOneSecond "2022-10-20 17:19:47"

    echo "\n"
    echo "--------------- 秒位+1超过60 ---------------"
    addOneSecond "2022-10-20 17:19:59"

    echo "\n"
    echo "--------------- 秒位+1超过60 & 分位+1超过60  ---------------"
    addOneSecond "2022-10-20 17:59:59"
}
test_addOneSecond