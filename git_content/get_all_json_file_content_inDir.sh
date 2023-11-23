#!/bin/bash
: <<!
获取目录下所有json文件的内容(如果不是json或者json不合规的不获取)
!

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


CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

GIT_SCIRTP_DIR_PATH=${CurCategoryFun_HomeDir_Absolute}
qbase_get_fileUrls_inDir_github_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_github.sh
qbase_get_fileUrls_inDir_gitee_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitee.sh
qbase_get_fileUrls_inDir_gitlab_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitlab.sh

qbase_get_filecontent_gitlab_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_filecontent_gitlab.sh
qbase_get_filecontent_git_all_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_filecontent_git_all.sh

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

# echo "===========inBranchName=${inBranchName}"


# 如果文件内容是json且有效，则返回文件内容；否则提示出错
function getContentIfJson() {
    while [ -n "$1" ]
    do
        case "$1" in
            -branchFile|--branchFile) branchFileAbsolutePathOrUrl=$2; shift 2;;
            -access-token|--access-token) access_token=$2; shift 2;;
            -curBranchName|--cur-branch-name) curBranchName=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done


    if [[ "${branchFileAbsolutePathOrUrl}" == *"https://gitlab"* ]]; then
        FileContent=$(sh $qbase_get_filecontent_gitlab_scriptPath -fileUrl "${branchFileAbsolutePathOrUrl}" -access-token "${access_token}" -curBranchName "${curBranchName}")
        if [ $? != 0 ]; then
            echo "${FileContent}"
            return 1
        fi

    elif [[ $branchFileAbsolutePathOrUrl == http* ]]; then
        FileContent=$(sh $qbase_get_filecontent_git_all_scriptPath -fileUrl "${branchFileAbsolutePathOrUrl}" -access-token "${access_token}" -curBranchName "${curBranchName}")
        if [ $? != 0 ]; then
            echo "${FileContent}"
            return 1
        fi
    else
        FileContent=$(cat "$branchFileAbsolutePathOrUrl")
    fi
    # 检查文件内容是否符合JSON规范
    if ! echo "$FileContent" | jq . >/dev/null 2>&1; then
        echo "您的 ${branchFileAbsolutePathOrUrl} 文件不是一个有效的JSON文件。其内容是 ${FileContent}"
        return 1
    fi

    # 为该json添加 fileUrl 字段，便于从json查看是来自哪个文件的json
    FileContent=$(printf "%s" "$FileContent" | jq --arg fileUrl "$branchFileAbsolutePathOrUrl" '. + { "fileUrl": $fileUrl }')

    printf "%s" "${FileContent}"
}

# 从本地获取
function get_fileUrls_inDir_local() {
    if [[ $DIRECTORY_URL =~ ^~.* ]]; then
        # 如果 $DIRECTORY_URL 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        DIRECTORY_URL="${HOME}${DIRECTORY_URL:1}"
    fi
    #获取featureBrances文件夹下的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 中
    if [ ! -d "${DIRECTORY_URL}" ]; then
        echo "Error❌:您的 -dirUrl 指向的'map是从哪个文件夹路径获取'的参数值 ${DIRECTORY_URL} 不存在，请检查！"
        return 1
    fi

    fileDownloadUrlArray=()
    for file in "${DIRECTORY_URL}"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        fileDownloadUrlArray[${#fileDownloadUrlArray[@]}]=${file}
    done
    printf "%s" "${fileDownloadUrlArray[*]}"
}

function isValidJsonFile() {
    filePathOrUrl=$1
    # 判断文件扩展名是否为.json
    if [[ "${filePathOrUrl##*.}" != "json" ]]; then
        errorMessage="File is not a .json file"
        rawFileContent='
        {
            "rawFileAbsUrl": "'"${rawFileAbsUrl}"'",
            "errorMessage": "'"${errorMessage}"'"
        }
        '
        printf "%s" "${rawFileContent}"
        return 1
    fi


    if [[ $filePathOrUrl == http* ]]; then
        FileContent=$(curl -s "$filePathOrUrl")
    else
        FileContent=$(cat "$filePathOrUrl")
    fi

    # 检查文件内容是否符合JSON规范
    if ! echo "$FileContent" | jq . >/dev/null 2>&1; then
        errorMessage="File content is not valid JSON"
        rawFileContent='
        {
            "rawFileAbsUrl": "'"${rawFileAbsUrl}"'",
            "errorMessage": "'"${errorMessage}"'"
        }
        '
        printf "%s" "${rawFileContent}"
        return 1
    fi

    rawFileContent=$(curl -s "${rawFileAbsUrl}")
    printf "%s" "${rawFileContent}"
    return 0
}


if [ -z "${inBranchName}" ]; then
    echo "您的 -inBranchName 参数指向的'要获取哪个分支下的文件'的参数值不能为空，请检查！"
    exit_script
fi


if [[ "${DIRECTORY_URL}" != "/"* ]] &&  [[ "${DIRECTORY_URL}" != "~"* ]] \
&& [[ "${DIRECTORY_URL}" != *"https://github.com"* ]] && [[ "${DIRECTORY_URL}" != *"https://gitee"* ]] && [[ "${DIRECTORY_URL}" != *"https://gitlab"* ]]; then
    echo "您输入的 -dirUrl 参数的文件源地址 ${DIRECTORY_URL} 不是 本地地址，也不是 git 地址，请检查。"
    exit 1
fi

if [[ "${DIRECTORY_URL}" == *"https://github.com"* ]]; then
    debug_log "${YELLOW}正在执行命令(获取github目录下的所有文件路径):《${BLUE} sh $qbase_get_fileUrls_inDir_github_scriptPath -dirUrl \"${DIRECTORY_URL}\" -access-token \"${access_token}\" -curBranchName \"${inBranchName}\" ${YELLOW}》${NC}"
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_github_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -curBranchName "${inBranchName}")

elif [[ "${DIRECTORY_URL}" == *"https://gitee"* ]]; then 
    debug_log "${YELLOW}正在执行命令(获取gitee目录下的所有文件路径):《${BLUE} sh $qbase_get_fileUrls_inDir_gitee_scriptPath -dirUrl \"${DIRECTORY_URL}\" -access-token \"${access_token}\" -curBranchName \"${inBranchName}\" ${YELLOW}》${NC}"
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitee_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -curBranchName "${inBranchName}")

elif [[ "${DIRECTORY_URL}" == *"https://gitlab"* ]]; then
    debug_log "${YELLOW}正在执行命令(获取gitlab目录下的所有文件路径):《${BLUE} sh $qbase_get_fileUrls_inDir_gitlab_scriptPath -dirUrl \"${DIRECTORY_URL}\" -access-token \"${access_token}\" -curBranchName \"${inBranchName}\" ${YELLOW}》${NC}"
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitlab_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -curBranchName "${inBranchName}")

else
    fileDownloadUrlArrayString=$(get_fileUrls_inDir_local)
fi

if [ $? != 0 ]; then
    echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
    exit_script
fi
fileDownloadUrlArray=(${fileDownloadUrlArrayString})
# echo "================fileDownloadUrlArray=${fileDownloadUrlArray[*]}"


allFileContent_JsonStrings=""
allFileContent_JsonStrings+="["
fileDownloadUrlCount=${#fileDownloadUrlArray[@]}
for((i=0;i<fileDownloadUrlCount;i++));
do
    rawFileAbsUrl=${fileDownloadUrlArray[i]}
    # echo "$((i+1)).rawFileAbsUrl=${rawFileAbsUrl}"

    rawFileContent=$(getContentIfJson -branchFile "$rawFileAbsUrl" -access-token "${access_token}" -curBranchName "${inBranchName}")
    if [ $? -ne 0 ]; then
        debug_log "${rawFileContent}"
        continue
    fi
    # echo "$((i+1)).${rawFileRelUrl}的内容如下:\n${rawFileContent}"
    if [ "${allFileContent_JsonStrings}" != "[" ]; then
        allFileContent_JsonStrings+=", "
    fi
    allFileContent_JsonStrings+="${rawFileContent}"
done
allFileContent_JsonStrings+="]"

allFileContent_count=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | length')
# echo "allFileContent_count=${allFileContent_count}"
if [ "${allFileContent_count}" == 0 ]; then
    echo "您目录 ${DIRECTORY_URL} 下的所有json文件提取成功了，但是未找到匹配 ${inBranchName} 分支名的json文件，请检查。"
    exit 1
fi

printf "%s" "${allFileContent_JsonStrings}"
