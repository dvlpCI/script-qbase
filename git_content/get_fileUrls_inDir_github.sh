#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-22 23:39:42
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 11:02:27
 # @FilePath: get_fileUrls_inDir_github.sh
 # @Description: 获取目录下的所有文件路径--github
 # @Other: github token 获取方式:进入 https://github.com/settings/tokens 创建（个人设置 -- 底部的Developer Settings -- 配置repo来支持repo中的数据读权限)
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


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -dirUrl|--dir-url) DIRECTORY_URL=$2; shift 2;;
        -access-token|--access-token) access_token=$2; shift 2;;
        -curBranchName|--cur-branch-name) curBranchName=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [ -z "${curBranchName}" ]; then
    echo "您的 -curBranchName 参数值为空，但github 暂时需要提供您的 -dirUrl 参数值 ${DIRECTORY_URL} 目前是哪个分支的，否则无法获取到文件列表。所以请检查。"
    exit 1
fi
# 去除origin/开头
curBranchName=${curBranchName#origin/}
debug_log "==========curBranchName=${curBranchName}"

if [[ "${DIRECTORY_URL}" != *"${curBranchName}"* ]]; then
    echo "您的 -curBranchName 参数值 ${curBranchName} 不是 ${DIRECTORY_URL} 的分支，请检查"
    exit 1
fi
debug_log "==========curBranchName=${curBranchName} DIRECTORY_URL=${DIRECTORY_URL}"

needReplaceText="tree/${curBranchName}"

# 将字符串中的内容进行替换
newUrl="${DIRECTORY_URL/https:\/\/github.com/https://api.github.com/repos}" # 前面\要转义，后面不用
api_url="${newUrl/${needReplaceText}/contents}" # 替换
# 判断是否存在 '?'
if [[ $api_url == *"?"* ]]; then
  api_url+="&"
else
  api_url+="?"
fi
api_url+="ref=${curBranchName}"
# echo "====api_url=${api_url}"
# exit


headers=(
    "Authorization: Bearer $access_token"  # 替换为新的身份验证令牌
)
# 执行请求:下载文件列表(GitHub链接:无法直接访问到特定的文件夹和文件。所以尝试使用GitHub API来获取文件列表并下载文件。)
# api_url="https://api.github.com/repos/dvlpCI/script-qbase/contents/branchMaps_10_resouce_get/example/featureBrances"
fileList=$(curl -s -H "${headers[@]}" "$api_url")
if [ $? != 0 ]; then
    echo "无法获取github文件列表。请检查您的身份验证令牌是否正确。详细的错误信息为:${fileList}"
    exit 1
fi
# 检查是否超过API请求限制
if [[ $fileList == *"Bad credentials"* ]]; then
    echo "获取git目录下的所有文件路径的凭证无效，请检查您的token值 ${access_token} 是否正确。或者进入git查看token是否已过期或者被删除(github请进入: https://github.com/settings/tokens ) 。详细的错误信息为:${fileList} ."
    exit 1
elif [[ $fileList == *"API rate limit exceeded"* ]]; then
    echo "超过API请求限制。请稍后再试。${fileList}"
    exit 1
fi
# echo "================fileList=${fileList}"


# 使用jq解析JSON并获取类型
json_type=$(echo "$fileList" | jq -r 'type')
if [[ "$json_type" != "array" ]]; then #  # 获取成功结果是数组，所以如果不是数组，则当做请求失败(array数组、object字典)
    echo "获取github文件列表失败，请检查。详细的错误信息为:${fileList}"
    exit 1
fi

# exit
# [
#   {
#     "name": "branch_get.json",
#     "path": "branchMaps_10_resouce_get/example/featureBrances/branch_get.json",
#     "sha": "436851fbe0b094a31ca3f68fc18a4f4a5690aaa4",
#     "size": 372,
#     "url": "https://api.github.com/repos/dvlpCI/script-qbase/contents/branchMaps_10_resouce_get/example/featureBrances/branch_get.json?ref=main",
#     "html_url": "https://github.com/dvlpCI/script-qbase/blob/main/branchMaps_10_resouce_get/example/featureBrances/branch_get.json",
#     "git_url": "https://api.github.com/repos/dvlpCI/script-qbase/git/blobs/436851fbe0b094a31ca3f68fc18a4f4a5690aaa4",
#     "download_url": "https://raw.githubusercontent.com/dvlpCI/script-qbase/main/branchMaps_10_resouce_get/example/featureBrances/branch_get.json",
#     "type": "file",
#     "_links": {
#       "self": "https://api.github.com/repos/dvlpCI/script-qbase/contents/branchMaps_10_resouce_get/example/featureBrances/branch_get.json?ref=main",
#       "git": "https://api.github.com/repos/dvlpCI/script-qbase/git/blobs/436851fbe0b094a31ca3f68fc18a4f4a5690aaa4",
#       "html": "https://github.com/dvlpCI/script-qbase/blob/main/branchMaps_10_resouce_get/example/featureBrances/branch_get.json"
#     }
#   }
# ]

fileDownloadUrlArrayString=$(printf "%s" "${fileList}" | jq -r '.[].download_url') # 记得此处去除双引号，避免后面取值不正确
printf "%s" "${fileDownloadUrlArrayString}"