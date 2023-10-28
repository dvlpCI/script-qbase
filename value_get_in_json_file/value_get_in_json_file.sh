#!/bin/bash
# 获取指定json文件中的指定key字段的值
# sh value_get_in_json_file.sh -jsonF ${FILE_PATH} -k ${UpdateJsonKey}
# sh value_get_in_json_file.sh -jsonF "../bulidScript/app_info.json" -k "package_message"

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function logMsg() {
    if [ "${showVerbose}" == true ]; then
        printf "${YELLOW}$1${NC}\n"
    fi
}

logResutValue() {
    # ❌错误方法：使用echo无法正确输出值
    # echo "=============${escaped_value//\\/\\\\}============="

    # ✅正确方法：使用先存到file，再从file中打印
    local now_time=$(date +"%m%d%H%M%S")
    local temp_file_abspath="${CurrentDIR_Script_Absolute}/${now_time}.json"

    echo $1 > ${temp_file_abspath} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    cat ${temp_file_abspath}

    # 删除文件temp_file_abspath
    rm -rf ${temp_file_abspath}
}



while [ -n "$1" ]
do
        case "$1" in
                -jsonF|--json-file) FILE_PATH=$2; shift 2;;
                -k|--key) UpdateJsonKey=$2; shift 2;;
                -verbose|--show-verbose) showVerbose=$2; shift 2;;
                --) break ;;
                *) echo $1,$2; break ;;
        esac
done



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
    
    
#echo "---正执行《 $FUNCNAME 》方法，在${FILE_PATH}中获取${UpdateJsonKey}字段的值"
if [ ! -f "${FILE_PATH}" ]; then
    printf "${RED}❌调用$0中的《 $FUNCNAME 》方法更新 ${UpdateJsonKey} 值的时候，发生错误，你要更新的文件不存在，请检查！${NC}\n"
    return 1
fi

JQ_EXEC=$(which jq)
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
    # printf "${YELLOW}${UpdateJsonKey} =========只有一层key${NC}\n"
    keyName=${keyArray[0]}
    JsonFileKeyValueResult=$(cat "${FILE_PATH}" | ${JQ_EXEC} --arg keyName "$keyName" '.[$keyName]')
    if [ $? != 0 ]; then
        printf "${RED}❌:jquery获取出错，请检查。(可能原因为您的${FILE_PATH}文件不是标准json，如是上文出错信息会提示可能哪一行有问题)${NC}\n"
        return 1
    fi
else
    # printf "${YELLOW}${UpdateJsonKey} =========有多层key${NC}\n"
    RootJsonString=$(cat ${FILE_PATH})
    CurrentJsonString=${RootJsonString}

    for ((i = 0; i < keyCount; i++)); do
        keyName=${keyArray[i]}

        # echo "CurrentJsonString=${CurrentJsonString}"
        # echo "正在执行《 echo ${CurrentJsonString//\\/\\\\} | ${JQ_EXEC} -r --arg keyName \"$keyName\" '.[$keyName]' 》"
        # 注意📢：${CurrentJsonString//\\/\\\\} 的目的是 "替换所有换行符，而不是只替换第一个"
        JsonFileKeyValueResult=$(echo ${CurrentJsonString} | ${JQ_EXEC} --arg keyName "$keyName" '.[$keyName]')
        if [ $? != 0 ]; then
            printf "${RED}❌:jquery获取出错，请检查。${NC}\n"
            return 1
        fi
        # echo "第$((i+1))层 $keyName:${JsonFileKeyValueResult}"
        CurrentJsonString=${JsonFileKeyValueResult}
    done
fi


# 判断值的类型
# value=$JsonFileKeyValueResult
# value_type=$(echo "$value" | jq -r "type")
# if [ "$value_type" = "string" ]; then
# elif [ "$value_type" = "array" ]; then
# else
# fi

# printf "%s" "${JsonFileKeyValueResult}"
echo $(logResutValue "${JsonFileKeyValueResult}")

# escaped_value=$(echo "$JsonFileKeyValueResult" | sed 's/\\/\\\\/g; s/\[/\\[/g; s/\]/\\]/g; s/"/\\"/g; s/\n/\\n/g')
# echo $(logResutValue "${escaped_value}")