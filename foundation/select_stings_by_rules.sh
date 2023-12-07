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

# readarray -t originStringArray <<< "$originStrings"           # 非Mac上
IFS=$'\n' read -d '' -ra originStringArray <<< "$originStrings" # Mac上 字符串转数组。这样，* 将作为数组的一个元素而不会被展开
# echo "originStrings======${originStrings}"
# echo "originStringArray======${originStringArray[*]}"

originStringCount=${#originStringArray[@]}
# echo "$(basename "$0")脚本: originStrings=${originStrings}"

matchPatternStringJsonString="["
unmatchPatternStringJsonString="["
for ((i=0;i<originStringCount;i+=1))
{
    iOriginString=${originStringArray[i]}
    iOriginString=$(echo "$iOriginString" | sed "s/(//g" | sed "s/)//g" | sed "s/,//g") #去除左右括号
    # echo "$((i+1)) iOriginString=${iOriginString}"
    
    matchPatter=$(sh $qbase_isStringMatchPatterns_scriptPath -inputString "${iOriginString}" -patternsString "${patternsString}")
    if [ $? == 0 ]; then # 被匹配的过滤掉
        if [ "${matchPatternStringJsonString}" != "[" ]; then
            matchPatternStringJsonString+=", "
        fi
        iJson='{"originString":"'"${iOriginString}"'", "matchPattern":"'"${matchPatter}"'"}'
        matchPatternStringJsonString+="${iJson}"
    else
        if [ "${unmatchPatternStringJsonString}" != "[" ]; then
            unmatchPatternStringJsonString+=", "
        fi
        iJson='{"originString":"'"${iOriginString}"'"}'
        unmatchPatternStringJsonString+="${iJson}"
    fi
}
matchPatternStringJsonString+="]"
unmatchPatternStringJsonString+="]"
# echo "----------match=${matchPatternStringJsonString}, unmatch=${unmatchPatternStringJsonString}"
stringMatchResultJsonString='{
    "matchs":'${matchPatternStringJsonString}',
    "unmatchs":'${unmatchPatternStringJsonString}'
}'
printf "%s" "${stringMatchResultJsonString}"
