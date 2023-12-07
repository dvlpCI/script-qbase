#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-25 01:20:50
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

# 使用git fetch命令从远程仓库获取最新的分支信息：
# git fetch

# 使用git show-branch --date=short --remotes=* --since=<date>命令获取指定日期之后的所有分支。将<date>替换为您希望筛选的日期，格式为YYYY-MM-DD。
# git show-branch --date=short --remotes=* --since=2023-09-01


# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -branchNames|--branchNames) branchNames=$2; shift 2;;
        -ignoreBranchNameOrRules|--ignoreBranchNameOrRules) ignoreBranchNameOrRules=$2; shift 2;;   # 要舍弃哪些分支(可以是分支名feature/test1、也可以是分支规则test/*)
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
# echo "您要请求的所有分支(原始值)为: ${branchNames}"


# 要舍弃哪些分支(可以是分支名feature/test1、也可以是分支规则test/*
if [ -n "${ignoreBranchNameOrRules}" ]; then
    # sh $qbase_select_stings_by_rules_scriptPath -originStrings "${branchNames}" -patternsString "${ignoreBranchNameOrRules}"
    # exit
    branchNameMatchResultJson=$(sh $qbase_select_stings_by_rules_scriptPath -originStrings "${branchNames}" -patternsString "${ignoreBranchNameOrRules}")
    if [ $? != 0 ]; then
        printf "%s" "${branchNameMatchResultJson}"
        exit 1
    fi
    if ! jq -e . <<< "$branchNameMatchResultJson" >/dev/null 2>&1; then
        echo "❌ qbase_select_stings_by_rules_scriptPath 失败，返回的结果不是json。其内容如下:"
        echo "$branchNameMatchResultJson"
        exit 1
    fi
    # echo "✅branchNameMatchResultJson=${branchNameMatchResultJson}"

    remainingPatternStringJsonString=$(printf "%s" "${branchNameMatchResultJson}" | jq -r ".unmatchs")
    needIgnorePatternStringJsonString=$(printf "%s" "${branchNameMatchResultJson}" | jq -r ".matchs")
    # echo "remainingPatternStringJsonString=${remainingPatternStringJsonString}"
    branchNames=$(printf "%s" "${remainingPatternStringJsonString}" | jq -r ".[].originString")
    # echo "您要请求的所有分支(过滤后)为: ${branchNames}"
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
errorJsonStrings=""
errorJsonStrings+="["
# 遍历分支列表
# echo "您要遍历的所有分支为: ${branchNames}"
branchNameArray=(${branchNames})
branchCount=${#branchNameArray[@]}
for((i=0;i<branchCount;i++));
do
    branch_name=${branchNameArray[$i]}
    # echo "---------$((i+1)). ${branch_name}"

    # 2>/dev/null 只将标准错误输出重定向到 /dev/null，保留标准输出。
    # >/dev/null 2>&1 将标准输出和标准错误输出都重定向到 /dev/null，即全部丢弃。
    # 获取分支创建的时间（格式化为 "2020-11-10 10:10:00"）
    timestamp_commit=$(git log --diff-filter=A --format="%ad" --date=format:'%Y-%m-%d %H:%M:%S' "${branch_name}" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        if [ "${errorJsonStrings}" != "[" ]; then
            errorJsonStrings+=", "
        fi
        branch_info='{
            "branch_name": "'"${branch_name}"'",
            "errorMessage": "获取分支创建的时间失败"
        }'
        errorJsonStrings+="$branch_info"
        continue
    fi
    timestamp_create=$(echo "$timestamp_commit" | tail -1)
    # echo "----------------------1------${timestamp_create}"

    # 获取最后一次提交的时间（格式化为 "2020-11-10 10:10:00"）
    timestamp_last_commit=$(git log -1 --format="%ad" --date=format:'%Y-%m-%d %H:%M:%S' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        if [ "${errorJsonStrings}" != "[" ]; then
            errorJsonStrings+=", "
        fi
        branch_info='{
            "branch_name": "'"${branch_name}"'",
            "errorMessage": "获取最后一次提交的时间失败"
        }'
        errorJsonStrings+="$branch_info"
        continue
    fi
    # echo "----------------------2------${timestamp_last_commit}"

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
    # echo "----------------------3------${isDateFormatter}"

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
    # echo "----------------------4------${isDateFormatter}"

    # 获取分支在指定时间范围内的提交次数
    commit_count=$(git rev-list --count "$branch_name" --since="$commitCount_start_date" --until="$commitCount_end_date" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        if [ "${errorJsonStrings}" != "[" ]; then
            errorJsonStrings+=", "
        fi
        branch_info='{
            "branch_name": "'"${branch_name}"'",
            "errorMessage": "获取分支在指定时间范围内的提交次数"
        }'
        errorJsonStrings+="$branch_info"
        continue
    fi
    # echo "----------------------5------$commit_count"

    # 获取分支的作者和最后修改者
    # branch_info=$(git log -1 --pretty=format:'{"branch_name":'"$branch_name"',"author":"%an","last_committer":"%cn","commit_count":'"$commit_count"'}' 2>/dev/null)
    branch_info=$(git log -1 --pretty=format:'{"branch_name":"'"$branch_name"'","author":"%an","last_committer":"%cn","commit_count":'"$commit_count"'}' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        if [ "${errorJsonStrings}" != "[" ]; then
            errorJsonStrings+=", "
        fi
        branch_info='{
            "branch_name": "'"${branch_name}"'",
            "errorMessage": "获取分支的作者和最后修改者"
        }'
        errorJsonStrings+="$branch_info"
        continue
    fi
    # echo "----------------------6------$branch_info"
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
done
match_branch_gitJsonStrings+="]"
unmatch_branch_gitJsonStrings+="]"
errorJsonStrings+="]"


responseJsonString='{
    "errors": '${errorJsonStrings}',
    "eligibles": '${match_branch_gitJsonStrings}',
    "ineligibles": '${unmatch_branch_gitJsonStrings}'
}'
if [ -n "${needIgnorePatternStringJsonString}" ]; then
    responseJsonString=$(printf "%s" "$responseJsonString" | jq --argjson ignores "$needIgnorePatternStringJsonString" '. + { "ignores": $ignores }')
fi

# 写入 JSON 文件
# echo "$responseJsonString" > branchNames.json
printf "%s" "${responseJsonString}"

# echo "所有分支的匹配和不匹配结果如下:"
# printf "%s\n" "${responseJsonString}" | jq "."