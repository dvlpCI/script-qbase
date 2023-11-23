#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-24 01:51:42
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

qbase_get_allBranchJson_inBranchNames_byJsonDir_scriptPath=${CategoryFun_HomeDir_Absolute}/get_allBranchJson_inBranchNames_byJsonDir.sh
get_branch_all_detail_info_script_path="${qbase_homedir_abspath}/branchMaps_20_info/get20_branchMapsInfo_byHisJsonFile.sh"

example_remote_branchs_json_github_filePath=${Example_HomeDir_Absolute}/example_remote_branchs_json_github.json

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



function testLocal {
    log_title "0.local"
    requestBranchName="test/test3"
    BranceMaps_From_Directory_URL="${CategoryFun_HomeDir_Absolute}/example/featureBrances"
}

function testGithub {
    log_title "1.github"
    # github token 获取方式:进入 https://github.com/settings/tokens 创建（个人设置 -- 底部的Developer Settings -- 配置repo来支持repo中的数据读权限)
    requestBranchNames="master test3 test/test1"
    access_token="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"
    ONE_OF_DIRECTORY_URL="https://github.com/dvlpCI/script-qbase/tree/test/test1/branchMaps_10_resouce_get/example/featureBrances"
    DIRECTORY_URL_BranchName="test/test1"
    example_remote_branchs_json_filePath=${example_remote_branchs_json_github_filePath}
}

function testGitee {
    log_title "2.gitee"
    requestBranchName="dev_script_pack"
    BranceMaps_From_Directory_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances"
}

function testGilab {
    log_title "3.gitlab"
    requestBranchName="chore/pack"
    access_token="glpat-xTEsz89Km9N1dessU56p"
    BranceMaps_From_Directory_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/master/bulidScript/featureBrances"
}


function dealFound() {
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
    showBranchLogFlag='true'
    showBranchName='true'
    showBranchTimeLog='all'
    showBranchAtLog='true'
    showBranchTable='false' # 通知也暂时都不显示
    showCategoryName='true' # 通知时候显示
    shouldMarkdown='false'
    
    RESULT_SALE_TO_JSON_FILE_PATH=${example_remote_branchs_json_filePath}
    RESULT_BRANCH_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.branch"
    RESULT_CATEGORY_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.category"
    RESULT_FULL_STRING_SALE_BY_KEY="branch_info_result.Notification.current.full"           

    branchMapsInJsonFile=${example_remote_branchs_json_filePath}
    branchMapsInKey="branchJsons"

    echo "${YELLOW}正在执行命令(整合 branchMapsInfo)：《${BLUE} sh $get_branch_all_detail_info_script_path -branchMapsInJsonF \"${branchMapsInJsonFile}\" -branchMapsInKey \".${branchMapsInKey}\" -showCategoryName \"${showCategoryName}\" -showFlag \"${showBranchLogFlag}\" -showName \"${showBranchName}\" -showTime \"${showBranchTimeLog}\" -showAt \"${showBranchAtLog}\" -showTable \"${showBranchTable}\" -shouldMD \"${shouldMarkdown}\" -resultSaveToJsonF \"${RESULT_SALE_TO_JSON_FILE_PATH}\" -resultBranchKey \"${RESULT_BRANCH_ARRAY_SALE_BY_KEY}\" -resultCategoryKey \"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\" -resultFullKey \"${RESULT_FULL_STRING_SALE_BY_KEY}\" ${YELLOW}》${NC}"
    sh $get_branch_all_detail_info_script_path -branchMapsInJsonF "${branchMapsInJsonFile}" -branchMapsInKey ".${branchMapsInKey}" -showCategoryName "${showCategoryName}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -showTable "${showBranchTable}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultBranchKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}" -resultCategoryKey "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -resultFullKey "${RESULT_FULL_STRING_SALE_BY_KEY}"
    

    echo ""
    echo "${YELLOW}更多详情请可点击查看文件:${BLUE} ${example_remote_branchs_json_filePath}${NC}"
}


testGithub && dealFound
# testGitee && dealFound
# testGilab && dealFound