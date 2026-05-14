#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: env_check.sh
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..


log_color_info() { printf "%b\n" "$1" >&2; }	# 日志含颜色：`%b` 会解释 `\033` 等转义序列

# 解析具名参数
ENV_NAME=""
ENV_VAR_PLACEHOLDER=""
ENV_VAR_TYPE=""
ACTION=""
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
if [ -z "${ENV_NAME}" ] || [ -z "${ENV_VAR_PLACEHOLDER}" ] || [ -z "${ACTION}" ]; then
    echo "错误: 缺少必要参数（--env-name --env-var-placeholder --action）" >&2
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


# 添加环境的占位符
addEnvPlaceHolderForKey() {
    envKey=$1
    if [ -z "$1" ]; then
        printf "${RED} envKey 参数的值不能为空 ，请检查。${NC}"
        return 1
    fi
    printf "${RED}您还未添加环境变量 ${envKey} ，请先补充。${NC}"

    envPlaceHolder=$2
    printf "${RED}补充方法如下：请将 ${BLUE}export ${envKey}=${envPlaceHolder}${RED} 中的 ${YELLOW}${envPlaceHolder} ${RED}替换成自己实际的路径)${NC}\n"
    printf "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量\n${NC}"

    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        printf "${NC}已为你自动打开 open ~/.bash_profile ${NC}\n"
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        printf "${NC}已为你自动打开 open ~/.zshrc ${NC}\n"
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    # echo "正在执行命令(更新环境变量):《 sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey \"${envKey}\" -envVariableValue \"${envPlaceHolder}\" 》"
    sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "${envKey}" -envVariableValue "${envPlaceHolder}"
    if [ $? != 0 ]; then
        log_color_info "${RED}设置环境变量 ${envKey} 失败，请检查。${NC}"
        return 1
    fi

    # envKeyFromSys=$(eval echo \$$envKey)
    envKeyFromSys=$(get_sysenvValueByKey "$envKey")
    if [ -z "${envKeyFromSys}" ]; then
        printf "${BLUE}补充结束后，请手动在终端执行 source 命令来生效所修改的环境变量${NC}"
    fi
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

checkEnv() {
    choices_value="${!ENV_NAME}"
    if [ -z "${choices_value}" ] || [ "${choices_value}" == "${ENV_VAR_PLACEHOLDER}" ]; then
        addEnvPlaceHolderForKey "${ENV_NAME}" "${ENV_VAR_PLACEHOLDER}"
        open_sysenv_file "${ENV_NAME}"
        exit 1
    fi
    if [ "${ENV_VAR_TYPE}" == "file" ] || [ "${ENV_VAR_TYPE}" == "json-file" ]; then
        if [ ! -f "${choices_value}" ]; then
            printf "${RED}您配置的环境变量指向的文件不存在 ${YELLOW}${ENV_NAME} ${RED}的值 ${YELLOW}${choices_value} ${RED}文件不存在，请先检查并修改 ${NC}\n"
            printf "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量\n${NC}"
            open_sysenv_file "${ENV_NAME}"
            exit 1
        fi
        
        if [ "${ENV_VAR_TYPE}" == "json-file" ]; then
            jsonFileData=$(cat "$choices_value" | jq ".")
            if [ -z "${jsonFileData}" ]; then
                echo "${RED}您配置的环境变量指向的文件不是有效的json文件，请重新输入。${BLUE} ENV_NAME=${choices_value} ${RED}${NC}"
                open_sysenv_file "${ENV_NAME}"
                exit 1
            fi
        fi
    fi

    if [ "${ACTION}" == "check" ]; then
        exit 0
    fi
}

open_sysenv_file() {
    local env=$1
    # 生效所有环境变量
    # echo "正在执行命令：《${BLUE} sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh open ${NC}》"
    sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh open
    if [ $? -ne 0 ]; then
        log_color_info "${RED}生效所有环境变量失败，请检查。${NC}"
        exit 2
    fi
    log_color_info "${GREEN}环境变量 ${env} 已设置成功${NC}"
}

checkEnv

# if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
#     addEnvPlaceHolder
#     if [ $? != 0 ]; then
#         exit 1
#     fi
#     printf "${RED}请先按以上提示，完成添加修改，再继续!${NC}"
#     exit 1
# else
#     checkFile
# fi
