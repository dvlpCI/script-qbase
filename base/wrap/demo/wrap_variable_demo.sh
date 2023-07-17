#!/bin/bash
:<<!
测试变量中有换行符的时候，如何保真，而不会换行显示
sh ./wrap_variable_demo.sh
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#Base_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
Base_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#echo "Base_HomeDir_Absolute=${Base_HomeDir_Absolute}"


Wrap_FILE_PATH="${CurrentDIR_Script_Absolute}/wrap_demo.json"


echo "---------------------------------------------1"
echo "-----------------------1.1未转义的变量"
WRAP_echo_Failure_VALUE='{"test": "第1行\n第2行"}'  # 未转义的变量
echo "---------1.1.② (将未转义的变量直接echo，经验证换行符失真❌)"
echo "${WRAP_echo_Failure_VALUE}"

echo "---------1.1.② (将未转义的变量直接保存到File中，再cat出来，经验证换行符失真❌)"
echo "${WRAP_echo_Failure_VALUE}" > ${Wrap_FILE_PATH}
cat ${Wrap_FILE_PATH}




echo "-----------------------1.2已转义的变量"
WRAP_echo_Success_VALUE='{"test": "第1行\\n第2行"}' # 已转义的变量
echo "---------1.2.② (将已转义的变量直接echo，经验证换行符保真✅)"
echo "${WRAP_echo_Success_VALUE}"

echo "---------1.2.② (将已转义变量直接保存到File中，再cat出来，经验证换行符保真✅)"
echo "${WRAP_echo_Success_VALUE}" > ${Wrap_FILE_PATH}
cat ${Wrap_FILE_PATH}


echo "\n"
echo "结论：：：：：：带换行符的变量，如果要保真，需要先转义，否则不管是在echo，还是文件cat，都会失真。"
echo "\n"
