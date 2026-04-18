#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2024-12-07 20:54:07
# @Description: qbase 不是所要执行的直接脚本，所以不要使用颜色
# @注意：修改本文件后，记得重新生成 qbase 二进制文件
###

# 定义颜色常量(qbase 不是所要执行的直接脚本，所以不要使用颜色)
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# 获取脚本自身目录（用于后续其他命令）
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
# 获取项目根目录（脚本所在目录）
project_homedir_abspath="${CurrentDIR_Script_Absolute}"

# -package 的测试，详见 qbase_example_quickCmd.sh
if [ "$1" == "-package" ]; then
    packageArg=$2 # 去除第一个参数之前，先保留下来
    shift 2  # 去除前两个个参数
    if [ "$1" == "-packageCodeDirName" ]; then
        packageCodeNameArg=$2 # 去除第一个参数之前，先保留下来
        shift 2  # 去除前两个个参数
    else
        echo "请在 -package 后添加 -packageCodeDirName 参数(常为bin或者lib), 否则无法知道您当前的 ${packageArg} 库的代码所在目录。"
        exit 1
    fi
else
    packageArg="qbase"
    packageCodeNameArg="bin" # 该值取决于您在 xxx.rb 中的设置
fi


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

args=()
if [ "${verbose}" == true ]; then
    args+=("-verbose")
fi
if [ "${isTestingScript}" == true ]; then
    args+=("test")
fi

function _verbose_log() {
    if [ "$verbose" == true ]; then
        echo "$1"
    fi
}

function qian_log() {
    # 只有定义 --qian 的时候才打印这个log
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2   # 使用 echo 信息里的颜色才能正常显示出来
        # printf "%s\n" "$1" >&2
    fi
}

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

    # echo "温馨提示:您 $packageArg 库里的 $dir_path 目录下的所有版本号为: ${versions[*]} 。"

    # 选择最新的版本号
    latest_version=$(echo "${versions[@]}" | tr ' ' '\n' | sort -r | head -n 1)
    echo "${latest_version}"
}

function getHomeDir_abspath_byVersion() {
    # 指定目录
    dir_path="$1"
    latest_version="$2"
    packageCodeName="$3"

    # 输出最新版本的路径
    curretnVersionDir_abspath="$dir_path/$latest_version/$packageCodeName" # 一般放在bin或者lib目录下
    if [[ $curretnVersionDir_abspath =~ ^~.* ]]; then
        # 如果 $curretnVersionDir_abspath 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        curretnVersionDir_abspath="${HOME}${curretnVersionDir_abspath:1}"
    fi
    
    if [ ! -d "${curretnVersionDir_abspath}" ]; then
        echo "Error❌:你脚本方法 $FUNCNAME 计算出来的 $curretnVersionDir_abspath 指向的目录不存在，请检查"
        return 1
    fi
    echo "$curretnVersionDir_abspath"
}
function getqscript_allVersionHomeDir_abspath() {
    requstQScript=$1
    
    packageBinNameArg="bin"
    # homebrew_Cellar_dir="$(echo $(which $requstQScript) | sed 's/\/'bin'\/.*//')" 
    homebrew_Cellar_dir=$(echo $(which $requstQScript) | sed "s/\(.*\)\/$packageBinNameArg\/.*/\1/")
    if [ -z "${homebrew_Cellar_dir}" ]; then
        echo "执行命令(截取${packageCodeNameArg}前的路径，作为homebrew的Cellar文件夹路径)失败，请检查：《 echo $(which $requstQScript) | sed \"s/\(.*\)\/$packageBinNameArg\/.*/\1/\" 》 。"
        return 1
    fi

    if [[ "${homebrew_Cellar_dir}" == */ ]]; then
        homebrew_Cellar_dir="${homebrew_Cellar_dir::-1}"
    fi
    homebrew_Cellar_dir=${homebrew_Cellar_dir}/Cellar

    qscript_allVersion_homedir="${homebrew_Cellar_dir}/$requstQScript"
    echo "${qscript_allVersion_homedir}"
}

# CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# 检查 realpath 命令是否安装，未安装则提示用什么命令在终端进行安装
if ! command -v realpath &> /dev/null; then
    echo "${RED}温馨提示：您当前的系统中未安装 realpath 命令，请使用《${BLUE} brew install coreutils ${RED}》命令在终端进行安装。${NC}"
    exit 1
fi

CurrentScript_absolute_path=$(realpath "$0")
# echo "$0 🆚 ${CurrentScript_absolute_path}"

if [ "$0" == "${CurrentScript_absolute_path}" ]; then
# if [ "${isTestingScript}" == true ]; then   # 如果是测试脚本中
    qbase_latest_version="local_qbase"
    qbase_homedir_abspath="$(cd "$(dirname "$0")" && pwd)" # 本地测试
else
    qbaseScript_allVersion_homedir=$(getqscript_allVersionHomeDir_abspath "qbase")
    if [ $? != 0 ]; then
        exit 1
    fi
    # echo "您的 qbaseScript_allVersion_homedir = ${qbaseScript_allVersion_homedir}"
    qbase_latest_version=$(getMaxVersionNumber_byDir "${qbaseScript_allVersion_homedir}")
    if [ $? != 0 ]; then
        echo "${qbase_latest_version}" # 此时此值是错误信息
        exit 1
    fi
    qbase_homedir_abspath=$(getHomeDir_abspath_byVersion "${qbaseScript_allVersion_homedir}" "${qbase_latest_version}" "bin")
    if [ $? != 0 ]; then
        echo "${qbase_homedir_abspath}" # 此时此值是错误信息
        exit 1
    fi
fi
if [ ! -d "${qbase_homedir_abspath}" ]; then
    echo "您的 qbase 库的根目录 ${qbase_homedir_abspath} 计算错误，请检查"
    exit 1
fi

if [ "$0" == "${CurrentScript_absolute_path}" ] && [ "${packageArg}" == "qbase" ]; then 
    qtarget_homedir_abspath="${qbase_homedir_abspath}"
else
    qtargetScript_allVersion_homedir=$(getqscript_allVersionHomeDir_abspath "${packageArg}")
    if [ $? != 0 ]; then
        echo "${qtargetScript_allVersion_homedir}" # 此时此值是错误信息
        exit 1
    fi
    # echo "您的 qtargetScript_allVersion_homedir = ${qtargetScript_allVersion_homedir}"
    qtarget_latest_version=$(getMaxVersionNumber_byDir "${qtargetScript_allVersion_homedir}")
    if [ $? != 0 ]; then
        echo "${qtarget_latest_version}" # 此时此值是错误信息
        exit 1
    fi
    qtarget_homedir_abspath=$(getHomeDir_abspath_byVersion "${qtargetScript_allVersion_homedir}" "${qtarget_latest_version}" "${packageCodeNameArg}")
    if [ $? != 0 ]; then
        echo "${qtarget_homedir_abspath}" # 此时此值是错误信息
        exit 1
    fi
fi
if [ ! -d "${qtarget_homedir_abspath}" ]; then
    echo "❌Error:您的 ${packageArg} 库的根目录 ${qtarget_homedir_abspath} 计算错误，请检查"
    exit 1
fi

qpackageJsonF="$qtarget_homedir_abspath/${packageArg}.json"
if [ ! -f "${qpackageJsonF}" ]; then
    echo "❌Error:您的 ${packageArg} 中缺少 json 文件，请检查您在qbase脚本中传入的 -package 和 -packageCodeDirName 的参数值，即: ${packageArg} 和 ${packageCodeNameArg} 。"
    exit 1
fi

function get_path_json() {
    target_category_file_abspath=$1
    showType=$2
    saveModuleOptionKeysToFile=$3 # 保存内容到哪个文件，可为空
    if [ -z "${target_category_file_abspath}" ]; then
        echo "参数不能为空"
        exit 1
    fi
    
    # 读取文件内容
    content=$(cat "${target_category_file_abspath}")

    requestCategoryKey="support_script_path"
    categoryMaps=$(echo "$content" | jq -r ".${requestCategoryKey}")
    if [ -z "${categoryMaps}" ] || [ "${categoryMaps}" == "null" ]; then
        echo "❌Error:请先在 ${target_category_file_abspath} 文件中设置 .${requestCategoryKey} "
        exit 1
    fi

    # branchBelongMapCount2=$(echo "$content" | jq ".${requestCategoryKey}" | jq ".|length")
    # # echo "=============branchBelongMapCount2=${branchBelongMapCount2}"
    # if [ ${branchBelongMapCount2} -eq 0 ]; then
    #     echo "友情提醒💡💡💡：没有找到可选的分支模块类型"
    #     return 1
    # fi
    if [ "${showType}" == "forUseChoose" ]; then
        echo "已知模块选项、已知基础选项："
    fi

    # 使用jq命令解析json数据
    categoryCount=$(echo "$content" | jq -r ".${requestCategoryKey}|length")
    # echo "===================${categoryCount}"
    if [ "${showType}" == "onlyMdFile" ]; then
        markdownString=""
        markdownString+="# 模块区分与负责人\n \n"
        markdownString+="## 一、模块区分与负责人\n"
        markdownString+="| $(printf '%-4s' "序号") | $(printf '%-8s' "标记") | $(printf '%-17s' "模块") | $(printf '%-4s' "功能") | $(printf '%-10s' "初始者") | $(printf '%-10s' "主开发") | $(printf '%-10s' "二开发") |\n"
        markdownString+="| ---- | -------- | ----------------- | ---- | ---------- | ---------- | ---------- |\n"

        printf "正在计算md内容，请耐心等待(预计需要5s)....\n"
    fi

    # 创建一个空数组
    itemKeys=()
    for ((categoryIndex = 0; categoryIndex < categoryCount; categoryIndex++)); do
        categoryMap_String=$(echo "$content" | jq -r ".${requestCategoryKey}[$categoryIndex]")
        # echo "$((categoryIndex+1)) categoryMap_String=${categoryMap_String}"

        categoryDes=$(echo "$categoryMap_String" | jq -r '.des')
        categoryValuesCount=$(echo "$categoryMap_String" | jq -r ".values|length")
        if [ "${showType}" == "forUseChoose" ]; then
            printf "===================${categoryDes}(共${categoryValuesCount}个)===================\n"
        fi

        for ((categoryValueIndex = 0; categoryValueIndex < categoryValuesCount; categoryValueIndex++)); do

            categoryValueMap_String=$(echo "$categoryMap_String" | jq -r ".values[$categoryValueIndex]")
            # echo "$((categoryValueIndex+1)) categoryValueMap_String=${categoryValueMap_String}"

            itemDes=$(echo "$categoryValueMap_String" | jq -r '.des')
            itemKey=$(echo "$categoryValueMap_String" | jq -r '.key')
            itemValue=$(echo "$categoryValueMap_String" | jq -r '.value')

            itemKeys+=("${itemKey}")

            if [ "${showType}" == "forUseChoose" ]; then
                # printf "%10s: %-20s [%s %s %s] %s\n" "$option" "$short_des" "${createrName}" "${mainerName}" "${backuperName}" "${detail_des}"
                # 格式化字符串
                format_str="%10s: %-20s %s\n"
                consoleString=$(printf "$format_str" "$itemKey" "$itemDes" "${itemValue}")
                printf "${consoleString}\n"
            fi

            if [ "${showType}" == "onlyMdFile" ]; then
                # 构建Markdown表格
                # markdownString+="| %-8s    | %-8s | %-17s | %-4s | %-10s | %-10s |\n" "$categoryIndex.$categoryValueIndex" "$option" "$short_des" "$option" "$createrName" "$mainerName"
                multiline_detail_des=$(echo "$itemValue" | sed 's/;/<br>/g')
                markdownString+="| $(printf '%-4s' "$((categoryIndex+1)).$((categoryValueIndex+1))") | $(printf '%-8s' "$itemKey") | $(printf '%-17s' "$itemDes") | $(printf '%-4s' "$itemValue") |\n"
            fi
        done
    done

    if [ "${saveModuleOptionKeysToFile}" != null ]; then
        echo "${itemKeys[@]}" > ${saveModuleOptionKeysToFile} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    fi
}

function _logQuickCmd() {
    cat "$qpackageJsonF" | jq '.quickCmd'
}


# 输出sh的所有参数
# echo "传递给脚本的参数列表："
# echo "$@"

firstArg=$1 # 去除第一个参数之前，先保留下来
shift 1  # 去除前一个参数
allArgsExceptFirstArg="$@"  # 将去除前一个参数，剩余的参数赋值给新变量
# allArgArray=($@)
# allArgCount=${#allArgArray[@]}
# for ((i=0;i<allArgCount;i+=1))
# {
#     if [ $i -lt 2 ]; then
#         continue
#     fi
#     currentArg=${allArgArray[i]}
#     allArgsExceptArgCount[${#allArgsExceptArgCount[@]}]=${currentArg}
# }


# 使用说明函数
show_usage() {
    INDENT_LEVEL=4  # 设置缩进的空格数量
    INDENT=$(printf "%*s" $INDENT_LEVEL "")

    # printf "Usage:"
    # printf "\n"
    # printf "%-20s %s\n" "Usage:" "$0 [options] [arguments]" # 本脚本路径
    printf "%-20s %s\n" "Commands:" ""
    printf "${INDENT}${GREEN}%-20s ${NC}%s\n" "+ custom" "执行自定义的命令菜单（若不存在会引导添加）"
    printf "${INDENT}${GREEN}%-20s ${NC}%s\n" "+ check-version" "检查/更新 qbase 的远程版本"
    printf "\n"
    printf "%-20s %s\n" "Options:" ""
    printf "${INDENT}${BLUE}%-20s ${NC}%s\n" "-verbose" "Show more debugging information"
    printf "${INDENT}${BLUE}%-20s ${NC}%s\n" "--help" "Show help banner of specified command"
    printf "${INDENT}${BLUE}%-20s ${NC}%s\n" "-quick" "执行快捷命令（如 qbase -quick xxx）"
    printf "${INDENT}${BLUE}%-20s ${NC}%s\n" "-quick-eg" "查看可使用的快捷命令"
    printf "${INDENT}${BLUE}%-20s ${NC}%s\n" "-path" "获取脚本路径（如 qbase -path xxx）"
    printf "${INDENT}${BLUE}%-20s ${NC}%s\n" "-path-eg" "查看可使用的脚本，需要密码"
    # printf "%-20s %s\n" "Arguments:" ""
    # printf "%-20s %s\n" "file" "Input file path"
    # printf "%-20s %s\n" "output" "Output file path"
    printf "${NC}"
}

# echo "打印变量firstArg的值:$firstArg"  # 打印变量b的值
# echo "打印变量allArgsExceptFirstArg的值:$allArgsExceptFirstArg"  # 打印变量b的值

# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")

# 判断第一个参数是不是 help 参数
shouldShowHelp=false
case "${firstArg}" in
    --help|-help|-h|help)
        shouldShowHelp=true
        exit 0  # 这行会退出脚本！
        ;;
esac
# 判断去除第一个参数后，剩余的参数是不是 help 参数
contains_help_in_allArgsExceptFirstArg=false
for arg in $allArgsExceptFirstArg; do
    case $arg in
        --help|-help|-h|help)
            contains_help_in_allArgsExceptFirstArg=true
            break
            ;;
    esac
done

if echo "${versionCmdStrings[@]}" | grep -wq "${firstArg}" &>/dev/null; then
    echo "${qbase_latest_version}"

elif [ "$shouldShowHelp" = true ]; then
    show_usage

elif [ "${firstArg}" == "custom" ]; then
    sh $qbase_homedir_abspath/qbase_custom.sh

elif [ "${firstArg}" == "check-version" ]; then
    # 拼接 package_remote_version.sh 脚本的绝对路径
    package_remote_version_script="${qbase_homedir_abspath}/package/package_remote_version.sh"
    if [ ! -f "${package_remote_version_script}" ]; then
        echo "${RED}Error: 未找到 ${package_remote_version_script} ${NC}"
        exit 1
    fi

    # 先判断是不是 help ，如果不是才执行后面的操作
    if [ "$contains_help_in_allArgsExceptFirstArg" = true ]; then
        sh "${package_remote_version_script}" -h
        exit 0
    fi

    # 提示用户输入要检查的包名
    while true; do
        printf "请输入要检查/更新的包名（如 qbase、qtool）【退出quit/q】）: "
        read packageName
        if [ -z "${packageName}" ]; then
            echo "${RED}Error: 包名不能为空，请重新输入${NC}"
            continue
        fi
        if [ "${packageName}" == "quit" ] || [ "${packageName}" == "q" ]; then
            echo "已退出"
            exit 0
        fi
        break
    done
    printf "\n"

    # echo "正在执行命令...《 sh $package_remote_version_script -p \"${packageName}\" 》"
    sh "${package_remote_version_script}" -p "${packageName}"

elif [ "${firstArg}" == "-path-eg" ]; then     # 查看快捷命令
    passwordStrings=("qian" "chaoqian" "lichaoqian")
    if ! printf "%s\n" "${passwordStrings[@]}" | grep -wq "$1"; then    # 检查是否不包含，另前面已执行 shift 1  去除前一个参数，所以当前的第二个参数是 $1
        echo "${RED}查看${BLUE} -path-eg ${RED}需要在命令中携带正确的密码${NC}"
        exit 1
    fi

    # categoryData=$(cat "$qpackageJsonF" | jq ".support_script_path")
    # qpackage_homedir_abspath=$(dirname "${qpackageJsonF}")
    # echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file ${qpackageJsonF} -categoryType support_script_path 》"
    sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file "${qpackageJsonF}" -categoryType "support_script_path"
    # echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/menu/qbrew_menu.sh -categoryData \"${categoryData}\" -relPath-baseDirPath \"${qpackage_homedir_abspath}\" 》"
    # sh $qbase_homedir_abspath/menu/qbrew_menu.sh -categoryData "${categoryData}" -relPath-baseDirPath "${qpackage_homedir_abspath}"
elif [ "${firstArg}" == "-path" ]; then
    qian_log "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/qbase_quickcmd.sh ${qtarget_homedir_abspath} $packageArg getPath $allArgsExceptFirstArg 》"
    sh $qbase_homedir_abspath/qbase_quickcmd.sh ${qtarget_homedir_abspath} $packageArg getPath $allArgsExceptFirstArg

elif [ "${firstArg}" == "-quick-eg" ]; then     # 查看快捷命令
    # echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file ${qpackageJsonF} -categoryType quickCmd 》"
    sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file ${qpackageJsonF} -categoryType "quickCmd"

elif [ "${firstArg}" == "-quick" ]; then        # 使用快捷命令
    inputArgsErrorMessage=$(sh $qbase_homedir_abspath/foundation/checkInputArgsValid.sh $allArgsExceptFirstArg)
    if [ $? != 0 ]; then
        echo "🚗🚗🚗🚗🚗🚗 如若后续执行发生错误，可能原因为: ${inputArgsErrorMessage}" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
    fi
    # echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/qbase_quickcmd.sh ${qtarget_homedir_abspath} $packageArg execCmd $allArgsExceptFirstArg 》"
    sh $qbase_homedir_abspath/qbase_quickcmd.sh ${qtarget_homedir_abspath} $packageArg execCmd $allArgsExceptFirstArg

else
    echo "${qbase_latest_version}"
fi



# 使用介绍的格式，可参考 pod
# Function to display the usage
# show_usage() {
#     cat <<EOF
# Usage:
#   mytool [command] [options]

# Commands:
#   init          Initialize the environment.
#   build         Build the project.
#   run           Run the application.
#   test          Run the test suite.
#   clean         Clean up generated files.

# Options:
#   -h, --help    Show help information.
#   -v, --version Display the version number.

# Examples:
#   mytool init
#   mytool build --release
#   mytool run
#   mytool test --coverage
#   mytool clean

# For more information, visit https://example.com/docs/mytool.
# EOF
# }
