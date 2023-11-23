#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 11:29:21
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
qbase_get_fileUrls_inDir_local_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_local.sh
qbase_get_fileUrls_inDir_github_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_github.sh
qbase_get_fileUrls_inDir_gitee_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitee.sh
qbase_get_fileUrls_inDir_gitlab_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitlab.sh


# repository_url="https://github.com/dvlpCI/script-qbase/tree/test/test1/branchMaps_10_resouce_get/example/featureBrances"
# # GitHub仓库地址
# # repository_url="https://github.com/username/repository.git"  # 替换为实际的GitHub仓库地址

# # 提取分支名
# # 提取分支名
# branch=$(echo "$repository_url" | awk -F'/' '{print $6}')

# # 输出分支名
# echo "$branch"
# exit


function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}


function testLocal {
    log_title "0.local"
    GIT_DIRECTORY_URL="${CategoryFun_HomeDir_Absolute}/example"

    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_local_scriptPath -dirUrl "${GIT_DIRECTORY_URL}")
    if [ $? != 0 ]; then
        echo "${RED}${fileDownloadUrlArrayString}${NC}"    # 此时此值是错误信息
        exit 1
    fi
}

function testGithub {
    log_title "1.github"
    # github token 获取方式:进入 https://github.com/settings/tokens 创建（个人设置 -- 底部的Developer Settings -- 配置repo来支持repo中的数据读权限)
    access_token="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"
    # script-qbase 的 test/test1 分支下
    GIT_DIRECTORY_URL="https://github.com/dvlpCI/script-qbase/tree/test/test1/branchMaps_10_resouce_get/example/featureBrances"
    curBranchName="test/test1"
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_github_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}")
    if [ $? != 0 ]; then
        echo "${RED}${fileDownloadUrlArrayString}${NC}"    # 此时此值是错误信息
        exit 1
    fi
}

function testGitee {
    log_title "2.gitee"
    # AutoPackage-CommitInfo 的 dev_script_pack 分支下
    GIT_DIRECTORY_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/dev_script_pack/example_packing_info/featureBrances"
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitee_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}")
    if [ $? != 0 ]; then
        echo "${RED}${fileDownloadUrlArrayString}${NC}"    # 此时此值是错误信息
        exit 1
    fi
}

function testGitlab {
    log_title "3.gitlab"
    access_token="glpat-xTEsz89Km9N1dessU56p"
    # mobile_flutter_wish 的 chore/pack 分支下
    GIT_DIRECTORY_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/chore/pack/bulidScript/featureBrances"
    curBranchName="chore/pack"
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitlab_scriptPath -dirUrl "${GIT_DIRECTORY_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}")
    if [ $? != 0 ]; then
        echo "${RED}${fileDownloadUrlArrayString}${NC}"    # 此时此值是错误信息
        exit 1
    fi
}

function printfUrls() {
    fileDownloadUrlArray=($fileDownloadUrlArrayString)
    fileDownloadUrlCount=${#fileDownloadUrlArray[@]}
    echo "${GREEN}恭喜：您获取的路径有${BLUE} ${fileDownloadUrlCount} ${GREEN}个，分别如下:${NC}"
    for((i=0;i<fileDownloadUrlCount;i++));
    do
        iFileDownloadUrl=${fileDownloadUrlArray[$i]}
        echo "$((i+1)).${BLUE} ${iFileDownloadUrl} ${NC}"
    done
}

testLocal && printfUrls
testGithub && printfUrls
testGitee && printfUrls
testGitlab && printfUrls

