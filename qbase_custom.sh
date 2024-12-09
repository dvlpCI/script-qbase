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




# 检查环境变量
checkEnvValue() {
    if [ -z "${QBASE_CUSTOM_MENU}" ]; then
        # 输入要添加的环境变量的值
        echo "${YELLOW}请先在环境变量中设置${BLUE} QBASE_CUSTOM_MENU ${YELLOW}变量，并为其指向你要执行的自定义命令菜单的json文件路径。${NC}"
        inputCustomJsonFilePath

        # 添加环境变量 QBASE_CUSTOM_MENU
        sh $qbase_homedir_abspath/env_variables/env_var_add_or_update.sh -envVariableKey "QBASE_CUSTOM_MENU" -envVariableValue "${QBASE_CUSTOM_MENU}"
        if [ $? -ne 0 ]; then
            echo "设置环境变量 QBASE_CUSTOM_MENU 失败，请检查。"
            exit 2
        fi

        # 生效所有环境变量
        echo "正在执行命令：《${BLUE} sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh ${NC}》"
        sh $qbase_homedir_abspath/env_variables/env_var_effective_or_open.sh
        if [ $? -ne 0 ]; then
            echo "生效所有环境变量失败，请检查。"
            exit 2
        fi
    fi
}

checkEnvValue




        

# echo "正在通过qbase调用快捷命令...《 sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file ${qpackageJsonF} -categoryType quickCmd -execChoosed "true"》"

# sh $qbase_homedir_abspath/menu/qbrew_menu.sh -file ${QBASE_CUSTOM_MENU} -categoryType "quickCmd" -execChoosed "true"



