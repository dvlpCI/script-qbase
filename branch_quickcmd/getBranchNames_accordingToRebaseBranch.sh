#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-14 13:37:20
# @Description: 根据 rebase 分支，获取当前分支所含的所有分支名
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

qbase_rebasebranch_last_commit_date_scriptPath=${qbase_homedir_abspath}/branch/rebasebranch_last_commit_date.sh
qbase_calculate_newdate_scriptPath=${qbase_homedir_abspath}/date/calculate_newdate.sh
qbase_get_merger_recods_after_date_scriptPath=${qbase_homedir_abspath}/branch/get_merger_recods_after_date.sh


# 计算倒数第一个参数的位置
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
    if [ $argCount -ge 2 ]; then
        second_last_index=$((argCount - 1))
        second_last_arg=${!second_last_index} # 获取倒数第二个参数
    fi
fi
# echo "========second_last_arg=${second_last_arg}"
# echo "========       last_arg=${last_arg}"

verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
    verbose=true
else # 最后一个元素不是 verbose
    verbose=false
fi


function _verbose_log() {
    if [ "$verbose" == true ]; then
        echo "$1"
    fi
}



# 优化分支名(对origin/optimize/a，去除origin/)
function optimizeBranchNames() {
    p_branchNamesString=($1)
    num=${#p_branchNamesString[@]}
    #echo "${p_branchNamesString[*]}"
    #echo "num=$num"
        
    for ((i=0;i<num;i+=1))
    {
        fullBranchName=${p_branchNamesString[i]}
        #echo "$((i+1)) fullBranchName=${fullBranchName}"
        if [[ $fullBranchName == origin/* ]]; then
            fullBranchName=${fullBranchName#origin/}
        fi

        if [ -n "$ONLY_NAME" ] && [ "$ONLY_NAME" == true ]; then
            fullBranchName=${fullBranchName##*/} # 取最后的component
        fi

        r_fullBranchNames[${#r_fullBranchNames[@]}]=${fullBranchName}
    }

    #[shell 数组去重](https://www.jianshu.com/p/1043e40c0502)
    r_fullBranchNames=($(awk -v RS=' ' '!a[$1]++' <<< ${r_fullBranchNames[@]}))

    echo "${r_fullBranchNames[*]}"
}


# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -rebaseBranch|--rebase-branch) REBASE_BRANCH=$2; shift 2;;
        -addValue|--add-value) add_value="$2" shift 2;;
        -addType|--add-type) add_type="$2" shift 2;;
        -onlyName|--only-name) ONLY_NAME=$2; shift 2;; # 名字是否只取最后部分，不为true时候为全名
        --) break ;;
        *) break ;;
    esac
done


_verbose_log "${YELLOW}正在执行命令(获取分支最后一次提交commit的时间)：《${BLUE} sh ${qbase_rebasebranch_last_commit_date_scriptPath} -rebaseBranch \"${REBASE_BRANCH}\" ${YELLOW}》${NC}"
lastCommitDate=$(sh ${qbase_rebasebranch_last_commit_date_scriptPath} -rebaseBranch "${REBASE_BRANCH}")
if [ $? != 0 ]; then
    echo "${lastCommitDate}" # 此时值为错误信息
    exit 1
fi
_verbose_log "${GREEN}恭喜获得:${BLUE}main${GREEN} 分支最后一次提交commit的时间:${BLUE} ${lastCommitDate} ${GREEN}。${NC}"

if [ -n "$add_value" ]; then
    searchFromDateString=$(sh ${qbase_calculate_newdate_scriptPath} --old-date "$lastCommitDate" --add-value "$add_value")
    if [ $? != 0 ]; then
        exit 1
    fi
else
    searchFromDateString=$lastCommitDate
fi


_verbose_log "${YELLOW}正在执行命令(获取指定日期之后的所有合入记录(已去除 HEAD -> 等)):《${BLUE} sh ${qbase_get_merger_recods_after_date_scriptPath} --searchFromDateString \"${searchFromDateString}\" ${YELLOW}》${NC}"
mergerRecordResult=$(sh ${qbase_get_merger_recods_after_date_scriptPath} --searchFromDateString "${searchFromDateString}")
if [ -z "$mergerRecordResult" ]; then  # 没有新commit,提前结束 
    _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录:${BLUE} 没有新的提交记录，更不用说分支了 ${GREEN}。${NC}"
else
    _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录:${BLUE} ${mergerRecordResult} ${GREEN}。${NC}"
    mergerRecordResult=$(optimizeBranchNames "${mergerRecordResult}")
fi


# if [ -n "$onlyThisBranchLine" ]; then
#     currentBranchResult=$(git branch --show-current) # 获取当前分支
#     # _verbose_log "正准备添加当前分支:$currentBranchResult"
#     # mergerRecordResult+=" ${currentBranchResult}"
# fi


responseJsonString='{
    "code": 0
}'
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg searchFromDate "$searchFromDateString" '. + { "searchFromDate": $searchFromDate }')
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg mergerRecords "$mergerRecordResult" '. + { "mergerRecords": $mergerRecords }')
printf "%s" "${responseJsonString}"

