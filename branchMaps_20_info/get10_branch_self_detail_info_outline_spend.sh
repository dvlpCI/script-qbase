#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-25 13:23:11
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-26 01:35:50
 # @FilePath: get10_branch_self_detail_info_outline_spend.sh
 # @Description: 获取分支概要信息的耗时
### 

while [ -n "$1" ]
do
    case "$1" in
        -outline|--outline-json-string) outlineJsonString=$2; shift 2;;
        --) continue ;;
        *) break ;;
    esac
done

if [ -z "${outlineJsonString}" ]; then
    echo "您的 -outline 参数不能为空，请检查"
    exit 0
fi

weekSpendJsonString=$(echo "${outlineJsonString}" | jq -r ".weekSpend")
if [ -z "${weekSpendJsonString}" ] || [ "${weekSpendJsonString}" == "null" ]; then
    echo "0"
    exit
fi
# echo "您的耗时情况如下: ${weekSpendJsonString}"

weekSpendHour=0
weekSpendCount=$(printf "%s" "${weekSpendJsonString}" | jq -r ".|length")
# echo "您共有 ${weekSpendCount} 次耗时投入"
for((i=0;i<weekSpendCount;i++));
do
    iSpendMap=$(printf "%s" "${weekSpendJsonString}" | jq -r ".[${i}]")
    # echo "$((i+1)). 您的耗时详情 ${iSpendMap}"
    iHour=$(printf "%s" "${iSpendMap}" | jq -r ".hour")
    # echo "$((i+1)). 您的耗时:${iHour}"
    weekSpendHour=$((weekSpendHour+iHour)) # 数字相加
done

echo "${weekSpendHour}"