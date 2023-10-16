#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-09 00:25:56
 # @Description: 获取当前分支新代码的起始时间
 # @Example: sh ./branch/rebasebranch_last_commit_date.sh -rebaseBranch "master"
### 
#responseResult=$(git log --graph --pretty=format:'%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges )
#responseResult=$(git log --pretty=format:'%s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges)

#responseResult=$(git log --pretty=format:'%C(yellow)%H' --after "10-12-2022" --no-merges )

#git log --pretty=format:'-%C(yellow)%d%Creset %s' --after "2022-10-16"

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -rebaseBranch|--rebase-branch) REBASE_BRANCH=$2; shift 2;;
                --) break ;;
                *)  break ;;
        esac
done

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

if [ -z "${REBASE_BRANCH}" ]; then
    echo "❌Error:缺少 -rebaseBranch 参数，会导致无法获取到的时间是准确分支(rebase分支)最后一条提交的时间，而是本分支。所以提前报错，请先检查。"
    exit 1
fi

# 获取指定分支的最后一次提交时间
function getBranchLastCommitDate() {
    branchName=$1

    debug_log "正在执行命令(获取指定分支的最后一次提交时间)：《 git log -1 --pretty=format:'%Cgreen%cd' --date=format:'%Y-%m-%d %H:%M:%S' ${branchName}  》"
    branchLastCommitDateResult=$(git log -1 --pretty=format:'%Cgreen%cd' --date=format:'%Y-%m-%d %H:%M:%S' ${branchName})
    if [ $? != 0 ]; then
        echo "${RED}❌Error:获取指定分支的最后一次提交时间发生了错误(如果本地不存在master分支，请使用 origin/master 来替代).执行的命令是《${BLUE} git log -1 --pretty=format:'%Cgreen%cd' --date=format:'%Y-%m-%d %H:%M:%S' ${branchName} ${RED}》${NC}"
        return 1
    fi
    #branchLastCommitDateResult="2022-10-20 17:19:47"
    echo "${branchLastCommitDateResult}"
}


branchLastCommitDateResult=$(getBranchLastCommitDate "$REBASE_BRANCH")
if [ $? != 0 ]; then
    echo "${branchLastCommitDateResult}"
    exit 1
else
    echo "${branchLastCommitDateResult}"
    exit 0
fi