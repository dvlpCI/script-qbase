#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-22 23:42:34
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 10:00:35
 # @FilePath: get_fileUrls_inDir_gitee.sh
 # @Description: 获取目录下的所有文件路径--gitee
### 


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


fileList=$(curl -s "${DIRECTORY_URL}" | grep -oE 'href="[^"]+\.json"' | sed -E 's/^href="([^"]+)".*/\1/')
# fileList=$(curl -s "https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances" | grep -oE 'href="[^"]+\.json"' | sed -E 's/^href="([^"]+)".*/\1/')
if [ $? != 0 ]; then
    echo "Error❌: 无法获取文件列表。请检查您的身份验证令牌是否正确。"
    exit 1
fi
debug_log "================fileList=${fileList}"

fileArray=(${fileList})
fileCount=${#fileArray[@]}


fileDownloadUrlArray=()
for((i=0;i<fileCount;i++));
do
    fileRelPath=${fileArray[i]}
    rawFileRelPath=${fileRelPath//blob/raw} # 将 "blob" 替换为 "raw"        
    rawFileAbsUrl="https://gitee.com$rawFileRelPath"    # 添加前缀 "https://gitee.com"
    fileDownloadUrlArray[${#fileDownloadUrlArray[@]}]=${rawFileAbsUrl}
done
printf "%s" "${fileDownloadUrlArray[*]}"