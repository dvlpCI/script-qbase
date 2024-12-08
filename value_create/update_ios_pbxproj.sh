#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-03-20 17:53:45
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-08 17:18:42
 # @Description: 对 project.pbxproj 更新版本号、build号、app展示名
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
    printf "${BLUE}%s${NC}\n" "对 project.pbxproj 更新版本号、build号、app展示名"
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
        -pbxproj|--pbxproj-path)
            # 知识点：如果 get_argument "$1" "$2" 返回失败（非零退出码），那么 handle_error "$1" 会被执行。
            pbxprojPath=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2 # 知识点：这里不能和 REBASE_BRANCH 同一行，否则会出如果执行脚本脚本卡住
            ;;
        -ver|--version) 
            VERSION=$(get_argument "$1" "$2") || handle_error "$1" 
            shift 2;;
        -bid|--buildId) 
            BUILD=$(get_argument "$1" "$2") || handle_error "$1" 
            shift 2;;
        -appNameOld|--appNameOld) 
            appNameOld=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2;;
        -appNameNew|--appNameNew) 
            appNameNew=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2;;
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
            echo "${RED}Error: Too many arguments provided. 多提供了【$1】${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# 脚本主逻辑
[ "$verbose" = "true" ] && echo "${GREEN}Verbose mode is on.${NC}"

# exit 0



# echo "------pbxprojPath=$pbxprojPath"
# echo "------VERSION:${VERSION}"
# echo "------BUILD:${BUILD}"
# echo "------appNameOld=$appNameOld appNameNew=$appNameNew"


# 检查文件是否存在
if [ ! -f "$pbxprojPath" ]; then
    echo "Error: File $pbxprojPath not found!"
    exit 1
fi

if [ -n "$appNameOld" ]; then
    if [ -z "$appNameNew" ]; then
        echo "${RED}Error: 如果要修改app展示名，则新名字和旧名字都必须告知，而不能用 pbxproj 中的 INFOPLIST_KEY_CFBundleDisplayName 属性，因为他可能是不同项目的。${NC}"
        show_usage
        exit 1
    fi
fi

# #替换Version
if [ -n "$VERSION" ]; then
    # 所有仅由数字和点号构成 的字符串，包括各种可能的格式（例如：1、1.0、1.2.3、12.1.0.03）
    # 1.	[0-9]：匹配至少一个数字，确保版本号以数字开头。
    # 2.    [0-9.]*：匹配零个或多个数字或点号，允许版本号中包含多个点号和数字组合。
    # 3.	;：确保只替换以分号结尾的语句。
    sed -i '' "s/MARKETING_VERSION = [0-9][0-9.]*;/MARKETING_VERSION = ${VERSION};/g" "$pbxprojPath"
    if [ $? -eq 0 ]; then
        echo "✅ MARKETING_VERSION updated to${BLUE} ${VERSION} ${NC}in $pbxprojPath"
    else
        echo "❌ Failed to update MARKETING_VERSION"
        exit 1
    fi
fi

# 替换Build号
if [ -n "$BUILD" ]; then
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = ${BUILD}/g" $pbxprojPath
    if [ $? -eq 0 ]; then
        echo "✅ CURRENT_PROJECT_VERSION updated to${BLUE} ${BUILD} ${NC}in $pbxprojPath"
    else
        echo "❌ Failed to update CURRENT_PROJECT_VERSION"
        exit 1
    fi
fi

# 修改app展示名
if [ -n "$appNameOld" ] && [ -n "$appNameNew" ]; then
    # 增加 "INFOPLIST_KEY_CFBundleDisplayName = "前缀，确保只替换以该前缀开头的语句
    appNameOldLine="INFOPLIST_KEY_CFBundleDisplayName = ${appNameOld}"
    appNameNewLine="INFOPLIST_KEY_CFBundleDisplayName = ${appNameNew}"
    sed -i '' "s/${appNameOldLine}/${appNameNewLine}/g" $pbxprojPath
    if [ $? -eq 0 ]; then
        echo "✅ ${appNameOld} updated to${BLUE} ${appNameNew} ${NC}in $pbxprojPath"
    else
        echo "❌ Failed to update ${appNameOld}"
        exit 1
    fi
fi