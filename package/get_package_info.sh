#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-03 19:12:17
# @Description: 脚本包的信息获取(版本号、根目录信息)
###

# 本地测试
function local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qbaseScriptDir_Absolute=${CurrentDIR_Script_Absolute}
    echo "$qbaseScriptDir_Absolute"
}

function getMaxVersionNumber_byDir() {
    # 指定目录
    dir_path="$1"

    # 获取目录下所有文件的列表
    files=("$dir_path"/*)

    # 从文件列表中筛选出版本号
    versions=()
    for file in "${files[@]}"; do
        version=$(basename "$file" | cut -d "-" -f 2)
        versions+=("$version")
    done

    # 选择最新的版本号
    latest_version=$(echo "${versions[@]}" | tr ' ' '\n' | sort -r | head -n 1)
    echo "${latest_version}"
}

function getHomeDir_abspath_byVersion() {
    # 指定目录
    dir_path="$1"
    latest_version="$2"

    # 输出最新版本的路径
    curretnVersionDir_abspath="$dir_path/$latest_version/bin" # 放在bin目录下
    if [[ $curretnVersionDir_abspath =~ ^~.* ]]; then
        # 如果 $curretnVersionDir_abspath 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        curretnVersionDir_abspath="${HOME}${curretnVersionDir_abspath:1}"
    fi
    echo "$curretnVersionDir_abspath"

    if [ ! -d "${curretnVersionDir_abspath}" ]; then
        return 1
    fi
}

# 粗略计算，容易出现arm64芯片上的路径不对等问题
# qbaseScriptDir_Absolute="/usr/local/Cellar/qtool/${bjfVersion}/lib"

# 精确计算
# which_qbase_bin_dir_path=$(which qtool)
# which_qbase_source_dir_path="$(echo "$which_qbase_bin_dir_path" | sed 's/bin/Cellar/')"
# echo "which_qbase_bin_dir_path: $which_qbase_bin_dir_path"
# echo "which_qbase_source_dir_path: $which_qbase_source_dir_path"

function getqscript_allVersionHomeDir_abspath() {
    requstQScript=$1
    homebrew_Cellar_dir="$(echo $(which $requstQScript) | sed 's/\/bin\/.*//')"
    if [ -z "${homebrew_Cellar_dir}" ]; then
        return 1
    fi

    if [[ "${homebrew_Cellar_dir}" == */ ]]; then
        homebrew_Cellar_dir="${homebrew_Cellar_dir::-1}"
    fi
    homebrew_Cellar_dir=${homebrew_Cellar_dir}/Cellar

    qscript_allVersion_homedir="${homebrew_Cellar_dir}/$requstQScript"
    echo "${qscript_allVersion_homedir}"
}

function get_packageName_info() {
    if [ "${isTestingScript}" == true ]; then   # 如果是测试脚本中
        qtargetScript_latest_version="local_$1"
        qtargetScript_curVersion_homedir_abspath=$(local_test) # 本地测试
    else
        qtargetScript_allVersion_homedir=$(getqscript_allVersionHomeDir_abspath "$1")
        qtargetScript_latest_version=$(getMaxVersionNumber_byDir "${qtargetScript_allVersion_homedir}")
        qtargetScript_curVersion_homedir_abspath=$(getHomeDir_abspath_byVersion "${qtargetScript_allVersion_homedir}" "${qtargetScript_latest_version}")
        if [ $? != 0 ]; then
            exit 1
        fi
    fi

    echo '{"version":"'"$qtargetScript_latest_version"'","homedir_abspath":"'"$qtargetScript_curVersion_homedir_abspath"'"}'
}


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

verboseStrings=("verbose" "-verbose" "--verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if [[ " ${verboseStrings[*]} " == *" $last_arg "* ]]; then
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


while [ -n "$1" ]
do
    case "$1" in
        -package|--request-package) requstQPackageName=$2; shift 2;; # 请求的库
        -param|--request-param) requstQPackageParam=$2; shift 2;;   # 请求库里面的什么内容
        --) break ;;
        *) break ;;
    esac
done


qPackageJson=$(get_packageName_info "${requstQPackageName}")
# echo "✅ qPackageJson=${qPackageJson}"
if [ "${requstQPackageParam}" == "version" ]; then
    qPackage_version=$(echo "$qPackageJson" | jq -r '.version')
    echo "${qPackage_version}"

elif [ "${requstQPackageParam}" == "homedir_abspath" ]; then
    qPackage_homedir_abspath=$(echo "$qPackageJson" | jq -r '.homedir_abspath')
    echo "${qPackage_homedir_abspath}"
else
    printf "%s" "${qPackageJson}"
fi


