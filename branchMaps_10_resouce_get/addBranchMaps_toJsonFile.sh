#!/bin/bash
: <<!
获取所有指定分支名的branchMaps输出到指定文件中，如有缺失输出缺失错误
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

# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
                -branchMapsAddToJsonF|--branchMaps-add-to-json-file) BranchMapAddToJsonFile=$2; shift 2;;
                -branchMapsAddToKey|--branchMaps-add-to-key) BranchMapAddToKey=$2; shift 2;;
                -requestBranchNamesString|--requestBranchNamesString) requestBranchNamesString=$2; shift 2;;
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
    echo "Error❌:您的 -branchMapsAddToJsonF 指向的'要添加到哪个文件路径'的参数值 ${BranchMapAddToJsonFile} 不存在，请检查！"
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

verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
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

qbase_json_file_check_script_path="${CommonFun_HomeDir_Absolute}/json_check/json_file_check.sh"
get_jsonstring_script_file=${CommonFun_HomeDir_Absolute}/json_formatter/get_jsonstring.sh
JsonUpdateFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/value_update_in_file/update_json_file.sh"

#exit


function get_required_branch_file_paths_from_dir() {
    isReadDirSuccess=true
    ReadDirErrorMessage=""
    dirFileContentsResult=""
    for file in "${BranceMaps_From_Directory_PATH}"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        shouldAdd=$(isBranchFileInBranchNames "$file")
        if [ $? != 0 ]; then
            isReadDirSuccess=false
            ReadDirErrorMessage=$shouldAdd
            echo "$shouldAdd" # 此时值为错误原因
            return 1
        fi
        if [ "${shouldAdd}" != "true" ]; then
            continue
        fi
        
        requiredBranch_FilePaths[${#requiredBranch_FilePaths[@]}]=${file}
    done


    if [ "${isReadDirSuccess}" != "true" ]; then
        echo "${ReadDirErrorMessage}"
        return 1
    fi

    printf "%s" "${requiredBranch_FilePaths[*]}"
}


function read_requiredBranchFilePaths() {
    isReadDirSuccess=true
    ReadDirErrorMessage=""
    dirFileContentsResult=""

    requiredBranch_FilePaths=($1) #转成数组

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
function isBranchFileInBranchNames() {
    branchAbsoluteFilePath=$1
    branchName=$(cat "${branchAbsoluteFilePath}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
    if [ $? != 0 ]; then
        echo "${RED}Error❌:获取文件 ${BLUE}${branchAbsoluteFilePath} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹 ${BLUE}$BranceMaps_From_Directory_PATH ${RED}内的所有json文件都是合规的。${NC}";
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


# isBranchFileInBranchNames "/Users/lichaoqian/Project/CQCI/script-qbase/branchMaps_10_resouce_get/example/featureBrances/dev_demo.json" || exit # 测试代码
# read_dir_path || exit # 测试代码
requiredBranch_FilePathsString=$(get_required_branch_file_paths_from_dir)
if [ $? != 0 ]; then
    echo "$requiredBranch_FilePathsString" # 此时值为错误消息
    exit 1
fi

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

