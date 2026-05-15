#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-09 22:56:13
# @FilePath: env_variables/env_file_check_and_set.sh
# @Description: 对指向json文件的环境变量进行检查和设置(设置时候，先添加环境变量及其占位值，然后通过①复制示例文件或者②终端输入来指定占位值要修改为的指定值。终端输入也会有示例的演示输入）。
#   检查指定的环境变量是否已设置且指向存在的文件，
#   若未设置则提供交互式引导（复制示例文件 / 手动输入路径）。
#   调用方负责在设置完成后执行后续操作。
# @Exampel: sh env_file_check_and_set.sh \
#           --env-name QBASE_CUSTOM_MENU \
#           --env-descript "自定义命令菜单" \
#           --env-var-placeholder "your_custom_menu_json_file" \
#           --example-json-file "./menu/example/custom_command_menu_example.json" \
#           --default-output-filename "custom_menu.json"
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

# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
helpCmdStrings=("-help" "help")

ENV_NAME=""
ENV_DESCRIPT=""
ENV_VAR_PLACEHOLDER=""
EXAMPLE_JSON_FILE=""
DEFAULT_OUTPUT_FILENAME=""

ENVIRONMENT_AUTO_OPEN=true

while [ $# -gt 0 ]; do
    case "$1" in
        --env-name) ENV_NAME="$2"; shift 2 ;;
        --env-descript) ENV_DESCRIPT="$2"; shift 2 ;;
        --env-var-placeholder) ENV_VAR_PLACEHOLDER="$2"; shift 2 ;;
        --example-json-file) EXAMPLE_JSON_FILE="$2"; shift 2 ;;
        --default-output-filename) DEFAULT_OUTPUT_FILENAME="$2"; shift 2 ;;
        -envFileAutoOpen|--environment-file-auto-open) 
            # 请避免多次打开同一文件（如环境变量文件）。因为在打开之后进行的修改，无法通过再次打开文件来才看到最新的内容，只能是之前没打开，然后编辑后打开才能看到最新的内容。
            # 抑制 open（打开编辑器）：避免多次打开的时候，看不到最后一次的最新内容，而是第一次打开时候的内容
            ENVIRONMENT_AUTO_OPEN=$2;
            shift 2
            ;;
        *) echo "未知参数: $1" >&2; exit 1 ;;
    esac
done

if [ -z "${ENV_NAME}" ] || [ -z "${EXAMPLE_JSON_FILE}" ]; then
    echo "错误: 缺少必要参数（--env-name --example-json-file）" >&2
    exit 1
fi

if [ "$ENVIRONMENT_AUTO_OPEN" != false ]; then
    ENVIRONMENT_AUTO_OPEN=true
fi

ENV_VAR_PLACEHOLDER="${ENV_VAR_PLACEHOLDER:-your_${ENV_NAME}_value}"
DEFAULT_OUTPUT_FILENAME="${DEFAULT_OUTPUT_FILENAME:-config.json}"
ENV_DESCRIPT="${ENV_DESCRIPT:-${ENV_NAME}}"

showCustomMenuJsonExample() {
    log_color_info "以下提供一个您的环境变量 ${ENV_NAME} 表示的 ${ENV_DESCRIPT} 的json文件内容的参考结构："
    jsonFileExamplePath="${EXAMPLE_JSON_FILE}"
    log_color_info "${BLUE}$(cat ${jsonFileExamplePath})${NC}"
}

log_guide() {
    log_color_info "$(cat <<EOF

${GREEN}你可以稍后执行以下命令来手动设置：
${BLUE} export ${ENV_NAME}=${targetFile}
${GREEN}也可将上述命令添加到 ~/.zshrc 中使其永久生效
 ${NC}
EOF
)"
}

inputCustomJsonFilePath() {
    valid_option=false
    while [ "$valid_option" = false ]; do
        read -r -p "请输入您要用本脚本执行的${ENV_DESCRIPT}json文件路径(若要退出请输入Q|q) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        if [ ! -f "${option}" ]; then
            log_color_info "${RED}您输入的文件${BLUE} ${option} ${RED}不存在，请重新输入${NC}"
            continue
        fi

        # 定义菜单选项
        jsonFileData=$(cat "$option" | jq ".")
        if [ -z "${jsonFileData}" ]; then
            log_color_info "${RED}您输入的文件${BLUE} ${option} ${RED}不是json文件或格式不正确，请检查或重新输入${NC}"
            continue
        fi

        result=$(checkValueCanbeUse "${option}")
        if [ $? != 0 ]; then
            log_color_info "${result}"
            showCustomMenuJsonExample
            continue
        fi

        eval "${ENV_NAME}='${option}'"
        log_color_info "${GREEN}您将使用输入的文件[${BLUE} ${option} ${GREEN}]作为${BLUE} ${ENV_DESCRIPT} ${ENV_NAME} ${NC}的值${NC}"
        break
    done
}

checkValueCanbeUse() {
    try_use_menu_json_file="${1}"

    if [ ! -f "${try_use_menu_json_file}" ]; then
        echo "${RED}您输入的文件${BLUE} ${try_use_menu_json_file} ${RED}不存在，请重新输入${NC}"
        return 1
    fi

    # 定义菜单选项
    jsonFileData=$(cat "$try_use_menu_json_file" | jq ".")
    if [ -z "${jsonFileData}" ]; then
        echo "${RED}您输入的文件${BLUE} ${try_use_menu_json_file} ${RED}不是有效的json文件，请重新输入${NC}"
        return 1
    fi
}



# 复制示例文件到当前目录
handleCopyExampleToCurrentDir() {
    exampleFilePath="${EXAMPLE_JSON_FILE}"
    targetFile="$(pwd)/${DEFAULT_OUTPUT_FILENAME}"

    if [ -f "${targetFile}" ]; then
        while true; do
            read -r -p "当前目录 $(pwd) 下已存在 ${DEFAULT_OUTPUT_FILENAME}，覆盖请输入 y (退出请输入 Q/q): " yn
            case $yn in
                y|Y) break ;;
                q|Q) exit 2 ;;
                *) echo "请输入 y 或 q" ;;
            esac
        done
    fi

    chmod +w "${targetFile}" 2>/dev/null    # 解决拷贝只读文件失败
    if cp "${exampleFilePath}" "${targetFile}"; then
        log_color_info "${GREEN}成功复制示例到${BLUE} ${targetFile} ${GREEN}。你可在此文件上修改${ENV_DESCRIPT}${NC}"
        setupEnvVar "${targetFile}"
    else
        log_color_info ""
        # log_color_info "执行文件拷贝命令《 cp \"${exampleFilePath}\" \"${targetFile}\" 》失败"
        log_color_info "${RED}复制示例文件到${BLUE} ${targetFile} ${RED}失败，请检查当前目录${BLUE} $(pwd) ${NC}是否有写入权限，或直接新建json文件并拷贝以上json示例${NC}"
        log_guide
        return 1
    fi
}

# 设置环境变量
setupEnvVar() {
    local targetFile="$1"
    log_color_info ""
    log_color_info "${PURPLE}是否设置${BLUE} ${ENV_NAME} ${PURPLE}环境变量指向此文件？${NC}"
    log_color_info "${PURPLE}  → 设置后，下次执行 ${ENV_DESCRIPT} 将直接使用此文件，无需再次选择${NC}"
    while true; do
        read -r -p "是否设置 ${ENV_NAME} 环境变量指向此文件？请输入 (y/n): " yn
        case $yn in
            y|Y)
                # 添加环境变量
                # 正确做法：让 env_var_add_or_update.sh 写入 .zshrc，然后通过 stdout 把路径传出去
                sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "${ENV_NAME}" -envVariableValue "${targetFile}"
                if [ $? -ne 0 ]; then
                    log_color_info "${RED}设置环境变量 ${ENV_NAME} 失败，请检查。${NC}"
                    exit 2
                fi

                # 生效所有环境变量（subprocess 中 source，只影响子进程，不影响父 shell）
                # echo "正在执行命令：《${BLUE} sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh ${NC}》"
                sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh
                if [ $? -ne 0 ]; then
                    log_color_info "${RED}生效所有环境变量失败，请检查。${NC}"
                    exit 2
                fi
                log_color_info "${GREEN}环境变量 ${ENV_NAME} 已设置成功${NC}"
                
                # 关键：把设置的路径通过 stdout 传出去！供父进程捕获
                echo "${targetFile}"
                return 0
                ;;
            n|N)
                log_guide
                exit 2
                ;;
            *)
                log_color_info "请输入 y 或 n"
                ;;
        esac
    done
}


# 在发现问题的时候展示引导流程
show_guide_process_when_found_error() {
    showCustomMenuJsonExample
    log_color_info "$(cat <<EOF

请选择操作：
  1. 复制示例到当前目录${BLUE} $(pwd) ${NC}，生成 ${DEFAULT_OUTPUT_FILENAME}（推荐）
  2. 手动输入已有 json 文件路径
 
EOF
)"

    while true; do
        read -r -p "请输入选项 (1/2)（退出请输入 Q/q）: " option
        if [ "${option}" == "q" ] || [ "${option}" == "Q" ]; then
            exit 2
        elif [ -z "${option}" ]; then
            log_color_info "输入不能为空，请重新输入。"
        else
            case $option in
                1)
                    handleCopyExampleToCurrentDir
                    if [ $? -eq 0 ]; then
                        return 0
                    else
                        exit 2
                    fi
                    ;;
                2)
                    inputCustomJsonFilePath
                    if [ -n "${!ENV_NAME}" ]; then
                        setupEnvVar "${!ENV_NAME}"
                        return 0
                    fi
                    ;;
                *)
                    log_color_info "无效选项，请重新输入"
                    ;;
            esac
        fi
    done
}

# 快速检查是否已设置环境变量
# echo "正在执行命令《 sh $qbase_homedir_abspath/env_variables/env_check.sh --env-name ${ENV_NAME} --env-var-placeholder \"${ENV_VAR_PLACEHOLDER}\" --env-var-type file --environment-file-auto-open \"${ENVIRONMENT_AUTO_OPEN}\" 》 "
checkResult=$(sh $qbase_homedir_abspath/env_variables/env_check.sh \
    --env-name "${ENV_NAME}" \
    --env-var-placeholder "${ENV_VAR_PLACEHOLDER}" \
    --env-var-type file \
    --environment-file-auto-open "${ENVIRONMENT_AUTO_OPEN}"
    )
if [ $? -ne 0 ]; then
    echo "${checkResult}"
    exit 1
fi


status_type=$(echo "${checkResult}" | jq -r '.status_type')
message=$(echo "${checkResult}" | jq -r '.message')
if [ "${status_type}" == "env_success" ]; then
    echo "${!ENV_NAME}" # 这里还是得输出给外部，因为下文失败的时候需要将更新的值输出给外部，为了保证代码不会出错，这里也要给，不然外部不给的话，外部取这个脚本的返回值会得到空
    exit 0
fi

jsonData=$(printf "%s" "${checkResult}" | jq -r '.')
log_color_info "${YELLOW}${jsonData}${NC}"

# 已经发现有错了，且发现该错误还不是文件不存在或者json问题，则不继续。如果是其他的则允许继续
# 关键：捕获 show_guide_process_when_found_error 的 stdout，它包含 setupEnvVar 成功时 echo 的路径
result=$(show_guide_process_when_found_error)
if [ $? -ne 0 ]; then
    echo "${result}"
    exit 2
fi

# 将更新完的新环境变量值，输出给调用者。直接用 result 即可，因为它包含了 setupEnvVar 成功时通过 stdout 传出的路径
echo "${result}"
