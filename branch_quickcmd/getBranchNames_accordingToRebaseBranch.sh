#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-17 21:43:34
# @Description: 根据 rebase 分支，获取当前分支所含的所有分支名
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
    # printf "${BLUE}%s${NC}\n" "对指定文件中匹配的指定字符串的所有行,从匹配到的位置开始将该行替换成新的字符串。"
    # printf "${BLUE}%s${NC}\n" "使用场景：对代码文件进行环境修改。"
    printf "${YELLOW}%s${PURPLE}\n" "qbase -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch \"master\" --add-value 1 -onlyName true --verbose"
    printf "%-20s %s\n" "Options:" ""
    printf "%-30s %s\n" "-v|--verbose" "Enable verbose mode"
    printf "%-30s %s\n" "-h|--help" "Display this help and exit"
    printf "%-30s %s\n" "-rebaseBranch|--rebase-branch" "必填：要reabase的分支名"
    printf "%-30s %s\n" "-addValue|--add-value" "可选；要增减的时间秒数(支持正负值)"
    printf "%-30s %s\n" "-onlyName|--only-name" "可选；名字是否只取最后部分，不为true时候为全名"
    # printf "%-20s %s\n" "Arguments:" ""
    # printf "%-20s %s\n" "file" "Input file path"
    # printf "%-20s %s\n" "output" "Output file path"
    printf "${NC}"
}

# --------------------- 的 ---------------------
# qian_log 函数
qian_log() {
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2
    fi
}

# --------------------- 具名参数值的解析和获取函数 ---------------------
# 获取具名参数的值（不允许以 - 开头）
# 用法：get_named_arg_value "$1" "$2" "参数名"
# 返回值：0=成功，1=参数缺失，2=参数为空，3=参数以-开头
# 输出：成功时输出参数值，失败时输出具体原因（不含 Error: 前缀）
get_named_arg_value() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    # 条件1：没有第2个参数
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    
    # 条件2：第2个参数为空字符串
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    
    # 条件3：第2个参数以 - 开头（是选项）
    if [[ "$val" =~ ^- ]]; then
        printf "%s 的 %s 不能以 '-' 开头: %s" "$opt" "$arg_name" "$val"
        return 3
    fi
    
    # 正常情况：输出值，返回0
    printf "%s" "$val"
    return 0
}

# 获取具名参数的值（允许以 - 开头）
# 用法：get_named_arg_dashValue "$1" "$2" "参数名"
# 返回值：0=成功，1=参数缺失，2=参数为空
# 输出：成功时输出参数值，失败时输出具体原因（不含 Error: 前缀）
get_named_arg_dashValue() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    # 条件1：没有第2个参数
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    
    # 条件2：第2个参数为空字符串
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    
    # 正常情况：输出值，返回0
    printf "%s" "$val"
    return 0
}

# 定义错误处理函数
handle_named_arg_error() {
    local option="$1"
    echo "${RED}Error: 您为参数${YELLOW} ${option} ${RED}指定了值，但该值不符合要求或为空，请检查是否在 ${option} 后提供了正确的值${NC}"
    exit 1
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
    echo "${RED}Error: 您为参数 ${YELLOW}${option}${RED} 指定了值，但该值不符合要求或为空，请检查是否在 ${option} 后提供了正确的值${NC}"
    exit 1
}


# ==================== 默认值设置 ====================
QBASE_CMD="qbase"  # 默认值（当用户不传这个参数时使用）
CONTAINS_VERSION=false  # 是否是打印版本号后就结束任务
DEFINE_QIAN=false
CONTAINS_VERBOSE=false
CONTAINS_HELP=false
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
        -rebaseBranch|--rebase-branch)
            # 知识点：如果 get_argument "$1" "$2" 返回失败（非零退出码），那么 handle_error "$1" 会被执行。
            REBASE_BRANCH=$(get_named_arg_value "$1" "$2") || handle_named_arg_error "$1"
            shift 2 # 知识点：这里不能和 REBASE_BRANCH 同一行，否则会出如果执行脚本脚本卡住
            ;;
        # 注意：-addValue 参数值允许为负数（如 -100000），不能使用通用的 get_argument 函数
        # 因为 get_argument 会把以 - 开头的值误判为新选项，导致解析失败
        -addValue|--add-value) 
            add_value=$(get_named_arg_dashValue "$1" "$2") || handle_named_arg_error "$1"
            shift 2;;
        -onlyName|--only-name) 
            VALUE=$(get_named_arg_value "$1" "$2")
            if [ $? -eq 0 ] && [ "$VALUE" = "true" ]; then
                ONLY_NAME="true"
                shift 2
            else
                ONLY_NAME="false"
                shift
            fi
            ;;
        --qian|-qian|-lichaoqian|-chaoqian)
            DEFINE_QIAN=true
            shift 1
            ;;
        --verbose|-v)
            CONTAINS_VERBOSE=true
            shift 1
            ;;
        --help|-h)
            CONTAINS_HELP=true
            shift 1
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
            if [ -z "$file" ]; then
                file="$1"
            elif [ -z "$output" ]; then
                output="$1"
            else
                echo "${RED}Error: Too many arguments provided.${NC}"
                show_usage
                exit 1
            fi
            shift
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



CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_rebasebranch_last_commit_date_scriptPath=${qbase_homedir_abspath}/branch/rebasebranch_last_commit_date.sh
qbase_calculate_newdate_scriptPath=${qbase_homedir_abspath}/date/calculate_newdate.sh
qbase_get_merger_recods_after_date_scriptPath=${qbase_homedir_abspath}/branch/get_merger_recods_after_date.sh


# 计算倒数第一个参数的位置
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
    if [ $argCount -ge 2 ]; then
        second_last_index=$((argCount - 1))
        second_last_arg=${!second_last_index} # 获取倒数第二个参数
    fi
fi
# echo "========second_last_arg=${second_last_arg}"
# echo "========       last_arg=${last_arg}"

verboseStrings=("verbose" "-verbose" "--verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if [[ " ${verboseStrings[*]} " == *" $last_arg "* ]]; then
    # echo "verbose✅:${last_arg}"
    verbose=true
else # 最后一个元素不是 verbose
    # echo "verbose❌:${last_arg}"
    verbose=false
fi


function _verbose_log() {
    if [ "$verbose" == true ]; then
        echo "$1"
    fi
}



# 优化分支名(对origin/optimize/a，去除origin/)
function optimizeBranchNames() {
    p_branchNamesString=($1)
    num=${#p_branchNamesString[@]}
    #echo "${p_branchNamesString[*]}"
    #echo "num=$num"
        
    for ((i=0;i<num;i+=1))
    {
        fullBranchName=${p_branchNamesString[i]}
        #echo "$((i+1)) fullBranchName=${fullBranchName}"
        if [[ $fullBranchName == origin/* ]]; then
            fullBranchName=${fullBranchName#origin/}
        fi

        if [ -n "$ONLY_NAME" ] && [ "$ONLY_NAME" == true ]; then
            fullBranchName=${fullBranchName##*/} # 取最后的component
        fi

        r_fullBranchNames[${#r_fullBranchNames[@]}]=${fullBranchName}
    }

    #[shell 数组去重](https://www.jianshu.com/p/1043e40c0502)
    r_fullBranchNames=($(awk -v RS=' ' '!a[$1]++' <<< ${r_fullBranchNames[@]}))

    echo "${r_fullBranchNames[*]}"
}


# shell 参数具名化           
# while [ -n "$1" ]
# do
#     case "$1" in
#         -rebaseBranch|--rebase-branch) REBASE_BRANCH=$2; shift 2;;
#         -addValue|--add-value) add_value="$2" shift 2;;
#         -onlyName|--only-name) ONLY_NAME=$2; shift 2;; # 名字是否只取最后部分，不为true时候为全名
#         --) break ;;
#         *) break ;;
#     esac
# done


qian_log "${YELLOW}正在执行命令(获取分支最后一次提交commit的时间)：《${BLUE} sh ${qbase_rebasebranch_last_commit_date_scriptPath} -rebaseBranch \"${REBASE_BRANCH}\" ${YELLOW}》${NC}"
lastCommitDate=$(sh ${qbase_rebasebranch_last_commit_date_scriptPath} -rebaseBranch "${REBASE_BRANCH}")
if [ $? != 0 ]; then
    echo "${lastCommitDate}" # 此时值为错误信息
    show_usage
    exit 1
fi
_verbose_log "${GREEN}恭喜获得:${BLUE}main${GREEN} 分支最后一次提交commit的时间:${BLUE} ${lastCommitDate} ${GREEN}。${NC}"

if [ -n "$add_value" ]; then
    searchFromDateString=$(sh ${qbase_calculate_newdate_scriptPath} --old-date "$lastCommitDate" --add-value "$add_value")
    if [ $? != 0 ]; then
        exit 1
    fi
else
    searchFromDateString=$lastCommitDate
fi


_verbose_log "${YELLOW}正在执行命令(获取指定日期之后的所有合入记录(已去除 HEAD -> 等)):《${BLUE} sh ${qbase_get_merger_recods_after_date_scriptPath} --searchFromDateString \"${searchFromDateString}\" ${YELLOW}》${NC}"
mergerRecordResult=$(sh ${qbase_get_merger_recods_after_date_scriptPath} --searchFromDateString "${searchFromDateString}")
if [ $? != 0 ]; then
    echo "${mergerRecordResult}"    # 此时此值是错误信息
    exit 1
fi
if [ -z "$mergerRecordResult" ]; then  # 没有新commit,提前结束 
    _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录:${BLUE} 没有新的提交记录，更不用说分支了 ${GREEN}。${NC}"
else
    _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录:${BLUE} ${mergerRecordResult} ${GREEN}。${NC}"
    mergerRecordResult=$(optimizeBranchNames "${mergerRecordResult}")
fi


# if [ -n "$onlyThisBranchLine" ]; then
#     currentBranchResult=$(git branch --show-current) # 获取当前分支
#     # _verbose_log "正准备添加当前分支:$currentBranchResult"
#     # mergerRecordResult+=" ${currentBranchResult}"
# fi


responseJsonString='{
    "code": 0
}'
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg searchFromDate "$searchFromDateString" '. + { "searchFromDate": $searchFromDate }')
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg mergerRecords "$mergerRecordResult" '. + { "mergerRecords": $mergerRecords }')
printf "%s" "${responseJsonString}"

