#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-23 00:54:34
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 17:26:01
 # @FilePath: addBranchMaps_toJsonFile.sh
 # @Description: 获取所有指定分支名的branchMap组成branchMaps输出到指定文件中
 #  (1添加前，可增加检查每个branchMap在指定环境下的属性缺失，2如果添加成功可设置是否删除已获取的文件)，如有缺失输出缺失错误
### 
: <<!
sh ./branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -requestBranchNamesString "${requestBranchNamesString}"
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

function qian_log() {
    # 只有定义 --qian 的时候才打印这个log
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2   # 使用 echo 信息里的颜色才能正常显示出来
        # printf "%s\n" "$1" >&2
    fi
}

# branchNameFileJsonString='{
#   "branchName": "",
#   "branchFiles": "null"
# }'
# branchNameFileJsonString='{
            
#         }'
# mappingBranchName_FilePaths="a b c d"
# mappingBranchName_FilePaths=($mappingBranchName_FilePaths)
# branchFiles=$(printf "%s\n" "${mappingBranchName_FilePaths[@]}" | jq -R . | jq -s .)
# branchFiles='[]'
# branchFiles='["a"]'
# # printf "%s\n" "✅branchFiles=${branchFiles}"
# branchNameFileJsonString=$(printf "%s" "$branchNameFileJsonString" | jq --argjson branchFiles "$branchFiles" '. + { "branchFiles": $branchFiles }')
# echo "$branchNameFileJsonString"
# exit 1

CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_json_file_check_script_path="${qbase_homedir_abspath}/json_check/json_file_check.sh"
get_jsonstring_script_file=${qbase_homedir_abspath}/json_formatter/get_jsonstring.sh
JsonUpdateFun_script_file_Absolute="${qbase_homedir_abspath}/value_update_in_file/update_json_file.sh"



qbase_get_filePath_mapping_branchName_from_dir_scriptPath=${CurCategoryFun_HomeDir_Absolute}/get_filePath_mapping_branchName_from_dir.sh
qbase_branchMapFile_checkMap_scriptPath=${qbase_homedir_abspath}/branchMaps_11_resouce_check/branchMapFile_checkMap.sh


# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
                -branchMapsAddToJsonF|--branchMaps-add-to-json-file) BranchMapAddToJsonFile=$2; shift 2;; # 要添加到哪个文件路径（可空，会尝试自动创建，创建失败，会报错）
                -branchMapsAddToKey|--branchMaps-add-to-key) BranchMapAddToKey=$2; shift 2;;
                -requestBranchNamesString|--requestBranchNamesString) requestBranchNamesString=$2; shift 2;;    # 要添加信息的是哪些分支名
                -checkPropertyInNetwork|--package-network-type) CheckPropertyInNetworkType=$2; shift 2;;
                -ignoreCheckBranchNames|--ignoreCheck-branchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
                -shouldDeleteHasCatchRequestBranchFile|--should-delete-has-catch-request-branch-file) shouldDeleteHasCatchRequestBranchFile=$2; shift 2;; # 如果脚本执行成功是否要删除掉已经捕获的文件(一般用于在版本归档时候删除就文件)
                --) break ;;
                *) break ;;
        esac
done

if [[ $BranceMaps_From_Directory_PATH =~ ^~.* ]]; then
    # 如果 $BranceMaps_From_Directory_PATH 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    BranceMaps_From_Directory_PATH="${HOME}${BranceMaps_From_Directory_PATH:1}"
fi
if [[ $BranchMapAddToJsonFile =~ ^~.* ]]; then
    # 如果 $BranchMapAddToJsonFile 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    BranchMapAddToJsonFile="${HOME}${BranchMapAddToJsonFile:1}"
fi
#获取featureBrances文件夹下的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 中
if [ ! -d "${BranceMaps_From_Directory_PATH}" ]; then
    echo "Error❌:您的 -branchMapsFromDir 指向的'map是从哪个文件夹路径获取'的参数值 ${BranceMaps_From_Directory_PATH} 不存在，请检查！"
    exit_script
fi

if [ ! -f "${BranchMapAddToJsonFile}" ]; then
    if [ -d "${BranchMapAddToJsonFile}" ]; then
        # 如果目标是目录，报错并提示用户
        echo "Error❌: ${BranchMapAddToJsonFile} 存在，但不是json文件，而是一个目录，请手动删除后再运行。"
        exit_script
    fi
    
    # 创建目录（如果不存在）
    mkdir -p "$(dirname "${BranchMapAddToJsonFile}")"
    # 创建空JSON文件
    echo "{}" > "${BranchMapAddToJsonFile}"
    # 验证创建成功
    if [ ! -f "${BranchMapAddToJsonFile}" ]; then
        echo "Error❌: ${BranchMapAddToJsonFile} 文件不存在且我为你尝试创建失败，请检查权限。【若要检查根源，请检查：您的 -branchMapsAddToJsonF 指向的'要添加到哪个文件路径'的参数值】"
        exit_script
    else
        qian_log "✅ ${BranchMapAddToJsonFile} 文件不存在但已为你尝试创建成功。【若不想我为你创建，请检查根源：您的 -branchMapsAddToJsonF 指向的'要添加到哪个文件路径'的参数值】"
    fi
fi

if [ -z "${requestBranchNamesString}" ]; then
    echo "Error❌:您的 -requestBranchNames 指向的'要添加信息的是哪些分支名'的参数值不能为空，请检查！"
    exit_script
fi
requestBranchNameArray=($requestBranchNamesString)

function look_detail() {
    echo "${YELLOW}分支源添加到文件后的更多详情可查看:${BLUE} ${BranchMapAddToJsonFile} ${NC}的 ${BLUE}${BranchMapAddToKey} ${NC}"
}


# 获取倒数第一个参数和倒数第二个参数，如果有的话
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
    if [ $argCount -ge 2 ]; then
        second_last_index=$((argCount - 1))
        second_last_arg=${!second_last_index} # 获取倒数第二个参数
    fi
fi
# echo "========second_last_arg=${second_last_arg}"
# echo "========       last_arg=${last_arg}"

verboseStrings=("verbose" "-verbose" "--verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if [[ " ${verboseStrings[*]} " == *" $last_arg "* ]]; then
    verbose=true
else # 最后一个元素不是 verbose
    verbose=false
fi

function log_msg() {
    if [ ${verbose} == true ]; then
        echo "$1"
    fi
}


# responseJsonString='{
#     "code": 0
# }'
# responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
# printf "%s" "${responseJsonString}"

function get_required_branch_file_paths_from_dir() {
    requestBranchNameCount=${#requestBranchNameArray[@]}

    responseJsonString='{

    }'
    resultBranchFilePaths_ErrorPaths=()
    for ((i=0;i<requestBranchNameCount;i++))
    do
        branchNameFileJsonString='{
            
        }'

        requestBranchName=${requestBranchNameArray[i]}
        branchNameFileJsonString=$(printf "%s" "$branchNameFileJsonString" | jq --arg branchName "$requestBranchName" '. + { "branchName": $branchName }')

        # echo "${YELLOW}正在执行命令（获取分支信息):《${BLUE} sh \"$qbase_get_filePath_mapping_branchName_from_dir_scriptPath\" -requestBranchName \"${requestBranchName}\" -branchMapsFromDir \"${BranceMaps_From_Directory_PATH}\" ${YELLOW}》${NC} "
        mappingBranchName_JsonStrings=$(sh "$qbase_get_filePath_mapping_branchName_from_dir_scriptPath" -requestBranchName "${requestBranchName}" -branchMapsFromDir "${BranceMaps_From_Directory_PATH}")
        if [ $? != 0 ]; then
            mappingBranchName_FilePaths=()
            branchFiles='[]'
        elif [ -z "${mappingBranchName_JsonStrings}" ]; then
            # echo "Error❌: 没有找到映射到 ${requestBranchName} 分支的信息文件。"
            mappingBranchName_FilePaths=()
            branchFiles='[]'
        else
            # 使用jq验证JSON格式
            echo "$mappingBranchName_JsonStrings" | jq empty > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "您 get_filePath_mapping_branchName_from_dir 返回的字符串结果不符合JSON格式，请检查 ${mappingBranchName_JsonStrings}"
                return 1
            fi

            # echo "mappingBranchName_JsonStrings=${mappingBranchName_JsonStrings}"
            mappingBranchName_FilePathsString=$(printf "%s" "${mappingBranchName_JsonStrings}" | jq -r ".[].fileUrl")   # 记得使用-r去除双引号，避免后续路径使用时出错
            # echo "mappingBranchName_FilePathsString=${mappingBranchName_FilePathsString}"
            mappingBranchName_FilePaths=(${mappingBranchName_FilePathsString})

            # if [ "${#mappingBranchName_FilePaths[@]}" == 0 ]; then
            #     echo "很遗憾：【未找到任何】符合分支名是 ${mappingName} 的文件，请检查 ${BranceMaps_From_Directory_PATH}。"
            #     return 1
            # fi

            # if [ "${#mappingBranchName_FilePaths[@]}" -gt 1 ]; then
            #     echo "发生异常：【找到多个】符合分支名是 ${mappingName} 的文件，请检查 ${BranceMaps_From_Directory_PATH}。"
            #     return 1
            # fi
            branchFiles=$(printf "%s\n" "${mappingBranchName_FilePaths[@]}" | jq -R . | jq -s .)
            # branchFiles='["a"]'
        fi
        # echo "🚗🚗🚗🚗 mappingBranchName_FilePaths 个数 ${#mappingBranchName_FilePaths[@]} ,分别为 ${mappingBranchName_FilePaths[*]}"
        # echo "🚗🚗🚗🚗 branchFiles=${branchFiles}"
        branchNameFileJsonString=$(printf "%s" "$branchNameFileJsonString" | jq --argjson branchFiles "$branchFiles" '. + { "branchFiles": $branchFiles }')
        # printf "%s" "$branchNameFileJsonString" | jq -r .
        # echo "✅🚗 $branchNameFileJsonString"
        
        # 注意下面是 jq --argjson element  而不是 jq --arg element
        responseJsonString=$(printf "%s" "$responseJsonString" | jq --argjson element "$branchNameFileJsonString" '.values += [$element]')
        # printf "%s" "$responseJsonString" | jq -r .
        # exit 1
    done


    # aaa=$(printf "%s" "${responseJsonString}" | jq -r .)
    # echo "${CYAN}温馨提示:您的分支名和文件的映射关系如下:${BLUE}\n${aaa}\n${NC}"

    # specified_value='[]'
    # missingFile_BranchNames=$(printf "%s" "${responseJsonString}" | jq --argjson value "$specified_value" '.values | map(select(.branchFiles == $value)) | .[].branchName')
    # for branchName in $missingFile_BranchNames; do
    # # 在这里处理每个空的 branchName 值，例如输出、传递给其他命令等
    # echo "Empty branchName: $branchName"
    # done

    specified_value="[]"
    missingBranchFileMaps=$(printf "%s" "${responseJsonString}" | jq --argjson value "$specified_value" '.values | map(select(.branchFiles == $value))')
    # echo "🚴🏻 missingBranchFileMaps=${missingBranchFileMaps}"
    if [ -n "${missingBranchFileMaps}" ] && [ "${missingBranchFileMaps}" != "null" ] && [ "${missingBranchFileMaps}" != "[]" ]; then
        missingFile_BranchNames=$(printf "%s" "${missingBranchFileMaps}" | jq -r '.[].branchName')
        # echo "☎️☎️☎️☎️☎️☎️☎️☎️ missingFile_BranchNames=${missingFile_BranchNames}"
        # 获取branchName的个数方法1：
        missingFile_BranchNameCount=$(printf "%s" "${missingBranchFileMaps}" | jq -r '.|length')
        # 获取branchName的个数方法2：
        # missingFile_BranchNames=($missingFile_BranchNames) # 因为上面取出来的是断开的，所以不是json字符串
        # missingFile_BranchNameCount=${#missingFile_BranchNames[@]}
        printf "%s" "${RED}Error:您有${missingFile_BranchNameCount}/${requestBranchNameCount}个分支，在${BLUE} ${BranceMaps_From_Directory_PATH} ${RED}中没找到描述其分支信息的文件，请进入该目录补充以下分支名的分支信息文件:${BLUE} ${missingFile_BranchNames} ${RED}。\n【附：当前所有分支的路径匹配信息如下:${BLUE}\n${missingBranchFileMaps} ${RED}\n】。${NC}"
        return 1
    fi


    
    specified_value="[]"
    mayResultMaps=$(printf "%s" "${responseJsonString}" | jq --argjson value "$specified_value" '.values | map(select(.branchFiles != $value))')
    # echo "🚴🏻 mayResultMaps=${mayResultMaps}"
    if [ -z "${mayResultMaps}" ] || [ "${mayResultMaps}" == "null" ] || [ "${mayResultMaps}" == "[]" ]; then
        echo "${RED}❌Error:您所要进行获取的分支(${BLUE} ${requestBranchNameArray[*]} ${RED})在${BLUE} ${BranceMaps_From_Directory_PATH} ${RED}中都未找到描述其分支的信息文件，请检查。${NC}"
        return 1
    fi
    # echo "✅ mayResultMaps=${mayResultMaps}"

    resultBranchFilePaths=()
    mayResultMapCount=$(printf "%s" "$mayResultMaps" | jq -r '.|length')
    # echo "✅ mayResultMapCount=${mayResultMapCount}个"
    for ((i=0;i<mayResultMapCount;i++))
    do
        iMayResultMap=$(printf "%s" "$mayResultMaps" | jq -r ".[$((i))]") # -r 去除字符串引号
        # echo "✅ $((i+1)). iMayResultMap=${iMayResultMap}"

        iMayResultBranchFileArray=$(printf "%s" "${iMayResultMap}" | jq -r '.branchFiles') # 为了去除双引号加的sed
        iMayResultBranchFileCount=$(printf "%s" "$iMayResultBranchFileArray" | jq -r '.|length')
        # echo "✅ $((i+1)). iMayResultBranchFileCount=${iMayResultBranchFileCount}个"
        for ((j=0;j<iMayResultBranchFileCount;j++))
        do
            jFilePath=$(printf "%s" "$iMayResultBranchFileArray" | jq -r ".[$((j))]") # -r 去除字符串引号
            # echo "✅ $((j+1)). jFilePath=${jFilePath}"

            # iMayResultBranchFileArray=$(printf "%s" "${iMayResultMap}" | jq -r '.branchFiles') # 为了去除双引号加的sed
            # iMayResultBranchFileCount=$(printf "%s" "$iMayResultBranchFileArray" | jq -r '.|length')
            # echo "✅ $((i+1)). 内共有 ${iMayResultBranchFileCount}个元素，分别是 iMayResultBranchFileArray=${iMayResultBranchFileArray}"
            if [ ! -f "${jFilePath}" ]; then
                resultBranchFilePaths_ErrorPaths[${#resultBranchFilePaths_ErrorPaths[@]}]=${jFilePath}
            else
                resultBranchFilePaths[${#resultBranchFilePaths[@]}]=${jFilePath}
            fi

        done
    done

    errorFilePathCount=${#resultBranchFilePaths_ErrorPaths[@]}
    if [ "${errorFilePathCount}" -gt 0 ]; then
        echo "您有 ${errorFilePathCount} 个文件路径错误，请检查 ${resultBranchFilePaths_ErrorPaths[*]}"
        exit 1
    fi
    # printf "🚗🚗🚗🚗 %s 🚗🚗🚗🚗" "${resultBranchFilePaths[*]}"
    # return 1
    printf "%s" "${resultBranchFilePaths[*]}"
}


function check_requiredBranchFilePaths() {
    requiredBranch_FilePaths=($1) #转成数组
    requiredBranch_FileCount=${#requiredBranch_FilePaths[@]}

    missingPropertyBranchNameArray=()
    errorMessageArray=()
    for ((i=0;i<requiredBranch_FileCount;i++))
    do
        branchMapFilePath=${requiredBranch_FilePaths[i]}
        iBranchMap=$(cat "${branchMapFilePath}" | jq -r ".") # -r 去除字符串引号
        branchName=$(echo ${iBranchMap} | jq -r ".name") # -r 去除字符串引号

        errorMessage=$(sh ${qbase_branchMapFile_checkMap_scriptPath} -checkBranchMap "${iBranchMap}" -pn "${CheckPropertyInNetworkType}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}")
        if [ $? != 0 ]; then
            missingPropertyBranchNameArray[${#missingPropertyBranchNameArray[@]}]=${branchName}
            iResultMessage=""
            if [ ${#errorMessageArray[@]} -gt 0 ]; then
                iResultMessage+="\n"
            fi
            iResultMessage+="${RED}$((i+1)).您的${BLUE} ${branchName} ${RED}分支缺失${BLUE} ${errorMessage} ${RED}【详情请查看${BLUE} ${branchMapFilePath} ${RED}。】${RED}"
            errorMessageArray[${#errorMessageArray[@]}]=${iResultMessage}
        fi
    done
    #echo "缺失分支属性的分支名分别为 missingPropertyBranchNameArray=${missingPropertyBranchNameArray[*]}"
    if [ "${#missingPropertyBranchNameArray[@]}" -gt 0 ]; then
        # 【分支类型type，该类型值为hotfix/feature/optimize/other 中一种【分别对应hotfix(线上修复)/feature(产品需求)/optimize(技术优化)/other(其他)】】
        echo "${RED}Error❌:您有${#missingPropertyBranchNameArray[@]}个分支的json文件有缺失标明的部分，请前往补充后再执行打包。详细缺失信息如下：\n${errorMessageArray[*]} ${RED}。${NC}"
        echo "${RED}附：若您不想进行以上属性检查的操作，请勿传${BLUE} -checkPropertyInNetwork ${RED}参数即可。${NC}"
        return 1
    fi
}

function read_requiredBranchFilePaths() {
    isReadDirSuccess=true
    ReadDirErrorMessage=""
    dirFileContentsResult=""

    requiredBranch_FilePaths=($1) #转成数组
    if [ "${#requiredBranch_FilePaths[@]}" == 0 ]; then
        echo "要进行读取内容的文件数组不能为空，请检查"
        return 1
    fi

    for file in "${requiredBranch_FilePaths[@]}"; do
        ReadDirResult=$(read_dir_file "$file")
        if [ $? -ne 0 ]; then
            isReadDirSuccess=false
            ReadDirErrorMessage="${ReadDirResult}"
            if [ -n "${ReadDirErrorMessage}" ]; then
                ReadDirErrorMessage+="\n"
            fi
            ReadDirErrorMessage+="$ScriptMessage(最后一次提交者 $BranchLastCommitAuthor)" # 此时为错误信息
            continue
        else
            FileContent="${ReadDirResult}"
        fi
        dirFileContentsResult[${#dirFileContentsResult[@]}]=${FileContent}
    done

    if [ "${isReadDirSuccess}" != "true" ]; then
        echo "${ReadDirErrorMessage}"
        return 1
    fi

    echo "${dirFileContentsResult[*]}"
}


# 获取branch文件是否应该被添加，并返回true或false
function isRequiredBranchFileInBranchNames() {
    branchAbsoluteFilePath=$1
    branchName=$(cat "${branchAbsoluteFilePath}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
    if [ $? != 0 ]; then
        echo "${RED}Error❌:获取文件${BLUE} ${branchAbsoluteFilePath} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹${BLUE} $BranceMaps_From_Directory_PATH ${RED}内的所有json文件都是合规的。${NC}";
        return 1
    fi
    # 判断是否在数组中
    # if echo "${requestBranchNameArray[*]}" | grep -wq "${branchName}" &>/dev/null; then
    #     echo "true"
    # else
    #     echo "false---${requestBranchNameArray[*]}---${branchName}"
    # fi

    found=false
    # 遍历数组a中的每个元素

    requestBranchNameCount=${#requestBranchNameArray[@]}
    for ((i=0;i<requestBranchNameCount;i+=1))
    {
        element=${requestBranchNameArray[$i]}
        # last_field="${element##*/}" # 获取元素的最后一个字段
        if [ "$element" == "$branchName" ]; then
            found=true
            break
        fi
    }
    echo "$found"
}


function read_dir_file() {
    absoluteFilePath=$1

    if [ ! -f "${absoluteFilePath}" ]; then
        echo "Error❌(读取目录时):您的 ${absoluteFilePath} 文件不存在，请检查！"
        return 1
    fi

    # [shell替换和去掉换行符](http://www.noobyard.com/article/p-ahlemikj-nz.html)
    FileContent=$(cat ${absoluteFilePath} | sed 's/ /\n/g' | awk '{{printf"%s",$0}}')

    # [Shell 命令变量去除空格方法](https://blog.csdn.net/jjc120074203/article/details/126663391)
    FileContent=${FileContent// /}

    ScriptMessage=$(sh "${qbase_json_file_check_script_path}" -checkedJsonF "${absoluteFilePath}")
    if [ $? != 0 ]; then
        BranchLastCommitAuthor=$(getLastCommitAuthorByBranchFile "${absoluteFilePath}")
        echo "$ScriptMessage(最后一次提交者 $BranchLastCommitAuthor)" # 此时为错误信息
        return 1                                               # 暂不退出循环，为了收集错误问题
    fi

    echo "${FileContent}"
}

# 获取某个远程分支最后一次提交的作者名字，并返回
function getLastCommitAuthorByBranchFile() {
    branchAbsoluteFilePath=$1
    # 文件json格式错误，无法读取，故转而使用不一定规范的文件名当做分支来获取分支最后一次的提交用户
    absoluteFileName=${branchAbsoluteFilePath##*/} # 取最后的component
    absoluteFileNameNoType=${absoluteFileName%%.*}
    errorBranchName=${absoluteFileNameNoType}

    errorBranchUser=$(git log -1 --format="%an" remotes/origin/${errorBranchName}) # 如果你想获取作者的电子邮件地址，可以把%an改为%ae。
    if [ $? != 0 ]; then
        echo "❌Error:获取获取某个远程分支最后一次提交的作者名字失败，执行的命令是《 git log -1 --format=\"%an\" remotes/origin/${errorBranchName} 》"
        return 1
    fi
    echo "${errorBranchUser}"
}


# isRequiredBranchFileInBranchNames "/Users/lichaoqian/Project/CQCI/script-qbase/branchMaps_10_resouce_get/example/featureBrances/dev_demo.json" || exit # 测试代码
# read_dir_path || exit 1 # 测试代码
# get_required_branch_file_paths_from_dir || exit 1 # 测试代码
requiredBranch_FilePathsString=$(get_required_branch_file_paths_from_dir)
if [ $? != 0 ]; then
    echo "$requiredBranch_FilePathsString" # 此时值为错误消息
    exit 1
fi
requiredBranch_FilePaths=($requiredBranch_FilePathsString)
if [ "${#requiredBranch_FilePaths[@]}" == 0 ]; then
    echo "${RED}❌Error:您所要进行获取的分支(${BLUE} ${requestBranchNameArray[*]} ${RED})在${BLUE} ${BranceMaps_From_Directory_PATH} ${RED}中都未找到描述其分支的信息文件，请检查。${NC}"
    exit 1
fi
# echo "requiredBranch_FilePathsString================${requiredBranch_FilePathsString}"
if [ -n "${CheckPropertyInNetworkType}" ]; then
    CheckErrorMessage=$(check_requiredBranchFilePaths "${requiredBranch_FilePathsString}")
    if [ $? != 0 ]; then
        printf "%s\n" "${CheckErrorMessage}"
        exit 1
    fi
fi

# echo "🚗 📢 🌶 ${requiredBranch_FilePathsString}"
# read_requiredBranchFilePaths "${requiredBranch_FilePathsString}"
# exit 1
ReadDirErrorMessage=$(read_requiredBranchFilePaths "${requiredBranch_FilePathsString}")
if [ $? != 0 ]; then
    echo "执行命令(读取目录下的文件)发生错误如下:\n${ReadDirErrorMessage}"
    exit 1
fi
if [ -z "${ReadDirErrorMessage}" ]; then
    echo "${RED}Error❌:获取所有指定分支名的branchMaps输出到指定文件中失败。想要要查找的分支数据是:${BLUE} ${requestBranchNameArray[*]} ${RED}，查找数据的文件夹源是${BLUE} ${BranceMaps_From_Directory_PATH} ${RED}。${NC}"
    # look_detail
    exit 1
fi
dirFileContentsResult=("${ReadDirErrorMessage}")
if [ ${#dirFileContentsResult[@]} == 0 ]; then
    echo "友情提示🤝：读取目录文件，未提取到符合条件的文件，即不会往 ${BranchMapAddToJsonFile} 中的 ${BranchMapAddToKey} 属性添加其他值，最终的分支信息只能靠其原有值了"
    exit 0
fi



log_msg "${YELLOW}正在执行命令(获取json内容)《${BLUE} sh ${get_jsonstring_script_file} -arrayString \"${dirFileContentsResult[*]}\" -escape \"true\" ${YELLOW}》${NC}"
dirFileContentJsonStrings=$(sh ${get_jsonstring_script_file} -arrayString "${dirFileContentsResult[*]}" -escape "false")
if [ $? != 0 ]; then
    echo "${dirFileContentJsonStrings}" # 此时此值为错误信息
    exit 1
fi
log_msg "${YELLOW}所得json结果为:\n${BLUE}${dirFileContentJsonStrings}${BLUE}${NC}"

log_msg "${YELLOW}正在执行命令(将从 featureBrances 文件夹下获取到的的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 属性中):\n《 ${BLUE}sh \"${JsonUpdateFun_script_file_Absolute}\" -f \"${BranchMapAddToJsonFile}\" -k \"${BranchMapAddToKey}\" -v \"${dirFileContentJsonStrings}\" -change-type \"cover\" ${YELLOW}》${NC}"
sh "${JsonUpdateFun_script_file_Absolute}" -f "${BranchMapAddToJsonFile}" -k "${BranchMapAddToKey}" -v "${dirFileContentJsonStrings}" -change-type "cover"


# 读取JSON文件内容并提取feature_brances数组中的name2值
function getUncatchRequestBranchNames() {
    c2=()  # 创建一个空数组来存储结果

    requestBranchNameCount=${#requestBranchNameArray[@]}
    for ((i=0;i<requestBranchNameCount;i+=1))
    {
        element=${requestBranchNameArray[$i]}
        # 获取元素的最后一个字段
        last_field="${element##*/}"
        
        # 检查元素是否在name2_values中
        if ! echo "${hasCatchRequestBranchNameArray[*]}" | grep -wq "${last_field}" &>/dev/null; then
            c2+=("$element")  # 将元素添加到数组c2中
        fi
    }

    echo "${c2[*]}"
}

name2_values=$(jq -r ".${BranchMapAddToKey}[].name" ${BranchMapAddToJsonFile})
hasCatchRequestBranchNameArray=($name2_values)
uncatchRequestBranchNames=$(getUncatchRequestBranchNames)
if [ -n "${uncatchRequestBranchNames}" ]; then
    echo "${PURPLE}完全匹配失败，结果如下>>>>>\n要查找的数据是:${BLUE} ${requestBranchNameArray[*]}\n${PURPLE}但找不到匹配的分支名是:${RED} ${uncatchRequestBranchNames} ${PURPLE}。${NC}"
    look_detail
    exit 1
fi


# shouldDeleteHasCatchRequestBranchFile="true"
if [ "${shouldDeleteHasCatchRequestBranchFile}" == true ]; then
    errorDeleteHasCatchRequestBranchFile=()
    requiredBranch_FilePaths=(${requiredBranch_FilePathsString})
    for file in "${requiredBranch_FilePaths[@]}"; do
        rm "$file"
        if [ $? != 0 ]; then
            errorDeleteHasCatchRequestBranchFile[${#errorDeleteHasCatchRequestBranchFile[@]}]=${file}
        fi
    done

    if [ ${#errorDeleteHasCatchRequestBranchFile[@]} -gt 0 ]; then 
        echo "${RED}Error:如果脚本执行成功是否要删除掉已经捕获的文件(一般用于在版本归档时候删除就文件)，删除失败。附删除失败的文件分别如下：${BLUE}\n${errorDeleteHasCatchRequestBranchFile[*]} 。${NC}"
        look_detail
        exit 1
    fi
fi

look_detail

