#!/bin/bash
:<<!
获取branchMaps
BranceMaps_From_Directory_PATH="${workspace}/buildScript/featureBrances"
BranchMapAddToJsonFile="${workspace}/buildScript/app_branch_info.json"
BranchMapAddToKey=".feature_brances"
ignoreAddJsonFileNames=("dev_demo.json")
sh ./branchMaps_10_resouce/addBranchMaps_toJsonFile.sh -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -ignoreAddJsonFileNames "${ignoreAddJsonFileNames}"
!

#echo "===========进入脚本$0==========="

JQ_EXEC=`which jq`

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# shell 参数具名化
show_usage="args: [-branchMapsFromDir, -branchMapsAddToJsonF, -branchMapsAddToKey, -ignoreAddJsonFileNames]\
                                  [--branchMaps-is-from-dir-path, --branchMaps-add-to-json-file=, --branchMaps-add-to-key=, --ignoreAddJsonFileNames=]"

while [ -n "$1" ]
do
        case "$1" in
                -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;;
                -branchMapsAddToJsonF|--branchMaps-add-to-json-file) BranchMapAddToJsonFile=$2; shift 2;;
                -branchMapsAddToKey|--branchMaps-add-to-key) BranchMapAddToKey=$2; shift 2;;
                -ignoreAddJsonFileNames|--ignoreAddJsonFileNames) ignoreAddJsonFileNames=$2; shift 2;;
                -scriptResultJsonF|--script-result-json-file) SCRIPT_RESULT_JSON_FILE=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done


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
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#echo "CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute}"

qbase_update_json_file_singleString_script_path="${CommonFun_HomeDir_Absolute}/update_value/update_json_file_singleString.sh"
qbase_json_file_check_script_path="${CommonFun_HomeDir_Absolute}/json_check/json_file_check.sh"
get_jsonstring_script_file=${CommonFun_HomeDir_Absolute}/json_formatter/get_jsonstring.sh
JsonUpdateFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/update_value/update_json_file.sh"

#exit

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}


function read_dir() {
#    echo "读取目录文件，当前路径:"$PWD
#    echo "读取目录文件，要检查的文件夹:"$1
    ignoreAddJsonFileNameArray=($2)
    SCRIPT_RESULT_JSON_FILE=$3
#    echo "读取目录文件，要忽略的文件有:${ignoreAddJsonFileNameArray[*]}"
    
    for file in `ls $1`
    do
        if [ -d $1/$file ];then
            cd $1/$file
            read dir $1" /"file
            cd -
        else
            absoluteFilePath=$1/$file
            if [ ! -f "${absoluteFilePath}" ];then
                echo "$0 $FUNCNAME ❌:您的${absoluteFilePath}文件不存在，请检查！"
                return 1
            fi
    
            dirFilePathArray[${#dirFilePathArray[@]}]=${absoluteFilePath}
            
            # [shell替换和去掉换行符](http://www.noobyard.com/article/p-ahlemikj-nz.html)
            FileContent=$(cat ${absoluteFilePath} |sed 's/ /\n/g'|awk '{{printf"%s",$0}}')
            
            # [Shell 命令变量去除空格方法](https://blog.csdn.net/jjc120074203/article/details/126663391)
            FileContent=${FileContent// /}
            
            #echo "file=${file}"
            if echo "${ignoreAddJsonFileNameArray[@]}" | grep -wq "${file}" &>/dev/null; then
                continue
            fi
            
            sh ${qbase_json_file_check_script_path} -checkedJsonF "${absoluteFilePath}" -scriptResultJsonF "${SCRIPT_RESULT_JSON_FILE}"
            if [ $? != 0 ]; then
                updateNotiPeopleByBranchFile "${absoluteFilePath}"
                echo "执行命令(检查json文件的完整性)时候出错:sh ${qbase_json_file_check_script_path} -checkedJsonF \"${absoluteFilePath}\" -scriptResultJsonF \"${SCRIPT_RESULT_JSON_FILE}\""
                return 1
            fi
            
            #echo "FileContent=${FileContent}"
            FileIndex=${#dirFileContentsResult[*]}
            #echo "FileIndex=${FileIndex}"
            dirFileContentsResult[${FileIndex}]="${FileContent}"
        fi
    done
    
#    echo "dirFileContentArray1=${dirFileContentsResult[0]}"
#    echo "dirFileContentArray2=${dirFileContentsResult[1]}"
#    echo "dirFilePathArray=${dirFilePathArray[*]}"
#    echo "dirFileContentsResult=${dirFileContentsResult[*]}"

    if [ ${#dirFileContentsResult[@]} == 0 ]; then
        echo "友情提示🤝：读取目录文件，未提取到符合条件的文件"
    fi
}

# 更新通知人为对应分支的提交者
function updateNotiPeopleByBranchFile() {
    branchAbsoluteFilePath=$1
    # 文件json格式错误，无法读取，故转而使用不一定规范的文件名当做分支来获取分支最后一次的提交用户
    absoluteFileName=${branchAbsoluteFilePath##*/} # 取最后的component
    absoluteFileNameNoType=${absoluteFileName%%.*}
    errorBranchName=${absoluteFileNameNoType}

    echo "正在执行命令(要获取某个远程分支最后一次提交的作者名字)：《git log -1 --format=\"%an\" remotes/origin/${errorBranchName}》 " # 如果你想获取作者的电子邮件地址，可以把%an改为%ae。
    errorBranchUser=$(git log -1 --format="%an" remotes/origin/${errorBranchName})
    sh "${qbase_update_json_file_singleString_script_path}" -jsonF "${SCRIPT_RESULT_JSON_FILE}" -k 'package_noti_people' -v "${errorBranchUser}"
    if [ $? != 0 ]; then
        echo "❌Error:更新 package_noti_people 失败"
        return 1
    fi
}


#获取featureBrances文件夹下的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 中    
    if [ ! -d "${BranceMaps_From_Directory_PATH}" ];then
        echo "Error❌:您的App_Feature_Brances_Directory_PATH= ${BranceMaps_From_Directory_PATH} 文件夹不存在，请检查！"
        exit_script
    fi

    if [ ! -f "${BranchMapAddToJsonFile}" ];then
        echo "Error❌:您的Branch_Info_FILE_PATH=${BranchMapAddToJsonFile} 文件不存在，请检查！"
        exit_script
    fi

    read_dir "${BranceMaps_From_Directory_PATH}" "${ignoreAddJsonFileNames}" "${SCRIPT_RESULT_JSON_FILE}"
    if [ $? != 0 ]; then
        echo "执行命令(读取目录下的文件)发生错误:《 read_dir \"${BranceMaps_From_Directory_PATH}\" \"${ignoreAddJsonFileNames}\" \"${SCRIPT_RESULT_JSON_FILE}\" 》"
        return 1
    fi    
    
    if [ ${#dirFileContentsResult[@]} == 0 ]; then
        echo "友情提示🤝：读取目录文件，未提取到符合条件的文件，即不会往 ${BranchMapAddToJsonFile} 中的 ${BranchMapAddToKey} 属性添加其他值，最终的分支信息只能靠其原有值了"
        return 0
    fi
    
    log_msg "${YELLOW}正在执行命令(获取json内容)《 ${BLUE}sh ${get_jsonstring_script_file} -arrayString \"${dirFileContentsResult[*]}\" -escape \"true\" ${YELLOW}》${NC}"
    dirFileContentJsonStrings=$(sh ${get_jsonstring_script_file} -arrayString "${dirFileContentsResult[*]}" -escape "false")
    if [ $? != 0 ]; then
        return 1
    fi
    log_msg "${YELLOW}所得json结果为:\n${BLUE}${dirFileContentJsonStrings}${BLUE}${NC}"

    log_msg "${YELLOW}正在执行命令(将从 featureBrances 文件夹下获取到的的所有分支json组成数组，添加到 ${BranchMapAddToJsonFile} 的 ${BranchMapAddToKey} 属性中):\n《 ${BLUE}sh \"${JsonUpdateFun_script_file_Absolute}\" -f \"${BranchMapAddToJsonFile}\" -k \"${BranchMapAddToKey}\" -v \"${dirFileContentJsonStrings}\" ${YELLOW}》${NC}\n"
    sh "${JsonUpdateFun_script_file_Absolute}" -f "${BranchMapAddToJsonFile}" -k "${BranchMapAddToKey}" -v "${dirFileContentJsonStrings}"
    echo "${YELLOW}分支源添加到文件后的更多详情可查看: ${BLUE}${BranchMapAddToJsonFile} ${NC}的 ${BLUE}${BranchMapAddToKey} ${NC}"