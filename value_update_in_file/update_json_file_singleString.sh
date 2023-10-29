#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-28 21:03:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 21:25:34
 # @Description: 
### 
# 更新/添加指定json文件中的指定字段
# sh update_json_file_singleString.sh -jsonF ${FILE_PATH} -k ${UpdateJsonKey} -v "${UpdateJsonKeyValue}"
# sh update_json_file_singleString.sh -jsonF "../bulidScript/app_info.json" -k "package_message" -v "这是新的更新说明"
# sh update_json_file_singleString.sh -jsonF "../bulidScript/app_info.json" -k "package_merger_branchs" -v "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]"
:<<!
更新/添加指定json文件中的指定字段
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute}/..
bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#echo "bulidScriptCommon_dir_Absolute=${bulidScriptCommon_dir_Absolute}"
sed_text_script_file_path=${bulidScriptCommon_dir_Absolute}/value_update_in_file/sed_text.sh
value_get_in_json_file_scriptPath=${bulidScriptCommon_dir_Absolute}/value_get_in_json_file/value_get_in_json_file.sh



# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}




while [ -n "$1" ]
do
        case "$1" in
                -jsonF|--json-file) FILE_PATH=$2; shift 2;;
                -k|--key) UpdateJsonKey=$2; shift 2;;
                -v|--value) UpdateJsonKeyValue=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done
# test eg:
# FILE_PATH="../bulidScript/app_info.json"
# UpdateJsonKey="package_url_result.package_local_backup_dir"
# UpdateJsonKeyValue="这是新的更新说明"

# 已知有如下json，
# {
#     "ab": {
#         "ef":{
#             }
#     }
# }
# 则层级key_name=ab.ef。代表是想修改ab里面ef键的值
# jq --arg key "$UpdateJsonKey" --argjson new_value "$UpdateJsonKeyValue" 'setpath($key | split(".") | map(select(. != ""))) |= $new_value' "$FILE_PATH" > temp.json && mv temp.json "$FILE_PATH"


# 已知json文件内容如下：
# '{
#   "other": {
#     "c": "这是干扰项"
#   },
#   "target": {
#     "b": {
#       "c": "这是目标项"
#     }
#   }
# }'
# 请使用shell修改 target里的b的c的键值。
# jq '.target.b.c = "修改后的值"' "$JSON_FILE_PATH" > temp.json && mv temp.json "$JSON_FILE_PATH"


# 使用单引号，形如 '.[$key] = $new_value' 的时候，key 和 new_value 都需要通过 --arg 或 --argjson 定义，且等号前面是 .[$key]
# 使用双引号，形如 ".$key = \$new_value" 的时候，key 不需要定义，但需写为 .$key；而 new_value 不仅需要通过 --arg 或 --argjson 定义，还应 \$new_value
# 判断 new_value 是否为 JSON
if jq -e . >/dev/null 2>&1 <<<"$UpdateJsonKeyValue"; then
    # new_value 是一个有效的 JSON
    # jq --arg key "$UpdateJsonKey" --argjson new_value "$UpdateJsonKeyValue" '.[$key] = $new_value' "$FILE_PATH" > temp.json && mv temp.json "$FILE_PATH"
    jq --argjson new_value "$UpdateJsonKeyValue" ".$UpdateJsonKey = \$new_value" "$FILE_PATH" > temp.json && mv temp.json "$FILE_PATH"
else
    # new_value 是一个普通字符串
    # jq --arg key "$UpdateJsonKey" --arg new_value "$UpdateJsonKeyValue" '.[$key] = $new_value' "$FILE_PATH" > temp.json && mv temp.json "$FILE_PATH"
    jq --arg new_value "$UpdateJsonKeyValue" ".$UpdateJsonKey = \$new_value" "$FILE_PATH" > temp.json && mv temp.json "$FILE_PATH"
fi
if [ $? != 0 ]; then
    exit 1
else
    exit 0
fi



# echo "${YELLOW}正在执行在${BLUE} ${FILE_PATH} ${YELLOW}中更新/添加${BLUE} ${UpdateJsonKey} ${YELLOW}字段的值为${BLUE} ${UpdateJsonKeyValue} ${YELLOW}。${NC}"
Old_JsonValue=$(sh ${value_get_in_json_file_scriptPath} -jsonF "${FILE_PATH}" -k "${UpdateJsonKey}")
if [ $? != 0 ]; then
    exit 1;
fi
# debug_log "Old_JsonValue=${Old_JsonValue}"
if [ -z "${Old_JsonValue}" ] || [ "${Old_JsonValue}" == "null" ];then
    printf "${RED}❌Error:$FUNCNAME 方法执行失败。原因为在 ${FILE_PATH} 中 ${BLUE}${UpdateJsonKey} ${RED}的值不能为空或null，否则容易导致其他空或null值，也会被sed替换掉${NC}\n"
    exit 1
fi

debug_log "${YELLOW}正在执行命令(替换文本):《${BLUE} sh $sed_text_script_file_path -f \"${FILE_PATH}\" -r \"${Old_JsonValue}\" -t \"${UpdateJsonKeyValue}\" ${YELLOW}》${NC}"
sh $sed_text_script_file_path -f "${FILE_PATH}" -r "${Old_JsonValue}" -t "${UpdateJsonKeyValue}"
scriptResultCode=$?
if [ ${scriptResultCode} != 0 ]; then
    debug_log "=============${scriptResultCode}"
    debug_log "执行命令(替换文本)发生错误:《 sh $sed_text_script_file_path -f \"${FILE_PATH}\" -r \"${Old_JsonValue}\" -t \"${UpdateJsonKeyValue}\" 》"
    UpdateJsonKeyValue="错误信息输出失败，请查看打包日志"
    sh $sed_text_script_file_path -f "${FILE_PATH}" -r "${Old_JsonValue}" -t "${UpdateJsonKeyValue}"
    
    exit ${scriptResultCode}
fi

debug_log "更新成功"