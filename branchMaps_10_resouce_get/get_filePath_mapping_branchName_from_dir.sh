#!/bin/bash
: <<!
在指定目录下获取符合分支名指向的文件，未找到返回空字符串
!

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'





exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function debug_log() {
    if [ "${verbose}" == true ]; then
        echo "$1"
    fi
}

# responseJsonString='{
#     "code": 0
# }'
# responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
# printf "%s" "${responseJsonString}"


CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

GIT_SCIRTP_DIR_PATH=${qbase_homedir_abspath}/git_content
qbase_get_fileUrls_inDir_github_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_github.sh
qbase_get_fileUrls_inDir_gitee_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitee.sh
qbase_get_fileUrls_inDir_gitlab_scriptPath=${GIT_SCIRTP_DIR_PATH}/get_fileUrls_inDir_gitlab.sh

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

# 判断文件是否映射到指定的分支名
function isFileMappingBranchName() {
    while [ -n "$1" ]
    do
        case "$1" in
            -branchFile|--branchFile) branchFileAbsolutePathOrUrl=$2; shift 2;;
            -mappingName|--mappingName) mappingName=$2; shift 2;;
            -access-token|--access-token) access_token=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done


    if [[ $branchFileAbsolutePathOrUrl == http* ]]; then
        if [ -z "${access_token}" ]; then
            echo "${YELLOW}正在执行命令(获取网络地址对应的内容):《${BLUE} curl -s \"$branchFileAbsolutePathOrUrl\" ${YELLOW}》${NC}"
            FileContent=$(curl -s "$branchFileAbsolutePathOrUrl")
            if [ $? != 0 ]; then
                echo "Error❌: 无法获取文件列表。您可能需要添加 -access-token 身份验证令牌参数才能查看此地址内容。"
                return 1
            fi
        else
            echo "${YELLOW}正在执行命令(获取网络地址对应的内容):《${BLUE} curl -s --header \"Private-Token: $access_token\" \"$branchFileAbsolutePathOrUrl\" ${YELLOW}》${NC}"
            FileContent=$(curl -s --header "Private-Token: $access_token" "$branchFileAbsolutePathOrUrl")
            if [ $? != 0 ]; then
                echo "Error❌: 无法获取文件列表。请检查您的身份验证令牌 ${access_token} 是否正确。"
                return 1
            fi
        fi

        # 检查字符串是否包含指定字符串变量
        errorFlagString="users/sign_in"
        if [[ $FileContent == *"$errorFlagString"* ]]; then
            echo "Error❌: 获取网络地址内容失败。执行的命令为 《 curl -s --header \"Private-Token: $access_token\" \"$branchFileAbsolutePathOrUrl\"》。得到的值为 $FileContent"
            # echo "所获得的错误内容如下:\n${FileContent}"
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

    branchName=$(printf "%s" "${FileContent}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
    if [ $? != 0 ]; then
        echo "${RED}Error❌:获取文件${BLUE} ${branchFileAbsolutePathOrUrl} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹${BLUE} $BranceMaps_From_Directory_PATH ${RED}内的所有json文件都是合规的。${NC}";
        return 1
    fi
    # echo "您文件的branchName=${branchName}"
    # last_field="${mappingName##*/}" # 获取元素的最后一个字段
    if [ "$mappingName" != "$branchName" ]; then
        return 1
    fi


    FileContent=$(printf "%s" "$FileContent" | jq --arg fileUrl "$branchFileAbsolutePathOrUrl" '. + { "fileUrl": $fileUrl }')

    # debug_log "恭喜:找到符合 ${mappingName} 的分支信息文件为: ${branchFileAbsolutePathOrUrl}"
    printf "%s" "${FileContent}"
}

# 从本地获取
function getBranchMapsFromDir_local() {
    # echo "正在执行 $FUNCNAME"
    mappingBranchName_FilePaths=()

    if [[ $BranceMaps_From_Directory_PATH =~ ^~.* ]]; then
        # 如果 $BranceMaps_From_Directory_PATH 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        BranceMaps_From_Directory_PATH="${HOME}${BranceMaps_From_Directory_PATH:1}"
    fi
    #获取featureBrances文件夹下的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 中
    if [ ! -d "${BranceMaps_From_Directory_PATH}" ]; then
        echo "Error❌:您的 -branchMapsFromDir 指向的'map是从哪个文件夹路径获取'的参数值 ${BranceMaps_From_Directory_PATH} 不存在，请检查！"
        exit_script
    fi

    if [ -z "${mappingName}" ]; then
        echo "Error❌:您的 -requestBranchName 指向的'要为哪个分支名获取信息的分支名'的参数值不能为空，请检查！"
        exit_script
    fi


    mappingBranchName_JsonStrings=""
    mappingBranchName_JsonStrings+="["
    for file in "${BranceMaps_From_Directory_PATH}"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        isMappingResult=$(isFileMappingBranchName -branchFile "$file" -mappingName "$mappingName")
        if [ $? != 0 ]; then
            continue
        fi
        if [ "${mappingBranchName_JsonStrings}" != "[" ]; then
            mappingBranchName_JsonStrings+=", "
        fi
        mappingBranchName_JsonStrings+="${isMappingResult}"

        mappingBranchName_FilePaths[${#mappingBranchName_FilePaths[@]}]=${file}
    done
    mappingBranchName_JsonStrings+="]"
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


function getBranchMapsFromDir_remote_github() {
    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_github_scriptPath -dirUrl "${BranceMaps_From_Directory_PATH}" -access-token "${access_token}" -inBranchName "${mappingName}")
    if [ $? != 0 ]; then
        echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
        exit_script
    fi
    fileDownloadUrlArray=(${fileDownloadUrlArrayString})
    # echo "================fileDownloadUrlArray=${fileDownloadUrlArray[*]}"


    mappingBranchName_JsonStrings=""
    mappingBranchName_JsonStrings+="["
    mappingBranchName_FilePaths=()
    fileDownloadUrlCount=${#fileDownloadUrlArray[@]}
    for((i=0;i<fileDownloadUrlCount;i++));
    do
        rawFileAbsUrl=${fileDownloadUrlArray[i]}
        # echo "$((i+1)).rawFileAbsUrl=${rawFileAbsUrl}"

        # # 检查文件是否映射到指定分支上
        isMappingResult=$(isFileMappingBranchName -branchFile "$rawFileAbsUrl" -mappingName "$mappingName" -access-token "${access_token}")
        if [ $? -ne 0 ]; then
            debug_log "${isMappingResult}"
            continue
        fi
        if [ "${mappingBranchName_JsonStrings}" != "[" ]; then
            mappingBranchName_JsonStrings+=", "
        fi
        mappingBranchName_JsonStrings+="${isMappingResult}"

        mappingBranchName_FilePaths+=("$rawFileAbsUrl")
    done
    mappingBranchName_JsonStrings+="]"
}


function getBranchMapsFromDir_remote_gitee() {
    BranceMaps_From_Directory_PATH=$1
    mappingName=$2

    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitee_scriptPath -dirUrl "${BranceMaps_From_Directory_PATH}" -access-token "${access_token}" -inBranchName "${mappingName}")
    if [ $? != 0 ]; then
        echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
        exit_script
    fi

    fileDownloadUrlArray=(${fileDownloadUrlArrayString})
    fileCount=${#fileDownloadUrlArray[@]}


    mappingBranchName_FilePaths=()
    file_JsonStrings=""
    file_JsonStrings+="["
    mappingBranchName_JsonStrings=""
    mappingBranchName_JsonStrings+="["
    for((i=0;i<fileCount;i++));
    do
        rawFileAbsUrl=${fileDownloadUrlArray[i]}

        rawFileContent=$(isValidJsonFile "$rawFileAbsUrl")
        # echo "$((i+1)).${rawFileRelUrl}的内容如下:\n${rawFileContent}"
        # if [ $? != 0 ]; then
        #    return 1        
        # fi
        if [ $i -gt 0 ]; then
            file_JsonStrings+=", "
        fi
        file_JsonStrings+="${rawFileContent}"

        # 检查文件是否映射到指定分支上
        isMappingResult=$(isFileMappingBranchName -branchFile "$rawFileAbsUrl" -mappingName "$mappingName")
        if [ $? -ne 0 ]; then
            debug_log "${isMappingResult}"
            continue
        fi
        if [ "${mappingBranchName_JsonStrings}" != "[" ]; then
            mappingBranchName_JsonStrings+=", "
        fi
        mappingBranchName_JsonStrings+="${isMappingResult}"

        mappingBranchName_FilePaths+=("$rawFileAbsUrl")
    done
    file_JsonStrings+="]"
    mappingBranchName_JsonStrings+="]"


    # echo "file_JsonStrings的值如下:"
    # echo "${file_JsonStrings}" | jq '.'

    # noCommit_branchJsonStrings=$(printf "%s" "${file_JsonStrings}" | jq '. | map(select(.name == "'"${mappingName}"'"))')
    # echo "noCommit_branchJsonStrings=${noCommit_branchJsonStrings}"
}



function getBranchMapsFromDir_remote_gitlab() {
    BranceMaps_From_Directory_PATH=$1
    mappingName=$2

    fileDownloadUrlArrayString=$(sh $qbase_get_fileUrls_inDir_gitlab_scriptPath -dirUrl "${BranceMaps_From_Directory_PATH}" -access-token "${access_token}" -inBranchName "${mappingName}")
    if [ $? != 0 ]; then
        echo "${fileDownloadUrlArrayString}"    # 此时此值是错误信息
        exit_script
    fi


    fileDownloadUrlArray=(${fileDownloadUrlArrayString})
    json_file_count=${#fileDownloadUrlArray[@]}

    mappingBranchName_FilePaths=()
    file_JsonStrings=""
    file_JsonStrings+="["
    mappingBranchName_JsonStrings=""
    mappingBranchName_JsonStrings+="["
    for((i=0;i<json_file_count;i++));
    do
        rawFileAbsUrl=${fileDownloadUrlArray[i]}
        # echo "$((i+1)).${rawFileAbsUrl}"

        rawFileContent=$(isValidJsonFile "$rawFileAbsUrl")
        # echo "$((i+1)).${rawFileRelUrl}的内容如下:\n${rawFileContent}"
        # if [ $? != 0 ]; then
        #    return 1        
        # fi
        if [ $i -gt 0 ]; then
            file_JsonStrings+=", "
        fi
        file_JsonStrings+="${rawFileContent}"

        # 检查文件是否映射到指定分支上
        isMappingResult=$(isFileMappingBranchName -branchFile "$rawFileAbsUrl" -mappingName "$mappingName" -access-token "${access_token}")
        if [ $? -ne 0 ]; then
            echo "${isMappingResult}"
            continue
        fi
        if [ "${mappingBranchName_JsonStrings}" != "[" ]; then
            mappingBranchName_JsonStrings+=", "
        fi
        mappingBranchName_JsonStrings+="${isMappingResult}"

        mappingBranchName_FilePaths+=("$rawFileAbsUrl")
    done
    file_JsonStrings+="]"
    mappingBranchName_JsonStrings+="]"
    debug_log "================fileDownloadUrlArray=${fileDownloadUrlArray[*]}"
    

    echo "file_JsonStrings的值如下:"
    echo "${file_JsonStrings}" | jq '.'

    echo "mappingBranchName_FilePaths=${mappingBranchName_FilePaths[*]}"

    # noCommit_branchJsonStrings=$(printf "%s" "${file_JsonStrings}" | jq '. | map(select(.name == "'"${mappingName}"'"))')
    # echo "noCommit_branchJsonStrings=${noCommit_branchJsonStrings}"
}



if [ -z "${mappingName}" ]; then
    echo "Error❌: 请提供要获取信息的分支名（-requestBranchName 参数）。"
    exit_script
fi


if [[ "${BranceMaps_From_Directory_PATH}" == *"https://github.com"* ]]; then
    # mappingName="optimize/dev_script_pack"
    # BranceMaps_From_Directory_PATH="https://github.com/dvlpCI/script-qbase/tree/main/branchMaps_10_resouce_get/example/featureBrances"
    getBranchMapsFromDir_remote_github

elif [[ "${BranceMaps_From_Directory_PATH}" == *"https://gitee"* ]]; then   # https://gitee.com/profile/personal_access_tokens/
    # mappingName="dev_script_pack"
    # BranceMaps_From_Directory_PATH="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances"
    getBranchMapsFromDir_remote_gitee "${BranceMaps_From_Directory_PATH}" "${mappingName}"

elif [[ "${BranceMaps_From_Directory_PATH}" == *"https://gitlab"* ]]; then
    mappingName="chore/pack"
    BranceMaps_From_Directory_PATH="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/master/bulidScript/featureBrances"
    getBranchMapsFromDir_remote_gitlab "${BranceMaps_From_Directory_PATH}" "${mappingName}"

else
    getBranchMapsFromDir_local
fi


printf "%s" "${mappingBranchName_JsonStrings}"