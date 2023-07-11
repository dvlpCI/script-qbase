#!/bin/bash
:<<!
测试处理结果中有换行符的时候，如何保真，而不会换行显示
sh ./wrap_dealresult_demo.sh
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute}/..
bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#echo "bulidScriptCommon_dir_Absolute=${bulidScriptCommon_dir_Absolute}"


Wrap_FILE_PATH="${CurrentDIR_Script_Absolute}/wrap_demo.json"


echo "---------------------------------------------2"
ADD_WRAP_UPDATE_VALUE='{"test": "第1行\n第2行"}'
echo "-----------------------2.1"
echo "---------2.1.① (将处理结果直接显示，未有任何修饰，经验证换行符显示✅)"
echo "{}" | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE}" \
    '.wrap1 = $jsonString'

echo "---------2.1.② (将处理结果直接保存到File中(不经过变量)，能避免换行符失真，，经验证换行符显示✅)"
echo "{}" | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE}" \
    '.wrap2 = $jsonString' > ${Wrap_FILE_PATH}
cat ${Wrap_FILE_PATH}

echo "---------2.1.③ (处理结果使用变量存放，经验证一旦经过变量，不管是打印变量还是后续再保存到File中都是不对的，故经验证换行符显示❌)"
newJsonString=$(echo "{}" | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE}" \
    '.wrap3 = $jsonString')
echo "----③.1经验证换行符显示❌"
echo "${newJsonString}" > ${Wrap_FILE_PATH}
cat ${Wrap_FILE_PATH}
echo "----③.2经验证换行符显示❌"
echo "${newJsonString}"


echo "\n"
echo "结论：：：：：：带换行符的处理结果，如果要保真，且需要使用，目前的方法是将处理结果不经过变量，直接保存到File中，再cat出来使用。"
echo "\n"
