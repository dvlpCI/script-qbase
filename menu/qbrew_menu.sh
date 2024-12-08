#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-08 22:01:11
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


# 使用说明函数
show_usage() {
    printf "${BLUE}%s${NC}\n" "对指定文件中的脚本进行选择,进行案例输出或者直接执行。"
    printf "${BLUE}%s${NC}\n" "使用场景：①系统脚本的示例演示;②自定义菜单中的命令的直接执行。"
    printf "${YELLOW}%s${PURPLE}\n" "sh xxx.sh -file qbase.json -categoryType support_script_path execIt"
    # printf "%-20s %s\n" "Usage:" "$0 [options] [arguments]" # 本脚本路径
    # printf "%-20s %s\n" "Options:" ""
    # printf "%-50s %s\n" "-v|--verbose" "Enable verbose mode"
    # printf "%-50s %s\n" "-h|--help" "Display this help and exit"
    # printf "%-50s %s\n" "-categoryData|--categoryData" "必填：菜单数据"
    # printf "%-50s %s\n" "-relPath-baseDirPath|--relPath-baseDirPath" "可选?：菜单中的脚本相对的是哪个目录"
    printf "%-50s %s\n" "-file|--file-path" "必填：对哪个json文件进行操作"
    printf "%-50s %s\n" "-categoryType|--categoryType" "可选?：对该文件的哪个分类进行操作"
    printf "%-50s %s\n" "-execChoosed|--execChoosed" "可选：是否直接执行选中的命令，true:是"
    # printf "%-20s %s\n" "Arguments:" ""
    # printf "%-20s %s\n" "file" "Input file path"
    # printf "%-20s %s\n" "output" "Output file path"
    printf "${NC}"
}


# 获取参数值的函数
get_argument() {
    option="$1"
    value="$2"

    # 检查参数是否为空或是选项
    if [ -z "$value" ] || [ "${value#-}" != "$value" ]; then
        echo "${RED}Error: Argument for $option is missing${NC}"
        return 1 # 返回错误状态
    fi
    echo "$value"
    return 0
}
# 定义错误处理函数
handle_error() {
    local option="$1"
    echo "${RED}Error:您指定了以下参数，却漏了为其复制，请检查${YELLOW} ${option} ${RED}${NC}"
    exit 1
}


# qbrew_json_file_path=$1
# qbrew_categoryType=$2         # 动态指定字段名  "quickCmd" 

# 处理具名参数
while [ "$#" -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            verbose="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -file|--file-path)
            # 知识点：如果 get_argument "$1" "$2" 返回失败（非零退出码），那么 handle_error "$1" 会被执行。
            qbrew_json_file_path=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2 # 知识点：这里不能和 REBASE_BRANCH 同一行，否则会出如果执行脚本脚本卡住
            ;;
        -categoryType|--categoryType)
            qbrew_categoryType=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2
            ;;
        # -categoryData|--categoryData)
        #     # 知识点：如果 get_argument "$1" "$2" 返回失败（非零退出码），那么 handle_error "$1" 会被执行。
        #     categoryData=$(get_argument "$1" "$2") || handle_error "$1"
        #     shift 2 # 知识点：这里不能和 REBASE_BRANCH 同一行，否则会出如果执行脚本脚本卡住
        #     ;;
        # -relPath-baseDirPath|--relPath-baseDirPath)
        #     relPath_baseDirPath=$(get_argument "$1" "$2") || handle_error "$1"
        #     ;;
        -execChoosed|--execChoosed)
            execChoosed=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2
            ;;
        --) # 结束解析具名参数
            shift
            break
            ;;
        -*)
            echo "${RED}Error: Invalid option $1${NC}"
            show_usage
            exit 1
            ;;
        *) # 普通参数
            echo "${RED}Error: Too many arguments provided.${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# 检查是否提供了必要的参数
# if [ -z "$file" ] || [ -z "$output" ]; then
#     echo "${RED}Error: Missing required arguments.${NC}"
#     show_usage
#     exit 1
# fi

# 脚本主逻辑
[ "$verbose" = "true" ] && echo "${GREEN}Verbose mode is on.${NC}"

# exit 0



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
    categoryData=$1

    # 使用 jq 命令解析 JSON 数据并遍历
    # catalog_count=$(jq ".${qbrew_categoryType} | length" "$qtool_menu_json_file_path")    # 使用 jq 提取动态字段的值
    catalogCount=$(echo "$categoryData" | jq "length")
    # echo "catalogCount=${catalogCount}"
    for ((i = 0; i < ${catalogCount}; i++)); do
        iCatalogMap=$(echo "$categoryData" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
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
    categoryData=$1

    # 读取用户输入的选项，并根据选项执行相应操作
    valid_option=false
    moreActionStrings=("qian" "chaoqian" "lichaoqian") # 输入哪些字符串算是想要退出
    while [ "$valid_option" = false ]; do
        read -r -p "请选择您想要查看的操作编号或id(若要退出请输入Q|q) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        # 定义菜单选项
        catalogCount=$(echo "$categoryData" | jq "length")
        tCatalogOutlineMap=""
        for ((i = 0; i < ${catalogCount}; i++)); do
            iCatalogMap=$(echo "$categoryData" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
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

        deal_for_choose ""
        
    done
}

deal_for_choose() {
    if [ -n "${execChoosed}" ] && [ "${execChoosed}" == "true" ]; then
        tCatalogOutlineCommand=$(echo "$tCatalogOutlineMap" | jq -r ".command")
        echo "${RED}您正在终端直接执行以下完整命令>>>>>>>>>>>【${BLUE} ${tCatalogOutlineCommand} ${RED}】<<<<<<<<<<<<<${NC}"
        eval "${tCatalogOutlineCommand}"
    else
        show_usage_for_choose
    fi
    
}

# 显示选中的脚本的使用方法
show_usage_for_choose() {
    # 选中 menu 的 rel_path 指向的脚本文件后，执行该脚本的 --help 命令输出该脚本的使用备注。
    # 如果有 --help 命令，则输出该脚本文件的使用方法。输出方法后，如果还存在该脚本的使用示例，即在example目录下存在_example.sh，则可以选择是否执行该示例，来演示脚本的使用。
    # 如果没有 --help 命令，则输出该脚本文件的 .example 使用示例方法。
    if [ -z "${tCatalogOutlineMap}" ]; then
        printf "${YELLOW}%s\n${NC}" "此选项，无使用示例。你可选择查看其他选项的使用示例。\n"
        return 1
    fi

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
    quickCmd_script_path=$(realpath "${relPath_baseDirPath}/$relpath") # 拼接相对路径为完整路径并转换为绝对路径
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
}

# 显示工具选项
# qpackage__name=$(basename "${qbrew_json_file_path}")
relPath_baseDirPath=$(dirname "${qbrew_json_file_path}")

# 读取 JSON 文件并提取指定部分的内容
categoryData=$(cat "$qbrew_json_file_path" | jq ".${qbrew_categoryType}")
# categoryData=$(jq ".${qbrew_categoryType}" "$qtool_menu_json_file_path")


tool_menu "${categoryData}"

# 开始选择
evalActionByInput "${categoryData}"
# chooseResult=$(evalActionByInput "${qbrew_json_file_path}")
# if [ $? != 0 ]; then
#     printf "${YELLOW}%s\n${NC}" "此选项，无使用示例。你可选择查看其他选项的使用示例。\n"
#     exit 1
# fi
# echo "${CYAN}使用示例:${PURPLE} ${chooseResult} ${NC}"

# 退出程序
exit 0
