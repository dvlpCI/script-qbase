#!/bin/bash

# 获取目录下的所有文件路径--github

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

# responseJsonString='{
#     "code": 0
# }'
# responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
# printf "%s" "${responseJsonString}"

while [ -n "$1" ]
do
    case "$1" in
        -dirUrl|--dir-url) DIRECTORY_URL=$2; shift 2;;
        -access-token|--access-token) access_token=$2; shift 2;;
        -inBranchName|--in-branch-name) inBranchName=$2 shift 2;;
        --) break ;;
        *) break ;;
    esac
done


function changeToRawUrl_gitlab() {
    input=$1
    if [[ $input != http* ]]; then
        echo "您要转化的地址 ${input} 不是以 http 开头，请检查"
        exit 1
    fi
    target=${input/tree/raw}    # 将 "blob" 替换为指定变量的值
    echo "${target}"
}


function changeToApiUrl_gitlab() {
    # 输入字符串
    # input="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/master/bulidScript/featureBrances"
          #  https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/raw/version/v1.7.4_1121/bulidScript/featureBrances/chore_pack.json
    input=$1
    if [[ $input != http* ]]; then
        echo "您要转化的地址 ${input} 不是以 http 开头，请检查"
        exit 1
    fi

    # 1、截取各内容
    project_host_removed_suffix=$(echo "$input" | sed -E 's/\.com.*$//')    # 去掉.com/之后(含.com)的字符串
    # echo "project_host_removed_suffix=${project_host_removed_suffix}"
    project_host_removed_suffix="${project_host_removed_suffix}.com"
    # echo "project_host_removed_suffix=${project_host_removed_suffix}"


    project_removed_suffix=$(echo "$input" | sed -e 's/\/-.*//')   # 去掉/-之后的字符串
    # echo "project_removed_suffix=${project_removed_suffix}"

    all_raw_home_url="${project_removed_suffix}/-/raw"

    project_removed_prefix=$(echo "$project_removed_suffix" | sed -e 's/.*\.com\///')    # 去掉.com/之前的字符串
    # echo "project_removed_prefix=${project_removed_prefix}"
    project_encoded_string=$(echo "$project_removed_prefix" | sed 's/\//%2F/g') # 将/替换成%2F
    # echo "project_encoded_string=${project_encoded_string}"


    project_path_removed_prefix=$(echo "$input" | sed -e 's/.*-\/tree\/master\///')    # 去掉.com/之前的字符串
    # echo "project_path_removed_prefix=${project_path_removed_prefix}"
    project_path_encoded_string=$(echo "$project_path_removed_prefix" | sed 's/\//%2F/g') # 将/替换成%2F
    # echo "project_path_encoded_string=${project_path_encoded_string}"

    # 去除origin/开头
    branchName="master"
    branchName=${branchName#origin/}

    # 2、拼接
    target="${project_host_removed_suffix}/api/v4/projects/${project_encoded_string}/repository/tree?ref=${branchName}&path=${project_path_encoded_string}"
    # successTarget="https://gitlab.xihuanwu.com/api/v4/projects/bojuehui%2Fmobile%2Fmobile_flutter_wish/repository/tree?ref=master&path=bulidScript%2FfeatureBrances"
    # if [ "${target}" != "${successTarget}" ]; then
    #     echo "抱歉，转化失败"
    #     exit 1
    # fi

    # DIRECTORY_URL=${project_removed_suffix//tree/$inBranchName}    # 将 "blob" 替换为指定变量的值
    responseJsonString='{
        "api_url_master_current_dir": "'"${target}"'",
        "raw_url_all_home": "'"${all_raw_home_url}"'"
    }'
    # responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
    printf "%s" "${responseJsonString}"
}


# master_api_dir_url
gitlab_responseJsonString=$(changeToApiUrl_gitlab "${DIRECTORY_URL}")
if [ $? != 0 ]; then
    echo "changeToApiUrl_gitlab ${gitlab_responseJsonString}"
    exit 1
fi
debug_log "${GREEN}恭喜:gitlab转化之后的结果如下:${NC}"
debug_log "${gitlab_responseJsonString}" | jq -r "."


master_api_dir_url=$(printf "%s" "${gitlab_responseJsonString}" | jq -r '.api_url_master_current_dir')
debug_log "master_api_dir_url=${master_api_dir_url}"

# raw_url_all_home
raw_url_all_home=$(printf "%s" "${gitlab_responseJsonString}" | jq -r '.raw_url_all_home')
if [ $? != 0 ]; then
    echo "changeToRawUrl_gitlab ${raw_url_all_home}"
    exit 1
fi
debug_log "raw_url_all_home=${raw_url_all_home}"


# branch_api_dir_url
branch_api_dir_url=${master_api_dir_url/master/$inBranchName}    # 将 "master" 替换为指定变量的值
debug_log "branch_api_dir_url=${branch_api_dir_url}"

# request: 发送带有访问令牌的请求获取目录内容
debug_log "${YELLOW}正在执行命令(获取网络地址对应的内容):《${BLUE} curl -s --header \"Private-Token: $access_token\" \"$branch_api_dir_url\" ${YELLOW}》${NC}"
response=$(curl -s --header "Private-Token: $access_token" "$branch_api_dir_url")
if [ $? != 0 ]; then
    echo "Error❌: 无法获取文件列表。请检查您的身份验证令牌是否正确。"
    exit_script
fi
debug_log "✅response=${response}"
# exit 1

# 解析 JSON 响应，提取 JSON 文件路径
json_file_relPaths=$(echo "$response" | jq -r '.[] | .path')
debug_log "json_file_relPaths=${json_file_relPaths}"
json_file_relPathArray=(${json_file_relPaths})
json_file_count=${#json_file_relPathArray[@]}

fileDownloadUrlArray=()
for((i=0;i<json_file_count;i++));
do
    fileRelPath=${json_file_relPathArray[i]}
    rawFileAbsUrl="${raw_url_all_home}/${inBranchName}/${fileRelPath}"
    # echo "$((i+1)).${rawFileAbsUrl}"
    fileDownloadUrlArray[${#fileDownloadUrlArray[@]}]=${rawFileAbsUrl}
done
printf "%s" "${fileDownloadUrlArray[*]}"