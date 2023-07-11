#!/bin/bash
:<<!
对字符串变量按指定要求转义 转义换行符/换行符
source ./function_update_text_variable.sh
📢：因为不能使用echo作为函数的输出值(使用的话会导致白转换了)，所以修改文本变量只能用source来进行上下文赋值
!

# 按指定要求转义转义换行符(①替换所有,②只换第一个)
function escapeEscapeCharacter() {
    WillUpdateText=$1
    shouldOnlyFirst=$2

   # 将\n替换成真正的\n，而n不能替换
   if [ "${shouldOnlyFirst}" == "true" ]; then
       # echo "只替换第一个换行符，而不是替换所有"
       escapeEscapeCharacterResult=${WillUpdateText/\\/\\\\}
   else
        # echo "替换所有换行符，而不是只替换第一个"
        escapeEscapeCharacterResult=${WillUpdateText//\\/\\\\}
    fi 
}


# 按指定要求转义换行符(①替换所有,②只换第一个)
function escapeNewlineCharacter() {
    WillUpdateText=$1
    shouldOnlyFirst=$2

   # 将\n替换成真正的\n，而n不能替换
   if [ "${shouldOnlyFirst}" == "true" ]; then
       # echo "只替换第一个换行符，而不是替换所有"
       escapeNewlineCharacterResult=${WillUpdateText/\\n/\\\\n}
   else
       # echo "替换所有换行符，而不是只替换第一个"
        escapeNewlineCharacterResult=${WillUpdateText//\\n/\\\\n}
    fi 
}


# 从指定文件中，获取指定key的值，且该值转义所有换行符
function getValueFromFile_escapeAllNewlineCharacter() {
    JSON_FILE_PATH=$1
    VALUE_KEY=$2

    # 注意使用jquery取值的时候，不要使用 jq -r 属性，否则取出来的数值\n会直接换行，导致无法转义成功
    fileValueWithoutEscape=$(cat ${JSON_FILE_PATH} | jq ".${VALUE_KEY}")
    fileValueWithEscapeNewlineCharacterResult=${fileValueWithoutEscape//\\n/\\\\n}
}


