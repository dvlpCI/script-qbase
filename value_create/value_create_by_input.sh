#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-09 22:56:13
# @FilePath: value_create/value_create_by_input.sh
# @Description: 进行输入并获取输入的值（能够对输入值进行json等基本检查）
# @Exampel: sh value_create/value_create_by_input.sh --input-descript 自定义命令菜单 --input-for json-file
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

# 日志信息输出到终端（规范 2.2：日志输出用 >&2，保持返回值干净）
log_color_info() {
    printf "%b\n" "$1" >&2
}

# 检查jq是否安装
if ! command -v jq &> /dev/null; then
    echo ""
    echo "${RED}Error:jq is not installed. Please install it with command:${BLUE} brew install jq${NC}"
    exit 1
fi


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..


INPUT_DESCRIPT=""
INPUT_FOR=""
while [ $# -gt 0 ]; do
    case "$1" in
        --input-descript) 
            # 不能为空
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                echo "错误: --input-descript 必须指定" >&2
                exit 1
            fi
            INPUT_DESCRIPT="$2"
            shift 2
            ;;
        --input-for)
            # 允许空值或者不传：检查下一个参数是否为空或者是选项（以 - 开头）
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                # 没有提供值，或者下一个参数是选项，则设置为空
                INPUT_FOR=""
                shift 1  # 只消费当前参数
            else
                INPUT_FOR="$2"
                shift 2
            fi
            ;;
        *) echo "未知参数: $1" >&2; exit 1 ;;
    esac
done

if [ -z "${INPUT_DESCRIPT}" ]; then
    echo "错误: 缺少必要参数（--input-descript）" >&2
    exit 1
fi


inputCustomJsonFilePath() {
    valid_option=false
    while [ "$valid_option" = false ]; do
        read -r -p "请输入您要用本脚本执行的${INPUT_DESCRIPT}json文件路径(若要退出请输入Q|q) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            return 2
        fi

        result=$(checkValueCanbeUse "${option}")
        if [ $? != 0 ]; then
            log_color_info "${result}"
            # showCustomMenuJsonExample
            continue
        fi

        echo "${option}"
        break
    done
}

checkValueCanbeUse() {
    try_use_menu_json_file="${1}"

    if [ "${INPUT_FOR}" == "file" ] || [ "${INPUT_FOR}" == "json-file" ]; then
        if [ ! -f "${try_use_menu_json_file}" ]; then
            echo "${RED}您输入的文件${BLUE} ${try_use_menu_json_file} ${RED}不存在，请重新输入${NC}"
            return 1
        fi

        if [ "${INPUT_FOR}" == "json-file" ]; then
            jsonFileData=$(cat "$try_use_menu_json_file" | jq ".")
            if [ -z "${jsonFileData}" ]; then
                echo "${RED}您输入的文件${BLUE} ${try_use_menu_json_file} ${RED}不是有效的json文件，请重新输入${NC}"
                return 1
            fi
        fi
    fi
}

result=$(inputCustomJsonFilePath)
if [ $? != 0 ]; then
    exit 1
fi

# 将更新完的新环境变量值，输出给调用者。直接用 result 即可，因为它包含了 setupEnvVar 成功时通过 stdout 传出的路径
echo "${result}"
