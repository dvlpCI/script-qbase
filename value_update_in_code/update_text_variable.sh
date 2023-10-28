#!/bin/bash
:<<!
对字符串变量按指定要求转义 转义换行符/换行符
SpecialCharacterType="EscapeCharacter" # NewlineCharacter / EscapeCharacter
# OnlyEscapeFirst="false"
sh ./update_text_variable.sh -willUpdateText "${WillUpdateText}" -specialCharType "${SpecialCharacterType}" -onlyEscapeFirst "${OnlyEscapeFirst}"
!

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"


# shell 参数具名化
show_usage="args: [-willUpdateText, -specialCharType, -onlyEscapeFirst]\
                                  [--will-update-text=, --special-character-type=, --only-escape-first=]"

while [ -n "$1" ]
do
    case "$1" in
        -willUpdateText|--will-update-text) WillUpdateText=$2; shift 2;;
        -specialCharType|--special-character-type) SpecialCharacterType=$2; shift 2;; # NewlineCharacter / EscapeCharacter
        -onlyEscapeFirst|--only-escape-first) OnlyEscapeFirst=$2; shift 2;;
        --) break ;;
        *) echo $1,$2,$show_usage; break ;;
    esac
done



# 按指定要求转义转义换行符(①替换所有,②只换第一个)
function escapeEscapeCharacter() {
    WillUpdateText=$1
    shouldOnlyFirst=$2

   # 将\n替换成真正的\n，而n不能替换
   if [ "${shouldOnlyFirst}" == "true" ]; then
       # echo "只替换第一个换行符，而不是替换所有"
       echo ${WillUpdateText/\\/\\\\}
   else
        # echo "替换所有换行符，而不是只替换第一个"
        echo ${WillUpdateText//\\/\\\\}
    fi 
}


# 按指定要求转义换行符(①替换所有,②只换第一个)
function escapeNewlineCharacter() {
    WillUpdateText=$1
    shouldOnlyFirst=$2

   # 将\n替换成真正的\n，而n不能替换
   if [ "${shouldOnlyFirst}" == "true" ]; then
       # echo "只替换第一个换行符，而不是替换所有"
       echo ${WillUpdateText/\\n/\\\\n}
   else
       # echo "替换所有换行符，而不是只替换第一个"
       echo ${WillUpdateText//\\n/\\\\n}
    fi 
}


if [ "${SpecialCharacterType}" == "NewlineCharacter" ]; then
    escapeNewlineCharacter "${WillUpdateText}" "${OnlyEscapeFirst}"
elif [ "${SpecialCharacterType}" == "EscapeCharacter" ]; then 
    escapeEscapeCharacter "${WillUpdateText}" "${OnlyEscapeFirst}"
else
    echo "${RED}❌Error:您没有设置要转义的字符串类型，或者设置错误。SpecialCharacterType=${BLUE} ${SpecialCharacterType} ${RED}指定错误。① 若不转义，请不要执行此脚本；② 若要转义换行符，请使用${BLUE} NewlineCharacter ${RED}；③ 若要转义转义换行符，请使用${BLUE} EscapeCharacter ${RED}。${NC}"
    exit 1
fi

