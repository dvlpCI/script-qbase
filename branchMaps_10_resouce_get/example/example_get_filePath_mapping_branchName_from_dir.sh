#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 14:18:30
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

qbase_get_filePath_mapping_branchName_from_dir_scriptPath=${CategoryFun_HomeDir_Absolute}/get_filePath_mapping_branchName_from_dir.sh

        

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
    requestBranchName="optimize/dev_script_pack"
    access_token="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"    #token获取:进入 https://github.com/settings/tokens 创建
    BranceMaps_From_Directory_URL="https://github.com/dvlpCI/script-qbase/tree/main/branchMaps_10_resouce_get/example/featureBrances"
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
    # sh "$qbase_get_filePath_mapping_branchName_from_dir_scriptPath" -requestBranchName "${requestBranchName}" -branchMapsFromDir "${BranceMaps_From_Directory_URL}" -access-token "${access_token}"
    # exit

    mappingBranchName_JsonStrings=$(sh "$qbase_get_filePath_mapping_branchName_from_dir_scriptPath" -requestBranchName "${requestBranchName}" -branchMapsFromDir "${BranceMaps_From_Directory_URL}" -access-token "${access_token}")
    if [ $? != 0 ]; then
        echo "${mappingBranchName_JsonStrings}"
        exit 1
    fi
    if [ -z "${mappingBranchName_JsonStrings}" ]; then
        branchDescription="${YELLOW}很遗憾:${BLUE} ${requestBranchName} ${YELLOW}:提交记录获取失败:未找到匹配分支名的文件。${NC}"
    else
        # echo "mappingBranchName_JsonStrings=${mappingBranchName_JsonStrings}"
        mappingBranchName_FilePathsString=$(printf "%s" "${mappingBranchName_JsonStrings}" | jq -r ".[].fileUrl") # 记得使用-r去除双引号，避免后续路径使用时出错
        # echo "mappingBranchName_FilePathsString=${mappingBranchName_FilePathsString}"
        mappingBranchName_FilePaths=(${mappingBranchName_FilePathsString})

        branchDescription="${GREEN}恭喜:${BLUE} ${requestBranchName} ${GREEN}:提交记录待获取。匹配到的分支信息文件分别为:${BLUE} ${mappingBranchName_FilePaths[*]} ${GREEN}。${NC}"
    fi
    echo "${branchDescription}"
}


testLocal && dealFound
testGithub && dealFound
testGitee && dealFound
testGilab && dealFound
