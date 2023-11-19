#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-19 22:30:26
 # @Description: 获取指定分组在指定日期范围内的分支情况(含修改情况)
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


function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

# 使用git fetch命令从远程仓库获取最新的分支信息：
# git fetch

# 使用git show-branch --date=short --remotes=* --since=<date>命令获取指定日期之后的所有分支。将<date>替换为您希望筛选的日期，格式为YYYY-MM-DD。
# git show-branch --date=short --remotes=* --since=2023-09-01


# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -branches|--branches) branches=$2; shift 2;;
        -startDate|--start-date) start_date=$2; shift 2;;
        -endDate|--end-date) end_date=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

# 日期变量
# start_date="2023-08-01"
# end_date="2023-09-01"

if [ -z "${branches}" ]; then
    echo "缺少 -branches 参数，请检查"
    # branches=$(git branch -r)
    # currentBranchResult=$(git branch --show-current) # 获取当前分支
    # branches=${currentBranchResult}
    exit 1
fi

if [ -z "${start_date}" ]; then
    echo "缺少 -startDate 参数，请检查"
    exit 1
fi

if [ -z "${end_date}" ]; then
    end_date=$(date +%Y-%m-%d)
fi


# 初始化 JSON 数组
all_branches_string=""
all_branches_string+="["
# 遍历分支列表
index=0 # 初始化索引计数器
while IFS= read -r branch; do
    # 提取分支名
    branch_name=$(echo "$branch" | awk '{print $1}')
    # branch_name=$(echo "$branch" | awk '{print $1}' | awk -F'/' '{print $2}')
    # echo "✅branch_name : $branch_name"
    # 获取分支在指定时间范围内的提交次数
    commit_count=$(git rev-list --count "$branch_name" --since="$start_date" --until="$end_date" 2>/dev/null)
    # echo "✅ commit_count : $commit_count"
    # 获取分支的作者和最后修改者
    # branch_info=$(git log -1 --pretty=format:'{"branch_name":'"$branch_name"',"author":"%an","last_committer":"%cn","commit_count":'"$commit_count"'}' 2>/dev/null)
    branch_info=$(git log -1 --pretty=format:'{"branch_name":"'"$branch_name"'","author":"%an","last_committer":"%cn","commit_count":'"$commit_count"'}' 2>/dev/null)
    # echo "branch_info : $branch_info"
    # 将分支信息添加到 JSON 数组
    if [ $index -gt 0 ]; then
        all_branches_string+=", "
    fi
    all_branches_string+="$branch_info"

    if [ $index -gt 4 ]; then
        break
    fi
    ((index++)) # 增加索引计数器
done <<< "$branches"
all_branches_string+="]"

# 写入 JSON 文件
# echo "$all_branches_string" > branches.json
printf "%s" "${all_branches_string}"
exit 0









result=$(echo "${all_branches_string}" | jq '.')

allBranchCount=$(echo "$all_branches_string" | jq -r 'length')

# printf "All Branches:\n%s\n\n" "$result"

# 使用 jq 进行筛选，获取 commit_count 不为 0 的分支信息
exsitCommit_branchJsonStrings=$(printf "%s" "${all_branches_string}" | jq '. | map(select(.commit_count != 0))')
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
noCommit_branchJsonStrings=$(printf "%s" "${all_branches_string}" | jq '. | map(select(.commit_count == 0))')
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
