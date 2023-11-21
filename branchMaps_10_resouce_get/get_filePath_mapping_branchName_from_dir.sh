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
            echo "Error❌: 获取网络地址内容失败。执行的命令为 《 curl -s --header \"Private-Token: $access_token\" \"$branchFileAbsolutePathOrUrl\"》"
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

    # debug_log "恭喜:找到符合 ${mappingName} 的分支信息文件为: ${branchFileAbsolutePathOrUrl}"
}

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

    # BranceMaps_From_Directory_PATH=${project_removed_suffix//tree/$mappingName}    # 将 "blob" 替换为指定变量的值
    responseJsonString='{
        "api_url_master_current_dir": "'"${target}"'",
        "raw_url_all_home": "'"${all_raw_home_url}"'"
    }'
    # responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
    printf "%s" "${responseJsonString}"
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

    for file in "${BranceMaps_From_Directory_PATH}"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        isMappingResult=$(isFileMappingBranchName -branchFile "$file" -mappingName "$mappingName")
        if [ $? != 0 ]; then
            continue
        fi
        
        mappingBranchName_FilePaths[${#mappingBranchName_FilePaths[@]}]=${file}
    done
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
    mappingBranchName_FilePaths=()


    # 将字符串中的内容进行替换
    newUrl="${BranceMaps_From_Directory_PATH/https:\/\/github.com/https://api.github.com/repos}" # 前面\要转义，后面不用
    api_url="${newUrl/tree\/main/contents}"
    # echo "====api_url=${api_url}"
    # exit


    headers=(
        "Authorization: Bearer $access_token"  # 替换为新的身份验证令牌
    )
    # 执行请求:下载文件列表(GitHub链接:无法直接访问到特定的文件夹和文件。所以尝试使用GitHub API来获取文件列表并下载文件。)
    # api_url="https://api.github.com/repos/dvlpCI/script-qbase/contents/branchMaps_10_resouce_get/example/featureBrances"
    fileList=$(curl -s -H "${headers[@]}" "$api_url")
    if [ $? != 0 ]; then
        echo "Error❌:无法获取文件列表。请检查您的身份验证令牌是否正确。"
        exit_script
    fi
    # 检查是否超过API请求限制
    if [[ $fileList == *"Bad credentials"* ]]; then
        echo "凭证无效。请稍后再试。"
        exit_script
    elif [[ $fileList == *"API rate limit exceeded"* ]]; then
        echo "超过API请求限制。请稍后再试。"
        exit_script
    fi
    # echo "================fileList=${fileList}"
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
    fileDownloadUrlArray=(${fileDownloadUrlArrayString})
    # echo "================fileDownloadUrlArray=${fileDownloadUrlArray[*]}"

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
        mappingBranchName_FilePaths+=("$rawFileAbsUrl")
    done
}


function getBranchMapsFromDir_remote_gitee() {
    BranceMaps_From_Directory_PATH=$1
    mappingName=$2
    # BranceMaps_From_Directory_PATH="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances"
    BranceMaps_From_Directory_PATH=${BranceMaps_From_Directory_PATH//master/$mappingName}    # 将 "blob" 替换为指定变量的值
    debug_log "BranceMaps_From_Directory_PATH=${BranceMaps_From_Directory_PATH}"

    mappingBranchName_FilePaths=()

    fileList=$(curl -s "${BranceMaps_From_Directory_PATH}" | grep -oE 'href="[^"]+\.json"' | sed -E 's/^href="([^"]+)".*/\1/')
    # fileList=$(curl -s "https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances" | grep -oE 'href="[^"]+\.json"' | sed -E 's/^href="([^"]+)".*/\1/')
    if [ $? != 0 ]; then
        echo "Error❌: 无法获取文件列表。请检查您的身份验证令牌是否正确。"
        exit_script
    fi
    debug_log "================fileList=${fileList}"

    fileArray=(${fileList})
    fileCount=${#fileArray[@]}


    fileDownloadUrlArray=()
    mappingBranchName_FilePaths=()
    file_JsonStrings=""
    file_JsonStrings+="["
    for((i=0;i<fileCount;i++));
    do
        fileRelPath=${fileArray[i]}
        rawFileRelPath=${fileRelPath//blob/raw} # 将 "blob" 替换为 "raw"        
        rawFileAbsUrl="https://gitee.com$rawFileRelPath"    # 添加前缀 "https://gitee.com"
        fileDownloadUrlArray[${#fileDownloadUrlArray[@]}]=${rawFileAbsUrl}

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
        mappingBranchName_FilePaths+=("$rawFileAbsUrl")

    done
    file_JsonStrings+="]"

    # echo "file_JsonStrings的值如下:"
    # echo "${file_JsonStrings}" | jq '.'

    # noCommit_branchJsonStrings=$(printf "%s" "${file_JsonStrings}" | jq '. | map(select(.name == "'"${mappingName}"'"))')
    # echo "noCommit_branchJsonStrings=${noCommit_branchJsonStrings}"
}



function getBranchMapsFromDir_remote_gitlab() {
    BranceMaps_From_Directory_PATH=$1
    mappingName=$2

    # master_api_dir_url
    gitlab_responseJsonString=$(changeToApiUrl_gitlab "${BranceMaps_From_Directory_PATH}")
    if [ $? != 0 ]; then
        echo "changeToApiUrl_gitlab ${gitlab_responseJsonString}"
        exit 1
    fi
    echo "${GREEN}恭喜:gitlab转化之后的结果如下:${NC}"
    echo "${gitlab_responseJsonString}" | jq -r "."


    master_api_dir_url=$(printf "%s" "${gitlab_responseJsonString}" | jq -r '.api_url_master_current_dir')
    echo "master_api_dir_url=${master_api_dir_url}"
    
    # raw_url_all_home
    raw_url_all_home=$(printf "%s" "${gitlab_responseJsonString}" | jq -r '.raw_url_all_home')
    if [ $? != 0 ]; then
        echo "changeToRawUrl_gitlab ${raw_url_all_home}"
        exit 1
    fi
    debug_log "raw_url_all_home=${raw_url_all_home}"


    # branch_api_dir_url
    branch_api_dir_url=${master_api_dir_url/master/$mappingName}    # 将 "master" 替换为指定变量的值
    echo "branch_api_dir_url=${branch_api_dir_url}"

    # request: 发送带有访问令牌的请求获取目录内容
    echo "${YELLOW}正在执行命令(获取网络地址对应的内容):《${BLUE} curl -s --header \"Private-Token: $access_token\" \"$branch_api_dir_url\" ${YELLOW}》${NC}"
    response=$(curl -s --header "Private-Token: $access_token" "$branch_api_dir_url")
    if [ $? != 0 ]; then
        echo "Error❌: 无法获取文件列表。请检查您的身份验证令牌是否正确。"
        exit_script
    fi
    echo "✅response=${response}"
    # exit 1

    # 解析 JSON 响应，提取 JSON 文件路径
    json_file_relPaths=$(echo "$response" | jq -r '.[] | .path')
    echo "json_file_relPaths=${json_file_relPaths}"
    json_file_relPathArray=(${json_file_relPaths})
    json_file_count=${#json_file_relPathArray[@]}

    fileDownloadUrlArray=()
    mappingBranchName_FilePaths=()
    file_JsonStrings=""
    file_JsonStrings+="["
    for((i=0;i<json_file_count;i++));
    do
        fileRelPath=${json_file_relPathArray[i]}
        rawFileAbsUrl="${raw_url_all_home}/${mappingName}/${fileRelPath}"
        # echo "$((i+1)).${rawFileAbsUrl}"
        fileDownloadUrlArray[${#fileDownloadUrlArray[@]}]=${rawFileAbsUrl}


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
        mappingBranchName_FilePaths+=("$rawFileAbsUrl")
    done
    file_JsonStrings+="]"
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


if [ "${#mappingBranchName_FilePaths[@]}" == 0 ]; then
    echo "Error❌: 没有找到映射到 ${mappingName} 分支的信息文件。"
    exit_script
fi

printf "%s" "${mappingBranchName_FilePaths[*]}"