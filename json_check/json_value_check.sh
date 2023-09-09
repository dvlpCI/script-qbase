#!/bin/bash
# source ./a_function.sh ./
:<<!
一些公共方法
!


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


function check_jsonString_valid () {
    check_jsonFile_valid_log="==================执行方法检查json数值是否合规"
    CheckJsonString=$1
    #echo "CheckJsonString=${CheckJsonString}"
    
    JsonPPString=$(echo ${CheckJsonString} | json_pp)
    JsonPPLength=${#JsonPPString}
    # echo "JsonPPLength=${JsonPPLength}"
    if [ ${JsonPPLength} == 0 ]; then
        echo "${check_jsonFile_valid_log}:失败❌"
        return 1
    fi

    #echo "${check_jsonFile_valid_log}:成功✅"
    return 0
}

while [ -n "$1" ]
do
        case "$1" in
                -checkedJsonValue|--checked-json-value) Checked_JSON_VALUE=$2; shift 2;;
                -scriptResultJsonF|--script-result-json-file) SCRIPT_RESULT_JSON_FILE=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done
check_jsonString_valid "${Checked_JSON_VALUE}" "${SCRIPT_RESULT_JSON_FILE}"
