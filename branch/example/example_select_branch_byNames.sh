#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-24 11:47:10
 # @Description: 测试从分支名中筛选符合条件的分支信息(含修改情况)
 # @使用示例: 
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qbase_select_branch_byNames_scriptPath=${CategoryFun_HomeDir_Absolute}/select_branch_byNames.sh
get_branch_self_detail_info_script_path=${qbase_homedir_abspath}/branchMaps_20_info/get10_branch_self_detail_info.sh
qbase_get_filePath_mapping_branchName_from_dir_scriptPath=${qbase_homedir_abspath}/branchMaps_10_resouce_get/get_filePath_mapping_branchName_from_dir.sh
BranceMaps_From_Directory_PATH="${qbase_homedir_abspath}/branchMaps_10_resouce_get/example/featureBrances"
        

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}


function test_getSingleBranchLog() {
    shouldMarkdown=$1 # "false"
    
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



log_title "1"
# 获取远程分支列表
# branchNames=$(git branch -r)
branchNames=$(git branch -r)
# currentBranchResult=$(git branch --show-current) # 获取当前分支
# branchNames=${currentBranchResult}
start_date="2023-08-01"
end_date="2023-09-01"
# echo "${YELLOW}正在执行测试命令(获取在指定日期范围内有提交记录的分支)：《 sh ${qbase_select_branch_byNames_scriptPath} -branchNames \"${branchNames}\" -startDate \"${start_date}\" -endDate \"${end_date}\" ${YELLOW}》${NC}"
branchGitInfoString=$(sh ${qbase_select_branch_byNames_scriptPath} -branchNames "${branchNames}" -startDate "${start_date}" -endDate "${end_date}")
if [ $? != 0 ]; then
    echo "$branchGitInfoString" # 此时输出的值是错误信息
    exit 1
fi
echo "所有分支的匹配和不匹配结果如下:"
printf "%s\n" "${branchGitInfoString}" | jq "."
matchBranchGitInfoString=$(printf "%s" "${branchGitInfoString}" | jq -r ".eligibles")
unmatchBranchGitInfoString=$(printf "%s" "${branchGitInfoString}" | jq -r ".ineligibles")

allBranchCount=$(echo "$matchBranchGitInfoString" | jq -r 'length')
for((i=0;i<allBranchCount;i++));
do
    iBranchJsonString=$(echo "$matchBranchGitInfoString" | jq -r ".[$i]")

    branch_name=$(echo "$iBranchJsonString" | jq -r '.branch_name')
    commit_count=$(echo "$iBranchJsonString" | jq -r '.commit_count')
    author=$(echo "$iBranchJsonString" | jq -r '.author')
    last_committer=$(echo "$iBranchJsonString" | jq -r '.last_committer')

    branchDescription=""
    if [ "$commit_count" == "0" ]; then
        branchDescription="${branch_name}:没有提交记录 @${last_committer}"
    else
        # test_getSingleBranchLog "false"
        requestBranchName=$branch_name
        mappingBranchName_JsonStrings=$(sh "$qbase_get_filePath_mapping_branchName_from_dir_scriptPath" -requestBranchName "${requestBranchName}" -branchMapsFromDir "${BranceMaps_From_Directory_PATH}")
        if [ $? != 0 ] || [ -z "${mappingBranchName_JsonStrings}" ]; then
            branchDescription="${branch_name}:提交记录获取失败:未找到匹配分支名的文件 @${last_committer}"
        else
            branchDescription="${branch_name}:提交记录待获取 @${last_committer}"
        fi
    fi
    echo "$((i+1)). ${branchDescription}"
done
exit 1





result=$(echo "${matchBranchGitInfoString}" | jq '.')


# printf "All Branches:\n%s\n\n" "$result"

# 使用 jq 进行筛选，获取 commit_count 不为 0 的分支信息
exsitCommit_branchJsonStrings=$(printf "%s" "${matchBranchGitInfoString}" | jq '. | map(select(.commit_count != 0))')
noCommit_branchJsonStrings=$(printf "%s" "${matchBranchGitInfoString}" | jq '. | map(select(.commit_count == 0))')
exsitCommit_branchCount=$(echo "$exsitCommit_branchJsonStrings" | jq -r 'length')
noCommit_branchCount=$(echo "$noCommit_branchJsonStrings" | jq -r 'length')

TotalMessage="✅你的远程分支共有 ${allBranchCount} 个，这些分支在 ${start_date} 到 ${end_date} 时间里，有 ${exsitCommit_branchCount} 个分支有提交记录，有 ${noCommit_branchCount} 个分支没有提交记录。"
TotalMessage+="\n"
if [ "$exsitCommit_branchCount" == 0 ]; then
    TotalMessage+="您所有分支都没有进行任何开发。"
else
    TotalMessage+="您正在开发的(有提交记录)的分支有 ${exsitCommit_branchCount}/${allBranchCount} 个，信息如下:"
    for ((i = 0; i < exsitCommit_branchCount; i++)); do
        exsitCommit_branchJsonString=$(echo "$exsitCommit_branchJsonStrings" | jq -r ".[$i]")
        TotalMessage+="$((i + 1)). $exsitCommit_branchJsonString"
    done
fi

TotalMessage+="\n"
if [ "$noCommit_branchCount" == 0 ]; then
    TotalMessage+="您检查到的所有分支在这段时间内都有更新。"
else
    TotalMessage+="您有 ${noCommit_branchCount}/${allBranchCount} 个分支已经没有新的开发记录。(如果已经上线了，请及时清理；)信息如下:"
    for ((i = 0; i < noCommit_branchCount; i++)); do
        noCommit_branchJsonString=$(echo "$noCommit_branchJsonStrings" | jq -r ".[$i]")
        TotalMessage+="$((i + 1)). $noCommit_branchJsonString"
    done
fi
echo "${TotalMessage}"

exsitCommit_branchNamesString=$(printf "%s" "${exsitCommit_branchJsonStrings}" | jq -r '.[].branch_name')
# echo "===============${exsitCommit_branchNamesString}"
exsitCommit_branchNameArray=($exsitCommit_branchNamesString)
# echo "===============${exsitCommit_branchNameArray[*]}"

noCommit_branchNamesString=$(printf "%s" "${noCommit_branchJsonStrings}" | jq -r '.[].branch_name')
# echo "===============${noCommit_branchNamesString}"
noCommit_branchNameArray=($noCommit_branchNamesString)
# echo "===============${noCommit_branchNameArray[*]}"

# echo "${GREEN}${BLUE}main${GREEN} 分支最后一次提交commit的时间: ${BLUE}${lastCommitDate}${NC}"
