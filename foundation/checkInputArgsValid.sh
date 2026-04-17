#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-15 21:11:32
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-17 23:46:46
 # @FilePath: checkInputArgsValid.sh
 # @Description: 检查输入参数的有效性
### 

# 判断字符串 -a a -b b -c -d ，如果字符串是以-开头，则其下个字符串不能以-开头
inputArgArray=($@)
# echo "inputArgArray=${inputArgArray[*]}, inputArgCount=${#inputArgArray[@]}"
inputArgsErrorMessage=""
for ((i = 0; i < ${#inputArgArray[@]}; i++)); do
    current_string=${inputArgArray[i]}
    if [[ $current_string == -* ]]; then
        next_index=$((i + 1))
        if [[ $next_index -lt ${#inputArgArray[@]} && ${inputArgArray[next_index]} == -* ]]; then
            next_arg=${inputArgArray[next_index]}
            inputArgsErrorMessage="您传入的参数不能存在两个连续的以-开头的字符串，请检查 ${current_string} 和 ${next_arg} 之间是不是少了空字符串。"
            break
        fi
    fi
done

if [ -n "${inputArgsErrorMessage}" ]; then
    echo "${inputArgsErrorMessage}"
    exit 1
fi
