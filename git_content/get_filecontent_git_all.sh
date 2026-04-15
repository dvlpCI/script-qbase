#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-22 23:35:57
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-16 04:04:50
 # @FilePath: get_filecontent_git_all.sh
 # @Description: 获取网络文件的内容-git
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}


CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_get_filecontent_gitlab_scriptPath=${CurCategoryFun_HomeDir_Absolute}/get_filecontent_gitlab.sh



# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -fileUrl|--file-url) FILE_URL=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
        -access-token|--access-token) access_token=$2; shift 2;;
        -curBranchName|--cur-branch-name) curBranchName=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [[ ! $FILE_URL == http* ]]; then
    echo "Error❌: 您的 -fileUrl 参数的值 ${FILE_URL} 不是一个正确的网络文件url地址，请检查."
    exit 1
fi

if [ -z "$curBranchName" ]; then
    echo "请求git的网络文件内容的时候 -curBranchName 参数值不能为空，否则等下无法从路径中获取到文件的相对路径。"
    exit 1
fi

function curl_with_auth() {
    local header_type=$1
    local header_value=""
    
    case "$header_type" in
        bearer)
            header_value="Authorization: Bearer $access_token"
            ;;
        private_token)
            header_value="Private-Token: $access_token"
            ;;
        none)
            ;;
        *)
            echo "Error❌: 不支持的认证类型: $header_type"
            exit 1
            ;;
    esac
    
    if [ -n "$header_value" ]; then
        curl -s -H "$header_value" "$FILE_URL"
    else
        curl -s "$FILE_URL"
    fi
}

function check_error() {
    local content=$1
    local platform=$2
    
    if [ $? != 0 ]; then
        echo "Error❌: 无法获取文件内容，请检查网络连接"
        exit 1
    fi
    
    if [[ $content == *"Bad credentials"* ]]; then
        echo "Error❌: ${platform} Token 无效或已过期，请检查: https://github.com/settings/tokens (GitHub) 或 https://gitee.com/profile/personal_access_tokens (Gitee)"
        exit 1
    fi
    
    if [[ $content == *"Not Found"* ]]; then
        echo "Error❌: 文件不存在或没有访问权限"
        exit 1
    fi
    
    if [[ $content == *"login"* ]] && [[ $content == *"password"* ]]; then
        echo "Error❌: 获取文件内容失败，可能需要登录"
        exit 1
    fi
}

if [[ "${FILE_URL}" == *"https://raw.githubusercontent.com"* ]]; then
    curl_with_auth "none"

elif [[ "${FILE_URL}" == *"https://gitee"* ]]; then   # https://gitee.com/profile/personal_access_tokens/
    FileContent=$(curl_with_auth "private_token")
    check_error "$FileContent" "Gitee"

elif [[ "${FILE_URL}" == *"https://github.com"* ]]; then
    FileContent=$(curl_with_auth "bearer")
    check_error "$FileContent" "GitHub"

elif [[ "${FILE_URL}" == *"https://gitlab"* ]]; then
    debug_log "正在读取gitlab文件内容:《 sh $qbase_get_filecontent_gitlab_scriptPath -fileUrl \"${FILE_URL}\" -access-token \"${access_token}\" -curBranchName \"${curBranchName}\" 》"
    # sh $qbase_get_filecontent_gitlab_scriptPath -fileUrl "${FILE_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}"
    FileContent=$(sh $qbase_get_filecontent_gitlab_scriptPath -fileUrl "${FILE_URL}" -access-token "${access_token}" -curBranchName "${curBranchName}")
    if [ $? != 0 ]; then
        echo "${FileContent}"   # 此时此值是错误信息
        exit 1
    fi

else
    echo "您输入的文件源地址 ${FILE_URL} 不是 git 地址"
    exit 1
fi

printf "%s" "${FileContent}"