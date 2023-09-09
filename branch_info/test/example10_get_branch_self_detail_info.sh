#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-25 02:04:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-09 22:21:08
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
# CommonFun_HomeDir_Absolute2=${CommonFun_HomeDir_Absolute3%/*}
CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}

# qscript_path_get_filepath="${CommonFun_HomeDir_Absolute}/qscript_path_get.sh"
# qbase_function_log_msg_script_path="$(sh ${qscript_path_get_filepath} qbase function_log_msg)"
qbase_function_log_msg_script_path="${CommonFun_HomeDir_Absolute}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultValueToJsonFile
echo "${YELLOW}引入文件： ${BLUE}${qbase_function_log_msg_script_path}${NC}"

Develop_Branchs_FILE_PATH="${CurrentDIR_Script_Absolute}/data/test_data_branch_info.json"
TEST_DATA_RESULT_FILE_PATH="${CurrentDIR_Script_Absolute}/data/test_data_save_result.json"

JsonUpdateFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/update_value/update_json_file.sh"
if [ ! -f "${JsonUpdateFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理更新json文件内从的脚本文件 ${JsonUpdateFun_script_file_Absolute} 不存在，请检查！"
    exit 1
fi
get_branch_self_detail_info_script_path=${CommonFun_HomeDir_Absolute}/branch_info/get10_branch_self_detail_info.sh



buildContainBranchMaps=$(cat ${Develop_Branchs_FILE_PATH} | jq -r '.package_merger_branchs') # -r 去除字符串引号
if [ -z "${buildContainBranchMaps}" ]; then
    echo "ERROR: 没有获取到分支信息，请检查文件 ${Develop_Branchs_FILE_PATH} 的 .package_merger_branchs 字段"
    exit 1
fi
logBranchIndex=0
iBranchMap=$(echo "${buildContainBranchMaps}" | jq -r ".[$((logBranchIndex))]") # -r 去除字符串引号
branchName=$(echo ${iBranchMap} | jq -r ".name") # -r 去除字符串引号
# echo "----------------------测试的数据buildContainBranchMaps=${buildContainBranchMaps}"
# echo "----------------------测试的数据iBranchMap=${iBranchMap}"


# echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}



function test_getSingleBranchLog() {
    echo "----------------------------------------------------------------------------1基础层方法:getSingleBranchLog"
    echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}

    shouldMarkdown="false"
    
    showBranchLogFlag='true'
    showBranchName='true'
    showBranchTimeLog='all'
    showBranchAtLog='true'
    showBranchTable='false' # 通知也暂时都不显示
    showCategoryName='true' # 通知时候显示
    RESULT_BRANCH_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.branch"
    # sh ${get_branch_self_detail_info_script_path} -iBranchMap "${iBranchMap}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${TEST_DATA_RESULT_FILE_PATH}" -resultArrayKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}"
    # exit
    # echo "${YELLOW}正在执行命令(获取分支自身的详细信息):《 ${BLUE}sh ${get_branch_self_detail_info_script_path} -iBranchMap \"${iBranchMap}\" -showFlag \"${showBranchLogFlag}\" -showName \"${showBranchName}\" -showTime \"${showBranchTimeLog}\" -showAt \"${showBranchAtLog}\" -shouldMD \"${shouldMarkdown}\" -resultSaveToJsonF \"${TEST_DATA_RESULT_FILE_PATH}\" -resultArrayKey \"${RESULT_BRANCH_ARRAY_SALE_BY_KEY}\" ${YELLOW}》${NC}"
    Normal_BRANCH_LOG_STRING_VALUE=$(sh ${get_branch_self_detail_info_script_path} -iBranchMap "${iBranchMap}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${TEST_DATA_RESULT_FILE_PATH}" -resultArrayKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}")
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
    # logResultValueToJsonFile "${BRANCH_OUTLINES_ELEMENT_LOG_JSON}"
    # exit

    echo "${GREEN}恭喜您的结果为:${BLUE}${BRANCH_OUTLINES_ELEMENT_LOG_JSON} ${GREEN}。${NC}"

    
    
    echo "------------1.1.①第$((logBranchIndex+1))个分支的分支信息如下:\n${BRANCH_OUTLINES_ELEMENT_LOG_JSON}"
    echo "------------1.1.②"
    echo "{}" > ${TEST_DATA_RESULT_FILE_PATH} #清空文件内容,但清空成{}

    BRANCH_OUTLINES_LOG_JSON="[${BRANCH_OUTLINES_ELEMENT_LOG_JSON}]"
    echo "正在执行命令(测试分支信息的保存)：《 sh ${JsonUpdateFun_script_file_Absolute} -f \"${TEST_DATA_RESULT_FILE_PATH}\" -k \"branch_info_result.Notification.current.branch\" -v \"${BRANCH_OUTLINES_LOG_JSON}\" --skip-value-check \"true\" 》"
    sh ${JsonUpdateFun_script_file_Absolute} -f "${TEST_DATA_RESULT_FILE_PATH}" -k "branch_info_result.Notification.current.branch" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
    cat ${TEST_DATA_RESULT_FILE_PATH} | jq ".${RESULT_BRANCH_ARRAY_SALE_BY_KEY}" | jq '.'

    echo "\n\n"
    echo "${YELLOW}更多详情请可点击查看文件:${BLUE}${TEST_DATA_RESULT_FILE_PATH}${NC}"
}





test_getSingleBranchLog
