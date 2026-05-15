#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 添加环境变量前会先添加占位，然后才修改占位为指定的值
# @FilePath: sh env_variables/env_file_change.sh --env-name QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH --env-descript qtool可操作的项目操作列表 --env-var-placeholder your_project_choices_json_file --example-json-file \"/Users/qian/Project/Github/script-branch-json-file/test/tool_choice.json\" --default-output-filename qtool_project_choice.json --action change --choose-for-env-name QTOOL_DEAL_PROJECT_CHOICES_PATH
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..

log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

# 解析具名参数
ENV_NAME=""
ENV_DESCRIPT=""
ENV_VAR_PLACEHOLDER=""
EXAMPLE_JSON_FILE=""
DEFAULT_OUTPUT_FILENAME=""

ACTION=""
CHOOSE_FOR_ENV_NAME=""
while [ $# -gt 0 ]; do
    case "$1" in
        --env-name)
            ENV_NAME="$2"
            shift 2
            ;;
        --env-descript) ENV_DESCRIPT="$2"; shift 2 ;;
        --env-var-placeholder)
            ENV_VAR_PLACEHOLDER="$2"
            shift 2
            ;;
        --example-json-file) EXAMPLE_JSON_FILE="$2"; shift 2 ;;
        --default-output-filename) DEFAULT_OUTPUT_FILENAME="$2"; shift 2 ;;

        --choose-for-env-name)
            CHOOSE_FOR_ENV_NAME="$2"
            shift 2
            ;;
        --action)
            ACTION="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "${ENV_NAME}" ] || [ -z "${EXAMPLE_JSON_FILE}" ]; then
    echo "错误: 缺少必要参数（--env-name --example-json-file）" >&2
    exit 1
fi

if [ -z "${ACTION}" ] || [ -z "${CHOOSE_FOR_ENV_NAME}" ]; then
    echo "错误: 缺少必要参数（--action --choices-env）" >&2
    exit 1
fi

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 打开环境变量的那个文件（本方法只负责打开，省去用户自己找）
open_sysenv_file() {
    # 获取调用者的信息
    # local caller_func=${FUNCNAME[1]}  # 调用者的函数名
    # local caller_script=${BASH_SOURCE[1]}   # 调用者的脚本路径
    # local caller_name="${caller_script##*/}"  # 调用者的脚本名（不含路径）：删除最后一个 / 之前的所有内容
    # local caller_line=${BASH_LINENO[0]}  # 调用行号
    # echo "调用信息: 函数[$caller_func] 脚本[$caller_script] 行[$caller_line]" >&2

    # echo "正在执行命令：《${BLUE} sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh open ${NC}》" >&2
    sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh open
}

# 更新tool处理的项目
showProjectList() {
    tool_choice_file_path=$1

    printf "支持的项目列表： (详见: ${YELLOW}${tool_choice_file_path}${NC})\n"
    choiceCount=$(cat "$tool_choice_file_path" | jq '.choice|length')
    for ((i = 0; i < ${choiceCount}; i++)); do
        iChoiceMap=$(cat "$tool_choice_file_path" | jq ".choice" | jq -r ".[${i}]")

        iChoiceOptionId="$((i + 1))"
        iChoiceName=$(echo "$iChoiceMap" | jq -r ".name")

        
        iChoiceProjectToolFilePath=$(echo "$iChoiceMap" | jq -r ".project_tool_file_path")
        #echo "iChoiceProjectToolFilePath=${iChoiceProjectToolFilePath}" >&2

        if [ ! -f "${iChoiceProjectToolFilePath}" ]; then
            iChoiceProjectDirPath="该项目指向的开启的菜单json文件不存在"
        else
            iChoiceProjectDirPath_rel_toolFile_dir=$(cat "${iChoiceProjectToolFilePath}" | jq -r ".project_path.home_path_rel_this_dir")
            iChoiceProjectDirPath=$(sh $qbase_homedir_abspath/path_util/get_dirpath_by_relpath.sh --file_or_dir_path "${iChoiceProjectToolFilePath}" --rel_path "${iChoiceProjectDirPath_rel_toolFile_dir}")
        fi
        #echo "iChoiceProjectDirPath========${iChoiceProjectDirPath}" >&2
        
        printf "${GREEN}%-2s%-20s(路径为 ${YELLOW}%s)${NC}\n" "${iChoiceOptionId}" "${iChoiceName}" "${iChoiceProjectDirPath}"
        printf "${NC}                          %s${NC}\n" "${iChoiceProjectToolFilePath}"
    done
}

updateToolDealProject() {
    tool_choice_file_path=$1

    valid_option=false
    while [ "$valid_option" = false ]; do
        target_value="${!ENV_NAME}"
        if [ -z "${target_value}" ]; then
            read -r -p "您还未选择想要操作的项目，请先选择想要操作的项目的编号(若要退出请输入Q|q) : " option
        else
            read -r -p "请选择您想要更换成的项目的编号(若要退出请输入Q|q) : " option
        fi

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        choiceCount=$(cat "$tool_choice_file_path" | jq '.choice|length')
        targetChoiceCountMap=""
        hasFound=false
        for ((i = 0; i < ${choiceCount}; i++)); do
            iChoiceMap=$(cat "$tool_choice_file_path" | jq ".choice" | jq -r ".[${i}]")

            iChoiceName=$(echo "$iChoiceMap" | jq -r ".name")
            iChoiceOptionId="$((i + 1))"

            if [ "${option}" = ${iChoiceOptionId} ] || [ "${option}" == ${iChoiceName} ]; then
                targetChoiceCountMap=$iChoiceMap
                hasFound=true
                break
            fi
        done

        if [ ${hasFound} == true ] && [ -n "${targetChoiceCountMap}" ]; then
            update_env_vars
            if [ $? != 0 ]; then
                return 1
            fi
            break
        else
            echo "无此选项，请重新输入。"
        fi
    done
}

update_env_vars() {
    project_tool_file_path=$(echo "$targetChoiceCountMap" | jq -r ".project_tool_file_path")
    if [ ! -f "${project_tool_file_path}" ]; then
        printf "${RED}选择项目失败：您从 ${ENV_NAME} 中选择的 $targetChoiceCountMap 的 ${BLUE}project_tool_file_path ${RED}指向的文件 ${YELLOW}${project_tool_file_path}${RED} 文件不存在，无法完成选择，请先检查和修改后，重新执行选择。${NC}\n"
        return 1
    fi

    sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "${CHOOSE_FOR_ENV_NAME}" -envVariableValue "${project_tool_file_path}" --environment-file-auto-open false
    if [ $? != 0 ]; then
        return 1
    fi
}

validate_choices_json() {
    local file_path="$1"

    jq '.' "$file_path" > /dev/null 2>&1
    if [ $? != 0 ]; then
        printf "${RED}${file_path} 不是有效的 JSON 格式，请检查。${NC}\n"
        exit 1
    fi

    local has_choice
    has_choice=$(jq 'if (.choice? | type) == "array" then true else false end' "$file_path")
    if [ "${has_choice}" != "true" ]; then
        printf "${RED}${file_path} 中缺少 .choice 字段或不是数组格式，请检查。${NC}\n"
        exit 1
    fi

    local choice_count
    choice_count=$(jq '.choice | length' "$file_path")
    if [ "${choice_count}" -eq 0 ]; then
        printf "${RED}${file_path} 中的 .choice 数组为空，请添加项目后再试。${NC}\n"
        exit 1
    fi

    for ((i = 0; i < choice_count; i++)); do
        local item_name
        item_name=$(jq -r ".choice[${i}].name" "$file_path")
        if [ -z "${item_name}" ] || [ "${item_name}" == "null" ]; then
            printf "${RED}${file_path} 格式错误：第 $((i+1)) 条缺少 name${NC}\n"
            exit 1
        fi
        local item_path
        item_path=$(jq -r ".choice[${i}].project_tool_file_path" "$file_path")
        if [ -z "${item_path}" ] || [ "${item_path}" == "null" ]; then
            printf "${RED}${file_path} 格式错误：第 $((i+1)) 条(${item_name}) 缺少 project_tool_file_path${NC}\n"
            exit 1
        fi
    done
}


# 快速检查是否已设置环境变量，未设置则添加并占位，之后我们还会去修改占位为指定的值
# 抑制 open（打开编辑器）：避免多次打开的时候，看不到最后一次的最新内容，而是第一次打开时候的内容
# 注意： env_file_change.sh 的逻辑是添加环境变量前会先添加占位，然后才修改占位为指定的值。
#                          进行环境变量的检查和占位的时候，不要立即自动打开环境变量的文件。
#                          因为等一下可以用户还会选择修改环境变量的值。所以应该等到你决定完是否将环境变量的占位符更新为指定的值后才去打开。
#                          否则如果占位时候就打开，则修改完占位后打开的看到还是旧值，因为根本没再打开
# echo "正在执行命令《 sh $qbase_homedir_abspath/env_variables/env_file_check_and_set.sh --env-name \"${ENV_NAME}\" --env-descript \"${ENV_DESCRIPT}\" --env-var-placeholder \"${ENV_VAR_PLACEHOLDER}\" --example-json-file \"${EXAMPLE_JSON_FILE}\" --default-output-filename \"${DEFAULT_OUTPUT_FILENAME}\" --environment-file-auto-open false 》 "
checkResult=$(sh $qbase_homedir_abspath/env_variables/env_file_check_and_set.sh \
    --env-name "${ENV_NAME}" \
    --env-descript "${ENV_DESCRIPT}" \
    --env-var-placeholder "${ENV_VAR_PLACEHOLDER}" \
    --example-json-file "${EXAMPLE_JSON_FILE}" \
    --default-output-filename "${DEFAULT_OUTPUT_FILENAME}" \
    --environment-file-auto-open false
)
if [ $? -ne 0 ]; then
    echo "${checkResult}"
    open_sysenv_file
    exit 2
fi
# echo "${checkResult}" >&2   # 注释调试代码，用于查看调试信息
ENV_NAME_VALUE=${checkResult} # 注意：此处一定要获取更新后的值，不然一定是执行 env_file_check_and_set.sh 前的旧值
tool_choice_file_path="${ENV_NAME_VALUE}"
# echo "您的环境变量值 ENV_NAME = \"${ENV_NAME_VALUE}\""  >&2

if [ "${ACTION}" == "check" ]; then
    open_sysenv_file
    exit 0
fi

validate_choices_json "${tool_choice_file_path}"

showProjectList "${tool_choice_file_path}"
if [ $? != 0 ]; then
    open_sysenv_file
    exit 1
fi

updateToolDealProject "${tool_choice_file_path}"
if [ $? != 0 ]; then
    open_sysenv_file
    exit 1
fi

open_sysenv_file
sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh effective
