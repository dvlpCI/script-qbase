#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-21 12:51:24
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


# testLocal && dealFound
# testGithub && dealFound
# testGitee && dealFound
# testGilab && dealFound
# exit 1

# gitlab 的json文件获取测试
# personal_access_token="glpat-BBhe_zYnj59Kt4eL35xq" # 仅 read
personal_access_token="glpat-mU-BBsFtjkNWa6NSaZ37" # 四种权限
project_access_token="glpat-xTEsz89Km9N1dessU56p"
headers=(
    "Authorization: Bearer $personal_access_token"  # 替换为新的身份验证令牌
)

project_path="bojuehui/mobile/mobile_flutter_wish"

# 1、获取 projet_id
# [gitlab查看项目ID/projectId](https://blog.csdn.net/LJLLJL20020628/article/details/101852672)
projectname="mobile_flutter_wish"
# https://gitlab.example.com/api/v3/projects?private_token=xxxx&search=projectname
responseJsonString=$(curl -s "https://gitlab.xihuanwu.com/api/v4/projects?private_token=${personal_access_token}&search=${projectname}")
mayMatchProjectCount=$(echo "${responseJsonString}" | jq -r ".|length")
echo "mayMatchProjectCount=${mayMatchProjectCount}"
project_id=""
for((i=0;i<${mayMatchProjectCount};i++));
do
    mayMatchProjectJsonString=$(echo "${responseJsonString}" | jq -r ".[$i]")
    # echo "$((i+1)).${mayMatchProjectJsonString}"
    path_with_namespace=$(echo "${mayMatchProjectJsonString}" | jq -r ".path_with_namespace")
    echo "$((i+1)).${path_with_namespace}"
    if [ "${path_with_namespace}" == "${project_path}" ]; then
        project_id=$(echo "${mayMatchProjectJsonString}" | jq -r ".id")
        echo "$((i+1)).project_id=${project_id}"
        break
    fi
done

if [ -z "${project_id}" ]; then
    echo "project_id is empty"
    exit 1
fi

# exit 1


# 2、通过 project_id 获取其他数据
# curl -s --header "Private-Token: <Your_Access_Token>" "https://gitlab.xihuanwu.com/api/v4/projects/<Project_ID>/repository/files/<File_Path>/raw"
# api_url="https://gitlab.xihuanwu.com/api/v4/projects/<Project_ID>/repository/files/<File_Path>/raw"
# project_id="4"
file_path="bulidScript/featureBrances/chore_pack.json"
file_path=$(echo "$file_path" | sed 's/\//%2F/g') # 将/替换成%2F


# GitLab API相关信息
gitlab_url="https://gitlab.xihuanwu.com"  # 替换为您的GitLab域名

# 构建API URL
api_url="${gitlab_url}/api/v4/projects/${project_id}/repository/files/${file_path}/raw"


echo "api_url:${api_url}"
# curl -s "${api_url}"
# curl -s --header "PRIVATE-TOKEN: ${project_access_token}" "${api_url}"
curl -s --header "Private-Token: ${project_access_token}" "${api_url}"
exit 1

log_title "headers 方式"
# # 执行请求:下载文件列表(GitHub链接:无法直接访问到特定的文件夹和文件。所以尝试使用GitHub API来获取文件列表并下载文件。)
# # api_url="https://api.github.com/repos/dvlpCI/script-qbase/contents/branchMaps_10_resouce_get/example/featureBrances"
blob_url="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/blob/master/bulidScript/featureBrances/chore_pack.json"
raw_url="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/raw/master/bulidScript/featureBrances/chore_pack.json"
viewsource_url="view-source:https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/raw/master/bulidScript/featureBrances/chore_pack.json"
api_url="${blob_url}"
api_url="${raw_url}"
# api_url="${viewsource_url}"
curl -s -H "${headers[@]}" "$api_url"
# fileList=$(curl -s -H "${headers[@]}" "$api_url")

echo "\n"
log_title " access_token 方式"
curl -s --header "Private-Token: ${access_token}" "$api_url"


