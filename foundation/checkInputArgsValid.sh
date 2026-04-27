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
# 判断参数格式：不能有两个连续的短参数（以单个-开头）
# 长参数（--开头）可以连续
inputArgArray=("$@")  # 注意：要用括号和引号，避免参数中的空格被拆分
# echo "inputArgArray=${inputArgArray[*]}, inputArgCount=${#inputArgArray[@]}"
inputArgsErrorMessage=""

for ((i = 0; i < ${#inputArgArray[@]}; i++)); do
    current_string=${inputArgArray[i]}
    
    # 检查是否是短参数（以单个-开头，但不是--开头）
    if [[ $current_string == -?* && $current_string != --* ]]; then
        next_index=$((i + 1))
        if [[ $next_index -lt ${#inputArgArray[@]} ]]; then
            next_arg=${inputArgArray[next_index]}
            # 检查下一个参数是否是短参数
            if [[ $next_arg == -?* && $next_arg != --* ]]; then
                inputArgsErrorMessage="您传入的参数不能存在两个连续的短参数（以单个-开头），请检查 ${current_string} 和 ${next_arg} 之间是不是缺少参数值。"
                break
            fi
        fi
    fi
done

if [ -n "${inputArgsErrorMessage}" ]; then
    echo "${inputArgsErrorMessage}"
    exit 1
fi
