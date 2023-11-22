#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-23 01:38:54
 # @Description: 测试获取目录下的所有文件路径--git
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


GIT_SCIRTP_DIR_PATH=${CategoryFun_HomeDir_Absolute}
qbase_get_fileUrls_inDir_github_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_github.sh
qbase_get_fileUrls_inDir_gitee_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitee.sh
qbase_get_fileUrls_inDir_gitlab_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitlab.sh

        

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}



function testLocal {
    log_title "0.local"
    inBranchName="test/test3"
    GIT_DIRECTORY_URL="${CategoryFun_HomeDir_Absolute}/example/featureBrances"

    # fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitee_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}")
    # if [ $? != 0 ]; then
    #     echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
    #     exit_script
    # fi
}

function testGithub {
    log_title "1.github"
    inBranchName="optimize/dev_script_pack"
    access_token="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"    #token获取:进入 https://github.com/settings/tokens 创建
    GIT_DIRECTORY_URL="https://github.com/dvlpCI/script-qbase/tree/main/branchMaps_10_resouce_get/example/featureBrances"

    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_github_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}")
    if [ $? != 0 ]; then
        echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
        exit_script
    fi
}

function testGitee {
    log_title "2.gitee"
    inBranchName="dev_script_pack"
    GIT_DIRECTORY_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances"

    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitee_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}")
    if [ $? != 0 ]; then
        echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
        exit_script
    fi
}

function testGilab {
    log_title "3.gitlab"
    inBranchName="chore/pack"
    access_token="glpat-xTEsz89Km9N1dessU56p"
    GIT_DIRECTORY_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/master/bulidScript/featureBrances"

    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitlab_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}")
    if [ $? != 0 ]; then
        echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
        exit_script
    fi
}


testLocal
testGithub
testGitee
testGilab

