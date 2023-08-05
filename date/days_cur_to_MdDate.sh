#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 18:10:03
 # @Description: 日期的相关计算方法--用来计算提测过程中的各个日期,与当前时间的天数间隔
 # @使用示例: sh ./date/days_cur_to_MdDate.sh --Md_date "12.09"
### 


# 默认参数值
Md_date=""

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --Md_date) Md_date="$2" shift 2;;
        *) echo "未知选项: $1" exit 1;;
        esac
    done

    # 检查必要参数是否提供
    if [ -z "$Md_date" ] ; then
        echo "缺少必要参数！"
        exit 1
    fi
}



# 计算指定日期到当前日期的时间差
function daysCurrentToOld() {
    old_date=$1
    
    old_date_component1=(${old_date//./ })
    old_date_month=${old_date_component1[0]}
    old_date_month=$(echo $old_date_month | sed -r 's/0*([0-9])/\1/')   # shell去除字符串前所有的0，方便做数字的 -eq 比较
    old_date_day=${old_date_component1[1]}
    old_date_day=$(echo $old_date_day | sed -r 's/0*([0-9])/\1/')       # shell去除字符串前所有的0，方便做数字的 -eq 比较
    #echo "旧日期:${old_date_month}月${old_date_day}日"
    

    #[shell去除字符串前所有的0](https://blog.csdn.net/whatday/article/details/88916546)
    cur_date=$(date "+%m.%d %H:%M:%S")
    cur_date_year=$(date "+%Y")
    cur_date_month=$(date "+%m")
    cur_date_month=$(echo $cur_date_month | sed -r 's/0*([0-9])/\1/')   # shell去除字符串前所有的0，方便做数字的 -eq 比较
    cur_date_day=$(date "+%d")
    cur_date_day=$(echo $cur_date_day | sed -r 's/0*([0-9])/\1/')       # shell去除字符串前所有的0，方便做数字的 -eq 比较
    # echo "新日期:${cur_date_month}月${cur_date_day}日"

    if [ $old_date_month -eq $cur_date_month ]; then
        daysResult=$((cur_date_day-old_date_day))
    else
        old_date_month_maxDay=30
        # echo "正在执行(跨月计算):《 $old_date_month_maxDay-$old_date_day+$cur_date_day 》"
        daysResult=$((old_date_month_maxDay-old_date_day+cur_date_day))
    fi
    echo "${daysResult}"
}

parse_arguments "$@" # 解析命令行参数
echo $(daysCurrentToOld "$Md_date")
