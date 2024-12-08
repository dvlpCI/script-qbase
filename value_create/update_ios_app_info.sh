#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-03-20 17:53:45
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-08 18:38:42
 # @Description: 更新指定文件里指定的ios项目及其环境（版本号、build号、app展示名、代码环境）
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用 %/* 方法可以避免路径上有..


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
    printf "${BLUE}%s${NC}\n" "更新指定文件里指定的ios项目及其环境（版本号、build号、app展示名、代码环境）"
    printf "${YELLOW}%s${PURPLE}\n" "sh xx.sh -pbxproj xxx/Beyond.xcodeproj/project.pbxproj -ver 1.7.3 -bid 24010809 -appNameOld Beyond -appNameNew Beyond开发版"
    printf "%-20s %s\n" "Options:" ""
    printf "%-30s %s\n" "-v|--verbose" "Enable verbose mode"
    printf "%-30s %s\n" "-h|--help" "Display this help and exit"
    printf "%-30s %s\n" "-pbxproj|--pbxproj-path" "必填：要修改的 pbxproj 文件路径"
    printf "%-30s %s\n" "-ver|--version" "可选：新的版本号"
    printf "%-30s %s\n" "-bid|--buildId" "可选:新的build号"
    printf "%-30s %s\n" "-appNameOld|--appNameOld" "可选?必填?:旧的app展示名,当要修改展示名时必填"
    printf "%-30s %s\n" "-appNameNew|--appNameNew" "可选:新的app展示名"
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

# while [ -n "$1" ]
# do
#         case "$1" in
#                 -pbxproj|--pbxproj-path) pbxprojPath=$2; shift 2;;
#                 -ver|--version) VERSION=$2; shift 2;;
#                 -bid|--buildId) BUILD=$2; shift 2;;
#                 -appNameOld|--appNameOld) appNameOld=$2; shift 2;;
#                 -appNameNew|--appNameNew) appNameNew=$2; shift 2;;
#                 --) break ;;
#                 *) echo $1,$2,$show_usage; break ;;
#         esac
# done

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
        -app|--app-params)
            # 知识点：如果 get_argument "$1" "$2" 返回失败（非零退出码），那么 handle_error "$1" 会被执行。
            appInfoParamJsonFile_absPath=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2 # 知识点：这里不能和 REBASE_BRANCH 同一行，否则会出如果执行脚本脚本卡住
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

# 脚本主逻辑
[ "$verbose" = "true" ] && echo "${GREEN}Verbose mode is on.${NC}"

# exit 0



# echo "------appInfoParamJsonFile_absPath=$appInfoParamJsonFile_absPath"


# 检查文件是否存在
if [ ! -f "$appInfoParamJsonFile_absPath" ]; then
    echo "${RED}Error: 你要更新的ios项目及其环境所在的${BLUE} $appInfoParamJsonFile_absPath ${RED}不存在!，请检查${NC}"
    exit 1
fi
jsonDir_absPath="$( cd "$( dirname "$appInfoParamJsonFile_absPath" )" && pwd )"



# 对 project.pbxproj 更新版本号、build号、app展示名
pbxproj_relPath=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.pbxproj_path_rel_this_dir')
pbxproj_absPath=$(realpath "$jsonDir_absPath/$pbxproj_relPath") # 拼接相对路径为完整路径并转换为绝对路径
if [ ! -f "$pbxproj_absPath" ]; then
    echo "Error: File $pbxproj_absPath not found!，请检查 ${appInfoParamJsonFile_absPath} 中的 pbxproj_path_rel_this_dir 值是否正确"
    exit 1
fi
VERSION=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.version')
BUILD=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.buildNumber')
appNameOld=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.app_display_name_old')
appNameNew=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.app_display_name_new')
# echo "------pbxproj_absPath= $pbxproj_absPath"
# echo "------VERSION:${VERSION}"
# echo "------BUILD:${BUILD}"
# echo "------appNameOld=$appNameOld"
# echo "------appNameNew=$appNameNew"
resultString=$(sh ${CurrentDIR_Script_Absolute}/update_ios_pbxproj.sh -pbxproj "${pbxproj_absPath}" -ver "${VERSION}" -bid "${BUILD}" -appNameOld "${appNameOld}" -appNameNew "${appNameNew}")
if [ $? -ne 0 ]; then
    echo "${resultString}"
    exit 1
fi


# 修改代码文件的环境：网络（有时候还要修改平台：appstore、adhoc、pgyer）
codeFilePath_relPath=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.env_file_path_rel_this_dir')
codeFilePath_absPath=$(realpath "$jsonDir_absPath/$codeFilePath_relPath")
if [ ! -f "$codeFilePath_absPath" ]; then
    echo "Error: File $codeFilePath_absPath not found!，请检查 ${appInfoParamJsonFile_absPath} 中的 env_file_path_rel_this_dir 值是否正确"
    exit 1
fi
# echo "------codeFilePath_absPath= $codeFilePath_absPath"
# 2.1、修改代码文件的环境：网络
network_matchString=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.env_network_match_string')
network_newString=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.env_network_new_string')
# echo "------network_matchString=$network_matchString"
# echo "------network_newString=$network_newString"
resultString=$(sh ${CurrentDIR_Script_Absolute}/update_line_that_match_text.sh -file "${codeFilePath_absPath}" -matchString "${network_matchString}" -newString "${network_newString}")
if [ $? -ne 0 ]; then
    echo "${resultString}"
    exit 1
fi

# 2.2、修改代码文件的环境：平台，打出来的包传到哪
uploadplatform_matchString=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.env_uploadplatform_match_string')
uploadplatform_newString=$(cat "$appInfoParamJsonFile_absPath" | jq -r '.env_uploadplatform_new_string')
# echo "------uploadplatform_matchString=$uploadplatform_matchString"
# echo "------uploadplatform_newString=$uploadplatform_newString"
if [ -n "$uploadplatform_matchString" ] && [ -n "$uploadplatform_newString" ]; then
    resultString=$(sh ${CurrentDIR_Script_Absolute}/update_line_that_match_text.sh -file "${codeFilePath_absPath}" -matchString "${uploadplatform_matchString}" -newString "${uploadplatform_newString}")
    if [ $? -ne 0 ]; then
        echo "${resultString}"
        exit 1
    fi
fi