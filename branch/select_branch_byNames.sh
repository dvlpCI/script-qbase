#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-24 11:59:45
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
        -branchNames|--branchNames) branchNames=$2; shift 2;;
        -create-startDate|--create-start-date) create_start_date=$2; shift 2;;  # 若有值，创建时间早于该值不显示
        -create-endDate|--create-end-date) create_end_date=$2; shift 2;;        # 若有值，创建时间晚于该值不显示
        -lastCommit-startDate|--lastCommit-start-date) lastCommit_start_date=$2; shift 2;;  # 若有值，最后修改时间不在该值之后不显示(即该时间值之后没有提交的不显示)
        -lastCommit-endDate|--lastCommit-end-date) lastCommit_end_date=$2; shift 2;;        # 若有值，最后修改时间晚于该值不显示
        -commitCount-startDate|--commitCount-start-date) commitCount_start_date=$2; shift 2;;   # 统计某个时间段的提交次数，默认从创建时间开始
        -commitCount-endDate|--commitCount-end-date) commitCount_end_date=$2; shift 2;;         # 统计某个时间段的提交次数，默认到当前时间结束
        --) break ;;
        *) break ;;
    esac
done


# 日期变量
# start_date="2023-08-01"
# end_date="2023-09-01"

if [ -z "${branchNames}" ]; then
    echo "缺少 -branchNames 参数，请检查"
    # branchNames=$(git branch -r)
    # currentBranchResult=$(git branch --show-current) # 获取当前分支
    # branchNames=${currentBranchResult}
    exit 1
fi

function isDateFormatter() {
    input_string=$1
    # 正则表达式模式
    pattern="^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$"

    # 进行匹配判断
    if [[ $input_string =~ $pattern ]]; then
        # echo "字符串符合日期格式 '2020-11-10 10:10:00'"
        return 0
    else
        # echo "字符串不符合日期格式 '2020-11-10 10:10:00'"
        return 1
    fi
}

function compareDate1Date2() {
    timestamp=$1
    compare_time=$2
    # 指定比较的时间
    # compare_time="2020-10-01 10:00:00"

    # 将时间转换为时间戳进行比较
    timestamp_unix=$(date -d "$timestamp" +%s)
    compare_time_unix=$(date -d "$compare_time" +%s)

    # 判断创建时间是否在指定时间之后
    if [[ $timestamp_unix -gt $compare_time_unix ]]; then
        # echo "${timestamp} 在 ${compare_time} 之后"
        echo "after"
    else
        # echo "${timestamp} 在 ${compare_time} 之前或等于"
        echo "before"
    fi
}


# 初始化 JSON 数组
match_branch_gitJsonStrings=""
match_branch_gitJsonStrings+="["
unmatch_branch_gitJsonStrings=""
unmatch_branch_gitJsonStrings+="["
# 遍历分支列表
index=0 # 初始化索引计数器
while IFS= read -r branch; do
    # 提取分支名
    branch_name=$(echo "$branch" | awk '{print $1}')
    # branch_name=$(echo "$branch" | awk '{print $1}' | awk -F'/' '{print $2}')
    # echo "✅branch_name : $branch_name"

    # 获取分支创建的时间（格式化为 "2020-11-10 10:10:00"）
    timestamp_create=$(git log --diff-filter=A --format="%ad" --date=format:'%Y-%m-%d %H:%M:%S' "${branch_name}" | tail -1)

    # 获取最后一次提交的时间（格式化为 "2020-11-10 10:10:00"）
    timestamp_last_commit=$(git log -1 --format="%ad" --date=format:'%Y-%m-%d %H:%M:%S')


    commitCount_start_date=${timestamp_create}
    commitCount_end_date=$(date +%Y-%m-%d)

    unMatchErrorMessage=""
    # 若有值，创建时间早于该值不显示
    isDateFormatter=$(isDateFormatter "${create_start_date}")
    if [ $? == 0 ]; then
        compare_result_for_create=$(compareDate1Date2 "${timestamp_create}" "${create_start_date}")
        if [ "${compare_result_for_create}" != "after" ]; then
            unMatchErrorMessage="您的 ${branch_name} 分支的创建时间早于 ${create_start_date} ，不显示"
        else
            commitCount_start_date="${create_start_date}"
        fi
    fi

    # 若有值，最后修改时间不在该值之后不显示(即该时间值之后没有提交的不显示)
    isDateFormatter=$(isDateFormatter "${lastCommit_start_date}")
    if [ $? == 0 ]; then
        compare_result_for_lastCommit=$(compareDate1Date2 "${timestamp_last_commit}" "${lastCommit_start_date}")
        if [ "${compare_result_for_lastCommit}" != "before" ]; then
            unMatchErrorMessage="您的 ${branch_name} 最后修改时间不在 ${lastCommit_start_date} 之后不显示(即该时间值之后没有提交的不显示)"
        else
            commitCount_end_date="${lastCommit_start_date}"
        fi
    fi
    
    # 获取分支在指定时间范围内的提交次数
    commit_count=$(git rev-list --count "$branch_name" --since="$commitCount_start_date" --until="$commitCount_end_date" 2>/dev/null)
    # echo "✅ commit_count : $commit_count"

    # 获取分支的作者和最后修改者
    # branch_info=$(git log -1 --pretty=format:'{"branch_name":'"$branch_name"',"author":"%an","last_committer":"%cn","commit_count":'"$commit_count"'}' 2>/dev/null)
    branch_info=$(git log -1 --pretty=format:'{"branch_name":"'"$branch_name"'","author":"%an","last_committer":"%cn","commit_count":'"$commit_count"'}' 2>/dev/null)
    # echo "branch_info : $branch_info"
    # 将分支信息添加到 JSON 数组
    if [ -n "${unMatchErrorMessage}" ]; then
        if [ "${unmatch_branch_gitJsonStrings}" != "[" ]; then
            unmatch_branch_gitJsonStrings+=", "
        fi
        unmatch_branch_gitJsonStrings+="$branch_info"
    else
        if [ "${match_branch_gitJsonStrings}" != "[" ]; then
            match_branch_gitJsonStrings+=", "
        fi
        match_branch_gitJsonStrings+="$branch_info"
    fi

    # if [ $index -gt 4 ]; then
    #     echo "============大于4,不显示"
    #     break
    # fi
    # ((index++)) # 增加索引计数器
done <<< "$branchNames"
match_branch_gitJsonStrings+="]"
unmatch_branch_gitJsonStrings+="]"

lastJson='{
    "matchs": '${match_branch_gitJsonStrings}',
    "unmatchs": '${unmatch_branch_gitJsonStrings}'
}'

# 写入 JSON 文件
# echo "$lastJson" > branchNames.json
printf "%s" "${lastJson}"

echo "所有分支的匹配和不匹配结果如下:"
printf "%s\n" "${lastJson}" | jq "."

exit 0









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
