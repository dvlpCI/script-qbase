#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 23:59:08
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

# 特别注意：这是qbase。所以无法(强烈不建议)使用 get_package_info.sh 文件，因为qbase.sh处理成qbase二进制文件后，其会被存放到任意路径。就不是相对qbase.sh的路径了。
# 特别注意：这是qbase。所以无法(强烈不建议)使用 get_package_info.sh 文件，因为qbase.sh处理成qbase二进制文件后，其会被存放到任意路径。就不是相对qbase.sh的路径了。
# 特别注意：这是qbase。所以无法(强烈不建议)使用 get_package_info.sh 文件，因为qbase.sh处理成qbase二进制文件后，其会被存放到任意路径。就不是相对qbase.sh的路径了。
# qbaseScriptDir_Absolute="$(cd "$(dirname "$0")" && pwd)"
# get_package_info_script_path=${qbaseScriptDir_Absolute}/package/get_package_info.sh
# echo "正在执行命令(获取脚本包的版本号):《 sh ${get_package_info_script_path} -package \"qbase\" -param \"version\" \"${args[@]}\" 》"
# qbase_latest_version=$(sh ${get_package_info_script_path} -package "qbase" -param "version" "${args[@]}")
# # echo "✅✅✅✅ qbase_latest_version=${qbase_latest_version}"

# # echo "正在执行命令(获取脚本包的根路径):《 sh ${get_package_info_script_path} -package \"qbase\" -param \"homedir_abspath\" \"${args[@]}\" 》"
# qbase_homedir_abspath=$(sh ${get_package_info_script_path} -package "qbase" -param "homedir_abspath" "${args[@]}")
# # echo "✅✅✅✅ qbase_homedir_abspath=${qbase_homedir_abspath}"

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


if [ "${isTestingScript}" == true ]; then   # 如果是测试脚本中
    qbase_latest_version="local_qbase"
    qbase_homedir_abspath="$(cd "$(dirname "$0")" && pwd)" # 本地测试
else
    qtargetScript_allVersion_homedir=$(getqscript_allVersionHomeDir_abspath "qbase")
    qbase_latest_version=$(getMaxVersionNumber_byDir "${qtargetScript_allVersion_homedir}")
    qbase_homedir_abspath=$(getHomeDir_abspath_byVersion "${qtargetScript_allVersion_homedir}" "${qbase_latest_version}")
    if [ $? != 0 ]; then
        exit 1
    fi
fi





function get_path() {
    if [ "$1" == "home" ]; then
        echo "$qbase_homedir_abspath"

    # env_var:环境变量
    elif [ "$1" == "env_var_effective_or_open" ]; then
        echo "$qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh"
    elif [ "$1" == "env_var_add_or_update" ]; then
        echo "$qbase_homedir_abspath/env_variables/env_var_add_or_update.sh"

    # package:脚本包
    elif [ "$1" == "get_package_util" ]; then
        echo "$qbase_homedir_abspath/package/get_package_info.sh"
    elif [ "$1" == "install_package" ]; then
        echo "$qbase_homedir_abspath/package/install_package.sh"

    # value_update:内容值更新(文本或文件中)
    elif [ "$1" == "sedtext" ]; then
        echo "$qbase_homedir_abspath/update_value/sed_text.sh"
    elif [ "$1" == "update_json_file_singleString" ]; then
        echo "$qbase_homedir_abspath/update_value/update_json_file_singleString.sh"

    # path:路径
    elif [ "$1" == "join_paths" ]; then
        echo "$qbase_homedir_abspath/path_util/join_paths.sh"
    elif [ "$1" == "get_dirpath_by_relpath" ]; then
        echo "$qbase_homedir_abspath/path_util/get_dirpath_by_relpath.sh"

    # date:日期
    elif [ "$1" == "days_cur_to_MdDate" ]; then
        echo "$qbase_homedir_abspath/date/days_cur_to_MdDate.sh"
    elif [ "$1" == "calculate_newdate" ]; then
        echo "$qbase_homedir_abspath/date/calculate_newdate.sh"
        
    # json_check:json检查(文件中)
    elif [ "$1" == "json_file_check" ]; then
        echo "$qbase_homedir_abspath/json_check/json_file_check.sh"

    # branch:分支
    elif [ "$1" == "rebasebranch_last_commit_date" ]; then
        echo "$qbase_homedir_abspath/branch/rebasebranch_last_commit_date.sh"
    elif [ "$1" == "first_commit_info_after_date" ]; then
        echo "$qbase_homedir_abspath/branch/first_commit_info_after_date.sh"
    elif [ "$1" == "get_merger_recods_after_date" ]; then
        echo "$qbase_homedir_abspath/branch/get_merger_recods_after_date.sh"
    
    # 其他
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



