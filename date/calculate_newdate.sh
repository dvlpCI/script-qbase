#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 18:09:54
 # @Description: 日期的相关计算方法--用来获取新时间(通过旧时间的加减)
 # @使用示例: sh ./date/calculate_newdate.sh --old-date $old_date --add-value "1" --add-type "second"
### 


# 默认参数值
old_date=""
add_value=0
add_type=""

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --old-date) old_date="$2" shift 2;;
        --add-value) add_value="$2" shift 2;;
        --add-type) add_type="$2" shift 2;;
        *) echo "未知选项: $1" exit 1;;
        esac
    done

    # 检查必要参数是否提供
    if [ -z "$old_date" ] ; then
        echo "缺少必要参数！"
        exit 1
    fi
}



function addOneSecond() {
    dateString=$1
    add_value=$2

    # echo "旧日期:${dateString}"
    if [ -z "${dateString}" ]; then
        echo "❌Error: $FUNCNAME 请输入要对哪个日期添加一秒的日期入参"
        return 1
    fi

    #    dateString_S=${dateString##*:} # 取最后的component
    #    dateString_YmdHM=${dateString%:*} # 取最后component前的所有
    #    dateString_S_new=$((dateString_S+1))
    #    dateString_S_new=`printf "%02d\n" "${dateString_S_new}"`
    #    newDateResultString="${dateString_YmdHM}:${dateString_S_new}"

    onlySecond=${dateString:0-2:2}
    onlyMinute=${dateString:0-5:2}
    onlyHour=${dateString:0-8:2}
    exceptHourMinuteSecond=${dateString:0:10}

    # 去除0
    onlySecond=$(echo "$onlySecond" | sed -r 's/0*([0-9])/\1/') # shell去除字符串前所有的0，方便做数字的 -eq 比较
    onlyMinute=$(echo "$onlyMinute" | sed -r 's/0*([0-9])/\1/') # shell去除字符串前所有的0，方便做数字的 -eq 比较
    onlyHour=$(echo "$onlyHour" | sed -r 's/0*([0-9])/\1/')     # shell去除字符串前所有的0，方便做数字的 -eq 比较

    if [ "${onlySecond}" -lt 59 ]; then
        onlySecond=$((onlySecond + $add_value))
        # 不够两位，自动补0
        onlySecond=$(echo "${onlySecond}" | awk '{printf("%02d\n",$0)}')
        onlyMinute=$(echo "${onlyMinute}" | awk '{printf("%02d\n",$0)}') # 避免之前的0不见了，这里将其补充
    else
        if [ "${onlyMinute}" -lt 59 ]; then
            onlySecond=00
            onlyMinute=$((onlyMinute + 1))
            onlyMinute=$(echo "${onlyMinute}" | awk '{printf("%02d\n",$0)}')
        else
            onlySecond=00
            onlyMinute=00
            onlyHour=$((onlyHour + 1))
            onlyHour=$(echo "${onlyHour}" | awk '{printf("%02d\n",$0)}')
        fi
    fi

    onlyHour=$(echo "${onlyHour}" | awk '{printf("%02d\n",$0)}') # 避免之前的0不见了，这里将其补充
    
    newDateResultString="${exceptHourMinuteSecond} ${onlyHour}:${onlyMinute}:${onlySecond}"
    # echo "新日期:${newDateResultString}"
    echo "${newDateResultString}"
}

parse_arguments "$@" # 解析命令行参数
echo $(addOneSecond "$old_date" "$add_value")
