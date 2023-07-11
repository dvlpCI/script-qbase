#!/bin/bash
:<<!
对字符串变量按指定要求转义 转义换行符/换行符
SpecialCharacterType="EscapeCharacter" # NewlineCharacter / EscapeCharacter
# OnlyEscapeFirst="false"
sh ./update_text_variable.sh -willUpdateText "${WillUpdateText}" -specialCharType "${SpecialCharacterType}" -onlyEscapeFirst "${OnlyEscapeFirst}"
!

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}

# shell 参数具名化
show_usage="args: [-willUpdateText, -specialCharType, -onlyEscapeFirst]\
                                  [--will-update-text=, --special-character-type=, --only-escape-first=]"

while [ -n "$1" ]
do
    case "$1" in
        -willUpdateText|--will-update-text) WillUpdateText=$2; shift 2;;
        -specialCharType|--special-character-type) SpecialCharacterType=$2; shift 2;;
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


# 测试修改JSON文件中的值
function tsFun_updateJsonFileValue() {
    TEST_JSON_FILE_PATH=${CommonFun_HomeDir_Absolute}/test/tsdata_update_text_variable.json

    # 注意📢1：使用jquery取值的时候，不要使用 jq -r 属性，否则会导致以下问题：
    # 导致的问题①：取出来的数值换行符\n会直接换行，导致要echo输出的时候，无法转义成功

    # 且注意📢2：因为上面使用jquery取值的时候没使用 jq -r 属性，所以得到的值会保留前后的双引号。
    # 所以，修改值的时候，需要先去除前后的双引号再去操作字符串(如果你只是读取值，而不用修改，可以直接使用)。
    
    fileValue_origin_withDoubleQuote=$(cat ${TEST_JSON_FILE_PATH} | jq ".data2")
    #echo "======fileValue_origin_withDoubleQuote=${fileValue_origin_withDoubleQuote}"
    echo "======fileValue_origin_withDoubleQuote_echo=${fileValue_origin_withDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
    
    fileValue_origin_noDoubleQuote=${fileValue_origin_withDoubleQuote: 1:${#fileValue_origin_withDoubleQuote}-2}
    #echo "======fileValue_origin_noDoubleQuote=${fileValue_origin_noDoubleQuote}"
    echo "======fileValue_origin_noDoubleQuote_echo   =${fileValue_origin_noDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
    
    fileValue_origin_noDoubleQuote+="\n结束"
    BRANCH_OUTLINES_LOG_JSON="{\"data3\": \"${fileValue_origin_noDoubleQuote}\"}"
    sh "${CommonFun_HomeDir_Absolute}/update_json_file.sh" -f "${TEST_JSON_FILE_PATH}" -k "test_result" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
    # 注意📢4：使用jquery取值的时候，不要使用 jq -r 属性
    cat ${TEST_JSON_FILE_PATH} | jq '.test_result' | jq '.data3'


    echo "：：：：：：结论(非常重要)：：：：：：使用jquery取值的不要使用 jq -r 属性，且需要先去除前后的双引号再去操作字符串。这样的好处有：\
    好处①：设置 json 的时候，仍然保留原本的在前后都要加双引号的操作。\
    好处②：当要对所取到的值修改后再更新回json文件时候，可以成功"
}



if [ "${SpecialCharacterType}" == "NewlineCharacter" ]; then
    escapeNewlineCharacter "${WillUpdateText}" "${OnlyEscapeFirst}"
elif [ "${SpecialCharacterType}" == "EscapeCharacter" ]; then 
    escapeEscapeCharacter "${WillUpdateText}" "${OnlyEscapeFirst}"
else
    echo "❌Error:您要转义的字符串类型${SpecialCharacterType}指定错误，不是 NewlineCharacter 或 EscapeCharacter ,请重新输入"
    exit 1
fi

