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


CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CommonFun_HomeDir_Absolute=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_branchMapFile_checkMap_scriptPath=${CommonFun_HomeDir_Absolute}/branchMaps_11_resouce_check/branchMapFile_checkMap.sh

# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
        -requestBranchName|--requestBranchName) mappingName=$2; shift 2;;    # 要添加信息的是哪些分支名
        --) break ;;
        *) break ;;
    esac
done

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

# 当前【shell命令】执行的工作目录
#CurrentDIR_WORK_Relative=$PWD
#echo "CurrentDIR_WORK_Relative=${CurrentDIR_WORK_Relative}"

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#echo "CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute}"

# responseJsonString='{
#     "code": 0
# }'
# responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
# printf "%s" "${responseJsonString}"


# 判断文件是否映射到指定的分支名
function isFileMappingBranchName() {
    branchAbsoluteFilePath=$1
    mappingName=$2

    branchName=$(cat "${branchAbsoluteFilePath}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
    if [ $? != 0 ]; then
        echo "${RED}Error❌:获取文件${BLUE} ${branchAbsoluteFilePath} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹${BLUE} $BranceMaps_From_Directory_PATH ${RED}内的所有json文件都是合规的。${NC}";
        return 1
    fi
    # last_field="${mappingName##*/}" # 获取元素的最后一个字段
    if [ "$mappingName" != "$branchName" ]; then
        return 1
    fi
}


# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -requestBranchName|--requestBranchName) mappingName=$2; shift 2;;
        -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
        -branchMapsFromDirUrl|--branchMaps-is-from-dir-url) BranceMaps_From_Directory_URL=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done




# 从本地获取
function getBranchMapsFromDir_local() {
    mappingBrancName_FilePaths=()
    for file in "${BranceMaps_From_Directory_PATH}"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        isFileMappingBranchName "$file" "$mappingName"
        if [ $? != 0 ]; then
            continue
        fi
        
        mappingBrancName_FilePaths[${#mappingBrancName_FilePaths[@]}]=${file}
    done
}

# 从远程中获取
function getBranchMapsFromDir_remote() {
    mappingBrancName_FilePaths=()
    for file in "${BranceMaps_From_Directory_PATH}"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        isFileMappingBranchName "$file" "$mappingName"
        if [ $? != 0 ]; then
            continue
        fi
        
        mappingBrancName_FilePaths[${#mappingBrancName_FilePaths[@]}]=${file}
    done
}

if [ -n "${BranceMaps_From_Directory_URL}" ]; then
    getBranchMapsFromDir_remote
else
    getBranchMapsFromDir_local
fi

printf "%s" "${mappingBrancName_FilePaths[*]}"