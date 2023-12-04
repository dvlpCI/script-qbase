#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-08-03 01:52:44
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-10 18:31:01
 # @FilePath: /script-qbase/json_check/json_value_check.sh
 # @Description: 检查 json 字符串是不是合规
### 

function check_jsonString_valid () {
    CheckJsonString=$1
    #echo "CheckJsonString=${CheckJsonString}"
    
    JsonPPString=$(echo "${CheckJsonString}" | json_pp)
    if [ $? != 0 ]; then
        echo "您的 ${CheckJsonString} 内容不是标准的json格式，请检查！"
        return 1
    fi

    JsonPPLength=${#JsonPPString}
    #echo "JsonPPLength=${JsonPPLength}"
    if [ "${JsonPPLength}" == 0 ]; then
        echo "您的 ${CheckJsonString} 内容不是标准的json格式，请检查！"
        return 1
    fi

    return 0
}

while [ -n "$1" ]
do
        case "$1" in
                -checkedJsonValue|--checked-json-value) Checked_JSON_VALUE=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done

# # 使用jq验证JSON格式
# echo "$Checked_JSON_VALUE" | jq empty > /dev/null 2>&1
# if [ $? -ne 0 ]; then
#     echo "❌Error:您的 -checkedJsonValue 参数值 ${Checked_JSON_VALUE} 字符串不符合JSON格式，请检查"
#     exit 1
# fi

check_jsonString_valid "${Checked_JSON_VALUE}" "${SCRIPT_RESULT_JSON_FILE}"
