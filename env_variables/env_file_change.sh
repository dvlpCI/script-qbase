#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: env_variables/env_file_change.sh
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..

log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

# 解析具名参数
CHOICES_ENV_VAR=""
ENV_NAME=""
ENV_VAR_PLACEHOLDER=""
ACTION=""
while [ $# -gt 0 ]; do
    case "$1" in
        --choices-env)
            CHOICES_ENV_VAR="$2"
            shift 2
            ;;
        --env-name)
            ENV_NAME="$2"
            shift 2
            ;;
        --env-var-placeholder)
            ENV_VAR_PLACEHOLDER="$2"
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
if [ -z "${CHOICES_ENV_VAR}" ] || [ -z "${ENV_NAME}" ] || [ -z "${ENV_VAR_PLACEHOLDER}" ] || [ -z "${ACTION}" ]; then
    echo "错误: 缺少必要参数（--choices-env --env-name --env-var-placeholder --action）" >&2
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
        iChoiceProjectDirPath_rel_toolFile_dir=$(cat "${iChoiceProjectToolFilePath}" | jq -r ".project_path.home_path_rel_this_dir")
        iChoiceProjectDirPath=$(sh $qbase_homedir_abspath/path_util/get_dirpath_by_relpath.sh --file_or_dir_path "${iChoiceProjectToolFilePath}" --rel_path "${iChoiceProjectDirPath_rel_toolFile_dir}")

        printf "${GREEN}%-2s%-20s(路径为 ${YELLOW}%s)${NC}\n" "${iChoiceOptionId}" "${iChoiceName}" "${iChoiceProjectDirPath}"
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
        printf "${RED}选择项目失败：您从 ${CHOICES_ENV_VAR} 中选择的 $targetChoiceCountMap 的 ${BLUE}project_tool_file_path ${RED}指向的文件 ${YELLOW}${project_tool_file_path}${RED} 文件不存在，无法完成选择，请先检查和修改后，重新执行选择。${NC}\n"
        return 1
    fi

    update_env_var "${ENV_NAME}" "${project_tool_file_path}"
    if [ $? != 0 ]; then
        return 1
    fi
}

update_env_var() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        return 1
    fi
    sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "$1" -envVariableValue "$2"
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

sh $qbase_homedir_abspath/env_variables/env_check.sh \
    --env-name "${CHOICES_ENV_VAR}" \
    --env-var-placeholder "${ENV_VAR_PLACEHOLDER}" \
    --env-var-type file \
    --action "${ACTION}"

if [ $? != 0 ]; then
    exit 1
fi

if [ "${ACTION}" == "check" ]; then
    exit 0
fi

validate_choices_json "${!CHOICES_ENV_VAR}"

tool_choice_file_path="${!CHOICES_ENV_VAR}"

showProjectList "${tool_choice_file_path}"
if [ $? != 0 ]; then
    exit 1
fi

updateToolDealProject "${tool_choice_file_path}"
if [ $? != 0 ]; then
    exit 1
fi

sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh effective
