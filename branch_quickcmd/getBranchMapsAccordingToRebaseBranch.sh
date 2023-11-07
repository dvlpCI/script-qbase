#!/bin/bash

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"


# 计算倒数第一个参数的位置
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
fi
# echo "========       last_arg=${last_arg}"

verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
    verbose=true
else # 最后一个元素不是 verbose
    verbose=false
fi

function debug_log() {
    if [ "${verbose}" == true ]; then
        echo "$1"
    fi
}

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..


quickCmdArgs="$@"
# echo "==========所有参数为: ${quickCmdArgs[*]}"

debug_log "${YELLOW}正在执行命令(根据rebase,获取分支名):《${BLUE} sh ${qbase_homedir_abspath}/branch/getBranchNames_accordingToRebaseBranch.sh ${quickCmdArgs[*]} ${YELLOW}》${NC}"
resultBranchNames=$(sh ${qbase_homedir_abspath}/branch/getBranchNames_accordingToRebaseBranch.sh ${quickCmdArgs[*]})
if [ -z "${resultBranchNames}" ]; then
    echo "${RED}您当前目录下的项目，没有新的提交记录，更不用说分支了，请检查确保cd到正确目录，或者提交了代码。${NC}"
    exit 1
fi
echo "${GREEN}恭喜：获取当前分支【在rebase指定分支后】的所有分支名的结果如下：${BLUE} $resultBranchNames ${GREEN}。${NC}"

# shift 1
while [ -n "$1" ]
do
    case "$1" in
        -rebaseBranch|--rebase-branch) REBASE_BRANCH=$2; shift 2;;
        --add-value) add_value=$2; shift 2;;
        --add-type) add_type=$2; shift 2;;
        -onlyName|--only-name) ONLY_NAME=$2; shift 2;;
        -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;;
        -branchMapsAddToJsonF|--branchMaps-add-to-json-file) BranchMapAddToJsonFile=$2; shift 2;;
        -branchMapsAddToKey|--branchMaps-add-to-key) BranchMapAddToKey=$2; shift 2;;
        -shouldDeleteHasCatchRequestBranchFile|--should-delete-has-catch-request-branch-file) shouldDeleteHasCatchRequestBranchFile=$2; shift 2;; # 如果脚本执行成功是否要删除掉已经捕获的文件(一般用于在版本归档时候删除就文件)
        # 发送信息
        -robot|--robot-url) ROBOT_URL=$2; shift 2;;
        -msgtype|--msgtype) msgtype=$2; shift 2;;
        # 注意📢：at 属性，尽在text时候有效,markdown无效。所以如果为了既要markdown又要at，则先markdown值，再at一条text信息。
        -at|--at-middleBracket-ids-string) 
            shift 1; avalue="$@"; # shift 1; 去除-at的key，然后使用 $@ 取剩余的数据，注意这个参数要放在最后，不然会取错
            # 提取以 ] 结尾的值作为 AtMiddleBracketIdsString
            # 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。
            AtMiddleBracketIdsString=$(printf "%s" "$avalue" | grep -o ".*\]") # 不需要写成 '".*\]"'
            # 去除首尾的双引号
            AtMiddleBracketIdsString=${AtMiddleBracketIdsString#\"}
            AtMiddleBracketIdsString=${AtMiddleBracketIdsString%\"}
            # 计算数组个数
            array_count=$(echo "$bvalue" | sed 's/[^,]//g' | wc -c)
            array_count=$((array_count))
            # echo "AtMiddleBracketIdsString count: $array_count"
            shift $array_count;;
        # -xxx|--xxx) xxx=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

debug_log "========1.1=======✅-rebaseBranch:${REBASE_BRANCH}"
debug_log "========1.2=======✅--add-value:${add_value}"
debug_log "========1.3=======✅--add-type:${add_type}"
debug_log "========1.4=======✅-onlyName:${ONLY_NAME}"
debug_log "========2.1=======✅-branchMapsFromDir:${BranceMaps_From_Directory_PATH}"
debug_log "========2.2=======✅-branchMapsAddToJsonF:${BranchMapAddToJsonFile}"
debug_log "========2.3=======✅-branchMapsAddToKey:${BranchMapAddToKey}"

requestBranchNameArray=${resultBranchNames}
debug_log "========r.r=======✅-requestBranchNamesString:${requestBranchNameArray[*]}"
debug_log "========2.5=======✅-shouldDeleteHasCatchRequestBranchFile:${shouldDeleteHasCatchRequestBranchFile}"

# 发送信息所需的参数
debug_log "========3.1=======✅-robot:${ROBOT_URL}"
debug_log "========3.2=======✅-msgtype:${msgtype}"
debug_log "========3.3=======✅-at:${AtMiddleBracketIdsString}"
# debug_log "========3.4=======✅-xxx:${xxx}"


debug_log "${YELLOW}正在执行命令(获取所有指定分支名的branchMaps输出到指定文件中):《 ${BLUE}sh ${qbase_homedir_abspath}/branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh -branchMapsFromDir \"${BranceMaps_From_Directory_PATH}\" -branchMapsAddToJsonF \"${BranchMapAddToJsonFile}\" -branchMapsAddToKey \"${BranchMapAddToKey}\" -requestBranchNamesString \"${requestBranchNameArray[*]}\" -shouldDeleteHasCatchRequestBranchFile \"${shouldDeleteHasCatchRequestBranchFile}\" ${YELLOW}》${NC}"
errorMessage=$(sh ${qbase_homedir_abspath}/branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -requestBranchNamesString "${requestBranchNameArray[*]}" -shouldDeleteHasCatchRequestBranchFile "${shouldDeleteHasCatchRequestBranchFile}")
if [ $? != 0 ]; then
    echo "${errorMessage}" # 这是错误信息，其内部已经对输出内容，添加${RED}等颜色区分了
    notification2wechat_scriptPath=${qbase_homedir_abspath}/notification/notification2wechat.sh
    sh ${notification2wechat_scriptPath} -robot "${ROBOT_URL}" -content "${errorMessage}" -at "${AtMiddleBracketIdsString}" -msgtype "${msgtype}"
    if [ $? != 0 ]; then
        exit 1
    fi
    exit 1
fi
echo "${GREEN}恭喜：获取branchMaps成功，详情查看${BLUE} ${BranchMapAddToJsonFile} ${GREEN}。${NC}"


# 获取信息
get_branch_all_detail_info_script_path="${qbase_homedir_abspath}/branchMaps_20_info/get20_branchMapsInfo_byHisJsonFile.sh"
Develop_Branchs_FILE_PATH=$BranchMapAddToJsonFile
branchMapsInKey="${BranchMapAddToKey}"
RESULT_SALE_TO_JSON_FILE_PATH=$BranchMapAddToJsonFile

showBranchLogFlag='true'
showBranchName='true'
showBranchTimeLog='all'
showBranchAtLog='true'
showBranchTable='false' # 通知也暂时都不显示
showCategoryName='true' # 通知时候显示
if [ "${msgtype}" == "markdown" ]; then
    shouldMarkdown='true'
else
    shouldMarkdown='false'
fi

RESULT_BRANCH_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.branch"
RESULT_CATEGORY_ARRAY_SALE_BY_KEY="branch_info_result.Notification.current.category"
RESULT_FULL_STRING_SALE_BY_KEY="branch_info_result.Notification.current.full"           

debug_log "${YELLOW}正在执行命令(整合 branchMapsInfo)：《${BLUE} sh $get_branch_all_detail_info_script_path -branchMapsInJsonF \"${Develop_Branchs_FILE_PATH}\" -branchMapsInKey \".${branchMapsInKey}\" -showCategoryName \"${showCategoryName}\" -showFlag \"${showBranchLogFlag}\" -showName \"${showBranchName}\" -showTime \"${showBranchTimeLog}\" -showAt \"${showBranchAtLog}\" -showTable \"${showBranchTable}\" -shouldMD \"${shouldMarkdown}\" -resultSaveToJsonF \"${RESULT_SALE_TO_JSON_FILE_PATH}\" -resultBranchKey \"${RESULT_BRANCH_ARRAY_SALE_BY_KEY}\" -resultCategoryKey \"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\" -resultFullKey \"${RESULT_FULL_STRING_SALE_BY_KEY}\" ${YELLOW}》${NC}"
errorMessage=$(sh $get_branch_all_detail_info_script_path -branchMapsInJsonF "${Develop_Branchs_FILE_PATH}" -branchMapsInKey ".${branchMapsInKey}" -showCategoryName "${showCategoryName}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -showTable "${showBranchTable}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultBranchKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}" -resultCategoryKey "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -resultFullKey "${RESULT_FULL_STRING_SALE_BY_KEY}")
if [ $? != 0 ]; then
    echo "${errorMessage}" # 这是错误信息，其内部已经对输出内容，添加${RED}等颜色区分了
    notification2wechat_scriptPath=${qbase_homedir_abspath}/notification/notification2wechat.sh
    sh ${notification2wechat_scriptPath} -robot "${ROBOT_URL}" -content "${errorMessage}" -at "${AtMiddleBracketIdsString}" -msgtype "${msgtype}"
    if [ $? != 0 ]; then
        exit 1
    fi
    exit 1
fi


# 发送信息
notification_strings_to_wechat_scriptPath=${qbase_homedir_abspath}/notification/notification_strings_to_wechat.sh

CONTENTS_JSON_FILE_PATH=${RESULT_SALE_TO_JSON_FILE_PATH}
CONTENTS_JSON_KEY="${RESULT_FULL_STRING_SALE_BY_KEY}_slice"
HEADER_TEXT=">>>>>>>>您当前打包的分支信息如下>>>>>>>>>\n"
# FOOTER_TEXT="未换行<<<<<<<<这是尾部<<<<<<<<<"
# AtMiddleBracketIdsString="[\"@all\", \"lichaoqian\"]"
debug_log "${YELLOW}正在执行命令(发送分支数组内容)《 ${BLUE}sh ${notification_strings_to_wechat_scriptPath} -robot \"${ROBOT_URL}\" -headerText \"${HEADER_TEXT}\" -contentJsonF \"${CONTENTS_JSON_FILE_PATH}\" -contentJsonKey \"${CONTENTS_JSON_KEY}\" -footerText \"${FOOTER_TEXT}\" -at \"${AtMiddleBracketIdsString}\" -msgtype \"${msgtype}\" ${YELLOW}》${NC}"
sh ${notification_strings_to_wechat_scriptPath} -robot "${ROBOT_URL}" -headerText "${HEADER_TEXT}" -contentJsonF "${CONTENTS_JSON_FILE_PATH}" -contentJsonKey "${CONTENTS_JSON_KEY}" -footerText "${FOOTER_TEXT}" -at "${AtMiddleBracketIdsString}" -msgtype "${msgtype}"
if [ $? != 0 ]; then
    exit 1
fi