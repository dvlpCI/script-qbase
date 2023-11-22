#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-23 01:47:28
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
    inBranchName="test/test3"
    Directory_URL="${CategoryFun_HomeDir_Absolute}/example/featureBrances"
}

function testGithub {
    log_title "1.github"
    inBranchName="optimize/dev_script_pack"
    access_token="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"    #token获取:进入 https://github.com/settings/tokens 创建
    Directory_URL="https://github.com/dvlpCI/script-qbase/tree/main/branchMaps_10_resouce_get/example/featureBrances"
}

function testGitee {
    log_title "2.gitee"
    inBranchName="dev_script_pack"
    Directory_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances"
}

function testGilab {
    log_title "3.gitlab"
    inBranchName="chore/pack"
    access_token="glpat-xTEsz89Km9N1dessU56p"
    Directory_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/master/bulidScript/featureBrances"
}

function dealFound() {
    git_file_content=$(sh $qbase_get_filecontent_git_all_scriptPath -fileUr "${FILR_URL}" -access-token "${access_token}")
    if [ $? != 0 ]; then
        echo "${git_file_content}"
        exit 1
    fi
    
    printf "%s" "${git_file_content}"
}


testLocal && dealFound
testGithub && dealFound
testGitee && dealFound
testGilab && dealFound
