#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 21:04:26
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

log_title "获取分支最后一次提交commit的时间"
lastCommitDate=$(sh ${CurrentDIR_Script_Absolute}/rebasebranch_last_commit_date.sh "main")
if [ $? != 0 ]; then
    error_exit_script
fi
echo "${BLUE}main${NC} 分支最后一次提交commit的时间:${BLUE}${lastCommitDate}${NC}"


log_title "获取指定分支在指定日期后的第一条提交记录及其所属的所有分"
currentBranch=$(git branch --show-current) # 获取当前分支
searchFromDateString=${lastCommitDate}

echo "正在执行命令(获取指定分支在指定日期后的第一条提交记录及其所属的所有分支):《 ${PURPLE}sh ${CurrentDIR_Script_Absolute}/first_commit_info_after_date.sh -date \"${lastCommitDate}\" -curBranch \"${currentBranch}\" ${NC}》${NC}"
sourceBranchJson=$(sh ${CurrentDIR_Script_Absolute}/first_commit_info_after_date.sh -date "${lastCommitDate}" -curBranch "${currentBranch}")
if [ $? != 0 ]; then
    error_exit_script
fi
# echo "✅>>>>>>>> sourceBranchJson=${sourceBranchJson} <<<<<<<✅"
firstCommitId=$(echo "$sourceBranchJson" | jq -r '.firstCommitId')
firstCommitDes=$(echo "$sourceBranchJson" | jq -r '.firstCommitDes')
sourceBranchNames=$(echo "$sourceBranchJson" | jq -r '.sourceBranchNames')
echo "${GREEN}============ 恭喜:获得 ${BLUE}${currentBranch} ${GREEN}分支在指定日期${BLUE}${searchFromDateString}${GREEN}后的第一条提交记录【 ${BLUE}${firstCommitId}${GREEN}: ${BLUE}${firstCommitDes}${GREEN} 】的根源分支名sourceBranchsNameForFisrtCommit=${BLUE}${sourceBranchNames}"


