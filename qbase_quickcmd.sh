#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-20 10:14:28
 # @FilePath: qbase_quickcmd.sh
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


# 使用数组保存参数，避免空格问题
allArgsArray=("$@")

# 初始化标志
contains_help_in_allArgs=false
contains_verbose_in_allArgs=false
DEFINE_QIAN=false
# 遍历数组
for arg in "${allArgsArray[@]}"; do
    case "$arg" in
        --help|-help|-h|help)
            contains_help_in_allArgs=true
            ;;
        --verbose|-verbose|-v)
            contains_verbose_in_allArgs=true
            ;;
        --qian|-qian|-lichaoqian|-chaoqian)
            DEFINE_QIAN=true
            ;;
    esac

    # 可选：如果所有标志都已找到，可以提前退出
    if $contains_help_in_allArgs && $contains_verbose_in_allArgs && $DEFINE_QIAN; then
        break
    fi
done


# --------------------- 的 ---------------------
function _verbose_log() {
    if [ "$CONTAINS_VERBOSE" == true ]; then
        echo "$1"
    fi
}

# qian_log 函数
function qian_log() {
    # 只有定义 --qian 的时候才打印这个log
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2   # 使用 echo 信息里的颜色才能正常显示出来
        # printf "%s\n" "$1" >&2
    fi
}

# 块注释
: '
# --------------------- 具名参数值的解析和获取函数 ---------------------
# 获取具名参数的值（不允许以 - 开头）
# 用法：get_named_arg_value "$1" "$2" "参数名"
# 返回值：0=成功，1=参数缺失，2=参数为空，3=参数以-开头
# 输出：成功时输出参数值，失败时输出具体原因（不含 Error: 前缀）
get_named_arg_value() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    # 条件1：没有第2个参数
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    
    # 条件2：第2个参数为空字符串
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    
    # 条件3：第2个参数以 - 开头（是选项）
    if [[ "$val" =~ ^- ]]; then
        printf "%s 的 %s 不能以 '-' 开头: %s" "$opt" "$arg_name" "$val"
        return 3
    fi
    
    # 正常情况：输出值，返回0
    printf "%s" "$val"
    return 0
}

# 获取具名参数的值（允许以 - 开头）
# 用法：get_named_arg_dashValue "$1" "$2" "参数名"
# 返回值：0=成功，1=参数缺失，2=参数为空
# 输出：成功时输出参数值，失败时输出具体原因（不含 Error: 前缀）
get_named_arg_dashValue() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    # 条件1：没有第2个参数
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    
    # 条件2：第2个参数为空字符串
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    
    # 正常情况：输出值，返回0
    printf "%s" "$val"
    return 0
}

# 定义错误处理函数
handle_named_arg_error() {
    local option="$1"
    echo "${RED}Error: 您为参数${YELLOW} ${option} ${RED}指定了值，但该值不符合要求或为空，请检查是否在 ${option} 后提供了正确的值${NC}"
    exit 1
}

# ==================== 默认值设置 ====================
QBASE_CMD="qbase"  # 默认值（当用户不传这个参数时使用）
DEFINE_QIAN=false
CONTAINS_VERBOSE=false
CONTAINS_HELP=false

# 解析命令行参数
allArgsOrigin="$@"
COMMON_FLAG_ARGS=() # 存储要传递给下个脚本的参数，只允许传递不影响脚本逻辑的公共参数，不然传了后发现有些脚本只接收指定的参数会造成反而无法正常运行
while [ $# -gt 0 ]; do
    case "$1" in
        # 具名参数（需要值的参数）
        -qpackage_homedir_abspath|--qpackage_homedir_abspath)
            # 用户明确传递了此参数，必须提供有效值
            qpackage_homedir_abspath=$(get_named_arg_value "$1" "$2" "qbase或qtool的home目录的绝对路径") || handle_named_arg_error "$1"
            shift 2;;
        -packageArg|--packageArg)
            # 用户明确传递了此参数，必须提供有效值
            packageArg=$(get_named_arg_value "$1" "$2" "qbase或qtool的包名，用来拼接得到qbase.json或qtool.json") || handle_named_arg_error "$1"
            shift 2;;
        -packagePathAction|--packagePathAction)
            # 用户明确传递了此参数，必须提供有效值
            packagePathAction=$(get_named_arg_value "$1" "$2" "qbase或qtool要操作的类型") || handle_named_arg_error "$1"
            shift 2;;
        -packagePathKey|--packagePathKey)
            # 用户明确传递了此参数，必须提供有效值
            packagePathKey=$(get_named_arg_value "$1" "$2" "qbase或qtool要操作的key") || handle_named_arg_error "$1"
            shift 2;;
        -argsJsonString|---argsJsonString)
            # 用户明确传递了此参数，必须提供有效值
            argsJsonString=$(get_named_arg_value "$1" "$2" "其他参数(json格式字符串)") || handle_named_arg_error "$1"
            shift 2;;

        -qbase-local-path|--qbase-local-path)
            # 用户明确传递了此参数，必须提供有效值
            QBASE_CMD=$(get_named_arg_value "$1" "$2" "qbase路径") || handle_named_arg_error "$1"
            COMMON_FLAG_ARGS+=("$1" "$2")
            shift 2;;
        # 标志参数（不需要值的开关）
        --qian|-qian|-lichaoqian|-chaoqian)
            DEFINE_QIAN=true
            COMMON_FLAG_ARGS+=("$1")
            shift 1
            ;;
        --verbose|-v)
            CONTAINS_VERBOSE=true
            COMMON_FLAG_ARGS+=("$1")
            shift 1
            ;;
        --help|-h)
            CONTAINS_HELP=true
            COMMON_FLAG_ARGS+=("$1")
            shift 1
            ;;
        
        # 遇到 -- 停止解析
        --)
            # COMMON_FLAG_ARGS+=("$1")
            shift
            break
            ;;
        # 未知参数或位置参数，继续解析（不 break，让后续参数能被处理）
        *)
            # 判断当前参数是否以 - 或 -- 开头
            if [[ "$1" == -* ]]; then
                # 具名参数，需要判断下一个参数是否也是以 - 开头
                shift
                if [[ "$1" != -* ]] && [ $# -gt 0 ]; then
                    shift
                fi
            else
                # 位置参数
                shift
            fi
            ;;
        
    esac
done

# 剩余的位置参数
POSITIONAL_ARGS=("$@")


# 输出解析结果（调试用）
qian_log "========== 参数解析结果 =========="
qian_log "QBASE_CMD: $QBASE_CMD"
qian_log "DEFINE_QIAN: $DEFINE_QIAN"
qian_log "CONTAINS_VERBOSE: $CONTAINS_VERBOSE"
qian_log "CONTAINS_HELP: $CONTAINS_HELP"
qian_log "位置参数（${#POSITIONAL_ARGS[@]}个）: ${POSITIONAL_ARGS[*]}"
qian_log "公共参数（${#COMMON_FLAG_ARGS[@]}个）: ${COMMON_FLAG_ARGS[*]}"
qian_log "传递给 -quick 命令的参数（${#QUICK_OR_PATH_ARGS[@]}个）: ${QUICK_OR_PATH_ARGS[*]}"
qian_log "=================================="

# 你的业务逻辑写在这里
# ...
'
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
qian_log "${GREEN}正在执行(获取脚本的相对路径)的命令:《${BLUE} sh $qbase_package_path_and_cmd_menu_scriptPath -file \"${qpackageJsonF}\" -key \"${specified_value}\" ${GREEN}》${NC}"
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
    qian_log "${RED}暂不支持的原因为：拼接 ${qpackage_homedir_abspath} 和 $relpath 得到的${BLUE} ${quickCmd_script_path} ${RED}不是文件路径或者文件不存在，请检查 qbase.json 文件中的路径配置是否正确。${NC}" >&2
    exit 1
fi
qian_log "${GREEN}正在执行(获取脚本的相对路径)的结果:《${YELLOW} $quickCmd_script_path ${GREEN}》${NC}"

if [ "${packagePathAction}" == "execCmd" ]; then
    if [[ "${quickCmd_script_path}" == *.py ]]; then
        qian_log "${GREEN}正在执行参数快捷py命令:《${BLUE} python3 ${YELLOW} ${quickCmd_script_path} ${BLUE} ${argsString} ${GREEN}》${NC}"
        python3 ${quickCmd_script_path} ${argsString}
    else
        qian_log "${GREEN}正在执行参数快捷sh命令:《${BLUE} sh ${YELLOW} ${quickCmd_script_path} ${BLUE} ${argsString} ${GREEN}》${NC}"
        sh ${quickCmd_script_path} ${argsString}
    fi
else
    echo "$quickCmd_script_path"
fi