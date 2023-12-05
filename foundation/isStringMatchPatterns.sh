#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-24 13:55:31
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-24 14:47:32
 # @Description: 检查字符串是否符合某个正则
### 

# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -inputString|--input-string) input_string=$2; shift 2;;
        -patternsString|--patternsString) patternsString=$2; shift 2;;   # 要舍弃哪些分支(可以是分支名feature/test1、也可以是分支规则test/*)
        --) break ;;
        *) break ;;
    esac
done

if [ -z "${patternsString}" ]; then
    echo "您的 -patternsString 参数不能为空，请检查。"
    exit 1
fi
# patternArray=(${patternsString})
# readarray -t patternArray <<< "$patternsString"           # 非Mac上
IFS=$'\n' read -d '' -ra patternArray <<< "$patternsString" # Mac上 字符串转数组。这样，* 将作为数组的一个元素而不会被展开
# echo "patternsString======${patternsString}"
# echo "patternArray======${patternArray[*]}"
patternCount=${#patternArray[@]}

# input_string="test/test1"
# patternArray=("unuse/" "test/*")

# 判断分支名是否满足任意一个模式
matchedToPattern=""
for((i=0;i<patternCount;i++));
do
    pattern=${patternArray[i]}
    # echo "$((i+1)).pattern======${pattern}"
    if [[ $pattern == *"*" ]]; then
        nosuffixstar_pattern=${pattern%"*"}
        if [[ $input_string == $nosuffixstar_pattern* ]]; then  # 判断$input_string是否以$pattern开头
            matchedToPattern=$pattern
            break
        fi
    else
        if [[ $input_string == "$pattern" ]]; then
            matchedToPattern=$pattern
            break
        fi
    fi
done


# 输出结果
if [ -n "${matchedToPattern}" ]; then
    # echo "${input_string} 分支名满足正则数组中的 ${matchedToPattern} 模式"
    printf "%s" "${matchedToPattern}"
    exit 0
else
    echo "很抱歉:您的 ${input_string} 分支名不满足自定义的正则数组中的任何模式(所有模式如下: ${patternArray[*]} )"
    exit 1
fi