#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-25 02:04:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-13 17:17:18
 # @FilePath: /AutoPackage-CommitInfo/bulidScriptCommon/brances_info/brances_info_log/test/tssh_branch_detail_info_result.sh
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

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}

# qscript_path_get_filepath="${CommonFun_HomeDir_Absolute}/qscript_path_get.sh"
# qbase_function_log_msg_script_path="$(sh ${qscript_path_get_filepath} qbase function_log_msg)"
qbase_function_log_msg_script_path="${CommonFun_HomeDir_Absolute}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultValueToJsonFile
echo "${YELLOW}引入文件： ${BLUE}${qbase_function_log_msg_script_path}${NC}"


get_category_all_detail_info_script_path="${CommonFun_HomeDir_Absolute}/branch_info/get11_category_all_detail_info.sh"


TEST_DATA_RESULT_FILE_PATH="${CurrentDIR_Script_Absolute}/data/example11_get_category_all_detail_info.json"


# echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}

function test_getCategoryBranchsLog() {
    echo "----------------------------------------------------------------------------3上层方法：按分类获取所有分支信息的整合字符串"

    showBranchLogFlag='true'
    showBranchName='true'
    showBranchTimeLog='all'
    showBranchAtLog='true'
    showBranchTable='false' # 通知也暂时都不显示
    showCategoryName='true' # 通知时候显示
    shouldMarkdown='true'
    
    # RESULT_BRANCH_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.branch"
    RESULT_CATEGORY_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.category"
    RESULT_FULL_STRING_SALE_BY_KEY="branch_info_result.Notification.current.full"           


    # log "----------------------------------------3.3 getCategoryBranchsLog"
    # TEST_ALL_CATEGORY_BRANCH_STRING=""
    # lastLogIndex=0
    # echo "${YELLOW}正在执行《 ${BLUE}sh ${get_branch_all_detail_info_script_path} -categoryJsonF \"${TEST_DATA_RESULT_FILE_PATH}\" -categoryArrayKey \"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\" -categoryName 'hotfix' -lastLogIndexInAll \"${lastLogIndex}\" -showCategoryName \"${showCategoryName}\" ${YELLOW}》${NC}"
    # sh ${get_branch_all_detail_info_script_path} -categoryJsonF "${TEST_DATA_RESULT_FILE_PATH}" -categoryArrayKey "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -categoryName 'hotfix' -lastLogIndexInAll "${lastLogIndex}" -showCategoryName "${showCategoryName}"
    # #echo "========categoryBranchsLogsResult=${categoryBranchsLogsResult}"
    # if [ $? == 0 ] && [ -n "${categoryBranchsLogsResult}" ]; then
    #     if [ -n "${TEST_ALL_CATEGORY_BRANCH_STRING}" ]; then
    #         TEST_ALL_CATEGORY_BRANCH_STRING+='\n'
    #     fi
    #     TEST_ALL_CATEGORY_BRANCH_STRING+="${categoryBranchsLogsResult}"
    # fi
    # #echo "------------3.3.①拿一个分类作为所有分类得到的总信息为如下:\n${TEST_ALL_CATEGORY_BRANCH_STRING}"
    # echo "------------3.3.②"
    # # echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}
    # RESULT_CATEGORY_ARRAY_SALE_TEST_KEY="branch_info_result.Notification.current.full_test"
    # sh ${CommonFun_HomeDir_Absolute}/update_json_file.sh -f "${TEST_DATA_RESULT_FILE_PATH}" -sk "${RESULT_CATEGORY_ARRAY_SALE_TEST_KEY}" -sv "\"${TEST_ALL_CATEGORY_BRANCH_STRING}\"" --skip-value-check "true"
    # cat ${TEST_DATA_RESULT_FILE_PATH} | jq ".${RESULT_CATEGORY_ARRAY_SALE_TEST_KEY}" | jq '.'
    # echo "\n\n"
    

    echo "----------------------------------------3.4 getAllCategoryBranchLog"
    showCategoryName="true"
    echo "${YELLOW}正在执行《 ${BLUE}sh ${get_category_all_detail_info_script_path} -categoryJsonF \"${TEST_DATA_RESULT_FILE_PATH}\" -categoryArrayKey \"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\" -showCategoryName \"${showCategoryName}\" -resultFullKey \"${RESULT_FULL_STRING_SALE_BY_KEY}\" -resultFullSaveToJsonF \"${TEST_DATA_RESULT_FILE_PATH}\" ${YELLOW}》${NC}"
    ALL_CATEGORY_BRANCH_STRING=$(sh ${get_category_all_detail_info_script_path} -categoryJsonF "${TEST_DATA_RESULT_FILE_PATH}" -categoryArrayKey "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -showCategoryName "${showCategoryName}" -resultFullKey "${RESULT_FULL_STRING_SALE_BY_KEY}" -resultFullSaveToJsonF "${TEST_DATA_RESULT_FILE_PATH}")
    if [ $? != 0 ]; then
        echo "${RED}${ALL_CATEGORY_BRANCH_STRING}${NC}" # 此时值为错误信息
        return 1
    fi
    # echo "通过分类顺序，获取到的所有分支信息ALL_CATEGORY_BRANCH_STRING=\n${GREEN}${ALL_CATEGORY_BRANCH_STRING}${NC}"
    # echo "------------3.4.②"
    cat ${TEST_DATA_RESULT_FILE_PATH} | jq ".${RESULT_FULL_STRING_SALE_BY_KEY}" | jq '.'
    echo "${YELLOW}更多详情请可点击查看文件: ${BLUE}${TEST_DATA_RESULT_FILE_PATH}${NC}"

    # logResultValueToJsonFile "${ALL_CATEGORY_BRANCH_STRING}"

}




test_getCategoryBranchsLog
