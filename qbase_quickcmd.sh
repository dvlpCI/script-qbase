#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-01 11:28:27
# @Description:
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

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
    if [ "$second_last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
else # 最后一个元素不是 verbose
    verbose=false
    if [ "$last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
fi

args=()
if [ "${verbose}" == true ]; then
    args+=("-verbose")
fi
if [ "${isTestingScript}" == true ]; then
    args+=("test")
fi

function _verbose_log() {
    if [ "$verbose" == true ]; then
        echo "$1"
    fi
}


qbase_homedir_abspath="$(cd "$(dirname "$0")" && pwd)" # 本地测试



function quickCmdExec() {
    # allArgsForQuickCmd="$@"
    # _verbose_log "✅快捷命令及其所有参数分别为 ${BLUE}${allArgsForQuickCmd}${BLUE} ${NC}"
    if [ -z "$1" ]; then
         printf "${YELLOW}提示：您未设置要执行的快捷命令。附:所有支持的快捷命令如下：${NC}\n"
        _logQuickCmd
        return
    fi

    quickCmdString=$1
    allArgArray=($@)
    # _verbose_log "😄😄😄哈哈哈 ${allArgArray[*]}"
    allArgCount=${#allArgArray[@]}
    for ((i=0;i<allArgCount;i+=1))
    {
        if [ $i -eq 0 ]; then
            continue
        fi
        currentArg=${allArgArray[i]}
        quickCmdArgs[${#quickCmdArgs[@]}]=${currentArg}
    }
    _verbose_log "✅快捷命令及其所有参数分别为${BLUE} ${quickCmdString}${BLUE}${NC}:${CYAN}${quickCmdArgs[*]} ${CYAN}。${NC}"

    if [ "${quickCmdString}" == "getAppVersionAndBuildNumber" ]; then
        sh ${qbase_homedir_abspath}/value_create/value_create_app_version_and_build.sh

    elif [ "${quickCmdString}" == "getBranchNamesAccordingToRebaseBranch" ]; then
        _verbose_log "${YELLOW}正在执行命令(根据rebase,获取分支名):《${BLUE} sh ${qbase_homedir_abspath}/branch/getBranchNames_accordingToRebaseBranch.sh ${quickCmdArgs[*]} ${BLUE}》${NC}"
        sh ${qbase_homedir_abspath}/branch/getBranchNames_accordingToRebaseBranch.sh ${quickCmdArgs[*]}
    
    # elif [ "${quickCmdString}" == "getBranchMapsAccordingToBranchNames" ]; then
    #     _verbose_log "${YELLOW}正在执行命令(根据分支名,获取并添加分支信息):《 ${BLUE}sh ${qbase_homedir_abspath}/branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh $quickCmdArgs ${BLUE}》${NC}"
    #     sh ${qbase_homedir_abspath}/branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh ${quickCmdArgs[*]}
        
    elif [ "${quickCmdString}" == "getBranchMapsAccordingToRebaseBranch" ]; then
        _verbose_log "${YELLOW}正在执行命令(根据rebase,获取分支信息并通知给你):《${BLUE} sh ${qbase_homedir_abspath}/branch_quickcmd/getBranchMapsAccordingToRebaseBranch.sh ${quickCmdArgs[*]} ${BLUE}》${NC}"
        sh ${qbase_homedir_abspath}/branch_quickcmd/getBranchMapsAccordingToRebaseBranch.sh ${quickCmdArgs[*]}

    else 
        printf "${RED}抱歉：暂不支持 ${BLUE}$1 ${RED} 快捷命令，请检查${NC}\n"
        exit 1
    fi
}




# 输出sh的所有参数
# echo "传递给脚本的参数列表："
# echo "$@"

quickCmdExec "$@"
