#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-27 22:37:52
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 21:27:07
 # @FilePath: example/value_get_and_update/ts_value_update_in_file_whereKey.sh
 # @Description: 测试文本更改
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function logTitle() {
    printf "${PURPLE}$1${NC}\n"
}




# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*}

TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/ts_value_update_in_file_whereKey.json
update_json_file_singleString_scriptPath=${CategoryFun_HomeDir_Absolute}/update_json_file_singleString.sh




# 测试修改JSON文件中的值
function tsFun_updateJsonFileValue() {
    # 注意📢1：使用jquery取值的时候，不要使用 jq -r 属性，否则会导致以下问题：
    # 导致的问题①：取出来的数值换行符\n会直接换行，导致要echo输出的时候，无法转义成功

    # 且注意📢2：因为上面使用jquery取值的时候没使用 jq -r 属性，所以得到的值会保留前后的双引号。
    # 所以，修改值的时候，需要先去除前后的双引号再去操作字符串(如果你只是读取值，而不用修改，可以直接使用)。
    
    fileValue_origin_withDoubleQuote=$(cat ${TEST_JSON_FILE_PATH} | jq ".data2")
    #echo "======fileValue_origin_withDoubleQuote=${fileValue_origin_withDoubleQuote}"
    # echo "======fileValue_origin_withDoubleQuote_echo=${fileValue_origin_withDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
    
    fileValue_origin_noDoubleQuote=${fileValue_origin_withDoubleQuote: 1:${#fileValue_origin_withDoubleQuote}-2}
    #echo "======fileValue_origin_noDoubleQuote=${fileValue_origin_noDoubleQuote}"
    # echo "======fileValue_origin_noDoubleQuote_echo   =${fileValue_origin_noDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
    
    fileValue_origin_noDoubleQuote+="\n结束3"
    BRANCH_OUTLINES_LOG_JSON="{\"data3\": \"${fileValue_origin_noDoubleQuote}\"}"
    sh "${CategoryFun_HomeDir_Absolute}/update_json_file.sh" -f "${TEST_JSON_FILE_PATH}" -k "test_result" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
    # 注意📢4：使用jquery取值的时候，不要使用 jq -r 属性
    cat ${TEST_JSON_FILE_PATH} | jq '.test_result' | jq '.data3'


    echo "：：：：：：结论(非常重要)：：：：：：使用jquery取值的不要使用 jq -r 属性，且需要先去除前后的双引号再去操作字符串。这样的好处有：\
    好处①：设置 json 的时候，仍然保留原本的在前后都要加双引号的操作。\
    好处②：当要对所取到的值修改后再更新回json文件时候，可以成功"
}



# tsFun_updateJsonFileValue
stringValue="https://www.xcxwo.com/app/qrcodeHistory/xxx"
dicValue='{
    "c": "这是嵌套key + json字典"
}'
arrayValue="[{\"dev_script_pack\":\"打包提示优化1234\"},{\"dev_fix\":\"修复\"}]"




logTitle "0.测试嵌套key"
new_value="修改后的值34422"
# new_value=$dicValue
# jq '.target.b.c = "修改后的值"' "$TEST_JSON_FILE_PATH" > temp.json && mv temp.json "$TEST_JSON_FILE_PATH"
sh ${update_json_file_singleString_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "target.b.c" -v "${new_value}"


logTitle "1.单层key"
logTitle "1.1. 单层key + 字符串"
sh ${update_json_file_singleString_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "singleKey1_str" -v "${stringValue}"


logTitle "1.2. 单层key + json字典"
singleKey="singleKey2_dic"
sh ${update_json_file_singleString_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "singleKey2_dic" -v "${dicValue}"


logTitle "1.3. 单层key + json数组"
# 使用 jq 修改 JSON 文件
# jq '.singleKey2_dic = '"[{\"dev_script_pack\":\"打包提示优化3224\"},{\"dev_fix\":\"修复\"}]" "$TEST_JSON_FILE_PATH" > temp.json && mv temp.json "$TEST_JSON_FILE_PATH"
sh ${update_json_file_singleString_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "singleKey3_arr" -v "${arrayValue}"




echo "\n"
logTitle "2.嵌套key"
logTitle "2.1. 嵌套key + 字符串"
nestingKey="nestingKey1_string.a.b.c"
nestingValue="这是嵌套key + 字符串"
sh ${update_json_file_singleString_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "${nestingKey}" -v "${nestingValue}"

logTitle "2.2. 嵌套key + json字典"
nestingKey="nestingKey2_dic.a.b"
nestingValue='{
    "c": "这是嵌套key + json字典"
}'
sh ${update_json_file_singleString_scriptPath} -jsonF "${TEST_JSON_FILE_PATH}" -k "${nestingKey}" -v "${nestingValue}"
