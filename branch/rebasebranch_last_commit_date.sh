#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 20:59:57
 # @Description: 获取当前分支新代码的起始时间
 # @使用示例: sh ./branch/rebasebranch_last_commit_date.sh --old-date $old_date --add-value "1" --add-type "second"
### 
#responseResult=$(git log --graph --pretty=format:'%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges )
#responseResult=$(git log --pretty=format:'%s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges)

#responseResult=$(git log --pretty=format:'%C(yellow)%H' --after "10-12-2022" --no-merges )

#git log --pretty=format:'-%C(yellow)%d%Creset %s' --after "2022-10-16"

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
    if [ "${isRelease}" == true ]; then
        echo "$1"
    fi
}

# 获取指定分支的最后一次提交时间
function getBranchLastCommitDate() {
    branchName=$1

    debug_log "正在执行命令(获取指定分支的最后一次提交时间)：《 git log -1 --pretty=format:'%Cgreen%cd' --date=format:'%Y-%m-%d %H:%M:%S' ${branchName}  》"
    branchLastCommitDateResult=$(git log -1 --pretty=format:'%Cgreen%cd' --date=format:'%Y-%m-%d %H:%M:%S' ${branchName})
    if [ $? != 0 ]; then
        echo "❌Error: $FUNCNAME 获取指定分支的最后一次提交时间发生了错误.执行的命令是《git log -1 --pretty=format:'%Cgreen%cd' --date=format:'%Y-%m-%d %H:%M:%S' ${branchName}》"
        return 1
    fi
    #branchLastCommitDateResult="2022-10-20 17:19:47"
    echo "${branchLastCommitDateResult}"
}


echo $(getBranchLastCommitDate "$REBASE_BRANCH")
