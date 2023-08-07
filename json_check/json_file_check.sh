#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 14:33:30
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-08 01:01:41
 # @Description: 检查指定Json文件的有效性，是不是合法
 # @example: sh ./json_file_check.sh -checkedJsonF "${Checked_JSON_FILE_PATH}" -scriptResultJsonF "${SCRIPT_RESULT_JSON_FILE}"
###


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..



# shell 参数具名化
show_usage="args: [-checkedJsonF, -scriptResultJsonF]\
                                  [--checked-json-file-path=, --script-result-json-file=]"

while [ -n "$1" ]
do
        case "$1" in
                -checkedJsonF|--checked-json-file-path) Checked_JSON_FILE_PATH=$2; shift 2;;
                -scriptResultJsonF|--script-result-json-file) SCRIPT_RESULT_JSON_FILE=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


function updatePackageErrorCodeAndMessage() {
    if [ $1 != 0 ]; then
        printf "${RED}❌Error:$1:$2${NC}\n"
    else
        printf "${BLUE}$1:$2${NC}\n"
    fi

    if [ ! -f "${SCRIPT_RESULT_JSON_FILE}" ]; then   # 指定文件，不存在，使用默认的
        SCRIPT_RESULT_JSON_FILE="${CommonFun_HomeDir_Absolute}/json/common_script_result.json"
    fi
    sh "${CommonFun_HomeDir_Absolute}/base/error_code_message/update_code_message.sh" -codeMessageJsonF "${SCRIPT_RESULT_JSON_FILE}" -code "$1" -message "$2"
    if [ $? != 0 ]; then
        echo "❌Error:执行以下更新命令时候失败，请检查《sh \"${CommonFun_HomeDir_Absolute}/base/error_code_message/update_code_message.sh\" -codeMessageJsonF \"${SCRIPT_RESULT_JSON_FILE}\" -code \"$1\" -message \"$2\"》"
        exit 1
    fi
}

#[在shell脚本中验证JSON文件的语法](https://qa.1r1g.com/sf/ask/2966952551/)
function check_jsonFile_valid() {
    check_jsonFile_valid_log="==================执行方法:$FUNCNAME 检查$1文件的Json有效性"
    Check_Json_FILE_PATH=$1
    
    if [ -z "${Check_Json_FILE_PATH}" ]; then
        updatePackageErrorCodeAndMessage 1 "执行命令时缺失填写要检查文件的入参，请检查！"
        return 1
    fi
    
    if [ ! -f "${Check_Json_FILE_PATH}" ]; then
        updatePackageErrorCodeAndMessage 1 "您的${Check_Json_FILE_PATH}文件不存在，请检查！"
        return 1
    fi
    
    if [ -z "$(cat ${Check_Json_FILE_PATH})" ]; then
        updatePackageErrorCodeAndMessage 1 "您的${Check_Json_FILE_PATH}文件内容为空，请检查！"
        return 1 # 为空是失败
    fi

    JsonPPString=$(cat ${Check_Json_FILE_PATH} | json_pp)
    JsonPPLength=${#JsonPPString}
    #echo "JsonPPLength=${JsonPPLength}"
    if [ ${JsonPPLength} == 0 ]; then
        updatePackageErrorCodeAndMessage 1 "您的${Check_Json_FILE_PATH}文件不是标准的json格式，请检查！"
        return 1
    fi

    #echo "${check_jsonFile_valid_log}:成功✅"
    return 0
}



check_jsonFile_valid "${Checked_JSON_FILE_PATH}"

