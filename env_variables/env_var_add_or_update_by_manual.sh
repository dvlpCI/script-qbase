#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 通过人工交互方式对指定环境变量进行修改(方式 ①从文件中选择[如果有传文件的话]或者 ②从终端输入）
# @FilePath: sh env_variables/env_var_add_or_update_by_manual.sh --env-name QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH --choose-from-env-keys-file-path /Users/qian/Project/Github/script-qbase/example_env_keys_menu.json
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

# 解析具名参数
ENV_NAME=""
ENV_VAR_REFERENCE_JSON_FILE_EXAMPLE=""   # 可选：环境变量是json文件才有用。代表json文件内容的的参考示例

CHOOSE_FROM_ENV_KEYS_FILE_PATH=""
while [ $# -gt 0 ]; do
    case "$1" in
        --env-name)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                echo "错误: --env-name 需要指定一个值" >&2
                exit 1
            fi
            ENV_NAME="$2"
            shift 2
            ;;
        --choose-from-env-keys-file-path)
            # 允许空值或者不传：检查下一个参数是否为空或者是选项（以 - 开头）
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                # 没有提供值，或者下一个参数是选项，则设置为空
                CHOOSE_FROM_ENV_KEYS_FILE_PATH=""
                shift 1  # 只消费当前参数
            else
                CHOOSE_FROM_ENV_KEYS_FILE_PATH="$2"
                shift 2
            fi
            ;;
        --env-reference-json-file-example)
            # 可选：环境变量是json文件才有用。代表json文件内容的的参考示例
            # 允许空值或者不传：检查下一个参数是否为空或者是选项（以 - 开头）
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                # 没有提供值，或者下一个参数是选项，则设置为空
                ENV_VAR_REFERENCE_JSON_FILE_EXAMPLE=""
                shift 1  # 只消费当前参数
            else
                ENV_VAR_REFERENCE_JSON_FILE_EXAMPLE="$2"
                shift 2
            fi
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

# 检查必需参数
if [ -z "${ENV_NAME}" ]; then
    log_color_info "错误: 缺少必要参数（--env-name）"
    exit 1
fi

# CHOOSE_FROM_ENV_KEYS_FILE_PATH 允许为空，所以不检查是否为空
# 但如果传了值且不是空字符串，则需要验证文件是否存在
if [ -n "${CHOOSE_FROM_ENV_KEYS_FILE_PATH}" ] && [ ! -f "${CHOOSE_FROM_ENV_KEYS_FILE_PATH}" ]; then
    log_color_info "错误: --choose-from-env-keys-file-path 的参数值不是有效文件: ${CHOOSE_FROM_ENV_KEYS_FILE_PATH}"
    exit 1
fi

selected_env_key=""

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

showCustomMenuJsonExample() {
    # 可选：环境变量是json文件才有用。代表json文件内容的的参考示例
    log_color_info "以下提供一个您的环境变量 ${ENV_NAME} 代表的json文件内容的参考结构："
    log_color_info "${BLUE}$(cat ${ENV_VAR_REFERENCE_JSON_FILE_EXAMPLE})${NC}"
}

# 验证 envs_choices 的 JSON 格式（验证顶层结构）
validate_envs_choices_json() {
    local file_path="$1"

    # 检查文件是否存在
    if [ ! -f "$file_path" ]; then
        printf "${RED} ${file_path} 文件不存在，请检查。${NC}\n"
        return 1
    fi

    # 验证是否为有效的 JSON 格式
    jq '.' "$file_path" > /dev/null 2>&1
    if [ $? != 0 ]; then
        printf "${RED}${file_path} 不是有效的 JSON 格式，请检查。${NC}\n"
        return 1
    fi

    # 检查是否有 envs_choices 字段且为数组
    local has_envs_choices
    has_envs_choices=$(jq 'if (.envs_choices? | type) == "array" then true else false end' "$file_path")
    if [ "${has_envs_choices}" != "true" ]; then
        printf "${RED}${file_path} 中缺少 .envs_choices 字段或不是数组格式，请检查。${NC}\n"
        return 1
    fi

    # 检查 envs_choices 数组是否为空
    local envs_choices_count
    envs_choices_count=$(jq '.envs_choices | length' "$file_path")
    if [ "${envs_choices_count}" -eq 0 ]; then
        printf "${RED}${file_path} 中的 .envs_choices 数组为空，请添加环境变量配置后再试。${NC}\n"
        return 1
    fi

    # 遍历验证每个 envs_choices 项
    for ((i = 0; i < envs_choices_count; i++)); do
        # 检查 env_key 字段（必填）
        local env_key
        env_key=$(jq -r ".envs_choices[${i}].env_key" "$file_path")
        if [ -z "${env_key}" ] || [ "${env_key}" == "null" ]; then
            printf "${RED}${file_path} 格式错误：第 $((i+1)) 条缺少 env_key 字段${NC}\n"
            return 1
        fi

        # 检查是否有 env_choices（可选，如果有则验证其格式）
        local has_env_choices
        has_env_choices=$(jq "if (.envs_choices[${i}] | has(\"env_choices\")) then true else false end" "$file_path")
        
        if [ "${has_env_choices}" == "true" ]; then
            # 验证 env_choices 是否为数组
            local is_array
            is_array=$(jq "if (.envs_choices[${i}].env_choices | type) == \"array\" then true else false end" "$file_path")
            if [ "${is_array}" != "true" ]; then
                printf "${RED}${file_path} 格式错误：env_key '${env_key}' 的 .env_choices 不是数组格式${NC}\n"
                return 1
            fi
            
            # 可选：检查 env_choices 数组是否为空（只警告，不退出）
            local env_choices_count
            env_choices_count=$(jq ".envs_choices[${i}].env_choices | length" "$file_path")
            if [ "${env_choices_count}" -eq 0 ]; then
                printf "${YELLOW}警告：${file_path} 中 env_key '${env_key}' 的 .env_choices 数组为空${NC}\n"
            fi
        fi
    done

    printf "${GREEN}✓ ${file_path} JSON 格式验证通过${NC}\n"
}


# 更新环境变量的值（有指定 key 直接选 value；不指定 key，先选 key 再选 value）
get_selected_env_value_ForKeyOrChoose() {
    local json_file=$1
    local target_env_key=$2
    
    log_color_info "${PURPLE}\n============== 1、确定要查找的 key ==================${NC}"
    get_selected_env_key "${json_file}" "${target_env_key}"
    if [ $? -ne 0 ] || [ -z "$selected_env_key" ]; then
        return 1
    fi
    #echo "selected_env_key =========== ${selected_env_key}" >&2

    log_color_info "${PURPLE}\n============== 2、对要查找的 key，进行选择 ==================${NC}"
    # 确定完要查找的key后，列出指定 env_key 的所有可选值，然后才是选择 value
    get_selected_env_value_for_selected_env_key
    if [ $? -ne 0 ] || [ -z "$selected_value" ]; then
        return 1
    fi
}

# ======================= 列出所有可用的 env_key 、先选 key 再选 value  =======================
function get_selected_env_key() {
    local json_file=$1
    local target_env_key=$2
    
    # ============== 1、确定要查找的 key ==================
    if [ -z "$target_env_key" ]; then
        # 未指定 key，列出所有可用的 env_key 供选择
        showEnvKeyList "$json_file"

        while true; do
            local current_value="${!ENV_NAME}"
            if [ -z "${current_value}" ]; then
                echo "您还未选择环境变量"
            else
                echo "当前环境变量 ${ENV_NAME} 的值为: ${YELLOW}${current_value}${NC}"
            fi

            selected_env_key=$(selectEnvKey "$json_file")
            if [ $? -ne 0 ] || [ -z "$selected_env_key" ]; then
                return 1
            fi
                
            log_color_info "选中的环境变量: ${BLUE}${selected_env_key}${NC}"
            return 0
        done
    else
        # 有指定的 Key，验证其是否在支持的表中
        local envKeysCount=$(cat "$json_file" | jq '.envs_choices|length')
        local support_keys=""
        local found=false
        for ((i = 0; i < envKeysCount; i++)); do
            local exist_key=$(jq -r ".envs_choices[${i}].env_key" "$json_file")
            # 拼接支持的key列表
            if [ -n "$support_keys" ]; then
                support_keys="${support_keys}, "
            fi
            support_keys="${support_keys}${exist_key}"
            
            if [ "$exist_key" = "$target_env_key" ]; then
                found=true
            fi
        done
        
        if [ "$found" = false ]; then
            log_color_info "你指定的 Key ${BLUE} '${target_env_key}' ${NC}不在支持的表中，请检查文件 $json_file，其支持的key有：${YELLOW}${support_keys}${NC}"
            return 1
        fi

        selected_env_key=$target_env_key
        log_color_info "你要查找的的环境变量: ${BLUE}${selected_env_key}${NC}"
        return 0
    fi
}


# 列出所有可用的 env_key
showEnvKeyList() {
    local json_file=$1
    
    printf "支持的环境变量列表： (详见: ${YELLOW}${json_file}${NC})\n"
    
    local envKeysCount=$(cat "$json_file" | jq '.envs_choices|length')
    for ((i = 0; i < ${envKeysCount}; i++)); do
        local iEnvKeyMap=$(cat "$json_file" | jq ".envs_choices" | jq -r ".[${i}]")
        
        local iEnvKeyOptionId="$((i + 1))"
        local iEnvKey=$(echo "$iEnvKeyMap" | jq -r ".env_key")
        local iEnvDesc=$(echo "$iEnvKeyMap" | jq -r ".env_des // \"无描述\"")
        
        printf "${GREEN}%-2s${NC}) ${BLUE}%-40s${NC} - ${YELLOW}%s${NC}\n" "${iEnvKeyOptionId}" "${iEnvKey}" "${iEnvDesc}"
    done
}

function get_selected_env_value_for_selected_env_key() {
    showEnvChoices "$json_file" "$selected_env_key"
    
    local valid_option=false
    while [ "$valid_option" = false ]; do        
        selected_value=$(_selectEnvValueForKey "$json_file" "$selected_env_key")
        if [ $? -ne 0 ] || [ -z "$selected_value" ]; then
            log_color_info "未获取到有效的值，请重新选择。"
        else
            log_color_info "${PURPLE}为${BLUE} ${selected_env_key} ${PURPLE}选中的环境变量值为${BLUE} ${selected_value} ${PURPLE}。${NC}"
            valid_option=true
            break
        fi
    done
}

# 列出指定 env_key 的所有可选值
showEnvChoices() {
    local json_file=$1
    local target_env_key=$2
    
    # 获取该 env_key 的配置
    local envConfig=$(cat "$json_file" | jq -r ".envs_choices[] | select(.env_key == \"${target_env_key}\")")
    
    if [ -z "$envConfig" ] || [ "$envConfig" = "null" ]; then
        echo "错误: 未找到 env_key '${target_env_key}' 的配置" >&2
        return 1
    fi
    
    # 检查是否有 env_choices
    local hasChoices=$(echo "$envConfig" | jq 'has("env_choices")')
    
    if [ "$hasChoices" = "true" ]; then
        local choicesCount=$(echo "$envConfig" | jq '.env_choices|length')
        
        if [ "$choicesCount" -eq 0 ]; then
            echo "该环境变量没有可选的配置项" >&2
            return 1
        fi
        
        printf "请选择 ${BLUE}${target_env_key}${NC} 的值:\n"
        for ((i = 0; i < ${choicesCount}; i++)); do
            local iChoice=$(echo "$envConfig" | jq -r ".env_choices[${i}]")
            local iChoiceOptionId="$((i + 1))"
            local iChoiceName=$(echo "$iChoice" | jq -r ".env_name // .env_des")
            local iChoiceValue=$(echo "$iChoice" | jq -r ".env_value")
            
            printf "${GREEN}%-2s${NC}) ${BLUE}%-30s${NC} -> ${YELLOW}%s${NC}\n" "${iChoiceOptionId}" "${iChoiceName}" "${iChoiceValue}"
        done
    else
        # 没有 env_choices，直接显示 env_value
        local directValue=$(echo "$envConfig" | jq -r ".env_value // empty")
        if [ -n "$directValue" ] && [ "$directValue" != "null" ]; then
            printf "该环境变量的值为: ${YELLOW}%s${NC}\n" "$directValue"
        else
            echo "该环境变量没有预设值，需要手动输入" >&2
        fi
    fi
}

# 交互式选择 env_key（不指定 key 时使用）
selectEnvKey() {
    local json_file=$1
    
    local envKeysCount=$(cat "$json_file" | jq '.envs_choices|length')
    
    local option
    while true; do
        read -r -p "请选择环境变量的编号 (1-${envKeysCount}) (若要退出请输入Q|q): " option
        
        if [ "${option}" = "q" ] || [ "${option}" = "Q" ]; then
            return 1
        fi
        
        if [[ "$option" =~ ^[0-9]+$ ]] && [ "$option" -ge 1 ] && [ "$option" -le "$envKeysCount" ]; then
            local selected_env_key=$(cat "$json_file" | jq -r ".envs_choices[$((option-1))].env_key")
            echo "$selected_env_key"
            return 0
        else
            echo "无效选择，请重新输入"
        fi
    done
}

# 交互式选择 env_value（有指定 key：列出指定key的可选值，直接选 value）
_selectEnvValueForKey() {
    local json_file=$1
    local target_env_key=$2
    
    # 获取该 env_key 的配置
    local envConfig=$(cat "$json_file" | jq -r ".envs_choices[] | select(.env_key == \"${target_env_key}\")")
    
    if [ -z "$envConfig" ] || [ "$envConfig" = "null" ]; then
        echo "错误: 未找到 env_key '${target_env_key}' 的配置" >&2
        return 1
    fi
    
    # 检查是否有 env_choices
    local hasChoices=$(echo "$envConfig" | jq 'has("env_choices")')
    
    if [ "$hasChoices" = "true" ]; then
        local choicesCount=$(echo "$envConfig" | jq '.env_choices|length')
        
        if [ "$choicesCount" -eq 0 ]; then
            echo "错误: 该环境变量没有可选的配置项" >&2
            return 1
        fi
        
        local option
        while true; do
            read -r -p "请选择值的编号 (1-${choicesCount}) (若要退出请输入Q|q): " option
            
            if [ "${option}" = "q" ] || [ "${option}" = "Q" ]; then
                return 1
            fi
            
            if [[ "$option" =~ ^[0-9]+$ ]] && [ "$option" -ge 1 ] && [ "$option" -le "$choicesCount" ]; then
                local selected_value=$(echo "$envConfig" | jq -r ".env_choices[$((option-1))].env_value")
                echo "$selected_value"
                return 0
            else
                echo "无效选择，请重新输入"
            fi
        done
    else
        # 没有 env_choices，直接取 env_value 或手动输入
        local directValue=$(echo "$envConfig" | jq -r ".env_value // empty")
        if [ -n "$directValue" ] && [ "$directValue" != "null" ]; then
            echo "$directValue"
            return 0
        else
            read -r -p "请输入 ${target_env_key} 的值: " manual_value
            echo "$manual_value"
            return 0
        fi
    fi
}

# 如果没有提供文件来选择，则使用让用户手动输入的方式
if [ -z "${CHOOSE_FROM_ENV_KEYS_FILE_PATH}" ]; then
    selected_env_key=${ENV_NAME}
    log_color_info "${PURPLE}\n============== 没有提供文件来选择，请手动输入环境变量要更新的值 ==================${NC}"
    inputResult=$(sh $qbase_homedir_abspath/value_create/value_create_by_input.sh --input-descript "${ENV_DESCRIPT}" --input-for json-file)
    if [ $? != 0 ]; then
        log_color_info "${inputResult}"
        open_sysenv_file
        exit 1
    fi
    
    selected_value=${inputResult}
    log_color_info "${GREEN}您将使用输入的文件[${BLUE} ${inputResult} ${GREEN}]作为${BLUE} ${ENV_NAME} ${NC}的值${NC}"
else
    # 验证envkey文件是否符合结构
    env_keys_file_path="${CHOOSE_FROM_ENV_KEYS_FILE_PATH}"
    validate_envs_choices_json "${env_keys_file_path}"
    if [ $? != 0 ]; then
        if [ -n "${ENV_VAR_REFERENCE_JSON_FILE_EXAMPLE}" ]; then
            showCustomMenuJsonExample
        fi
    fi

    get_selected_env_value_ForKeyOrChoose "${env_keys_file_path}" "${ENV_NAME}"
    if [ $? != 0 ]; then
        open_sysenv_file
        exit 1
    fi
fi

log_color_info "${PURPLE}\n============== 对为环境变量 key 选中的值，进行更新 ==================${NC}"
# log_color_info "正在执行命令《 sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey \"${selected_env_key}\" -envVariableValue \"${selected_value}\" --environment-file-auto-open false 》"
sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "${selected_env_key}" -envVariableValue "${selected_value}" --environment-file-auto-open false
if [ $? != 0 ]; then
    open_sysenv_file
    exit 1
fi
log_color_info "已更新环境变量 ${selected_env_key} = ${YELLOW}${selected_value}${NC}"

open_sysenv_file
sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh effective
