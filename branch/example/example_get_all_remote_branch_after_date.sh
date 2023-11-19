#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-19 22:21:22
 # @Description: 测试获取在指定日期范围内有提交记录的分支
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

qbase_get_all_remote_branch_after_date_scriptPath=${CategoryFun_HomeDir_Absolute}/get_all_remote_branch_after_date.sh


function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

log_title "1"
# 获取远程分支列表
# branches=$(git branch -r)
branches=$(git branch -r)
# currentBranchResult=$(git branch --show-current) # 获取当前分支
# branches=${currentBranchResult}
start_date="2023-08-01"
end_date="2023-09-01"
# echo "${YELLOW}正在执行测试命令(获取在指定日期范围内有提交记录的分支)：《 sh ${qbase_get_all_remote_branch_after_date_scriptPath} -branches \"${branches}\" -startDate \"${start_date}\" -endDate \"${end_date}\" ${YELLOW}》${NC}"
all_branches_string=$(sh ${qbase_get_all_remote_branch_after_date_scriptPath} -branches "${branches}" -startDate "${start_date}" -endDate "${end_date}")
if [ $? != 0 ]; then
    echo "$all_branches_string" # 此时输出的值是错误信息
    exit 1
fi
allBranchCount=$(echo "$all_branches_string" | jq -r 'length')
for((i=0;i<allBranchCount;i++));
do
    iBranchJsonString=$(echo "$all_branches_string" | jq -r ".[$i]")

    branch_name=$(echo "$iBranchJsonString" | jq -r '.branch_name')
    commit_count=$(echo "$iBranchJsonString" | jq -r '.commit_count')
    author=$(echo "$iBranchJsonString" | jq -r '.author')
    last_committer=$(echo "$iBranchJsonString" | jq -r '.last_committer')

    branchDescription=""
    if [ "$commit_count" == "0" ]; then
        branchDescription="${branch_name}:没有提交记录 @${last_committer}"
    else
        branchDescription="${branch_name}:提交记录待获取 @${last_committer}"
    fi
    echo "$((i+1)). ${branchDescription}"
done
exit 1





result=$(echo "${all_branches_string}" | jq '.')


# printf "All Branches:\n%s\n\n" "$result"

# 使用 jq 进行筛选，获取 commit_count 不为 0 的分支信息
exsitCommit_branchJsonStrings=$(printf "%s" "${all_branches_string}" | jq '. | map(select(.commit_count != 0))')
noCommit_branchJsonStrings=$(printf "%s" "${all_branches_string}" | jq '. | map(select(.commit_count == 0))')
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
