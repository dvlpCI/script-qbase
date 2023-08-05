#!/bin/bash
:<<!
获取指定分支在指定日期后的第一条提交记录及其所属的所有分支
!
#responseResult=$(git log --graph --pretty=format:'%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges )
#responseResult=$(git log --pretty=format:'%s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges)

#responseResult=$(git log --pretty=format:'%C(yellow)%H' --after "10-12-2022" --no-merges )

#git log --pretty=format:'-%C(yellow)%d%Creset %s' --after "2022-10-16"


# shell 参数具名化                                  
while [ -n "$1" ]
do
        case "$1" in
                -date|--searchFromDateString) searchFromDateString=$2; shift 2;;
                -curBranch|--currentBranch) currentBranch=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done

# 检查必要参数是否提供
if [ -z "$searchFromDateString" ] ; then
    echo "${RED}缺少必要参数，不能不传要从哪个时间开始搜索！${NC}"
    exit 1
fi


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

#echo "searchFromDateString=${searchFromDateString}"


function getFirstCommitIdFromDate() {
    searchFromDateString=$1
    
    # echo "\n------下面开始获取本分支在${searchFromDateString}后提交的所有--no-merges记录的commitId------"
    ##noMergesCommitsResponseResult=$(git log --pretty=format:'%s' --after "2022-10-13" --merges)
    debug_log "${YELLOW}正在执行命令(获取本分支在 ${BLUE}${searchFromDateString} ${YELLOW}时间后提交的所有--no-merges记录的commitIds)：《 ${BLUE}git log --pretty=format:'%C(yellow)%H' --after \"${searchFromDateString}\" --no-merges ${YELLOW}》${NC}"
    noMergesCommitsResponseResult=$(git log --pretty=format:'%C(yellow)%H' --after "${searchFromDateString}" --no-merges) # 注意:此处只能打印hash值，不添加%s去打印commit信息，才能避免下面因为有些commit信息有空格或换行，从而导致无法规律性的分断数组，从而找不到最后一条
    noMergesCommitsStringLength=${#noMergesCommitsResponseResult}
    #echo "noMergesCommitsStringLength=${#noMergesCommitsStringLength}"
    if [ ${noMergesCommitsStringLength} == 0 ]; then
        echo "友情提示🤝：本分支在${searchFromDateString}后没有--no-merges的提交记录，所以你的打包将只打包现有的功能"
        return 1
    else
        debug_log "本分支在 ${searchFromDateString} 时间后提交的所有--no-merges记录的commitIds,如下:\n${noMergesCommitsResponseResult}"
    fi

    debug_log "------得到本分支在${searchFromDateString}后第一条--no-merges提交的commitId,如下------"
    noMergesCommitArrayResponseResult=(${noMergesCommitsResponseResult})
    noMergesCommitCountResponseResult=${#noMergesCommitArrayResponseResult[@]}
    #echo "noMergesCommitCountResponseResult=${noMergesCommitCountResponseResult}"

    lastCommitId=${noMergesCommitArrayResponseResult[0]}
    lastCommitMessage=${noMergesCommitArrayResponseResult[1]}
    #echo "lastCommit   = ${lastCommitId} ${lastCommitMessage}"
    #echo "lastCommitId = ${lastCommitId}"

    #:<<!
    #[shell脚本中的加减](https://blog.csdn.net/dong976209075/article/details/7780480?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-7780480-blog-125188842.pc_relevant_3mothn_strategy_recovery&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-7780480-blog-125188842.pc_relevant_3mothn_strategy_recovery&utm_relevant_index=2)
    #firstCommitIndex=`expr ${noMergesCommitCountResponseResult} - 1`
    firstCommitIndex=$((noMergesCommitCountResponseResult-1))
    #echo "firstCommitIndex=${firstCommitIndex}"
    for ((i=0;i<noMergesCommitCountResponseResult;i+=1))
    {
        #imodel=$((i%2))
        commitId=${noMergesCommitArrayResponseResult[i]}
        commitMessage=${noMergesCommitArrayResponseResult[i+1]}
        #echo "${commitId} : ${commitMessage}"
        
        if [ ${i} -lt ${firstCommitIndex} ] ; then
            #echo "${i}:过${commitMessage}"
            continue
        fi
        firstCommitIdResult=${commitId}
        debug_log "firstCommitIdResult = ${firstCommitIdResult}"
        firstCommitDes=$(git show -s --oneline "${firstCommitIdResult}")
        debug_log "firstCommitDes   = ${firstCommitDes}"
    }
    #!
}

function getBranchsWhichContainsCommitId() {
    firstCommitId=$1
    
    debug_log "${YELLOW}正在执行命令(开始获取firstCommitDes: ${CYAN}${firstCommitDes}${YELLOW}这条提交所属的所有远程功能分支名):《 ${BLUE}git branch --contains \"${firstCommitId}\" -r ${YELLOW}》------${NC}"
    #[git获取某次commit是在哪个分支提交的](https://www.jianshu.com/p/6ad6981f8ec5)
    branchResultForFisrtCommit=$(git branch --contains "${firstCommitId}" -r)

    branchArrayForCommitIdResult=(${branchResultForFisrtCommit})
    branchCountForFisrtCommit=${#branchArrayForCommitIdResult[@]}
    #echo "branchCountForFisrtCommit=$branchCountForFisrtCommit"
    #for ((i=0;i<branchCountForFisrtCommit;i+=1))
    #{
    #    branchName=${branchArrayForCommitIdResult[i]}
    #    echo "branchName=${branchName}"
    #}
}


function getFirstCommitAllSourceBranchNameAfterDate() {
    searchFromDateString=$1
    
    getFirstCommitIdFromDate "${searchFromDateString}"
    if [ $? != 0 ]; then
        return 1
    fi
    firstCommitId=${firstCommitIdResult}

    getBranchsWhichContainsCommitId "${firstCommitId}"
    branchArrayForFisrtCommit="${branchArrayForCommitIdResult[*]}"
}

getFirstCommitAllSourceBranchNameAfterDate "${searchFromDateString}"
if [ $? != 0 ]; then
    exit_script
fi

echo '{"sourceBranchNames":"'"$branchArrayForFisrtCommit"'","firstCommitId":"'"$firstCommitId"'","firstCommitDes":"'"$firstCommitDes"'"}'

# echo "${GREEN}============ 恭喜:获得 ${BLUE}${currentBranch} ${GREEN}分支在指定日期${BLUE}${searchFromDateString}${GREEN}后的第一条提交记录【 ${BLUE}${firstCommitId}${GREEN}: ${BLUE}${firstCommitDes}${GREEN} 】的所属所有分支名sourceBranchsNameForFisrtCommit=${BLUE}${branchArrayForFisrtCommit}"
