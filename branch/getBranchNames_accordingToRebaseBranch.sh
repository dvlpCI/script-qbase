#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-09 17:38:44
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

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..


# shell 参数具名化           
while [ -n "$1" ]
do
        case "$1" in
                -rebaseBranch|--rebase-branch) REBASE_BRANCH=$2; shift 2;;
                --add-value) add_value="$2" shift 2;;
                --add-type) add_type="$2" shift 2;;
                -onlyName|--only-name) ONLY_NAME=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done
    


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


# 根据 rebase 的分支，获取当前分支所含的所有分支名
function getBranchNames_accordingToRebaseBranch() {    
    rebaseFromBranch=$1
    add_value=$2

    _verbose_log "${YELLOW}正在执行命令(获取分支最后一次提交commit的时间)：《 sh ${qbase_homedir_abspath}/branch/rebasebranch_last_commit_date.sh -rebaseBranch \"${rebaseFromBranch}\" ${YELLOW}》${NC}"
    lastCommitDate=$(sh ${qbase_homedir_abspath}/branch/rebasebranch_last_commit_date.sh -rebaseBranch "${rebaseFromBranch}")
    if [ $? != 0 ]; then
        echo "${lastCommitDate}" # 此时值为错误信息
        return 1
    fi
    _verbose_log "${GREEN}恭喜获得:${BLUE}main${GREEN} 分支最后一次提交commit的时间: ${BLUE}${lastCommitDate} ${GREEN}。${NC}"

    if [ -n "$add_value" ]; then
        searchFromDateString=$(sh ${qbase_homedir_abspath}/date/calculate_newdate.sh --old-date "$lastCommitDate" --add-value "$add_value")
        if [ $? != 0 ]; then
            return 1
        fi
    else
        searchFromDateString=$lastCommitDate
    fi


    _verbose_log "${YELLOW}正在执行命令(获取指定日期之后的所有合入记录(已去除 HEAD -> 等)):《 ${BLUE} sh ${qbase_homedir_abspath}/branch/get_merger_recods_after_date.sh --searchFromDateString \"${searchFromDateString}\" ${YELLOW}》${NC}"
    mergerRecordResult=$(sh ${qbase_homedir_abspath}/branch/get_merger_recods_after_date.sh --searchFromDateString "${searchFromDateString}")
    if [ -z "$mergerRecordResult" ]; then  # 没有新commit,提前结束 
        _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录: ${BLUE}没有新的提交记录，更不用说分支了 ${GREEN}。${NC}"
        echo "${mergerRecordResult}" 
        return 0
    fi
    _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录: ${BLUE}${mergerRecordResult} ${GREEN}。${NC}"


    # if [ -n "$onlyThisBranchLine" ]; then
    #     currentBranchResult=$(git branch --show-current) # 获取当前分支
    #     # _verbose_log "正准备添加当前分支:$currentBranchResult"
    #     # mergerRecordResult+=" ${currentBranchResult}"
    # fi

    mergerRecordResult=$(optimizeBranchNames "${mergerRecordResult}")

    echo "${mergerRecordResult}"

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



getBranchNames_accordingToRebaseBranch "$REBASE_BRANCH" "$add_value"

