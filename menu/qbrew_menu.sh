#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-07 19:47:48
# @FilePath: qbrew_menu.sh
# @Description: 输出 qbrew 库中 qbase.json 、 qtool.json 的菜单，并可选择查看哪项的使用示例
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出
versionCmdStrings=("--version" "-version" "-v" "version")
qtoolQuickCmdStrings=("cz") # qtool 支持的快捷命令


# 工具选项
tool_menu() {
    qtool_menu_json_file_path=$1

    # 使用 jq 命令解析 JSON 数据并遍历
    catalogCount=$(cat "$qtool_menu_json_file_path" | jq '.quickCmd|length')
    # echo "catalogCount=${catalogCount}"
    for ((i = 0; i < ${catalogCount}; i++)); do
        iCatalogMap=$(cat "$qtool_menu_json_file_path" | jq ".quickCmd" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
        iCatalogOutlineMaps=$(echo "$iCatalogMap" | jq -r ".values")
        iCatalogOutlineCount=$(echo "$iCatalogOutlineMaps" | jq '.|length')
        if [ $i = 0 ]; then
            iCatalogColor=${BLUE}
        elif [ $i = 1 ]; then
            iCatalogColor=${PURPLE}
        elif [ $i = 2 ]; then
            iCatalogColor=${GREEN}
        elif [ $i = 3 ]; then
            iCatalogColor=${CYAN}
        elif [ $i = 4 ]; then
            iCatalogColor=${YELLOW}
        else
            iCatalogColor=${YELLOW}
        fi
        for ((j = 0; j < ${iCatalogOutlineCount}; j++)); do
            iCatalogOutlineMap=$(echo "$iCatalogOutlineMaps" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
            iCatalogOutlineName=$(echo "$iCatalogOutlineMap" | jq -r ".key")
            iCatalogOutlineDes=$(echo "$iCatalogOutlineMap" | jq -r ".des")
            
            iBranchOption="$((i + 1)).$((j + 1))|${iCatalogOutlineName}"
            printf "${iCatalogColor}%-50s%s${NC}\n" "${iBranchOption}" "$iCatalogOutlineDes" # 要拼接两个字符串，并在拼接的结果中，如果第一个字符串不够 15 位则自动补充空格到 15 位
        done
    done
}

evalActionByInput() {
    qtool_menu_json_file_path=$1

    # 读取用户输入的选项，并根据选项执行相应操作
    valid_option=false
    moreActionStrings=("qian" "chaoqian" "lichaoqian") # 输入哪些字符串算是想要退出
    while [ "$valid_option" = false ]; do
        read -r -p "请选择您想要查看的操作编号或id(若要退出请输入Q|q) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        # 定义菜单选项
        catalogCount=$(cat "$qtool_menu_json_file_path" | jq '.quickCmd|length')
        tCatalogOutlineMap=""
        for ((i = 0; i < ${catalogCount}; i++)); do
            iCatalogMap=$(cat "$qtool_menu_json_file_path" | jq ".quickCmd" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
            iCatalogOutlineMaps=$(echo "$iCatalogMap" | jq -r ".values")
            iCatalogOutlineCount=$(echo "$iCatalogOutlineMaps" | jq '.|length')
            hasFound=false
            for ((j = 0; j < ${iCatalogOutlineCount}; j++)); do
                iCatalogOutlineMap=$(echo "$iCatalogOutlineMaps" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
                iCatalogOutlineName=$(echo "$iCatalogOutlineMap" | jq -r ".key")

                iBranchOptionId="$((i + 1)).$((j + 1))"
                iBranchOptionName="${iCatalogOutlineName}"

                if [ "${option}" = ${iBranchOptionId} ] || [ "${option}" == ${iBranchOptionName} ]; then
                    tCatalogOutlineMap=$iCatalogOutlineMap
                    hasFound=true
                    break
                # else
                #     printf "${RED}%-4s%-25s${NC}不是想要找的%s\n" "${iBranchOptionId}" "$iBranchOptionName" "${option}"
                fi
            done
            if [ ${hasFound} == true ]; then
                break
            fi
        done

        if [ -n "${tCatalogOutlineMap}" ]; then
            tCatalogOutlineKey=$(echo "$tCatalogOutlineMap" | jq -r ".key")
            tCatalogOutlineAction=$(echo "$tCatalogOutlineMap" | jq -r ".example")
            relpath=$(echo "$tCatalogOutlineMap" | jq -r ".rel_path")
            if [ -z "${relpath}" ] || [ "${relpath}" == "null" ]; then
                echo "${RED}Error:您的 ${map} 缺失描述脚本相对位置的 rel_path 属性值。请检查 ${NC}"
                # cat "$qpackageJsonF" | jq '.quickCmd'
                # cat "$qpackageJsonF" | jq '.'
                exit 1
            fi
            relpath="${relpath//.\//}"  # 去掉开头的 "./"
            quickCmd_script_path="$qpackage_homedir_abspath/$relpath"
            if [ ! -f "$quickCmd_script_path" ]; then
                echo "Error:您的json路径配置出错了，请检查。"
                return 1
            fi

            # echo "您正在调用《 sh ${quickCmd_script_path} --help 》"
            printf "${CYAN}【${BLUE}%s${CYAN}】使用示例：\n${NC}" "${tCatalogOutlineKey}"    # printf 的正确换行
            sh ${quickCmd_script_path} "--help"
            if [ $? != 0 ]; then
                printf "${PURPLE} %s\n${NC}" "${tCatalogOutlineAction}"    # printf 的正确换行
                return 0
            fi            
        else
            printf "${YELLOW}%s\n${NC}" "此选项，无使用示例。你可选择查看其他选项的使用示例。\n"
            # exit 1
        fi
    done
}

# 显示工具选项
qbrew_json_file_path=$1
# qpackage__name=$(basename "${qbrew_json_file_path}")
qpackage_homedir_abspath=$(dirname "${qbrew_json_file_path}")
tool_menu "${qbrew_json_file_path}"

# 开始选择
evalActionByInput "${qbrew_json_file_path}"
# chooseResult=$(evalActionByInput "${qbrew_json_file_path}")
# if [ $? != 0 ]; then
#     printf "${YELLOW}%s\n${NC}" "此选项，无使用示例。你可选择查看其他选项的使用示例。\n"
#     exit 1
# fi
# echo "${CYAN}使用示例:${PURPLE} ${chooseResult} ${NC}"

# 退出程序
exit 0
