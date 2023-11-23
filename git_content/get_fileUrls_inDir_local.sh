#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-22 23:42:34
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 10:13:28
 # @FilePath: get_fileUrls_inDir_local.sh
 # @Description: 获取目录下的所有文件路径--local
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


while [ -n "$1" ]
do
    case "$1" in
        -dirUrl|--dir-url) DIRECTORY_URL=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done


# CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# DIRECTORY_URL="${CategoryFun_HomeDir_Absolute}/example/featureBrances"
debug_log "DIRECTORY_URL=${DIRECTORY_URL}"


if [[ $DIRECTORY_URL =~ ^~.* ]]; then
    # 如果 $DIRECTORY_URL 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    DIRECTORY_URL="${HOME}${DIRECTORY_URL:1}"
fi
#获取featureBrances文件夹下的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 中
if [ ! -d "${DIRECTORY_URL}" ]; then
    echo "Error❌:您的 -dirUrl 指向的'map是从哪个文件夹路径获取'的参数值 ${DIRECTORY_URL} 不存在，请检查！"
    exit 1
fi

fileDownloadUrlArray=()
for file in "${DIRECTORY_URL}"/*; do
    if [ ! -f "$file" ]; then
        continue
    fi
    fileDownloadUrlArray[${#fileDownloadUrlArray[@]}]=${file}
done
printf "%s" "${fileDownloadUrlArray[*]}"
