#!/bin/bash
# sh ./test_json_file_check.sh
:<<!
测试检查指定Json文件的有效性，是不是合法
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute}/..
bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#echo "bulidScriptCommon_dir_Absolute=${bulidScriptCommon_dir_Absolute}"

#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute}/..
#CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#CommonFun_HomeDir_Absolute2=${CommonFun_HomeDir_Absolute3%/*}
#CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}

echo "---------------------------------------------1"
#'{"data1": "第1行\n第2行"}'

echo "-----------------------1.1 json_pp 检查带换行符的【字符串String】失败❌"
CheckJsonString='{"data1": "第1行\n第2行"}'
JsonPPString=$(echo "${CheckJsonString}" | json_pp) # json_pp 检查带换行符的【字符串String】失败❌
JsonPPLength=${#JsonPPString}
if [ ${JsonPPLength} == 0 ]; then
    echo "json_pp 检查带换行符的【字符串String】失败❌！"
else
    echo "json_pp 检查带换行符的【字符串String】成功✅！"
fi


echo "-----------------------1.2 json_pp 检查带换行符的【文件File】成功✅"
Check_Json_FILE_PATH="${CurrentDIR_Script_Absolute}/test_data.json"
JsonPPString=$(cat ${Check_Json_FILE_PATH} | json_pp)   # json_pp 检查带换行符的【文件File】成功✅
JsonPPLength=${#JsonPPString}
if [ ${JsonPPLength} == 0 ]; then
    echo "json_pp 检查带换行符的【文件File】失败❌！"
else
    echo "json_pp 检查带换行符的【文件File】成功✅！"
fi



echo "\n"
echo "结论：：：：：：带换行符的JSON字符串，使用 json_pp 检查有效性的时候，只能通过文件File，而不能是字符串String"
echo "\n"

#echo '{"data1": "第1行\n第2行"}' >> ${Check_Json_FILE_PATH}
#echo "{\"data1\": \"第3行\n第2行\"}" >> ${Check_Json_FILE_PATH}
#cat "${Check_Json_FILE_PATH}"
#exit
