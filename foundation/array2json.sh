#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-15 21:11:32
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-16 00:51:41
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



# array=("abc" " " "./branch_quickcmd/getBranchMapsAccordingToBranchNames.sh" efg)
array=($1) # 字符串转成数组

jsonString=""
jsonString+="["
count=${#array[@]}
for ((i=0;i<count;i++))
do
    element=${array[i]}
    # echo "✅ $((i+1)). element=${element}"
    
    if [ "${i}" -gt 0 ]; then
        jsonString+=", "
    fi
    jsonString+="\"${element}\""
done
jsonString+="]"


# newCount=$(printf "%s" "$jsonString" | jq -r '.|length')
# echo "newCount=${newCount}"
printf "%s" "${jsonString}"
# printf "%s" "$jsonString" | jq -r '.'


