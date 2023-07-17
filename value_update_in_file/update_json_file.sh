#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-27 22:41:36
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-07-17 23:02:51
 # @FilePath: /script-qbase/value_update_in_file/update_json_file.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 
# 更新/添加指定json文件中的指定字段
# sh update_json_file.sh -f "app_info.json" -k "package_merger_branchs" -v "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]" -skipVCheck "false" -resultJsonF "app_info.json"
:<<!
更新/添加指定json文件中的指定字段
!



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
#CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute}/..
Base_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}


if [ ! -f "${FILE_PATH}" ];then
    echo "❌Error:您要检查JSON有效性的${FILE_PATH}文件不存在，请检查！($0)"
    exit_script
fi
sh ${Base_HomeDir_Absolute}/json_check/json_file_check.sh -checkedJsonF "${FILE_PATH}" -scriptResultJsonF "${RESULT_JSON_FILE_PATH}"
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
    source ${Base_HomeDir_Absolute}/a_function.sh ${Base_HomeDir_Absolute}
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


#| jq -r --arg branchsKey "$branchsKey" '.[$branchsKey]'
if [ "${UpdateJsonKey}" == "testKey" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.testKey = $jsonString' >> ${FilePath_temp}   # 这是覆盖，用=，不用+=
elif [ "${UpdateJsonKey}" == "test_result" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.test_result += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
    

elif [ "${UpdateJsonKey}" == "package_url_result" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_url_result += $jsonString' >> ${FilePath_temp}      # 这是添加，用+=，不用=
    
elif [ "${UpdateJsonKey}" == "package_merger_branchs" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_merger_branchs += $jsonString' >> ${FilePath_temp}
    
elif [ "${UpdateJsonKey}" == "feature_brances" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.feature_brances += $jsonString' >> ${FilePath_temp}

elif [ "${UpdateJsonKey}" == "package_notification_argument_current" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_notification_argument_current = $jsonString' >> ${FilePath_temp}   # 这是覆盖，用=，不用+=
    
elif [ "${UpdateJsonKey}" == "package_pgyer_params" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_pgyer_params = $jsonString' >> ${FilePath_temp}   # 这是覆盖，用=，不用+=
        
elif [ "${UpdateJsonKey}" == "package_pgyer_params_current" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_pgyer_params_current += $jsonString' >> ${FilePath_temp}

elif [ "${UpdateJsonKey}" == "package_result.pgyer_branch_config" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_result.pgyer_branch_config = $jsonString' >> ${FilePath_temp}   # 这是覆盖，用=，不用+=
    
elif [ "${UpdateJsonKey}" == "package_version_update_detail" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.package_version_update_detail = $jsonString' >> ${FilePath_temp}   # 这是覆盖，用=，不用+=
            

# 1、更新 branch element 数组
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.current.branch" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.current.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.lastOnline.branch" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.lastOnline.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.current.branch" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.current.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.lastOnline.branch" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.lastOnline.branch += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
        

# 2、更新 branch category 数组
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.current.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.current.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.current.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.current.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.lastOnline.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.lastOnline.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.lastOnline.category" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.lastOnline.category += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.branch_sort" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.branch_sort += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.branch_sort" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.branch_sort += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=



# 3、更新 branch 的 current \ lastOnline 各自的总字符串
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.current" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.current += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.lastOnline" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.lastOnline += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.current" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.current += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.lastOnline" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.lastOnline += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

# 更新 all
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.all" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.all += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer.all" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer.all += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=


# 4、更新 branch 的总字符串full
elif [ "${UpdateJsonKey}" == "branch_info_result" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

# 5.1、更新打包结果 header 
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.header" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.header += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
# 5.2、更新打包结果 bottom 
elif [ "${UpdateJsonKey}" == "branch_info_result.Notification.bottom" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification.bottom += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

elif [ "${UpdateJsonKey}" == "branch_info_result.Notification" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Notification += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=
elif [ "${UpdateJsonKey}" == "branch_info_result.Pgyer" ]; then
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        '.branch_info_result.Pgyer += $jsonString' >> ${FilePath_temp}   # 这是添加，用+=，不用=

        
else
    cat ${FILE_PATH} |
      jq --arg     objectName "${UpdateJsonKey}" \
         --argjson jsonString "${UpdateJsonKeyValue}" \
        ".${UpdateJsonKey} += $jsonString" >> ${FilePath_temp}   # 这是添加，用+=，不用=
    if [ $? != 0 ]; then
        echo "错误❌:暂不支持该key的更新,即不支持的Json键值为${UpdateJsonKey},字符串key为${UpdateStringKey}"
        exit_script
    fi
fi


if [ $? != 0 ]; then
    echo "❌Error:更新json文件 ${FILE_PATH} 的 ${UpdateJsonKey} 键值失败。附：想要更新成的值为如下:\n${UpdateJsonKeyValue}"
    exit_script
fi

    
#echo "开始执行②删除${FILE_PATH}的内容，并将之前创建的 ${FilePath_temp} 文件的内容复制给它，以达到更新的目的"
cat /dev/null > ${FILE_PATH}
cat "${FilePath_temp}" >> ${FILE_PATH} # FilePath_temp 加引号，避免名称中有空格，导致的错误
rm -f ${FilePath_temp}
