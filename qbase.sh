#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-03 19:10:29
# @Description:
###


# 计算倒数第一个参数的位置
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
    if [ "$second_last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
else # 最后一个元素不是 verbose
    verbose=false
    if [ "$last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
fi

args=()
if [ "${verbose}" == true ]; then
    args+=("-verbose")
fi
if [ "${isTestingScript}" == true ]; then
    args+=("test")
fi


qbaseScriptDir_Absolute="$(cd "$(dirname "$0")" && pwd)"
# echo "正在执行命令(获取脚本包的版本号):《 sh ${qbaseScriptDir_Absolute}/get_package_util.sh -package \"qbase\" -param \"version\" \"${args[@]}\" 》"
qbase_latest_version=$(sh ${qbaseScriptDir_Absolute}/get_package_util.sh -package "qbase" -param "version" "${args[@]}")
# echo "✅✅✅✅ qbase_latest_version=${qbase_latest_version}"

# echo "正在执行命令(获取脚本包的根路径):《 sh ${qbaseScriptDir_Absolute}/get_package_util.sh -package \"qbase\" -param \"homedir_abspath\" \"${args[@]}\" 》"
qbase_homedir_abspath=$(sh ${qbaseScriptDir_Absolute}/get_package_util.sh -package "qbase" -param "homedir_abspath" "${args[@]}")
# echo "✅✅✅✅ qbase_homedir_abspath=${qbase_homedir_abspath}"


function get_path() {
    if [ "$1" == "home" ]; then
        echo "$qbase_homedir_abspath"
    elif [ "$1" == "get_package_util" ]; then
        echo "$qbase_homedir_abspath/get_package_util.sh"
    elif [ "$1" == "sedtext" ]; then
        echo "$qbase_homedir_abspath/update_value/sed_text.sh"
    elif [ "$1" == "update_json_file_singleString" ]; then
        echo "$qbase_homedir_abspath/update_value/update_json_file_singleString.sh"
    elif [ "$1" == "json_file_check" ]; then
        echo "$qbase_homedir_abspath/json_check/json_file_check.sh"
    else
        echo "$qbase_homedir_abspath"
    fi
}

# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
if echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${qbase_latest_version}"
elif [ "$1" == "-path" ]; then
    get_path "$2"
else
    echo "${qbase_latest_version}"
fi



