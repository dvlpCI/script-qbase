#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 14:05:50
 # @Description: 获取 gitlab 上的文件内容
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

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -fileUrl|--file-url) FILE_URL=$2; shift 2;; # 文件地址
        -access-token|--access-token) access_token=$2; shift 2;; # gitlab有多种token，建议用 personal_access_token ，而不用 project_access_token
        -curBranchName|--cur-branch-name) curBranchName=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [[ $FILE_URL != http* ]]; then
    echo "您要转化的地址 ${FILE_URL} 不是以 http 开头，请检查"
    exit 1
fi

if [ -z "$curBranchName" ]; then
    echo " -curBranchName 参数值不能为空，否则等下无法从路径中获取到文件的相对路径。"
    exit 1
fi
# 去除origin/开头
curBranchName=${curBranchName#origin/}
debug_log "==========curBranchName=${curBranchName}"
if [[ "${FILE_URL}" != *"${curBranchName}"* ]]; then
    echo "您的 -curBranchName 参数值 ${curBranchName} 不是 ${FILE_URL} 文件的分支，请检查"
    exit 1
fi
debug_log "==========curBranchName=${curBranchName} FILE_URL=${FILE_URL}"

if [ -z "${access_token}" ]; then
    echo "缺少 -access-token 参数值，无法获取文件内容，请检查"
    exit 1
fi
personal_access_token=${access_token}
project_access_token=${access_token}


function projectInfoFromFileUrl_gitlab() {
    # 1、 gitlab_base_url
    project_host_removed_suffix=$(echo "$FILE_URL" | sed -E 's/\.com.*$//')    # 去掉.com/之后(含.com)的字符串
    # echo "project_host_removed_suffix=${project_host_removed_suffix}"
    gitlab_base_url="${project_host_removed_suffix}.com"
    # echo "gitlab_base_url=${gitlab_base_url}"

    # 2、 project_path_with_namespace
    project_removed_suffix=$(echo "$FILE_URL" | sed -e 's/\/-.*//')   # 去掉/-之后的字符串
    # echo "project_removed_suffix=${project_removed_suffix}"
    project_path_with_namespace=$(echo "$project_removed_suffix" | sed -e 's/.*\.com\///')    # 去掉.com/之前的字符串
    # echo "project_path_with_namespace=${project_path_with_namespace}"

    # 3、 projectname
    projectname=${project_path_with_namespace##*/} # 取最后的component
    # echo "projectname=${projectname}"
    
    # 4、 file_path
    needRemoveText="${curBranchName}/"
    file_path=$(echo "$FILE_URL" | sed -E "s|.*${needRemoveText}||")   # 去掉needRemoveText之前的字符串(将 sed 命令中的替换分隔符从 / 更改为 |，以避免与 URL 中的斜杠冲突)
    # echo "file_path=${file_path}"

    responseJsonString='{
        "gitlab_base_url": "'"${gitlab_base_url}"'",
        "project_path_with_namespace": "'"${project_path_with_namespace}"'",
        "projectname": "'"${projectname}"'",
        "file_path": "'"${file_path}"'"
    }'
    # responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
    printf "%s" "${responseJsonString}"
}

curBranchName=${curBranchName#origin/}
responseJsonString=$(projectInfoFromFileUrl_gitlab "${FILE_URL}" "${curBranchName}")
if [ $? != 0 ]; then
    echo "${responseJsonString}"    # 此时此值是错误信息
    exit 1
fi


gitlab_base_url=$(printf "%s" "${responseJsonString}" | jq -r '.gitlab_base_url')
project_path_with_namespace=$(printf "%s" "${responseJsonString}" | jq -r '.project_path_with_namespace')
projectname=$(printf "%s" "${responseJsonString}" | jq -r '.projectname')
file_path=$(printf "%s" "${responseJsonString}" | jq -r '.file_path')
debug_log "==========gitlab_base_url=${gitlab_base_url}"
debug_log "==========project_path_with_namespace=${project_path_with_namespace}"
debug_log "==========projectname=${projectname}"
debug_log "==========file_path=${file_path}"


# 1、获取 projet_id
# [gitlab查看项目ID/projectId](https://blog.csdn.net/LJLLJL20020628/article/details/101852672)
# https://gitlab.example.com/api/v4/projects?private_token=xxxx&search=projectname
responseJsonString=$(curl -s "${gitlab_base_url}/api/v4/projects?private_token=${personal_access_token}&search=${projectname}")
mayMatchProjectCount=$(echo "${responseJsonString}" | jq -r ".|length")
# echo "mayMatchProjectCount=${mayMatchProjectCount}"
project_id=""
for((i=0;i<${mayMatchProjectCount};i++));
do
    mayMatchProjectJsonString=$(echo "${responseJsonString}" | jq -r ".[$i]")
    # echo "$((i+1)).${mayMatchProjectJsonString}"
    i_path_with_namespace=$(echo "${mayMatchProjectJsonString}" | jq -r ".path_with_namespace")
    # echo "$((i+1)).${i_path_with_namespace}"
    if [ "${i_path_with_namespace}" == "${project_path_with_namespace}" ]; then
        project_id=$(echo "${mayMatchProjectJsonString}" | jq -r ".id")
        # echo "$((i+1)).project_id=${project_id}"
        break
    fi
done

if [ -z "${project_id}" ]; then
    echo "project_id is empty"
    exit 1
fi
debug_log "=============project_id=${project_id}"
# exit 1


# 2、通过 project_id 获取其他数据
# curl -s --header "Private-Token: <Your_Access_Token>" "https://gitlab.xihuanwu.com/api/v4/projects/<Project_ID>/repository/files/<File_Path>/raw"
# api_url="https://gitlab.xihuanwu.com/api/v4/projects/<Project_ID>/repository/files/<File_Path>/raw"
# project_id="4"
file_path=$(echo "$file_path" | sed 's/\//%2F/g') # 将/替换成%2F


# 构建API URL
api_url="${gitlab_base_url}/api/v4/projects/${project_id}/repository/files/${file_path}/raw"
# 判断是否存在 '?'
if [[ $api_url == *"?"* ]]; then
  api_url+="&"
else
  api_url+="?"
fi
api_url+="ref=${curBranchName}"
debug_log "=============api_url=${api_url}"

FileContent=$(curl -s --header "Private-Token: ${project_access_token}" "${api_url}")
if [ $? != 0 ]; then
    echo "====${FileContent}"   # 此时此值是错误信息
    exit 1
fi

# message=$(echo "${FileContent}" | jq -r ".message")
# 检查字符串是否包含指定字符串变量
errorFlagString="404 File Not Found"
if [[ $FileContent == *"$errorFlagString"* ]]; then
    echo "获取网络地址内容失败，在 ${curBranchName} 上位找到你想要的 ${file_path} 文件，请检查。执行的命令为 《 curl -s --header \"Private-Token: ${project_access_token}\" \"${api_url}\" 》。得到的值为 $FileContent"
    # echo "所获得的错误内容如下:\n${FileContent}"
    exit 1
fi

printf "%s" "${FileContent}"









# log_title "headers 方式"
# headers=(
#     "Authorization: Bearer $personal_access_token"  # 替换为新的身份验证令牌
# )
# # # 执行请求:下载文件列表(GitHub链接:无法直接访问到特定的文件夹和文件。所以尝试使用GitHub API来获取文件列表并下载文件。)
# # # api_url="https://api.github.com/repos/dvlpCI/script-qbase/contents/branchMaps_10_resouce_get/example/featureBrances"
# blob_url="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/blob/master/bulidScript/featureBrances/chore_pack.json"
# raw_url="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/raw/master/bulidScript/featureBrances/chore_pack.json"
# viewsource_url="view-source:https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/raw/master/bulidScript/featureBrances/chore_pack.json"
# api_url="${blob_url}"
# api_url="${raw_url}"
# # api_url="${viewsource_url}"
# curl -s -H "${headers[@]}" "$api_url"
# # fileList=$(curl -s -H "${headers[@]}" "$api_url")

# echo "\n"
# log_title " access_token 方式"
# curl -s --header "Private-Token: ${access_token}" "$api_url"


