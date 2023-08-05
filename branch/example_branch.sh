#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-06 00:14:36
 # @Description: 日期的相关计算方法--用来获取新时间(通过旧时间的加减)
 # @使用示例: sh ./date/calculate_newdate.sh --old-date $old_date --add-value "1" --add-type "second"
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

log_title "1"
echo "${YELLOW}正在执行命令(获取分支最后一次提交commit的时间)：《 sh ${CurrentDIR_Script_Absolute}/rebasebranch_last_commit_date.sh \"main\" ${YELLOW}》${NC}"
lastCommitDate=$(sh ${CurrentDIR_Script_Absolute}/rebasebranch_last_commit_date.sh "main")
if [ $? != 0 ]; then
    error_exit_script
fi
echo "${GREEN}${BLUE}main${GREEN} 分支最后一次提交commit的时间: ${BLUE}${lastCommitDate}${NC}"





echo "\n"
log_title "2"
currentBranch=$(git branch --show-current) # 获取当前分支
searchFromDateString=${lastCommitDate}

echo "${YELLOW}正在执行命令(获取执行此脚本的分支在指定日期后的第一条提交记录及其所属的所有分支):《 ${PURPLE}sh ${CurrentDIR_Script_Absolute}/first_commit_info_after_date.sh -date \"${lastCommitDate}\" ${YELLOW}》${NC}"
sourceBranchJson=$(sh ${CurrentDIR_Script_Absolute}/first_commit_info_after_date.sh -date "${lastCommitDate}")
if [ $? != 0 ]; then
    error_exit_script
fi
# echo "✅>>>>>>>> sourceBranchJson=${sourceBranchJson} <<<<<<<✅"
firstCommitId=$(echo "$sourceBranchJson" | jq -r '.firstCommitId')
firstCommitDes=$(echo "$sourceBranchJson" | jq -r '.firstCommitDes')
sourceBranchNames=$(echo "$sourceBranchJson" | jq -r '.sourceBranchNames')
echo "${GREEN}恭喜:获得在指定日期${BLUE}${searchFromDateString}${GREEN}后的第一条提交记录【 ${BLUE}${firstCommitId}${GREEN}: ${BLUE}${firstCommitDes}${GREEN} 】的所属所有分支名sourceBranchsNameForFisrtCommit= ${BLUE}${sourceBranchNames}"




echo "\n"
log_title "3"
echo "${YELLOW}正在执行命令(获取指定日期之后的所有合入记录(已去除 HEAD -> 等)):《 ${BLUE} sh ${CurrentDIR_Script_Absolute}/get_merger_recods_after_date.sh --searchFromDateString "2023-08-03 11:46:28" ${YELLOW}》${NC}"
mergerRecordResult=$(sh ${CurrentDIR_Script_Absolute}/get_merger_recods_after_date.sh --searchFromDateString "2023-08-03 11:46:28")
echo "${GREEN}指定日期之后的所有合入记录: ${BLUE}${mergerRecordResult}${NC}"
