#!/bin/bash
# 更新/添加指定json文件中的指定字段
# sh update_json_file.sh -f "app_info.json" -k "package_merger_branchs" -v "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]" -skipVCheck "false" -resultJsonF "app_info.json"
:<<!
更新/添加指定json文件中的指定字段
!

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


JQ_EXEC=`which jq`

CurrentDirName=${PWD##*/}

# shell 参数具名化
show_usage="args: [-f , -k , -v, -skipVCheck, -resultJsonF]\
                                  [--file=, --key=, --value=, --skip-value-check, --result-json-file=]"

while [ -n "$1" ]
do
        case "$1" in
                -f|--file) FILE_PATH=$2; shift 2;;
                -k|--key) UpdateJsonKey=$2; shift 2;;
                -v|--value) UpdateJsonKeyValue=$2; shift 2;;
                -sk|--string-key) UpdateStringKey=$2; shift 2;;
                -sv|--string-value) UpdateStringKeyValue=$2; shift 2;;
                -skipVCheck|--skip-value-check) SKIP_VALUE_CHECK=$2; shift 2;;      # 要更新的value值，已确保是合法的json，不需要再检查json的有效性。目前由于对含换行符的字符串的有效性检查还不支持，所以对那些已确保是合法的的字符串可以通过此项来跳过检查，避免更新操作被中断(可为空,默认都要检查)
                -resultJsonF|--result-json-file) RESULT_JSON_FILE_PATH=$2; shift 2;;# 执行结果的 code 和 message 保存到的指定文件的 package_code 和 package_message 中(可为空,默认不保存执行结果)
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

#echo "\n"
#echo "===========进入脚本$0 更新/添加指定json文件中的指定字段==========="
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute%/*}
#echo "bulidScriptCommon_dir_Absolute=${bulidScriptCommon_dir_Absolute}"

# qscript_path_get_filepath="${bulidScriptCommon_dir_Absolute}/qscript_path_get.sh"
# qbase_json_file_check_script_path="$(sh ${qscript_path_get_filepath} qbase json_file_check)"
qbase_json_file_check_script_path="${bulidScriptCommon_dir_Absolute}/json_check/json_file_check.sh"

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}


if [ ! -f "${FILE_PATH}" ];then
    echo "❌Error:您要检查JSON有效性的文件 ${FILE_PATH} 不存在，请检查！($0)"
    exit_script
fi
sh ${qbase_json_file_check_script_path} -checkedJsonF "${FILE_PATH}" -scriptResultJsonF "${RESULT_JSON_FILE_PATH}"
if [ $? != 0 ]; then
    exit_script
fi

if [ -n "${UpdateStringKey}" ]; then
  UPDATE_STRING_HOME_KEY=$(echo ${UpdateStringKey%.*})  # %.* 表示从右边开始，删除第一个 . 号及右边的字符
  UPDATE_STRING_PATH_KEY=$(echo ${UpdateStringKey##*.}) # *. 表示从左边开始删除最后（最右边）一个 . 号及左边的所有字符
  UpdateJsonKey="${UPDATE_STRING_HOME_KEY}"
  UpdateJsonKeyValue="{\"${UPDATE_STRING_PATH_KEY}\": ${UpdateStringKeyValue}}"
else
    UpdateStringKey="${UpdateJsonKey}_TODO字符串"
fi

if [ -z "${UpdateJsonKey}" ]; then
  echo "❌:您要更新${FILE_PATH}文件的Key值不能不指定，请检查！"
  exit_script
fi

if [ -z "${SKIP_VALUE_CHECK}" ]; then
    SKIP_VALUE_CHECK="false"
fi
if [ "${SKIP_VALUE_CHECK}" != "true" ]; then
    source ${bulidScriptCommon_dir_Absolute}/a_function.sh ${bulidScriptCommon_dir_Absolute}
    check_jsonString_valid "${UpdateJsonKeyValue}" "${RESULT_JSON_FILE_PATH}"
    if [ $? != 0 ]; then
        exit_script
    fi
fi


FileName=${FILE_PATH##*/} # 取最后的component
#echo "FileName=${FileName}"
FileType=${FileName##*.}
FileNameNoType=${FileName%%.*}
#echo "FileNameNoType=${FileNameNoType}, FileType=${FileType}"
FilePath_temp="${FileNameNoType}_temp.${FileType}"
#echo "FilePath_temp=${FilePath_temp}"
#echo "更新本次打包的内容到项目外和项目内，便于下次检查"
cat /dev/null > ${FilePath_temp} # 清空文件内容
#echo "开始执行①对${FILE_PATH}的内容添加 ${UpdateJsonKey} 属性的值，并在添加后输出到 ${FilePath_temp} 文件中"


# TODO:以下 branchPathKey  还不支持 层级key，待完善
if [ "${UpdateJsonKey}" == "branch_info_result.Notification.current" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.current += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.current.branch" ]; then
  cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.current.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.current.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.current.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.lastOnline" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.lastOnline += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.lastOnline.branch" ]; then
  cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.lastOnline.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.lastOnline.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.lastOnline.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.current" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.current += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.current.branch" ]; then
  cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.current.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.current.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.current.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.lastOnline" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.lastOnline += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.lastOnline.branch" ]; then
  cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.lastOnline.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.lastOnline.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.lastOnline.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=



else
  cat ${FILE_PATH} |
    jq --arg branchPathKey "${UpdateJsonKey}" --argjson jsonString "${UpdateJsonKeyValue}" \
      '.[$branchPathKey] += $jsonString' \
    >> ${FilePath_temp}
fi
if [ $? != 0 ]; then
    echo "错误❌:更新失败,即不支持的Json键值为${UpdateJsonKey},字符串key为${UpdateStringKey}"
    exit_script
fi




if [ $? != 0 ]; then
    echo "${RED}❌Error:更新json文件 ${BLUE}${FILE_PATH} ${RED}的 ${BLUE}${UpdateJsonKey} ${RED}键值失败，想要更新成的值为如下:\n${BLUE}${UpdateJsonKeyValue} ${NC}"
    exit_script
fi

    
#echo "开始执行②删除${FILE_PATH}的内容，并将之前创建的 ${FilePath_temp} 文件的内容复制给它，以达到更新的目的"
cat /dev/null > ${FILE_PATH}
cat "${FilePath_temp}" >> ${FILE_PATH} # FilePath_temp 加引号，避免名称中有空格，导致的错误
rm -f ${FilePath_temp}
