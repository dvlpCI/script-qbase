#!/bin/bash
: <<!
获取所有指定分支名的branchMaps输出到指定文件中，如有缺失输出缺失错误
sh ./branchMaps_10_resouce/addBranchMaps_toJsonFile.sh -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -requestBranchNamesString "${requestBranchNamesString}"
!

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;;
                -branchMapsAddToJsonF|--branchMaps-add-to-json-file) BranchMapAddToJsonFile=$2; shift 2;;
                -branchMapsAddToKey|--branchMaps-add-to-key) BranchMapAddToKey=$2; shift 2;;
                -requestBranchNamesString|--requestBranchNamesString) requestBranchNamesString=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done

requestBranchNameArray=($requestBranchNamesString)

function look_detail() {
    echo "${YELLOW}分支源添加到文件后的更多详情可查看: ${BLUE}${BranchMapAddToJsonFile} ${NC}的 ${BLUE}${BranchMapAddToKey} ${NC}"
}

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
        printf "$1"
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
JsonUpdateFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/update_value/update_json_file.sh"

#exit

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function read_dir_path() {
    isReadDirSuccess=true
    ReadDirErrorMessage=""
    dirFileContentsResult=""
    for file in "${BranceMaps_From_Directory_PATH}"/*; do
        if [ -f "$file" ]; then
            shouldAdd=$(isBranchFileInBranchNames "$file")
            if [ "${shouldAdd}" != "true" ]; then
                continue
            fi
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
        fi
    done

    if [ "${isReadDirSuccess}" != "true" ]; then
        echo "${ReadDirErrorMessage}"
        return 1
    fi

    echo "${dirFileContentsResult[*]}"
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

# 获取branch文件是否应该被添加，并返回true或false
function isBranchFileInBranchNames() {
    branchAbsoluteFilePath=$1
    branchName=$(cat "${branchAbsoluteFilePath}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上

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
        # 获取元素的最后一个字段
        last_field="${element##*/}"
        # 比较最后一个字段和变量b的值
        if [ "$last_field" == "$branchName" ]; then
            found=true
            break
        fi
    }
    echo "$found"
}



#获取featureBrances文件夹下的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 中
if [ ! -d "${BranceMaps_From_Directory_PATH}" ]; then
    echo "Error❌:您的App_Feature_Brances_Directory_PATH= ${BranceMaps_From_Directory_PATH} 文件夹不存在，请检查！"
    exit_script
fi

if [ ! -f "${BranchMapAddToJsonFile}" ]; then
    echo "Error❌:您的Branch_Info_FILE_PATH=${BranchMapAddToJsonFile} 文件不存在，请检查！"
    exit_script
fi

# isBranchFileInBranchNames "/Users/lichaoqian/Project/Bojue/mobile_flutter_wish/bulidScript/featureBrances/chore_pack.json" && exit # 测试代码
# read_dir_path && exit # 测试代码
ReadDirErrorMessage=$(read_dir_path)
if [ $? != 0 ]; then
    echo "执行命令(读取目录下的文件)发生错误如下:\n${ReadDirErrorMessage}"
    exit 1
fi
if [ -z "${ReadDirErrorMessage}" ]; then
    echo "${RED}Error❌:《获取当前分支【在rebase指定分支后】的所有分支信息合入指定文件中》失败，想要要查找的数据是: ${BLUE}${requestBranchNameArray[*]}${RED}，但未在文件 ${BLUE}${BranceMaps_From_Directory_PATH} ${RED}找到任何符合条件的分支文件。${NC}"
    # look_detail
    exit 1
fi
dirFileContentsResult=("${ReadDirErrorMessage}")

if [ ${#dirFileContentsResult[@]} == 0 ]; then
    echo "友情提示🤝：读取目录文件，未提取到符合条件的文件，即不会往 ${BranchMapAddToJsonFile} 中的 ${BranchMapAddToKey} 属性添加其他值，最终的分支信息只能靠其原有值了"
    exit 0
fi

log_msg "${YELLOW}正在执行命令(获取json内容)《 ${BLUE}sh ${get_jsonstring_script_file} -arrayString \"${dirFileContentsResult[*]}\" -escape \"true\" ${YELLOW}》${NC}"
dirFileContentJsonStrings=$(sh ${get_jsonstring_script_file} -arrayString "${dirFileContentsResult[*]}" -escape "false")
if [ $? != 0 ]; then
    exit 1
fi
log_msg "${YELLOW}所得json结果为:\n${BLUE}${dirFileContentJsonStrings}${BLUE}${NC}"

log_msg "${YELLOW}正在执行命令(将从 featureBrances 文件夹下获取到的的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 属性中):\n《 ${BLUE}sh \"${JsonUpdateFun_script_file_Absolute}\" -f \"${BranchMapAddToJsonFile}\" -k \"${BranchMapAddToKey}\" -v \"${dirFileContentJsonStrings}\" ${YELLOW}》${NC}\n"
sh "${JsonUpdateFun_script_file_Absolute}" -f "${BranchMapAddToJsonFile}" -k "${BranchMapAddToKey}" -v "${dirFileContentJsonStrings}"


# 读取JSON文件内容并提取feature_brances数组中的name2值
name2_values=$(jq -r ".${BranchMapAddToKey}[].name" ${BranchMapAddToJsonFile})
hasCatchRequestBranchNameArray=($name2_values)
uncatchRequestBranchNames=$(getUncatchRequestBranchNames)
if [ -n "${uncatchRequestBranchNames}" ]; then
    echo "${PURPLE}完全匹配失败，结果如下要查找的数据是: ${BLUE}${requestBranchNameArray[*]}\n${PURPLE}但找不到匹配的分支名是: ${RED}${uncatchRequestBranchNames}${NC}"
    look_detail
    exit 1
fi

look_detail

