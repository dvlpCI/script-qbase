#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-09 22:56:13
# @Description: 执行自定义的命令菜单（若不存在会引导添加）
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"


# 检查jq是否安装
if ! command -v jq &> /dev/null; then
    echo ""
    echo "${RED}Error:jq is not installed. Please install it with command:${BLUE} brew install jq${NC}"
    exit 1
fi


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CurrentDIR_Script_Absolute} # 使用 %/* 方法可以避免路径上有..

# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
helpCmdStrings=("-help" "help")

showCustomMenuJsonExample() {
    echo "您自定义命令菜单json文件的内容参考如下："
    jsonFileExamplePath="${qbase_homedir_abspath}/menu/example/custom_command_menu_example.json"
    echo "${BLUE}$(cat ${jsonFileExamplePath})${NC}"
}

inputCustomJsonFilePath() {
    valid_option=false
    while [ "$valid_option" = false ]; do
        read -r -p "请输入您要用本脚本执行的自定义命令菜单的json文件路径(若要退出请输入Q|q) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        if [ ! -f "${option}" ]; then
            echo "${RED}您输入的文件${BLUE} ${option} ${RED}不存在，请重新输入${NC}"
            continue
        fi

        # 定义菜单选项
        jsonFileData=$(cat "$option" | jq ".")
        if [ -z "${jsonFileData}" ]; then
            echo "${RED}您输入的文件${BLUE} ${option} ${RED}不是json文件或格式不正确，请检查或重新输入${NC}"
            continue
        fi

        result=$(checkValueCanbeUse "${option}")
        if [ $? != 0 ]; then
            echo "${result}"
            showCustomMenuJsonExample
            continue
        fi

        QBASE_CUSTOM_MENU="${option}"
        echo "${GREEN}您将使用输入的文件${BLUE} ${option} ${GREEN}作为自定义的命令菜单${NC}"
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
    exampleFilePath="${qbase_homedir_abspath}/menu/example/custom_command_menu_example.json"
    targetFile="$(pwd)/custom_menu.json"

    if [ -f "${targetFile}" ]; then
        while true; do
            read -r -p "当前目录下已存在 custom_menu.json，是否覆盖？(y/n): " yn
            case $yn in
                y|Y) break ;;
                n|N) return 1 ;;
                *) echo "请输入 y 或 n" ;;
            esac
        done
    fi

    cp "${exampleFilePath}" "${targetFile}"
    echo "${GREEN}已复制示例文件到 ${targetFile}${NC}"
    echo "你可在此文件上修改自定义命令菜单"

    setupEnvVar "${targetFile}"
}

# 设置环境变量 QBASE_CUSTOM_MENU
setupEnvVar() {
    local targetFile="$1"
    echo ""
    echo "是否设置 QBASE_CUSTOM_MENU 环境变量指向此文件？"
    echo "  → 设置后，下次执行 qbase custom 将直接使用此文件，无需再次选择"
    while true; do
        read -r -p "请输入 (y/n): " yn
        case $yn in
            y|Y)
                # 添加环境变量 QBASE_CUSTOM_MENU
                QBASE_CUSTOM_MENU="${targetFile}"
                sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "QBASE_CUSTOM_MENU" -envVariableValue "${QBASE_CUSTOM_MENU}"
                if [ $? -ne 0 ]; then
                    echo "${RED}设置环境变量 QBASE_CUSTOM_MENU 失败，请检查。${NC}"
                    exit 2
                fi

                # 生效所有环境变量
                # echo "正在执行命令：《${BLUE} sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh ${NC}》"
                sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh
                if [ $? -ne 0 ]; then
                    echo "${RED}生效所有环境变量失败，请检查。${NC}"
                    exit 2
                fi
                echo "${GREEN}环境变量 QBASE_CUSTOM_MENU 已设置成功${NC}"
                return 0
                ;;
            n|N)
                echo ""
                echo "你可以稍后执行以下命令来手动设置："
                echo "  export QBASE_CUSTOM_MENU=${targetFile}"
                echo "也可将上述命令添加到 ~/.zshrc 中使其永久生效"
                exit 2
                ;;
            *)
                echo "请输入 y 或 n"
                ;;
        esac
    done
}


# 检查环境变量
checkEnvValue() {
    if [ -z "${QBASE_CUSTOM_MENU}" ]; then
        echo "${YELLOW}未检测到 QBASE_CUSTOM_MENU 环境变量${NC}"
        echo ""
        showCustomMenuJsonExample
        echo ""
        echo "请选择操作："
        echo ""
        echo "  1. 复制示例文件到当前目录"
        echo "     → 复制示例 custom_menu.json 到当前目录下"
        echo "     → 后续询问是否自动设置 QBASE_CUSTOM_MENU 环境变量"
        echo ""
        echo "  2. 手动输入已有 json 文件路径"
        echo "     → 输入你已准备好的 json 文件路径"
        echo "     → 后续询问是否自动设置 QBASE_CUSTOM_MENU 环境变量"
        echo ""
        echo "  3. 退出"
        echo "     → 不做任何操作，直接退出"
        echo ""

        while true; do
            read -r -p "请输入选项 (1/2/3): " option
            case $option in
                1)
                    handleCopyExampleToCurrentDir
                    if [ $? -eq 0 ]; then
                        return 0
                    fi
                    ;;
                2)
                    inputCustomJsonFilePath
                    if [ -n "${QBASE_CUSTOM_MENU}" ]; then
                        setupEnvVar "${QBASE_CUSTOM_MENU}"
                        return 0
                    fi
                    ;;
                3)
                    exit 2
                    ;;
                *)
                    echo "无效选项，请重新输入"
                    ;;
            esac
        done
    fi
}

result=$(checkEnvValue)
if [ $? -ne 0 ]; then
    echo "${result}"
    exit 2
fi


# echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file \"${QBASE_CUSTOM_MENU}\" -categoryType custom -execChoosed "true"》"
sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file "${QBASE_CUSTOM_MENU}" -categoryType "custom" -execChoosed "true"



