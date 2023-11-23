#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-23 00:54:34
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-24 01:12:00
 # @FilePath: get_filePath_mapping_branchName_from_dir.sh
 # @Description: 获取所有远程的分支信息(每个分支从它自己的分支里提取)
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


while [ -n "$1" ]
do
    case "$1" in
        -requestBranchNames|--request-branch-names) requestBranchNames=$2 shift 2;;
        -access-token|--access-token) access_token=$2; shift 2;;
        -oneOfDirUrl|--one-of-dir-url) ONE_OF_DIRECTORY_URL=$2; shift 2;;
        -dirUrlBranchName|--dir-url-branch-name) DIRECTORY_URL_BranchName=$2 shift 2;;
        --) break ;;
        *) break ;;
    esac
done


function get_all_json_file_content_inDir_mapping_branchName() {
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

    # echo "${YELLOW}正在执行测试命令(获取git上指定目录下所有的json文件的内容):《${BLUE} sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl \"${DIRECTORY_URL}\" -access-token \"${access_token}\" -inBranchName \"${inBranchName}\" ${YELLOW}》${NC}"
    # sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}"
    # return 1
    allFileContent_JsonStrings=$(sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${inBranchName}")
    if [ $? != 0 ]; then
        # echo "${allFileContent_JsonStrings}" #此时此值是错误原因
        # return 1
        allFileContent_JsonStrings=$(echo "$allFileContent_JsonStrings" | sed 's/"//g' | tr -d '\n') # 去除所有双引号，避免放到JSON中的时候出错
        jsonStringWhereJsonMappingBranchName='[
            {
                "create_time": "null",
                "submit_test_time": "null",
                "pass_test_time": "null",
                "merger_pre_time": "null",
                "type": "null",
                "name": "'"${inBranchName}"'",
                "des": "详见outlines",
                "outlines": [
                {
                    "title": "未获取到分支信息，原因为'${allFileContent_JsonStrings}'"
                }
                ],
                "answer": {
                    "name": "null"
                },
                "tester": {
                    "name": "null"
                },
                "fileUrl": null
            }
        ]'
        printf "%s" "${jsonStringWhereJsonMappingBranchName}"
        return 0
    fi
    allFileContent_Count=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | length')
    # echo "${GREEN}恭喜:指定目录${BLUE} ${DIRECTORY_URL} ${GREEN}下的所有json文件共有${BLUE} ${allFileContent_Count} ${GREEN}个，它们内容组成的值如下:${NC}"
    # echo "${allFileContent_JsonStrings}" | jq '.'


    # jsonStringWhereJsonMappingBranchName=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | map(select(.name == "'"${requestBranchName}"'"))')

    jsonStringWhereJsonMappingBranchName=""
    jsonStringWhereJsonMappingBranchName+="["
    for((i=0;i<$allFileContent_Count;i++));
    do
        iFileContentJsonString=$(printf "%s" "${allFileContent_JsonStrings}" | jq ".[${i}]")
        # echo "$((i+1)).${iFileContentJsonString}"
        # 判断文件是否映射到指定的分支名
        branchName=$(printf "%s" "${iFileContentJsonString}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
        if [ $? != 0 ]; then
            branchFileAbsolutePathOrUrl=$(printf "%s" "${iFileContentJsonString}" | jq -r '.fileUrl')
            echo "${RED}Error❌:获取文件${BLUE} ${branchFileAbsolutePathOrUrl} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹${BLUE} $DIRECTORY_URL ${RED}内的所有json文件都是合规的。${NC}";
            continue
        fi
        # echo "$((i+1)).${branchName}"
        # last_field="${inBranchName##*/}" # 获取元素的最后一个字段
        if [ "$inBranchName" != "$branchName" ]; then
            continue
        fi

        if [ "${jsonStringWhereJsonMappingBranchName}" != "[" ]; then
            jsonStringWhereJsonMappingBranchName+=", "
        fi
        jsonStringWhereJsonMappingBranchName+=${iFileContentJsonString}
    done
    jsonStringWhereJsonMappingBranchName+="]"
    # echo "jsonStringWhereJsonMappingBranchName============${jsonStringWhereJsonMappingBranchName}"


    jsonWhereJsonMappingBranchName_count=$(printf "%s" "${jsonStringWhereJsonMappingBranchName}" | jq '. | length')
    # echo "jsonWhereJsonMappingBranchName_count=${jsonWhereJsonMappingBranchName_count}"
    if [ "${jsonWhereJsonMappingBranchName_count}" == 0 ]; then
        echo "您目录 ${DIRECTORY_URL} 下的所有json文件提取成功了，但是未找到匹配 ${inBranchName} 分支名的json文件，请检查。"
        return 1
    else
        # echo "${GREEN}恭喜:您找到匹配${BLUE} ${inBranchName} ${GREEN}分支名的json文件共有${BLUE} ${jsonWhereJsonMappingBranchName_count} ${GREEN}个，它们组成的json数组如下:${NC}"
        printf "%s" "${jsonStringWhereJsonMappingBranchName}"
    fi
}

# 测试单个
# i=0
# requestBranchNameArray=($requestBranchNames)
# requestBranchCount=${#requestBranchNameArray[@]}
# iRequestBranchName=${requestBranchNameArray[i]}
# iDirUrl=${ONE_OF_DIRECTORY_URL//${DIRECTORY_URL_BranchName}/${iRequestBranchName}} # 将 "blob" 替换为 "raw"      
# echo "$((i+1)).请求${BLUE} ${iRequestBranchName} ${NC}-----${BLUE} ${iDirUrl} ${NC}"
# get_all_json_file_content_inDir_mapping_branchName -dirUrl "${iDirUrl}" -access-token "${access_token}" -inBranchName "${iRequestBranchName}"
# exit 1


allBranchJsonStrings=""
allBranchJsonStrings+="["
allBranchJsonErrorMessage=""
allBranchJsonErrorMessage+="["
requestBranchNameArray=($requestBranchNames)
requestBranchCount=${#requestBranchNameArray[@]}
for((i=0;i<requestBranchCount;i++));
do
    iRequestBranchName=${requestBranchNameArray[i]}
    iDirUrl=${ONE_OF_DIRECTORY_URL//${DIRECTORY_URL_BranchName}/${iRequestBranchName}} # 将 "blob" 替换为 "raw"      
    # echo "$((i+1)).请求${BLUE} ${iRequestBranchName} ${NC}-----${BLUE} ${iDirUrl} ${NC}"

    iBranchJsonStrings=$(get_all_json_file_content_inDir_mapping_branchName -dirUrl "${iDirUrl}" -access-token "${access_token}" -inBranchName "${iRequestBranchName}")
    if [ $? != 0 ]; then
        # echo "$((i+1)).结果❌${BLUE} ${iRequestBranchName} ${NC}-----${BLUE} ${iBranchJsonStrings} ${NC}"
        if [ "${allBranchJsonErrorMessage}" != "[" ]; then
            allBranchJsonErrorMessage+=", "
        fi
        iBranchJsonStrings=$(echo "$iBranchJsonStrings" | sed 's/"//g' | tr -d '\n') # 去除所有双引号，避免放到JSON中的时候出错
        allBranchJsonErrorMessage+="\"${iRequestBranchName}: ${iBranchJsonStrings}\""  # 此时此值是错误信息
        continue
    fi
    # echo "$((i+1)).结果✅${BLUE} ${iRequestBranchName} ${NC}-----${BLUE} ${iBranchJsonStrings} ${NC}"
    jsonStringCount=$(printf "%s" "${iBranchJsonStrings}" | jq '. | length')
    for((j=0;j<jsonStringCount;j++));
    do
        iJsonString=$(printf "%s" "${iBranchJsonStrings}" | jq ".[${j}]")
        # echo "$((j+1)). ${iJsonString}"
        if [ "${allBranchJsonStrings}" != "[" ]; then
            allBranchJsonStrings+=", "
        fi
        allBranchJsonStrings+="${iJsonString}"
    done
done
allBranchJsonStrings+="]"
allBranchJsonErrorMessage+="]"

# echo ""
# echo "${YELLOW}获取所有远程的分支信息(每个分支从它自己的分支里提取)分支总结:${NC}"
# if [ "${allBranchJsonErrorMessage}" != "[]" ]; then
#     echo "${RED}其中失败的分支及其信息如下:${NC}"
#     echo "${allBranchJsonErrorMessage}" | jq "."
#     # exit 1
# fi

# echo "${GREEN}成功的分支及其信息如下:${NC}"
# printf "%s" "${allBranchJsonStrings}" | jq "."

printf "%s" "${allBranchJsonStrings}"
