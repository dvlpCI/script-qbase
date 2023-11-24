#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-24 18:41:49
 # @Description: 从分支名中筛选符合条件的分支信息(含修改情况)
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

CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_select_stings_by_rules_scriptPath=${qbase_homedir_abspath}/foundation/select_stings_by_rules.sh


function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}



result=$(echo "${match_branch_gitJsonStrings}" | jq '.')

allBranchCount=$(echo "$match_branch_gitJsonStrings" | jq -r 'length')

# printf "All Branches:\n%s\n\n" "$result"

# 使用 jq 进行筛选，获取 commit_count 不为 0 的分支信息
exsitCommit_branchJsonStrings=$(printf "%s" "${match_branch_gitJsonStrings}" | jq '. | map(select(.commit_count != 0))')
# echo "===========exsitCommit_branchJsonStrings : $exsitCommit_branchJsonStrings"


TotalMessage="✅从 ${start_date} 到 ${end_date} 时间里，"
TotalMessage+="\n"
exsitCommit_branchCount=$(echo "$exsitCommit_branchJsonStrings" | jq -r 'length')
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
# 使用 jq 进行筛选，获取 commit_count 不为 0 的分支信息
noCommit_branchJsonStrings=$(printf "%s" "${match_branch_gitJsonStrings}" | jq '. | map(select(.commit_count == 0))')
# echo "===========noCommit_branchJsonStrings : $noCommit_branchJsonStrings"
noCommit_branchCount=$(echo "$noCommit_branchJsonStrings" | jq -r 'length')
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
