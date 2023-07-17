#!/bin/bash
# 更新/添加指定json文件中的指定字段
# sh update_json_file_singleString.sh -jsonF ${FILE_PATH} -k ${UpdateJsonKey} -v "${UpdateJsonKeyValue}"
# sh update_json_file_singleString.sh -jsonF "../bulidScript/app_info.json" -k "package_message" -v "这是新的更新说明"
# sh update_json_file_singleString.sh -jsonF "../bulidScript/app_info.json" -k "package_merger_branchs" -v "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]"
: <<!
更新/添加指定json文件中的指定字段
!

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
Base_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
sed_text_script_file_path=${Base_HomeDir_Absolute}/value_update_in_file/sed_text.sh
get_script_file_path=${Base_HomeDir_Absolute}/value_get_in_json_file/value_get_in_json_file.sh

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

function UpdateJsonFileKeyWithValue() {
    while [ -n "$1" ]
    do
            case "$1" in
                    -jsonF|--json-file) FILE_PATH=$2; shift 2;;
                    -k|--key) UpdateJsonKey=$2; shift 2;;
                    -v|--value) UpdateJsonKeyValue=$2; shift 2;;
                    --) break ;;
                    *) echo $1,$2; break ;;
            esac
    done
    
    # printf "${BLUE}正在使用 $FUNCNAME 方法，更新/添加 ${FILE_PATH} 中的 ${UpdateJsonKey} 字段的值为《 ${UpdateJsonKeyValue} 》${NC}\n"
    Old_JsonValue=$(sh ${get_script_file_path} -jsonF "${FILE_PATH}" -k "${UpdateJsonKey}")
    if [ $? != 0 ]; then
        return 1
    fi
    logMsg "==============未转义前的旧值:${Old_JsonValue}"

    Old_JsonValue=${Old_JsonValue//\\/\\\\}
    logMsg "==============已转义后的旧值:${Old_JsonValue}"

    # UpdateJsonKeyValue="哈哈哈"
    
    if [ "${Old_JsonValue}" == "null" ]; then
        printf "${RED}❌Error:$FUNCNAME 方法执行失败。原因为在 ${FILE_PATH} 中 ${BLUE}${UpdateJsonKey} ${RED}的值不能为null，否则容易导致其他null值，也会被sed替换掉${NC}\n"
        return 1
    fi

    logMsg "正在执行命令(替换文本):《 sh $sed_text_script_file_path -f \"${FILE_PATH}\" -r \"${Old_JsonValue}\" -t \"${UpdateJsonKeyValue}\" -verbose \"${showVerbose}\" 》"
    sh $sed_text_script_file_path -f "${FILE_PATH}" -r "${Old_JsonValue}" -t "${UpdateJsonKeyValue}" -verbose "${showVerbose}"
    scriptResultCode=$?
    if [ ${scriptResultCode} != 0 ]; then
        echo "=============${scriptResultCode}"
        printf "${RED}执行命令(替换文本)发生错误:《 sh $sed_text_script_file_path -f \"${FILE_PATH}\" -r \"${Old_JsonValue}\" -t \"${UpdateJsonKeyValue}\" -verbose \"${showVerbose}\" 》${NC}\n"
        UpdateJsonKeyValue="错误信息输出失败，请查看打包日志"
        sh $sed_text_script_file_path -f "${FILE_PATH}" -r "${Old_JsonValue}" -t "${UpdateJsonKeyValue}"

        return ${scriptResultCode}
    fi
}

while [ -n "$1" ]
do
        case "$1" in
                -jsonF|--json-file) FILE_PATH=$2; shift 2;;
                -k|--key) UpdateJsonKey=$2; shift 2;;
                -v|--value) UpdateJsonKeyValue=$2; shift 2;;
                -verbose|--show-verbose) showVerbose=$2; shift 2;;
                --) break ;;
                *) echo $1,$2; break ;;
        esac
done

function logMsg() {
    if [ "${showVerbose}" == true ]; then
        printf "${YELLOW}$1${NC}\n"
    fi
}

#[在shell脚本中验证JSON文件的语法](https://qa.1r1g.com/sf/ask/2966952551/)
#cat app_info.json
fullJsonString=$(cat ${FILE_PATH} | json_pp)
fullJsonLength=${#fullJsonString}
#echo "fullJsonLength=${#fullJsonLength}"
if [ ${fullJsonLength} == 0 ]; then
    PackageErrorCode=-1
    PackageErrorMessage="${FILE_PATH}不是标准的json格式，请检查"
    sed -i '' "s/package_code_0/${PackageErrorCode}/g" ${FILE_PATH}
    sed -i '' "s/可以打包/${PackageErrorMessage}/g" ${FILE_PATH}
    #sh sed_text.sh -appInfoF ${FILE_PATH} -r "package unknow message" -t "${PackageErrorMessage}"
    echo ${PackageErrorCode}:${PackageErrorMessage}
    exit_script
fi

#echo "正在执行命令(更新JSON文件中的数值)：《UpdateJsonFileKeyWithValue -jsonF \"${FILE_PATH}\" -k \"${UpdateJsonKey}\" -v \"${UpdateJsonKeyValue}\"》"
UpdateJsonFileKeyWithValue -jsonF "${FILE_PATH}" -k "${UpdateJsonKey}" -v "${UpdateJsonKeyValue}"
