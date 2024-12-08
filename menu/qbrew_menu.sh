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


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..

qbase_execScript_by_configJsonFile_scriptPath=$qbase_homedir_abspath/pythonModuleSrc/dealScript_by_scriptConfig.py

# 生成随机 RGB 颜色并转换为 ANSI 颜色码
generate_random_color() {
    red=$((RANDOM % 256))   # 随机生成 0-255 的红色分量
    green=$((RANDOM % 256)) # 随机生成 0-255 的绿色分量
    blue=$((RANDOM % 256))  # 随机生成 0-255 的蓝色分量

    # 输出 ANSI 转义序列：\033[38;2;R;G;Bm
    printf "\033[38;2;%d;%d;%dm" "$red" "$green" "$blue"
}

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出
versionCmdStrings=("--version" "-version" "-v" "version")
qtoolQuickCmdStrings=("cz") # qtool 支持的快捷命令


# 工具选项
tool_menu() {
    qtool_menu_json_file_path=$1

    # 使用 jq 命令解析 JSON 数据并遍历
    # catalog_count=$(jq ".${qbrew_categoryType} | length" "$qtool_menu_json_file_path")    # 使用 jq 提取动态字段的值
    catalogCount=$(cat "$qtool_menu_json_file_path" | jq ".${qbrew_categoryType}|length")
    # echo "catalogCount=${catalogCount}"
    for ((i = 0; i < ${catalogCount}; i++)); do
        iCatalogMap=$(cat "$qtool_menu_json_file_path" | jq ".${qbrew_categoryType}" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
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
            iCatalogColor=$(generate_random_color)
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
        catalogCount=$(cat "$qtool_menu_json_file_path" | jq ".${qbrew_categoryType}|length")
        tCatalogOutlineMap=""
        for ((i = 0; i < ${catalogCount}; i++)); do
            iCatalogMap=$(cat "$qtool_menu_json_file_path" | jq ".${qbrew_categoryType}" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
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
            if [ -z "${tCatalogOutlineAction}" ] || [ "${tCatalogOutlineAction}" == "null" ]; then
                tCatalogOutlineAction="暂时没有 ${tCatalogOutlineKey} 的演示示例"
            fi
            relpath=$(echo "$tCatalogOutlineMap" | jq -r ".rel_path")
            if [ -z "${relpath}" ] || [ "${relpath}" == "null" ]; then
                echo "${RED}Error:您的 ${tCatalogOutlineMap} 缺失描述脚本相对位置的 rel_path 属性值。请检查 ${NC}"
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
            
            # helpString=$(sh ${quickCmd_script_path} --help 2>&1)
            helpString=$(sh ${quickCmd_script_path} --help)
            if [ $? != 0 ] || [ -z "${helpString}" ]; then
                printf "${PURPLE} %s\n${NC}" "${tCatalogOutlineAction}"    # printf 的正确换行
                return 0
            fi
            echo "${helpString}"

            quickCmd_script_dir_path=$(dirname "$quickCmd_script_path")
            quickCmd_script_file_name=$(basename "$relpath")
            quickCmd_script_file_name_no_ext="${quickCmd_script_file_name%.*}"
            input_params_from_file_path="$quickCmd_script_dir_path/example/${quickCmd_script_file_name_no_ext}_example.json"
            if [ ! -f "$input_params_from_file_path" ]; then
                printf "${PURPLE} %s\n${NC}" "${tCatalogOutlineAction}"    # printf 的正确换行
                return 0
            else
                printf "${PURPLE} %s\n${NC}" "${tCatalogOutlineAction}"    # printf 的正确换行
                while [ "$valid_option" = false ]; do
                    read -r -p "本脚本提供演示示例，若要演示请输入yes|YES|y|Y : " exec_demo_option

                    if [ "${exec_demo_option}" == yes ] || [ "${exec_demo_option}" == "YES" ]; then
                        # echo "${CYAN}======================正在使用${BLUE} ${qbase_execScript_by_configJsonFile_scriptPath} ${CYAN}执行${BLUE} ${input_params_from_file_path} ${CYAN}======================${NC}"
                        python3 $qbase_execScript_by_configJsonFile_scriptPath $input_params_from_file_path
                        printf "\n"
                        break
                    else
                        # 非 yes 等全部视为不执行
                        break
                    fi
                done
            fi

            # 尝试执行脚本的 --help 命令
            # help_output=$("$quickCmd_script_path" --help 2>&1)
            # if echo "$help_output" | grep -q "Usage\|help"; then
            #     echo "The script supports '--help' command and outputs help information."
            # else
            #     echo "The script does not output help information with '--help' command."
            # fi

            # if ! grep -q -- '--help' "$quickCmd_script_path"; then   # 检查是否不包含 "--help"
            #     printf "${PURPLE} %s\n${NC}" "${tCatalogOutlineAction}"    # printf 的正确换行
            #     return 0
            # else
            #     a=$(sh ${quickCmd_script_path} "--help")
            #     if [ $? != 0 ]; then
            #         printf "${PURPLE} %s\n${NC}" "${tCatalogOutlineAction}"    # printf 的正确换行
            #         return 0
            #     fi
            # fi
        else
            printf "${YELLOW}%s\n${NC}" "此选项，无使用示例。你可选择查看其他选项的使用示例。\n"
            # exit 1
        fi
    done
}

# 显示工具选项
qbrew_json_file_path=$1
qbrew_categoryType=$2         # 动态指定字段名  "quickCmd" 
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
