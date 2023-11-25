#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-25 02:04:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-26 02:12:19
 # @FilePath: example10_get_branch_self_detail_info.sh
 # @Description: 测试分支本身的详情信息
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

# qscript_path_get_filepath="${qbase_homedir_abspath}/qscript_path_get.sh"
# qbase_function_log_msg_script_path="$(sh ${qscript_path_get_filepath} qbase function_log_msg)"
qbase_function_log_msg_script_path="${qbase_homedir_abspath}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultObjectStringToJsonFile
echo "${YELLOW}引入文件： ${BLUE}${qbase_function_log_msg_script_path}${NC}"

Develop_Branch_FILE_PATH="${Example_HomeDir_Absolute}/data/example10_get_branch_self_detail_info.json"
TEST_DATA_RESULT_FILE_PATH="${Example_HomeDir_Absolute}/data/test_data_save_result.json"
chmod +rw "${TEST_DATA_RESULT_FILE_PATH}" # 增加读写权限


JsonUpdateFun_script_file_Absolute="${qbase_homedir_abspath}/value_update_in_file/update_json_file.sh"
if [ ! -f "${JsonUpdateFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理更新json文件内从的脚本文件 ${JsonUpdateFun_script_file_Absolute} 不存在，请检查！"
    exit 1
fi
get_branch_self_detail_info_script_path=${qbase_homedir_abspath}/branchMaps_20_info/get10_branch_self_detail_info.sh



iBranchMap=$(cat ${Develop_Branch_FILE_PATH} | jq -r '.') # -r 去除字符串引号
branchName=$(echo ${iBranchMap} | jq -r ".name") # -r 去除字符串引号
# echo "----------------------测试的数据buildContainBranchMaps=${buildContainBranchMaps}"
# echo "----------------------测试的数据iBranchMap=${iBranchMap}"


# echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}



function test_getSingleBranchLog() {
    echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}

    shouldMarkdown=$1 # "false"
    
    showBranchLogFlag='true'
    showBranchName='true'
    showBranchTimeLog='all'
    showBranchAtLog='true'
    showBranchTable='false' # 通知也暂时都不显示
    showCategoryName='true' # 通知时候显示
    shouldShowSpendHours="true"
    RESULT_BRANCH_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.branch"
    # sh ${get_branch_self_detail_info_script_path} -iBranchMap "${iBranchMap}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -shouldShowSpendHours \"${shouldShowSpendHours}\" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${TEST_DATA_RESULT_FILE_PATH}" -resultArrayKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}"
    # exit
    # echo "${YELLOW}正在执行命令(获取分支自身的详细信息):《 ${BLUE}sh ${get_branch_self_detail_info_script_path} -iBranchMap \"${iBranchMap}\" -showFlag \"${showBranchLogFlag}\" -showName \"${showBranchName}\" -showTime \"${showBranchTimeLog}\" -showAt \"${showBranchAtLog}\" -shouldShowSpendHours \"${shouldShowSpendHours}\" -shouldMD \"${shouldMarkdown}\" -resultSaveToJsonF \"${TEST_DATA_RESULT_FILE_PATH}\" -resultArrayKey \"${RESULT_BRANCH_ARRAY_SALE_BY_KEY}\" ${YELLOW}》${NC}"
    Normal_BRANCH_LOG_STRING_VALUE=$(sh ${get_branch_self_detail_info_script_path} -iBranchMap "${iBranchMap}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -shouldShowSpendHours "${shouldShowSpendHours}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${TEST_DATA_RESULT_FILE_PATH}" -resultArrayKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}")
    # exit
    # Normal_BRANCH_LOG_STRING_VALUE="哈哈"
    # Normal_BRANCH_LOG_STRING_VALUE="❓【33天<font color=warning>@test1</font>】<font color=warning>dev_login_err</font>:<font color=comment>[02.09已提测]</font><font color=comment>@producter1</font><font color=comment>@test1</font>\n<font color=warning>①登录失败错误提示</font>"
    if [ $? != 0 ]; then
        echo "${RED}${Normal_BRANCH_LOG_STRING_VALUE}${NC}" # 此时值为错误原因
        return 1
    fi
    # print "%s" "${Normal_BRANCH_LOG_STRING_VALUE}" 
    # logResultValueToJsonFile "${Normal_BRANCH_LOG_STRING_VALUE}"
    # exit

    BRANCH_OUTLINES_ELEMENT_LOG_JSON="{\"name\": \"${branchName}\", \"outline\": \"${Normal_BRANCH_LOG_STRING_VALUE}\"}"
    echo "${GREEN}恭喜您的第$((logBranchIndex+1))个分支的分支信息结果为:${BLUE}${BRANCH_OUTLINES_ELEMENT_LOG_JSON} ${GREEN}。${NC}"


    
    # 保存所获得的分支信息到文件中，方便查看
    # logResultObjectStringToJsonFile "${BRANCH_OUTLINES_ELEMENT_LOG_JSON}"
    echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}
    BRANCH_OUTLINES_LOG_JSON="[${BRANCH_OUTLINES_ELEMENT_LOG_JSON}]"
    echo "${YELLOW}正在执行命令(保存所获得的分支信息到文件中，方便查看)：《${BLUE} sh ${JsonUpdateFun_script_file_Absolute} -f \"${TEST_DATA_RESULT_FILE_PATH}\" -k \"branch_info_result.Notification.current.branch\" -v \"${BRANCH_OUTLINES_LOG_JSON}\" --skip-value-check \"true\" ${YELLOW}》${NC}"
    sh ${JsonUpdateFun_script_file_Absolute} -f "${TEST_DATA_RESULT_FILE_PATH}" -k "branch_info_result.Notification.current.branch" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
    cat ${TEST_DATA_RESULT_FILE_PATH} | jq ".${RESULT_BRANCH_ARRAY_SALE_BY_KEY}" | jq '.'
    echo "${YELLOW}更多详情请可点击查看文件:${BLUE}${TEST_DATA_RESULT_FILE_PATH}${NC}"
}


log_title "1.获取分支功能点的耗时"
getOutlineSpend_scriptPath=${CategoryFun_HomeDir_Absolute}/get10_branch_self_detail_info_outline_spend.sh
outlineJsonString=$(printf "%s" "${iBranchMap}" | jq -r ".outlines[0]")
# echo "========${outlineJsonString}"
weekSpendHour=$(sh "$getOutlineSpend_scriptPath" -outline "${outlineJsonString}")
if [ $? != 0 ]; then
    weekSpendHour="?"
fi 
echo "${GREEN}恭喜：您该功能的耗时如下:${BLUE} ${weekSpendHour}h ${GREEN}。${NC}"
# exit


log_title "2.获取单个分支的描述信息"
getSingleBranchDescription_scriptPath=${CategoryFun_HomeDir_Absolute}/get10_branch_self_detail_info_outline.sh
testState="product"
shouldShowSpendHours="true"
# sh "$getSingleBranchDescription_scriptPath" -branchMap "${iBranchMap}" --test-state "${testState}" -shouldShowSpendHours "${shouldShowSpendHours}" --should-markdown "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultArrayKey "${RESULT_ARRAY_SALE_BY_KEY}"
# exit
des_info_string=$(sh "$getSingleBranchDescription_scriptPath" -branchMap "${iBranchMap}" --test-state "${testState}" -shouldShowSpendHours "${shouldShowSpendHours}" --should-markdown "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultArrayKey "${RESULT_ARRAY_SALE_BY_KEY}")
if [ $? != 0 ]; then
    exit 1
fi 
echo "${GREEN}恭喜：您的分支描述信息如下:${NC}"
echo "${BLUE}${des_info_string}${NC}"
# exit

echo "\n\n"
log_title "3.获取单个分支信息, text 形式"
test_getSingleBranchLog "false"


echo "\n\n"
log_title "4.获取单个分支信息, text 形式"
test_getSingleBranchLog "true"
