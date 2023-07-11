#!/bin/bash
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


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


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
    
    
#    echo "$0 $FUNCNAME 执行在${FILE_PATH}中更新/添加${UpdateJsonKey}字段的值为${UpdateJsonKeyValue}"
    getJsonFileKeyValue -jsonF "${FILE_PATH}" -k "${UpdateJsonKey}"
    if [ $? != 0 ]; then
        return 1;
    fi
    Old_JsonValue=${JsonFileKeyValueResult}
#    echo "Old_JsonValue=${Old_JsonValue}"
    if [ "${Old_JsonValue}" == "null" ];then
        printf "${RED}❌Error:$FUNCNAME 方法执行失败。原因为在 ${FILE_PATH} 中 ${BLUE}${UpdateJsonKey} ${RED}的值不能为null，否则容易导致其他null值，也会被sed替换掉${NC}\n"
        return 1
    fi

    #echo "正在执行命令(替换文本):sh ${bulidScriptCommon_dir_Absolute}/update_value/sed_text.sh -appInfoF \"${FILE_PATH}\" -r \"${Old_JsonValue}\" -t \"${UpdateJsonKeyValue}\""
    sh ${bulidScriptCommon_dir_Absolute}/update_value/sed_text.sh -appInfoF "${FILE_PATH}" -r "${Old_JsonValue}" -t "${UpdateJsonKeyValue}"
   scriptResultCode=$?
   if [ ${scriptResultCode} != 0 ]; then
   echo "=============${scriptResultCode}"
        echo "执行命令(替换文本)发生错误:《 sh ${bulidScriptCommon_dir_Absolute}/update_value/sed_text.sh -appInfoF \"${FILE_PATH}\" -r \"${Old_JsonValue}\" -t \"${UpdateJsonKeyValue}\" 》"
        UpdateJsonKeyValue="错误信息输出失败，请查看打包日志"
        sh ${bulidScriptCommon_dir_Absolute}/update_value/sed_text.sh -appInfoF "${FILE_PATH}" -r "${Old_JsonValue}" -t "${UpdateJsonKeyValue}"
       
       return ${scriptResultCode}
   fi
#
#    getJsonFileKeyValue -jsonF ${FILE_PATH} -k ${UpdateJsonKey}
#    New_JsonValue=${JsonFileKeyValueResult}
#    if [ "${New_JsonValue}" == "${UpdateJsonKeyValue}" ]; then
#        return 0
#    else
#        return 1
#    fi
}

function getJsonFileKeyValue() {
    while [ -n "$1" ]
    do
            case "$1" in
                    -jsonF|--json-file) FILE_PATH=$2; shift 2;;
                    -k|--key) UpdateJsonKey=$2; shift 2;;
                    -ifNullCreate|--ifNull-createIt) ifNullCreateIt=$2; shift 2;;
                    --) break ;;
                    *) echo $1,$2; break ;;
            esac
    done
    
    
    #echo "---正执行《 $FUNCNAME 》方法，在${FILE_PATH}中获取${UpdateJsonKey}字段的值"
    if [ ! -f "${FILE_PATH}" ];then
        printf "${RED}❌调用$0中的《 $FUNCNAME 》方法更新${UpdateJsonKey}值的时候，发生错误，你要更新的文件不存在，请检查！${NC}\n"
        return 1
    fi
    
    JQ_EXEC=`which jq`
    # 只需处理一层时候，可简写为如下
    #JsonFileKeyValueResult=$(cat ${FILE_PATH} | ${JQ_EXEC} -r ".package_code") # "package_code_0"
#    JsonFileKeyValueResult=$(cat ${FILE_PATH} | ${JQ_EXEC} -r --arg UpdateJsonKey "$UpdateJsonKey" '.[$UpdateJsonKey]')
#    echo ${JsonFileKeyValueResult}
    
    
    # 需要处理多层key时候，应使用如下:(eg:package_url_result.package_local_backup_dir)
#    appOfficialWebsite=$(cat $FILE_PATH | ${JQ_EXEC} .package_result | ${JQ_EXEC} '.package_official_website' | sed 's/\"//g')
    
    keyArray=(${UpdateJsonKey//./ })
#    echo "$0 $FUNCNAME keyArray=${keyArray[*]}"
    keyCount=${#keyArray[@]}
    
    # 📢注：使用 cat ${FILE_PATH} 是为了避免出现使用 echo ${CurrentJsonString} 时候出现的CurrentJsonString中含有乱七八糟的字符串(eg✅)时候，出现提取错误的问题
    if [ $keyCount -eq 1 ]; then
        #echo "=========只有一层key"
        keyName=${keyArray[0]}
        JsonFileKeyValueResult=$(cat "${FILE_PATH}" | ${JQ_EXEC} -r --arg keyName "$keyName" '.[$keyName]')
        if [ $? != 0 ]; then
            printf "${RED}❌:jquery获取出错，请检查。(可能原因为您的${FILE_PATH}文件不是标准json，如是上文出错信息会提示可能哪一行有问题)${NC}\n"
            return 1
        fi
    else
        #echo "=========有多层key"
        RootJsonString=`cat ${FILE_PATH}`
        CurrentJsonString=${RootJsonString}

        for ((i=0;i<keyCount;i++))
        do
            keyName=${keyArray[i]}
            
            #echo "CurrentJsonString=${CurrentJsonString}"
            JsonFileKeyValueResult=$(echo ${CurrentJsonString} | ${JQ_EXEC} -r --arg keyName "$keyName" '.[$keyName]')
            if [ $? != 0 ]; then
                printf "${RED}❌:jquery获取出错，请检查。${NC}\n"
                return 1
            fi
            #echo "第$((i+1))层 $keyName:${JsonFileKeyValueResult}"
            CurrentJsonString=${JsonFileKeyValueResult}
        done
    fi
    
    #echo "---通过《 $FUNCNAME 》方法，获取${UpdateJsonKey}键值的结果为${JsonFileKeyValueResult}"
}


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


#echo "正在执行命令(更新JSON文件中的数值)：《UpdateJsonFileKeyWithValue -jsonF \"${FILE_PATH}\" -k \"${UpdateJsonKey}\" -v \"${UpdateJsonKeyValue}\"》"
UpdateJsonFileKeyWithValue -jsonF "${FILE_PATH}" -k "${UpdateJsonKey}" -v "${UpdateJsonKeyValue}"



# test eg:
# UpdateJsonFileKeyWithValue -jsonF "../bulidScript/app_info.json" -k "package_url_result.package_local_backup_dir" -v "这是新的更新说明"
