#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-25 02:04:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-10 02:06:07
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

get_branch_all_detail_info_script_path="${CommonFun_HomeDir_Absolute}/branchMaps_20_info/get20_branchMapsInfo_byHisJsonFile.sh"


Develop_Branchs_FILE_PATH="${CurrentDIR_Script_Absolute}/data/test_data_branch_info.json"
TEST_DATA_RESULT_FILE_PATH="${CurrentDIR_Script_Absolute}/data/test_data_save_result.json"


# echo "正在引入方法文件(brances_info_log_common.sh)：《source ${CommonFun_HomeDir_Absolute}/brances_info/brances_info_log/brances_info_log_common.sh -commonFunHomeDir \"${CommonFun_HomeDir_Absolute}\" --branch-info-json-file \"${Develop_Branchs_FILE_PATH}\"》"
# source ${CommonFun_HomeDir_Absolute}/brances_info/brances_info_log/brances_info_log_common.sh -commonFunHomeDir "${CommonFun_HomeDir_Absolute}" --branch-info-json-file "${Develop_Branchs_FILE_PATH}"


# echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}

function test_getAllBranchLogArray_andCategoryThem() {
    echo "----------------------------------------------------------------------------3上层方法：按分类获取所有分支信息的整合字符串"
    echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}

    showBranchLogFlag='true'
    showBranchName='true'
    showBranchTimeLog='all'
    showBranchAtLog='true'
    showBranchTable='false' # 通知也暂时都不显示
    showCategoryName='true' # 通知时候显示
    shouldMarkdown='false'
    
    RESULT_BRANCH_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.branch"
    RESULT_CATEGORY_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.category"
    RESULT_FULL_STRING_SALE_BY_KEY="branch_info_result.Notification.current.full"           

    echo "----------------------------------------3.2 getAllBranchLogArray_andCategoryThem"
    echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}
    echo "正在执行命令(整合 branchMapsInfo)：《 sh $get_branch_all_detail_info_script_path -branchMapsInJsonF \"${Develop_Branchs_FILE_PATH}\" -branchMapsInKey \".package_merger_branchs\" -showCategoryName \"${showCategoryName}\" -showFlag \"${showBranchLogFlag}\" -showName \"${showBranchName}\" -showTime \"${showBranchTimeLog}\" -showAt \"${showBranchAtLog}\" -showTable \"${showBranchTable}\" -shouldMD \"${shouldMarkdown}\" -resultSaveToJsonF \"${TEST_DATA_RESULT_FILE_PATH}\" -resultBranchKey \"${RESULT_BRANCH_ARRAY_SALE_BY_KEY}\" -resultCategoryKey \"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\" -resultFullKey \"${RESULT_FULL_STRING_SALE_BY_KEY}\" 》"
    sh $get_branch_all_detail_info_script_path -branchMapsInJsonF "${Develop_Branchs_FILE_PATH}" -branchMapsInKey ".package_merger_branchs" -showCategoryName "${showCategoryName}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -showTable "${showBranchTable}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${TEST_DATA_RESULT_FILE_PATH}" -resultBranchKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}" -resultCategoryKey "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -resultFullKey "${RESULT_FULL_STRING_SALE_BY_KEY}"
    

    # echo "------------3.2.②"
    # cat ${TEST_DATA_RESULT_FILE_PATH} | jq '.branch_info_result.Notification.current' | jq '.'

    echo "\n\n"
    echo "${YELLOW}更多详情请可点击查看文件: ${BLUE}${TEST_DATA_RESULT_FILE_PATH}${NC}"
}




test_getAllBranchLogArray_andCategoryThem
