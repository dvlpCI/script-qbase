#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2024-12-08 03:08:01
 # @LastEditors: dvlproad
 # @LastEditTime: 2024-12-08 13:42:04
 # @Description: 
### 
#!/bin/bash

# shell 的 在指定文件中，将符合指定规则的字符串（这是一个字符串），则从匹配到的位置开始将该行替换成新的字符串，而该行该字符串之前的保留不变。
# 即我传入要匹配的字符串 static var networkType = PackageNetworkType.
# 并传入希望改为的字符串  static var networkType = PackageNetworkType.new
# 则对以下内容
# class HHH {
#       static var networkType = PackageNetworkType.product
# }
# 执行后会变成
# class HHH {
#       static var networkType = PackageNetworkType.new
# }


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
    printf "${BLUE}%s${NC}\n" "对指定文件中匹配的指定字符串的所有行,从匹配到的位置开始将该行替换成新的字符串。"
    printf "${BLUE}%s${NC}\n" "使用场景：对代码文件进行环境修改。"
    printf "${YELLOW}%s${PURPLE}\n" "sh xx.sh -file xxx/yy.dart -matchString \"static var networkType = PackageNetworkType.\" -newString \"static var networkType = PackageNetworkType.test1\""
    printf "%-20s %s\n" "Options:" ""
    printf "%-30s %s\n" "-v|--verbose" "Enable verbose mode"
    printf "%-30s %s\n" "-h|--help" "Display this help and exit"
    printf "%-30s %s\n" "-file|--file-path" "必填：要修改的文件路径"
    printf "%-30s %s\n" "-matchString|--matchString" "必填：匹配的字符串"
    printf "%-30s %s\n" "-newString|--newString" "必填：要替换成什么新字符串"
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


# # 解析具名参数
# while [[ "$#" -gt 0 ]]; do
#     case $1 in
#         --filePath) filePath="$2"; shift ;;
#         --matchString) matchString="$2"; shift ;;
#         --newString) newString="$2"; shift ;;
#         *) echo "Unknown parameter passed: $1"; exit 1 ;;
#     esac
#     shift
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
        -file|--file-path)
            # 知识点：如果 get_argument "$1" "$2" 返回失败（非零退出码），那么 handle_error "$1" 会被执行。
            filePath=$(get_argument "$1" "$2") || handle_error "$1"
            shift 2 # 知识点：这里不能和 REBASE_BRANCH 同一行，否则会出如果执行脚本脚本卡住
            ;;
        -matchString|--matchString) 
            matchString=$(get_argument "$1" "$2") || handle_error "$1" 
            shift 2;;
        -newString|--newString) 
            newString=$(get_argument "$1" "$2") || handle_error "$1" 
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
            echo "${RED}Error: Too many arguments provided.${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# 脚本主逻辑
[ "$verbose" = "true" ] && echo "${GREEN}Verbose mode is on.${NC}"

# exit 0


# 输出参数确认
# echo "File Path: $filePath"
# echo "Target String: $matchString"
# echo "New String: $newString"
# 参数校验
if [[ -z "$filePath" || -z "$matchString" || -z "$newString" ]]; then
    echo "Usage: $0 --filePath <path> --matchString <string> --newString <string>"
    exit 1
fi

# 替换逻辑
escapedTargetString=$(echo "$matchString" | sed 's/[.[\*^$(){}?+|]/\\&/g') # 转义特殊字符
escapedNewString=$(echo "$newString" | sed 's/[&/\]/\\&/g')                  # 转义特殊字符
# 1.	保留前缀：
# •	正则表达式 \(.*\) 捕获目标字符串之前的所有字符。
# 2.	精确匹配目标字符串：
# •	使用 sed 将 $matchString 转义后匹配。
# •	匹配内容包括 $matchString 和其后续内容。
# 3.	替换后半部分：
# •	保留捕获的前缀部分，并将目标字符串和其后续内容替换为 $newString。
sed -i '' -e "s/\(.*\)$escapedTargetString.*/\1$escapedNewString/" "$filePath"
if [ $? != 0 ]; then
    echo "❌ ${RED}替换${BLUE} ${filePath} ${RED}中${BLUE} ${matchString} ${RED}为${BLUE} ${newString} ${RED}失败${NC}"
    exit 1
fi
echo "✅ ${GREEN}替换${BLUE} ${filePath} ${GREEN}中${BLUE} ${matchString} ${GREEN}为${BLUE} ${newString} ${GREEN}成功${NC}"