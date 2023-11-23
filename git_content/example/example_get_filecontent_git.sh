#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 14:16:00
 # @Description: 测试git上的文件的内容的获取
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


GIT_SCIRTP_DIR_PATH=${CategoryFun_HomeDir_Absolute}
qbase_get_filecontent_gitlab_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_filecontent_gitlab.sh
qbase_get_filecontent_git_all_scriptPath=${CategoryFun_HomeDir_Absolute}/get_filecontent_git_all.sh



function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}



function testLocal {
    log_title "0.local"
    FILE_URL="${Example_HomeDir_Absolute}/test_this_is_test.json"
    cat "${FILE_URL}" | jq '.'
}

function testGithub {
    log_title "1.github"
    # github token 获取方式:进入 https://github.com/settings/tokens 创建（个人设置 -- 底部的Developer Settings -- 配置repo来支持repo中的数据读权限)
    access_token="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"
    curBranchName="test/test1"
    FILE_URL="https://raw.githubusercontent.com/dvlpCI/script-qbase/test/test1/branchMaps_10_resouce_get/example/featureBrances/this_is_test.json"
}

function testGitee {
    log_title "2.gitee"
    curBranchName="dev_script_pack"
    FILE_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/raw/dev_script_pack/example_packing_info/featureBrances/this_is_test.json"
}

function testGitlab {
    log_title "3.gitlab"

    personal_access_token="glpat-mU-BBsFtjkNWa6NSaZ37" # 四种权限
    project_access_token="glpat-xTEsz89Km9N1dessU56p"
    access_token=${personal_access_token}

    curBranchName="chore/pack"
    FILE_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/raw/chore/pack/bulidScript/featureBrances/this_is_test.json"
    # git_file_content=$(sh ${qbase_get_filecontent_gitlab_scriptPath} -fileUrl "${FILE_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}")
    # if [ $? != 0 ]; then
    #     echo "${git_file_content}"
    #     exit 1
    # fi
    
    # printf "%s" "${git_file_content}" | jq '.'
}

function dealFound() {
    # sh $qbase_get_filecontent_git_all_scriptPath -fileUrl "${FILE_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}"
    # return
    git_file_content=$(sh $qbase_get_filecontent_git_all_scriptPath -fileUrl "${FILE_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}")
    if [ $? != 0 ]; then
        echo "${git_file_content}"
        exit 1
    fi
    
    printf "%s" "${git_file_content}" | jq '.'
}


testLocal
testGithub && dealFound
testGitee && dealFound
testGitlab && dealFound
