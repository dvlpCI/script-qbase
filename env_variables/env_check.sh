#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 对任意环境变量进行检查和占位设置(不存在的时候，进行设置，添加环境变量及其占位值）
# @FilePath: env_variables/env_check.sh
# @Example: sh env_variables/env_check.sh --env-name QBASE_CUSTOM_MENU --env-var-placeholder your_qbase_custom_menu_json_file --env-var-type json-file --environment-file-auto-open true
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..


log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

# 解析具名参数
ENV_NAME=""
ENV_VAR_PLACEHOLDER=""
ENV_VAR_TYPE=""
ENVIRONMENT_AUTO_OPEN=true
while [ $# -gt 0 ]; do
    case "$1" in
        --env-name)
            ENV_NAME="$2"
            shift 2
            ;;
        --env-var-placeholder)
            ENV_VAR_PLACEHOLDER="$2"
            shift 2
            ;;
        --env-var-type)
            ENV_VAR_TYPE="$2"
            shift 2
            ;;
        -envFileAutoOpen|--environment-file-auto-open) 
            # 抑制 open（打开编辑器）：避免多次打开的时候，看不到最后一次的最新内容，而是第一次打开时候的内容
            # 如添加前会先添加占位，然后才修改占位，如果占位时候就打开，则修改完占位后打开的看到还是旧值，因为根本没再打开
            ENVIRONMENT_AUTO_OPEN=$2;
            shift 2
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done
if [ -z "${ENV_NAME}" ] || [ -z "${ENV_VAR_PLACEHOLDER}" ]; then
    echo "错误: 缺少必要参数（--env-name --env-var-placeholder" >&2
    exit 1
fi

if [ "$ENVIRONMENT_AUTO_OPEN" != false ]; then
    ENVIRONMENT_AUTO_OPEN=true
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
    # echo "正在执行命令：《${BLUE} sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh open ${NC}》" >&2
    sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh open
}

# 添加环境的占位符
addEnvPlaceHolderForKey() {
    envKey=$1
    if [ -z "$1" ]; then
        printf "${RED} envKey 参数的值不能为空 ，请检查。${NC}"
        return 1
    fi
    log_color_info "${RED}您还未添加环境变量 ${envKey} ，请先补充；或者环境变量未生效，导致在终端执行命令 echo \$${ENV_NAME} 为空，请执行 source 使其生效${NC}"

    envPlaceHolder=$2
    log_color_info "${RED}补充方法如下：请将 ${BLUE}export ${envKey}=${envPlaceHolder}${RED} 中的 ${YELLOW}${envPlaceHolder} ${RED}替换成自己实际的路径)${NC}"
    log_color_info "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量${NC}"

    envFileAutoOpen=$3
    # echo "正在执行命令(更新环境变量):《 sh $qbase_homedir_abspath/env_variables/env_var_2add_or_update.sh -envVariableKey \"${envKey}\" -envVariableValue \"${envPlaceHolder}\" -envFileAutoOpen ${envFileAutoOpen} 》"
    sh $qbase_homedir_abspath/env_variables/env_var_2add_or_update.sh \
        -envVariableKey "${envKey}" \
        -envVariableValue "${envPlaceHolder}" \
        -envFileAutoOpen ${envFileAutoOpen}
    if [ $? != 0 ]; then
        log_color_info "${RED}设置环境变量 ${envKey} 失败，请检查。${NC}"
        return 1
    fi

    # envKeyFromSys=$(eval echo \$$envKey)
    envKeyFromSys=$(get_sysenvValueByKey "$envKey")
    if [ -z "${envKeyFromSys}" ]; then
        log_color_info "${BLUE}补充结束后，请手动在终端执行 source 命令来生效所修改的环境变量${NC}"
    fi

    log_color_info "${GREEN}已自动为你设置环境变量 ${envKey} 及其占位值成功，请等下记得修改${NC}"
}

# 定义一个函数，用来获取指定名称的环境变量的值
function get_sysenvValueByKey() {
    local varname="$1"

    # 检查是否传入了环境变量名
    if [ -z "$varname" ]; then
        echo "Usage: getenv varname"
        return 1
    fi

    # 根据当前使用的 SHELL_TYPE 类型，选择正确的语法或命令来获取环境变量的值
    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        echo "${!varname}"
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        eval echo \$$varname
    elif [ "$SHELL_TYPE" = "fish" ]; then
        eval "echo \$$varname"
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    return 0
}


env_name="${!ENV_NAME}"
if [ -z "${env_name}" ] || [ "${env_name}" == "${ENV_VAR_PLACEHOLDER}" ]; then
    if [ -z "${env_name}" ]; then
        status_type="env_not_set"
        message="您还未添加环境变量 ${ENV_NAME}，请先补充；或者环境变量未生效，导致在终端执行命令 echo \$${ENV_NAME} 为空，请执行 source 使其生效"
        # 未检测到 ${ENV_NAME} 环境变量(请确保在终端执行命令 echo \$${ENV_NAME} 能有结果)。无结果的可能原因有：① 您还未添加环境变量，则请添加；或者② 环境变量未生效，请执行 source 使其生效
    else
        status_type="env_is_placeholder"
        message="环境变量 ${ENV_NAME} 仍是占位值 ${ENV_VAR_PLACEHOLDER}，请替换为实际路径。"
    fi
    
    # 通过 ENVIRONMENT_AUTO_OPEN 自动决定 addEnvPlaceHolderForKey 是否内部执行 open_sysenv_file
    addEnvPlaceHolderForKey "${ENV_NAME}" "${ENV_VAR_PLACEHOLDER}" "${ENVIRONMENT_AUTO_OPEN}"
    if [ $? != 0 ]; then
        status_type="env_placeHolder_set_failure"
        message="设置环境变量 ${ENV_NAME} 失败，请检查。"
        printf "%s\n" "{\"status_type\":\"${status_type}\",\"message\":\"${message}\"}"
        exit 0
    fi

    status_type="env_placeHolder_set_success"
    message="已自动为你设置环境变量 ${ENV_NAME} 及其占位值成功，请等下记得修改"
    printf "%s\n" "{\"status_type\":\"${status_type}\",\"message\":\"${message}\"}"
    exit 0
fi
if [ "${ENV_VAR_TYPE}" == "file" ] || [ "${ENV_VAR_TYPE}" == "json-file" ]; then
    if [ ! -f "${env_name}" ]; then
        log_color_info "${RED}您配置的环境变量指向的文件不存在。即 ${YELLOW}${ENV_NAME} ${RED}的值 ${YELLOW}${env_name} ${RED}文件不存在，请先检查并修改 ${NC}"
        log_color_info "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量${NC}"
        status_type="env_file_noexsit"
        message="您配置的环境变量指向的文件不存在。即 ${ENV_NAME} 的值 ${env_name} 文件不存在！"
        printf "%s\n" "{\"status_type\":\"${status_type}\",\"message\":\"${message}\"}"
        
        open_sysenv_file
        
        exit 0
    fi
    
    if [ "${ENV_VAR_TYPE}" == "json-file" ]; then
        jsonFileData=$(cat "$env_name" | jq ".")
        if [ -z "${jsonFileData}" ]; then
            log_color_info "${RED}您配置的环境变量指向的文件不是有效的json文件，请重新输入。${BLUE} ENV_NAME=${env_name} ${RED}${NC}"
            status_type="env_file_not_json"
            message="您配置的环境变量指向的文件不是有效的json文件。ENV_NAME=${env_name}"
            printf "%s\n" "{\"status_type\":\"${status_type}\",\"message\":\"${message}\"}"

            open_sysenv_file

            exit 0
        fi
    fi
fi

status_type="env_success"
message="您配置的环境变量正确。ENV_NAME=${env_name}"
printf "%s\n" "{\"status_type\":\"${status_type}\",\"message\":\"${message}\"}"