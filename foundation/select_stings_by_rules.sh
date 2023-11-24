#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-24 14:13:17
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-24 14:45:26
 # @Description: 
### 

CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_isStringMatchPatterns_scriptPath=${qbase_homedir_abspath}/foundation/isStringMatchPatterns.sh


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -originStrings|--originStrings) originStrings=$2; shift 2;;
        -patternsString|--patternsString) patternsString=$2; shift 2;;  # 要舍弃哪些分支(可以是分支名feature/test1、也可以是分支规则test/*)
        -returnIsMatch|--returnIsMatch) returnIsMatch=$2; shift 2;;     # 不设置默认返回匹配的结果(true:返回匹配的结果，false返回不匹配的结果)
        --) break ;;
        *) break ;;
    esac
done

if [ -z "${patternsString}" ]; then
    echo "您的 -patternsString 参数不能为空，请检查。"
    exit 1
fi

# originStrings="test/test1 test1/test1"
# patternsString="unuse/* test/*"

originStringArray=($originStrings)
originStringCount=${#originStringArray[@]}

resultStringArray=()
for ((i=0;i<originStringCount;i+=1))
{
    iOriginString=${originStringArray[i]}
    iOriginString=$(echo "$iOriginString" | sed "s/(//g" | sed "s/)//g" | sed "s/,//g") #去除左右括号
    # iOriginString=${iOriginString##*/} # 取最后的component
    #echo "$((i+1)) iOriginString=${iOriginString}"
    
    matchPatter=$(sh $qbase_isStringMatchPatterns_scriptPath -inputString "${iOriginString}" -patternsString "${patternsString}")
    isMatch=$?
    if [ "${returnIsMatch}" == "false" ]; then  # 返回不匹配的，匹配的过滤掉
        if [ ${isMatch} == 0 ]; then # 被匹配的过滤掉
            continue
        fi
        resultStringArray[${#resultStringArray[@]}]=${iOriginString}
    else
        if [ ${isMatch} != 0 ]; then # 不匹配的过滤掉
            continue
        fi
        resultStringArray[${#resultStringArray[@]}]=${iOriginString}
    fi
}

#[shell 数组去重](https://www.jianshu.com/p/1043e40c0502)
resultStringArray=($(awk -v RS=' ' '!a[$1]++' <<< ${resultStringArray[@]}))
printf "%s" "${resultStringArray[*]}"
