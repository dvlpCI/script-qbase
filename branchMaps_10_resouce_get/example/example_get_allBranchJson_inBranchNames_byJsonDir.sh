#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-25 01:22:45
 # @Description: 测试获取在指定日期范围内有提交记录的分支
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

qbase_get_only_branch_from_recods_scriptPath=${qbase_homedir_abspath}/branch/get_only_branch_from_recods.sh
qbase_select_branch_byNames_scriptPath=${qbase_homedir_abspath}/branch/select_branch_byNames.sh
qbase_get_allBranchJson_inBranchNames_byJsonDir_scriptPath=${CategoryFun_HomeDir_Absolute}/get_allBranchJson_inBranchNames_byJsonDir.sh
qbase_getBranchMapsInfoAndNotifiction_scriptPath=${qbase_homedir_abspath}/branch_quickcmd/getBranchMapsInfoAndNotifiction.sh

example_remote_branchs_json_github_filePath=${Example_HomeDir_Absolute}/example_remote_branchs_json_github.json
example_remote_branchs_json_gitee_filePath=${Example_HomeDir_Absolute}/example_remote_branchs_json_gitee.json
example_remote_branchs_json_gitlab_filePath=${Example_HomeDir_Absolute}/example_remote_branchs_json_gitlab.json

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}


function getRequestBranchNames() {
    # 获取远程分支列表
    branchNames=$(git branch -r)
    # branchNames=$(git branch -l --format=%\(refname:short\)) # 这里要加上 --format=%\(refname:short\) 否则结果里可能出现*星号
    # echo "======branchNames=${branchNames}"
    # sh $qbase_get_only_branch_from_recods_scriptPath -recordsString "${branchNames[*]}" -branchShouldRemoveOrigin "false"
    # exit 
    # 不能去除origin，否则git取分支信息的时候会变成取本地，而本地又没该分支的错误现象了
    branchNamesString=$(sh $qbase_get_only_branch_from_recods_scriptPath -recordsString "${branchNames[*]}" -branchShouldRemoveOrigin "false")
    if [ $? -ne 0 ]; then
        echo "${branchNamesString}"
        return 1
    fi
    # echo "======branchNamesString=${branchNamesString}==="
    
    # sh $qbase_select_branch_byNames_scriptPath -branchNames "${branchNamesString}" -ignoreBranchNameOrRules "${ignoreBranchNameOrRules}" -create-startDate "${create_start_date}" -lastCommit-startDate "${lastCommit_start_date}"
    # if [ $? -ne 0 ]; then
    #     return 1
    # else
    #     return 0
    # fi

    # echo "${YELLOW}正在执行命令(筛选符合条件的分支名):《${BLUE} sh $qbase_select_branch_byNames_scriptPath -branchNames \"${branchNamesString}\" -ignoreBranchNameOrRules \"${ignoreBranchNameOrRules}\" -create-startDate \"${create_start_date}\" -lastCommit-startDate \"${lastCommit_start_date}\" ${YELLOW}》${NC}"
    branchGitInfoString=$(sh $qbase_select_branch_byNames_scriptPath -branchNames "${branchNamesString}" -ignoreBranchNameOrRules "${ignoreBranchNameOrRules}" -create-startDate "${create_start_date}" -lastCommit-startDate "${lastCommit_start_date}")
    if [ $? != 0 ]; then
        echo "${branchGitInfoString}"
        return 1
    fi
    if ! jq -e . <<< "$branchGitInfoString" >/dev/null 2>&1; then
        echo "qbase_select_branch_byNames_scriptPath 失败，返回的结果不是json"
        echo "❌branchGitInfoString=${branchGitInfoString}"
        return 1
    fi
    # echo "✅恭喜：您从分支名中筛选符合条件的分支信息(含修改情况)的结果如下:${branchGitInfoString}"
    
    errorBranchGitInfoString=$(printf "%s" "${branchGitInfoString}" | jq -r ".errors")
    # echo "======errorBranchGitInfoString=${errorBranchGitInfoString}"
    errorBranchGitInfoCount=$(printf "%s" "${errorBranchGitInfoString}" | jq -r ".|length")
    if [ "${errorBranchGitInfoCount}" -gt 0 ]; then
        echo "你有 ${errorBranchGitInfoCount} 个分支获取失败了，分别如下："
        # echo "${errorBranchGitInfoString}" | jq "."
        for((i=0;i<errorBranchGitInfoCount;i++));
        do
            iErrorBranchGitInfoString=$(printf "%s" "${errorBranchGitInfoString}" | jq -r ".[${i}]")
            echo "$((i+1)). ${iErrorBranchGitInfoString}"
        done
        return 1
    fi
    matchBranchGitInfoString=$(printf "%s" "${branchGitInfoString}" | jq -r ".eligibles")
    unmatchBranchGitInfoString=$(printf "%s" "${branchGitInfoString}" | jq -r ".ineligibles")

    matchBranchNamesString=$(printf "%s" "${matchBranchGitInfoString}" | jq -r '.[].branch_name')
    printf "%s" "${matchBranchNamesString}"
}


function testGithub {
    log_title "1.github"
    # 获取要请求的分支列表
    ignoreBranchNameOrRules="unuse/* test/*"
    create_start_date=""        # 若有值，创建时间早于该值不显示
    lastCommit_start_date=""    # 若有值，最后修改时间早于该值不显示(即该时间值之后没有提交的不显示)
    requestBranchNames=$(getRequestBranchNames)
    echo "您当前项目${BLUE} ${PWD} ${NC}获取信息的远程分支名分别是${BLUE} ${requestBranchNames} ${NC}"
    # exit
    
    # github token 获取方式:进入 https://github.com/settings/tokens 创建（个人设置 -- 底部的Developer Settings -- 配置repo来支持repo中的数据读权限)
    access_token="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"
    
    ONE_OF_DIRECTORY_URL="https://github.com/dvlpCI/script-qbase/tree/test/test1/branchMaps_10_resouce_get/example/featureBrances"
    DIRECTORY_URL_BranchName="test/test1"
    example_remote_branchs_json_filePath=${example_remote_branchs_json_github_filePath}
}


function testGitee {
    log_title "2.gitee"
    # 获取要请求的分支列表
    ignoreBranchNameOrRules="unuse/* test/*"
    create_start_date=""        # 若有值，创建时间早于该值不显示
    lastCommit_start_date=""    # 若有值，最后修改时间早于该值不显示(即该时间值之后没有提交的不显示)
    # requestBranchNames="master test3 test/test1"
    requestBranchNames=$(getRequestBranchNames)
    echo "您当前项目${BLUE} ${PWD} ${NC}获取信息的远程分支名分别是${BLUE} ${requestBranchNames} ${NC}"
    # exit

    ONE_OF_DIRECTORY_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/dev_script_pack/example_packing_info/featureBrances"
    DIRECTORY_URL_BranchName="dev_script_pack"
    example_remote_branchs_json_filePath=${example_remote_branchs_json_gitee_filePath}
}


function testGitlab {
    log_title "3.gitlab"
    # 获取要请求的分支列表
    ignoreBranchNameOrRules="unuse/* test/*"
    create_start_date=""        # 若有值，创建时间早于该值不显示
    lastCommit_start_date=""    # 若有值，最后修改时间早于该值不显示(即该时间值之后没有提交的不显示)
    requestBranchNames="origin/chore/ipa_backup origin/chore/pack origin/dev_route_trantive"
    requestBranchNames=$(getRequestBranchNames)
    # getRequestBranchNames
    echo "您当前项目${BLUE} ${PWD} ${NC}获取信息的远程分支名分别是${BLUE} ${requestBranchNames} ${NC}"
    # exit

    access_token="glpat-xTEsz89Km9N1dessU56p"

    ONE_OF_DIRECTORY_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/chore/pack/bulidScript/featureBrances"
    DIRECTORY_URL_BranchName="chore/pack"
    example_remote_branchs_json_filePath=${example_remote_branchs_json_gitlab_filePath}
}


function dealFound() {
    echo "${YELLOW}正在执行测试名(获取所有json):《${BLUE} sh \"$qbase_get_allBranchJson_inBranchNames_byJsonDir_scriptPath\" -requestBranchNames \"${requestBranchNames}\" -access-token \"${access_token}\" -oneOfDirUrl \"${ONE_OF_DIRECTORY_URL}\" -dirUrlBranchName \"${DIRECTORY_URL_BranchName}\" ${YELLOW}》${NC}"
    # sh "$qbase_get_allBranchJson_inBranchNames_byJsonDir_scriptPath" -requestBranchNames "${requestBranchNames}" -access-token "${access_token}" -oneOfDirUrl "${ONE_OF_DIRECTORY_URL}" -dirUrlBranchName "${DIRECTORY_URL_BranchName}"
    # return
    allBranchJsonStrings=$(sh "$qbase_get_allBranchJson_inBranchNames_byJsonDir_scriptPath" -requestBranchNames "${requestBranchNames}" -access-token "${access_token}" -oneOfDirUrl "${ONE_OF_DIRECTORY_URL}" -dirUrlBranchName "${DIRECTORY_URL_BranchName}")
    if [ $? != 0 ]; then
        echo "${allBranchJsonStrings}"
        exit 1
    fi

    # echo ""
    echo "${GREEN}恭喜:获取所有远程的分支信息(每个分支从它自己的分支里提取)分支总结:${NC}"
    printf "%s" "${allBranchJsonStrings}" | jq "."

    lastJson='
    {
        "branchJsons": '${allBranchJsonStrings}'
    }
    '
    printf "%s" "$lastJson" > ${example_remote_branchs_json_filePath}
    open "${example_remote_branchs_json_filePath}"

    test_getAllBranchLogArray_andCategoryThem
}


function test_getAllBranchLogArray_andCategoryThem() {
    branchMapsInJsonFile=${example_remote_branchs_json_filePath}
    branchMapsInKey="branchJsons"

    showBranchLogFlag='true'
    showBranchName='true'
    showBranchTimeLog='all'
    showBranchAtLog='true'
    showBranchTable='false' # 通知也暂时都不显示
    showCategoryName='true' # 通知时候显示
    shouldMarkdown='true'

    TEST_ROBOT_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"

    sh $qbase_getBranchMapsInfoAndNotifiction_scriptPath -branchMapsInJsonF "${branchMapsInJsonFile}" -branchMapsInKey "${branchMapsInKey}" \
    -showCategoryName "${showCategoryName}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -showTable "${showBranchTable}" -shouldMD "${shouldMarkdown}"\
    -robot "${TEST_ROBOT_URL}"
    

    echo ""
    echo "${YELLOW}更多详情请可点击查看文件:${BLUE} ${example_remote_branchs_json_filePath}${NC}"
}


testGithub && dealFound
# testGitee && dealFound
# testGitlab && dealFound
