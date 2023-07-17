#!/bin/bash
:<<!
测试对json文件添加新值含换行符的内容中，换行符是否保真
sh ./wrap_3GetAndChange_demo.sh
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
CommonFun_HomeDir_Absolute2=${CommonFun_HomeDir_Absolute3%/*}
Base_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}


echo "---------------------------------------------3对json文件添加新【常量值含换行符】"
ADD_WRAP_UPDATE_VALUE_1='{"data2": "第1行\n第2行"}'         #无变量，外层可以直接用单引号

echo "-----------------------3.1对从未存在换行符的json文件添加新值含换行符"
# 本来已经存在换行符的json文件
echo "--------3.1.①从未存在换行符的json文件 的原始值"
Old_NOExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_no_exsit_old.json"
cat ${Old_NOExistWrap_FILE_PATH}
# 对【本来已经存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容
echo "--------3.1.②对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的原始值"
New_AddFrom_NOExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_no_exsit_new.json"
cat ${New_AddFrom_NOExistWrap_FILE_PATH}


echo "--------3.1.③对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的新值"
echo > ${New_AddFrom_NOExistWrap_FILE_PATH} #清空文件内容
cat ${Old_NOExistWrap_FILE_PATH} | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE_1}" \
    '.wrap2 = $jsonString' > ${New_AddFrom_NOExistWrap_FILE_PATH}
cat ${New_AddFrom_NOExistWrap_FILE_PATH}


echo "-----------------------3.2对已经存在换行符的json文件添加新【常量值含换行符】"
ADD_WRAP_UPDATE_VALUE_2='{"data2": "第3行\n第4行"}'         #无变量，外层可以直接用单引号
# 本来已经存在换行符的json文件
echo "--------3.2.①本来已经存在换行符的json文件 的原始值"
Old_HasExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_has_exsit_old.json"
cat ${Old_HasExistWrap_FILE_PATH}
# 对【本来已经存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容
echo "--------3.2.②对【本来已经存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的原始值"
New_AddFrom_HasExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_has_exsit_new.json"
cat ${New_AddFrom_HasExistWrap_FILE_PATH}


echo "--------3.2.③对【本来已经存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的新值"
echo > ${New_AddFrom_HasExistWrap_FILE_PATH} #清空文件内容
cat ${Old_HasExistWrap_FILE_PATH} | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE_2}" \
    '.wrap2 = $jsonString' > ${New_AddFrom_HasExistWrap_FILE_PATH}
cat ${New_AddFrom_HasExistWrap_FILE_PATH}




echo "\n\n\n"
echo "---------------------------------------------4对json文件添加新【变量值含换行符】"
ADD_WRAP_STRING="第5行n第6行"
ADD_WRAP_UPDATE_VALUE_3="{\"data3\": \"${ADD_WRAP_STRING}\"}"   #有变量，外层必须是双引号，不能是单引号

echo "-----------------------4.1对从未存在换行符的json文件添加新值含换行符"
# 本来已经存在换行符的json文件
echo "--------4.1.①从未存在换行符的json文件 的原始值"
Old_NOExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_no_exsit_old.json"
cat ${Old_NOExistWrap_FILE_PATH}
# 对【本来已经存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容
echo "--------4.1.②对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的原始值"
New_AddFrom_NOExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_no_exsit_new.json"
cat ${New_AddFrom_NOExistWrap_FILE_PATH}


echo "--------4.1.③对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的新值"
echo > ${New_AddFrom_NOExistWrap_FILE_PATH} #清空文件内容
echo "---${ADD_WRAP_UPDATE_VALUE_3}"
cat ${Old_NOExistWrap_FILE_PATH} | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE_3}" \
    '.wrap4 = $jsonString' > ${New_AddFrom_NOExistWrap_FILE_PATH}
cat ${New_AddFrom_NOExistWrap_FILE_PATH}



echo "\n\n\n"
echo "---------------------------------------------5对json文件添加新【数组+变量值+含换行符】"
categoryBranchsLogArray=("a" "b" "c")
categoryBranchsLogArrayString=${categoryBranchsLogArray[*]}
source "${Base_HomeDir_Absolute}/a_function_jsonstring.sh"
CATEGORY_BRANCHS_LOG_ARRAY_VALUE=$(getJsonStringWithEscapeFromArrayString "${categoryBranchsLogArrayString}" "true")
CATEGORY_BRANCHS_LOG_JSON="{\"other\": ${CATEGORY_BRANCHS_LOG_ARRAY_VALUE}}"

echo "--------5.1.③对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的新值"
echo > ${New_AddFrom_NOExistWrap_FILE_PATH} #清空文件内容
echo "---${CATEGORY_BRANCHS_LOG_JSON}"
cat ${Old_NOExistWrap_FILE_PATH} | jq --argjson jsonString "${CATEGORY_BRANCHS_LOG_JSON}" \
    '.branch_info_category = $jsonString' > ${New_AddFrom_NOExistWrap_FILE_PATH}
cat ${New_AddFrom_NOExistWrap_FILE_PATH}
