#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-23 00:54:34
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-23 03:22:56
 # @FilePath: get_filePath_mapping_branchName_from_dir.sh
 # @Description: 在指定目录下获取符合分支名指向的文件及其json内容，未找到返回错误信息
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_get_all_json_file_content_inDir_scriptPath=${qbase_homedir_abspath}/git_content/get_all_json_file_content_inDir.sh

# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
        -access-token|--access-token) access_token=$2; shift 2;;
        -requestBranchName|--requestBranchName) mappingName=$2; shift 2;;    # 要添加信息的是哪些分支名
        --) break ;;
        *) break ;;
    esac
done

if [ -z "${mappingName}" ]; then
    echo "Error❌: 请提供要获取信息的分支名（-requestBranchName 参数）。"
    exit 1
fi

DIRECTORY_URL=${BranceMaps_From_Directory_PATH}
inBranchName=${mappingName}
allFileContent_JsonStrings=$(sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}")
if [ $? != 0 ]; then
    echo "${allFileContent_JsonStrings}" #此时此值是错误原因
    exit 1
fi
# echo "allFileContent_JsonStrings 的值如下:"
# echo "${allFileContent_JsonStrings}" | jq '.'


# jsonStringWhereJsonMappingBranchName=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | map(select(.name == "'"${inBranchName}"'"))')

jsonStringWhereJsonMappingBranchName=""
jsonStringWhereJsonMappingBranchName+="["
allFileContent_Count=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | length')
for((i=0;i<$allFileContent_Count;i++));
do
    iFileContentJsonString=$(printf "%s" "${allFileContent_JsonStrings}" | jq ".[${i}]")
    # echo "$((i+1)).${iFileContentJsonString}"
    # 判断文件是否映射到指定的分支名
    branchName=$(printf "%s" "${iFileContentJsonString}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
    if [ $? != 0 ]; then
        branchFileAbsolutePathOrUrl=$(printf "%s" "${iFileContentJsonString}" | jq -r '.fileUrl')
        echo "${RED}Error❌:获取文件${BLUE} ${branchFileAbsolutePathOrUrl} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹${BLUE} $BranceMaps_From_Directory_PATH ${RED}内的所有json文件都是合规的。${NC}";
        continue
    fi
    # echo "$((i+1)).${branchName}"
    # last_field="${mappingName##*/}" # 获取元素的最后一个字段
    if [ "$mappingName" != "$branchName" ]; then
        continue
    fi

    if [ "${jsonStringWhereJsonMappingBranchName}" != "[" ]; then
        jsonStringWhereJsonMappingBranchName+=", "
    fi
    jsonStringWhereJsonMappingBranchName+=${iFileContentJsonString}
done
jsonStringWhereJsonMappingBranchName+="]"


jsonWhereJsonMappingBranchName_count=$(printf "%s" "${jsonStringWhereJsonMappingBranchName}" | jq '. | length')
if [ "${jsonWhereJsonMappingBranchName_count}" == 0 ]; then
    echo "您目录 ${BranceMaps_From_Directory_PATH} 下的所有json文件提取成功了，但是未找到匹配 ${mappingName} 分支名的json文件，请检查。"
    exit 1
else
    # echo "您找到匹配 ${mappingName} 分支名的json文件组成的json数组如下:"
    printf "%s" "${jsonStringWhereJsonMappingBranchName}"
fi
