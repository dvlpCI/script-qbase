#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-16 02:16:08
# @Description:
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

# qpackageJsonF=$1
# if [ ! -f "${qpackageJsonF}" ]; then
#     qpackageJsonFileName=$(basename "$qpackageJsonF")
#     packageArg="${qpackageJsonFileName%.*}"
#     echo "${RED}Error:您的 ${packageArg} 中缺少 json 文件，请检查。${NC}"
#     exit 1
# fi
# packagePathKey=$2
# if [ -z "${packagePathKey}" ]; then
#     echo "${RED}Error:您的 packagePathKey 的值 ${packagePathKey} 不能为空，请检查。${NC}"
#     exit 1
# fi
# shift 2

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
    # echo "verbose✅:${last_arg}"
    verbose=true
    if [ "$second_last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
else # 最后一个元素不是 verbose
    # echo "verbose❌:${last_arg}"
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

# echo "✅✅✅✅✅✅✅ last_arg=$last_arg, verbose=${verbose}"


qbase_homedir_abspath="$(cd "$(dirname "$0")" && pwd)" # 本地测试
qbase_package_path_and_cmd_menu_scriptPath=${qbase_homedir_abspath}/menu/package_path_and_cmd_menu.sh

function _logQuickPathKeys() {
    # cat "$qpackageJsonF" | jq '.quickCmd'

    # 第一个提取为空的时候，取第二个
    # cat "$qpackageJsonF" | jq --arg value "$specified_value" '.quickCmd[].values[].key // .support_script_path[].values[].key'
    # 第一个和第二个都提取
    cat "$qpackageJsonF" | jq --arg value "$specified_value" '.quickCmd[].values[].key, .support_script_path[].values[].key'
}


# 输出sh的所有参数
# echo "传递给脚本的参数列表："
# echo "$@"

# allArgsForQuickCmd="$@"
# _verbose_log "✅快捷命令及其所有参数分别为 ${BLUE}${allArgsForQuickCmd}${BLUE} ${NC}"


# 检查参数
qpackage_homedir_abspath=$1
if [ ! -d "${qpackage_homedir_abspath}" ]; then
    echo "${RED}❌Error:错误提示如下:\n第一个参数必须是package的根目录，但当前是${qpackage_homedir_abspath} ，请检查 ${NC}"
    exit 1
fi
# packageArg=${qpackage_homedir_abspath##*/} # 取最后的component
shift 1

packageArg=$1
qpackageJsonF="$qpackage_homedir_abspath/$packageArg.json"
if [ ! -f "${qpackageJsonF}" ]; then
    echo "${RED}❌Error:您的第二个参数 ${packageArg} 中缺少 json 文件，请检查。如果本脚本是被qbase调用的，请检查您在qbase脚本中传入的 -package 和 -packageCodeDirName 的参数值。${NC}"
    exit 1
fi
shift 1

packagePathAction=$1
packagePathActionTip="packagePathAction 只能为 getPath 或 execCmd 中的一个"
if [ "${packagePathAction}" != "execCmd" ] && [ "${packagePathAction}" != "getPath" ]; then
    echo "${RED}❌Error:第三个参数 ${packagePathActionTip} ，当前是${packagePathAction}。${NC}"
    exit 1
fi
shift 1

packagePathKey=$1
packagePathKeyTip="packagePathKey 只能为以下内容中的值"
if [ "${packagePathAction}" != "execCmd" ] && [ "${packagePathAction}" != "getPath" ]; then
    echo "${RED}❌Error:第三个参数 ${packagePathKeyTip} ，当前是${packagePathKey}。${NC}"
    _logQuickPathKeys
    exit 1
fi
shift 1

# 获取路径(对 home 进行特殊处理)
if [ "${packagePathKey}" == "home" ]; then
    printf "%s" "${qpackage_homedir_abspath}"
    exit 0
fi

if [ "$1" == "-argsJsonString" ]; then
    shift 1 # 去除 -argsJsonString
    argsJsonString="$@"

    _verbose_log "✅ $packagePathKey 的参数分别如下:"
    # 🚗📢:使用下面的方法会丢失空元素，详情可看 foundation/string2array_example.sh 进行错误示例的查看
    # argArray=($(sh $qbase_homedir_abspath/foundation/json2array.sh "${argsJsonString}"))
    # 所以，直接使用源码来处理
    argArray=()
    count=$(printf "%s" "$argsJsonString" | jq -r '.|length')
    for ((i=0;i<count;i++))
    do
        element=$(printf "%s" "$argsJsonString" | jq -r ".[$((i))]") # -r 去除字符串引号
        # echo "✅ $((i+1)). element=${element}"
        if [ -z "$element" ] || [ "$element" == " " ]; then
            element="null"
        fi
        argArray[${#argArray[@]}]=${element}
    done
    argsString=${argArray[*]}
    # echo "1.解析json字符串 ${argsJsonString} 得到的结果是===============argsString=${argsString}"
else
    argsString="$@"
fi
_verbose_log "✅ $packagePathKey 的参数分别如下:${argsString}"

specified_value=${packagePathKey}
_verbose_log "${YELLOW}正在执行命令(获取脚本的相对路径):《${BLUE} sh $qbase_package_path_and_cmd_menu_scriptPath -file \"${qpackageJsonF}\" -key \"${specified_value}\" ${YELLOW}》${NC}"
# sh $qbase_package_path_and_cmd_menu_scriptPath -file "${qpackageJsonF}" -key "${specified_value}" && exit 1 # 测试脚本就退出脚本
relpath=$(sh $qbase_package_path_and_cmd_menu_scriptPath -file "${qpackageJsonF}" -key "${specified_value}")
if [ $? != 0 ]; then
    echo "$relpath" # 此时此值是错误信息
    exit 1
fi
relpath="${relpath//.\//}"  # 去掉开头的 "./"
quickCmd_script_path="$qpackage_homedir_abspath/$relpath"
if [ $? != 0 ] || [ ! -f "$quickCmd_script_path" ]; then
    echo "抱歉：暂不支持 ${packagePathAction} 对 ${packagePathKey} 的快捷命令，请检查。"
    #echo "${RED}提示${YELLOW}（仅供个人调试时候打开）${RED}：暂不支持的原因为：${BLUE} ${quickCmd_script_path} ${RED}文件不存在，请检查 qbase.json 文件中的路径配置是否正确。${NC}"
    exit 1
fi

if [ "${packagePathAction}" == "execCmd" ]; then
    _verbose_log "正在执行参数快捷命令:《 sh ${quickCmd_script_path} ${argsString} 》"
    sh ${quickCmd_script_path} ${argsString}
else
    echo "$quickCmd_script_path"
fi