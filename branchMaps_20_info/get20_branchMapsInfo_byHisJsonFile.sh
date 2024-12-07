#!/bin/bash
:<<!
脚本的测试使用如下命令：
获取branchMaps整理后的分支信息
./get20_branchMapsInfo_byHisJsonFile.sh 
!



# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function logSuccessMsg() {
    printf "${GREEN}$1${GREEN}\n${NC}"
}

function logMsg() {
    printf "$1\n${NC}"
}

function debug_log() {
    if [ "${isRelease}" == true ]; then
        echo "$1"
    fi
}

#! /bin/bash
JQ_EXEC=`which jq`


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
# CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
# echo "CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute} ✅"

# qscript_path_get_filepath="${CommonFun_HomeDir_Absolute}/qscript_path_get.sh"
# qbase_update_json_file_singleString_script_path="$(sh ${qscript_path_get_filepath} qbase update_json_file_singleString)"
# qbase_function_log_msg_script_path="$(sh ${qscript_path_get_filepath} qbase function_log_msg)"
qbase_function_log_msg_script_path="${CommonFun_HomeDir_Absolute}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultValueToJsonFile


markdownFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/markdown/function_markdown.sh"
JsonUpdateFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/value_update_in_file/update_json_file.sh"

get_branch_self_detail_info_script_path=${CommonFun_HomeDir_Absolute}/branchMaps_20_info/get10_branch_self_detail_info.sh


if [ ! -f "${markdownFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理markdown的脚本文件 ${markdownFun_script_file_Absolute} 不存在，请检查！"
fi
if [ ! -f "${JsonUpdateFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理更新json文件内从的脚本文件 ${JsonUpdateFun_script_file_Absolute} 不存在，请检查！"
    exit 1
fi
source "${markdownFun_script_file_Absolute}" # 为了使用 markdown_fontColor 等 markdown 方法


# 更新指定文件的键值为指定值
function updateBranchResultFileKeyValue() {
    RESULT_SALE_TO_JSON_FILE_PATH=$1
    RESULT_FULL_STRING_SALE_BY_KEY=$2
    LAST_BRANCHS_INFO_STRING=$3
    
    if [ ! -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ] || [ -z "${RESULT_FULL_STRING_SALE_BY_KEY}" ]; then
        echo "$FUNCNAME  提示💡💡💡：您存放分支最终结果信息的文件${RESULT_SALE_TO_JSON_FILE_PATH}不存在 或 要保存到的key值${RESULT_FULL_STRING_SALE_BY_KEY}未设置，所以所得的值将不会保存到文件中"
        return 0
    fi
    RESULT_FULL_SALE_BY_HOME_KEY=$(echo ${RESULT_FULL_STRING_SALE_BY_KEY%.*})  # %.* 表示从右边开始，删除第一个 . 号及右边的字符
    RESULT_FULL_SALE_BY_PATH_KEY=$(echo ${RESULT_FULL_STRING_SALE_BY_KEY##*.}) # *. 表示从左边开始删除最后（最右边）一个 . 号及左边的所有字符
    LAST_BRANCHS_INFO_JSON="{\"${RESULT_FULL_SALE_BY_PATH_KEY}\": \"${LAST_BRANCHS_INFO_STRING}\"}"
    sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_FULL_SALE_BY_HOME_KEY}" -v "${LAST_BRANCHS_INFO_JSON}" --skip-value-check "true"
}



# 获取所有分支的Log信息，并保存到指定文件中
# function getAllBranchLogArray_andCategoryThem() {
# }

while [ -n "$1" ]
do
    case "$1" in
        # -branchMaps|--branchMap-array) branchMapArray=$2; shift 2;;
        -branchMapsInJsonF|--branchMaps-json-file-path) branchMapsInJsonFile=$2; shift 2;; # 要计算的branchMaps所在的json文件
        -branchMapsInKey|--branchMaps-key) branchMapsInKey=$2; shift 2;; # 要计算的branchMaps在json文件中的哪个字段

        -showCategoryName|--show-category-name) showCategoryName=$2; shift 2;;
        -showFlag|--show-branchLog-Flag) showBranchLogFlag=$2; shift 2;;
        -showName|--show-branchName) showBranchName=$2; shift 2;;
        -showTime|--show-branchTimeLog) showBranchTimeLog=$2; shift 2;; # 时间显示方式(all、only_last、none)
        -showAt|--show-branchAtLog) showBranchAtLog=$2; shift 2;;
        -shouldShowSpendHours|--should-show-spend-hours) shouldShowSpendHours=$2; shift 2;;
        -showTable|--show-branchTable) showBranchTable=$2; shift 2;;
        -shouldMD|--should-markdown) shouldMarkdown=$2; shift 2;;
        -resultSaveToJsonF|--result-save-to-json-file-path) RESULT_SALE_TO_JSON_FILE_PATH=$2; shift 2;; # 为简化换行符的保真(而不是显示成换行,导致后面计算数组个数麻烦),将结果保存在的JSON文件
        -resultBranchKey|--result-branch-array-save-by-key) RESULT_BRANCH_ARRAY_SALE_BY_KEY=$2; shift 2;;   # 分支branch元素数组结果,用什么key保存到上述文件
        -resultCategoryKey|--result-category-array-save-by-key) RESULT_CATEGORY_ARRAY_SALE_BY_KEY=$2; shift 2;;   # 分类category元素数组结果,用什么key保存到上述文件
        -resultFullKey|--result-full-string-save-by-key) RESULT_FULL_STRING_SALE_BY_KEY=$2; shift 2;;   # 总字符串结果,用什么key保存到上述文件
        --) break ;;
    esac
done

if [ ! -f "${branchMapsInJsonFile}" ];then
    echo "❌${RED}Error:您要处理的json文件 ${branchMapsInJsonFile} 不存在，请检查！${NC}"
    # printf "%s" "红红火火恍恍惚惚哈哈哈哈哈哈"
    exit 1
fi
branchMapArray=$(cat ${branchMapsInJsonFile} | jq -r "${branchMapsInKey}") # -r 去除字符串引号
# echo "✅哈哈哈哈 131"
# echo "执行文件信息获取《 ${BLUE}cat ${branchMapsInJsonFile} | jq -r \"${branchMapsInKey}\" ${NC}》所得的值如下:\n${branchMapArray} ${NC}"
# exit 1

if [ ! -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ]; then
    echo "您的 -resultSaveToJsonF 参数的值指向的 ${RESULT_SALE_TO_JSON_FILE_PATH} 文件不存在，请检查。"
    exit 1
fi

#echo "要获取信息的所有分支数组branchMapArray=${branchMapArray}"
if [ -z "${branchMapArray}" ] || [ "${branchMapArray}" == "null" ]; then
    echo "-------------------------💡💡💡友情提示tips：您的 ${branchMapsInJsonFile} 文件中不存在 ${branchMapsInKey} 字段的数据,请检查"
    branchMapArray="" # 写此行，只是为了将 "null" 也设置成空字符串
    updateBranchResultFileKeyValue "${RESULT_SALE_TO_JSON_FILE_PATH}" "${RESULT_FULL_STRING_SALE_BY_KEY}" ""
    exit 0
fi

if [ -z "${showCategoryName}" ]; then   # 避免外面没传值
    showCategoryName="false"
fi

# 获取分类 category 的值
# 注意📢:赋值前先清空数据，避免其他接口也调用此方法，导致有残留数据
categoryBranchsLogArray_hotfix=()
categoryBranchsLogArray_feature=()
categoryBranchsLogArray_optimize=()
categoryBranchsLogArray_other=()

Escape_CATEGORY_STRING_VALUE_hotfix="["
Escape_CATEGORY_STRING_VALUE_feature="["
Escape_CATEGORY_STRING_VALUE_optimize="["
Escape_CATEGORY_STRING_VALUE_other="["

branchCount=$(echo ${branchMapArray} | ${JQ_EXEC} -r ".|length")
#echo "branchCount=${branchCount}"
for ((logBranchIndex=0;logBranchIndex<branchCount;logBranchIndex++)) # 注意📢:取名logBranchIndex，而不用i避免被getSingleBranchLog中的getSingleBranchDescription的i给影响了
do
    iBranchMap=$(echo ${branchMapArray} | ${JQ_EXEC} -r ".[$((logBranchIndex))]") # -r 去除字符串引号
    debug_log "${YELLOW}正在执行命令(获取单分支信息,并添加(而不是覆盖)保存到 ${RESULT_SALE_TO_JSON_FILE_PATH} 文件的 ${RESULT_BRANCH_ARRAY_SALE_BY_KEY} 中)：《 sh ${get_branch_self_detail_info_script_path} -iBranchMap \"${iBranchMap}\" -showFlag \"${showBranchLogFlag}\" -showName \"${showBranchName}\" -showTime \"${showBranchTimeLog}\" -showAt \"${showBranchAtLog}\" -shouldShowSpendHours \"${shouldShowSpendHours}\" -shouldMD \"${shouldMarkdown}\" -resultSaveToJsonF \"${RESULT_SALE_TO_JSON_FILE_PATH}\" -resultArrayKey \"${RESULT_BRANCH_ARRAY_SALE_BY_KEY}\" 》${NC}"
    iBranchLog=$(sh ${get_branch_self_detail_info_script_path} -iBranchMap "${iBranchMap}" -showFlag "${showBranchLogFlag}" -showName "${showBranchName}" -showTime "${showBranchTimeLog}" -showAt "${showBranchAtLog}" -shouldShowSpendHours "${shouldShowSpendHours}" -shouldMD "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultArrayKey "${RESULT_BRANCH_ARRAY_SALE_BY_KEY}")
    if [ $? != 0 ]; then
        echo "${RED}您的${BLUE} ${branchMapsInJsonFile} ${RED}文件出错了，请检查。出错信息为：${NC} ${iBranchLog}" # 此时此值为错误信息
        exit 1
    fi
    # logResultValueToJsonFile "${iBranchLog}"
    # echo "😄✅😄✅😄✅😄✅😄✅😄✅😄✅"
    # exit 1



    if [ $logBranchIndex -eq $((branchCount-1)) ]; then #如果已经全部添加完，则可以一次性输出最新的了
        logSuccessMsg "恭喜:最后获取(.branch)markdown:${shouldMarkdown}的 ${PURPLE}.${RESULT_BRANCH_ARRAY_SALE_BY_KEY} ${GREEN}值(在 ${BLUE}${RESULT_SALE_TO_JSON_FILE_PATH} ${GREEN}文件中)如下:"
        cat ${RESULT_SALE_TO_JSON_FILE_PATH} | jq ".${RESULT_BRANCH_ARRAY_SALE_BY_KEY}" | jq '.'
    fi
            
    #echo "第${logBranchIndex}个分支的分支信息为-----------------${iBranchLog}" # 使用echo做函数返回值，所以不能写此行，除非你是在调试中用于临时查看一些信息
    # if [ $logBranchIndex -eq 0 ]; then
    #     echo "\n"
    # fi
    # echo "${CYAN}===============分支信息结果(未归类前的顺序)$((logBranchIndex+1)) ${BLUE}${iBranchLog} ✅${NC}"
    # if [ $logBranchIndex -eq $((branchCount-1)) ]; then
    #     echo "\n"
    # fi
    
    branchType=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".type") # -r 去除字符串引号
    # echo ".............branchType=${branchType}"
    if [ "${branchType}" == "hotfix" ]; then
        categoryBranchsLogArray_hotfix[${#categoryBranchsLogArray_hotfix[@]}]="${iBranchLog}"
        Escape_CATEGORY_STRING_VALUE_hotfix+="\"${iBranchLog}\","  # 要转义
    elif [ "${branchType}" == "feature" ]; then
        categoryBranchsLogArray_feature[${#categoryBranchsLogArray_feature[@]}]="${iBranchLog}"
        Escape_CATEGORY_STRING_VALUE_feature+="\"${iBranchLog}\","  # 要转义
    elif [ "${branchType}" == "optimize" ]; then
        categoryBranchsLogArray_optimize[${#categoryBranchsLogArray_optimize[@]}]="${iBranchLog}"
        Escape_CATEGORY_STRING_VALUE_optimize+="\"${iBranchLog}\","  # 要转义
    else
        categoryBranchsLogArray_other[${#categoryBranchsLogArray_other[@]}]="${iBranchLog}"
        Escape_CATEGORY_STRING_VALUE_other+="\"${iBranchLog}\","  # 要转义
    fi
done

# 去除最后一个字符,即逗号","
if [ -n "${Escape_CATEGORY_STRING_VALUE_hotfix}" ] && [ "${Escape_CATEGORY_STRING_VALUE_hotfix}" != "[" ]; then
    Escape_CATEGORY_STRING_VALUE_hotfix=${Escape_CATEGORY_STRING_VALUE_hotfix: 0:${#Escape_CATEGORY_STRING_VALUE_hotfix}-1}
fi
if [ -n "${Escape_CATEGORY_STRING_VALUE_feature}" ] && [ "${Escape_CATEGORY_STRING_VALUE_feature}" != "[" ]; then
    Escape_CATEGORY_STRING_VALUE_feature=${Escape_CATEGORY_STRING_VALUE_feature: 0:${#Escape_CATEGORY_STRING_VALUE_feature}-1}
fi
if [ -n "${Escape_CATEGORY_STRING_VALUE_optimize}" ] && [ "${Escape_CATEGORY_STRING_VALUE_optimize}" != "[" ]; then
    Escape_CATEGORY_STRING_VALUE_optimize=${Escape_CATEGORY_STRING_VALUE_optimize: 0:${#Escape_CATEGORY_STRING_VALUE_optimize}-1}
fi
if [ -n "${Escape_CATEGORY_STRING_VALUE_other}" ] && [ "${Escape_CATEGORY_STRING_VALUE_other}" != "[" ]; then
    Escape_CATEGORY_STRING_VALUE_other=${Escape_CATEGORY_STRING_VALUE_other: 0:${#Escape_CATEGORY_STRING_VALUE_other}-1}
fi
Escape_CATEGORY_STRING_VALUE_hotfix+="]"
Escape_CATEGORY_STRING_VALUE_feature+="]"
Escape_CATEGORY_STRING_VALUE_optimize+="]"
Escape_CATEGORY_STRING_VALUE_other+="]"
debug_log "✅ hotfix  分类信息----------\n${Escape_CATEGORY_STRING_VALUE_hotfix}"
debug_log "✅ feature 分类信息----------\n${Escape_CATEGORY_STRING_VALUE_feature}"
debug_log "✅ optimize分类信息----------\n${Escape_CATEGORY_STRING_VALUE_optimize}"
debug_log "✅ other   分类信息----------\n${Escape_CATEGORY_STRING_VALUE_other}"


# logResultObjectStringToJsonFile "${Escape_CATEGORY_STRING_VALUE_hotfix}"
# # logResultObjectStringToJsonFile "${Escape_CATEGORY_STRING_VALUE_feature}"
# exit

# 设置分类 category 的值到FILE中
if [ ! -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ] || [ -z "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" ]; then
    echo "$FUNCNAME  提示💡💡💡：您存放每个分支信息的文件${RESULT_SALE_TO_JSON_FILE_PATH}不存在 或 要保存到的key值${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}未设置，所以所得的值将不会保存到文件中"
    exit 0
fi
# 在文件和key值存在的前提下
if [ -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ] && [ -n "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" ]; then
    if [ -n "${Escape_CATEGORY_STRING_VALUE_hotfix}" ]; then
        CATEGORY_BRANCHS_LOG_JSON_hotfix="{\"hotfix\": ${Escape_CATEGORY_STRING_VALUE_hotfix}}"
        # logResultObjectStringToJsonFile "${CATEGORY_BRANCHS_LOG_JSON_hotfix}"
        # UpdateJsonKeyValue="{\"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\": ${CATEGORY_BRANCHS_LOG_JSON_hotfix}}"
        # logResultObjectStringToJsonFile "${UpdateJsonKeyValue}"
        # logResultObjectStringToJsonFile_byJQ "${CATEGORY_BRANCHS_LOG_JSON_hotfix}"
        # exit

        sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -v "${CATEGORY_BRANCHS_LOG_JSON_hotfix}" --skip-value-check "true"
        if [ $? != 0 ]; then
            exit 1
        fi
        # echo "${YELLOW}更多详情请可点击查看文件: ${BLUE}${RESULT_SALE_TO_JSON_FILE_PATH} ${NC}"
        # exit
    fi
    if [ -n "${Escape_CATEGORY_STRING_VALUE_feature}" ]; then
        CATEGORY_BRANCHS_LOG_JSON_feature="{\"feature\": ${Escape_CATEGORY_STRING_VALUE_feature}}"
        sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -v "${CATEGORY_BRANCHS_LOG_JSON_feature}" --skip-value-check "true"
        if [ $? != 0 ]; then
            exit 1
        fi
    fi
    if [ -n "${Escape_CATEGORY_STRING_VALUE_optimize}" ]; then
        CATEGORY_BRANCHS_LOG_JSON_optimize="{\"optimize\": ${Escape_CATEGORY_STRING_VALUE_optimize}}"
        sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -v "${CATEGORY_BRANCHS_LOG_JSON_optimize}" --skip-value-check "true"
        if [ $? != 0 ]; then
            exit 1
        fi
    fi
    if [ -n "${Escape_CATEGORY_STRING_VALUE_other}" ]; then
        CATEGORY_BRANCHS_LOG_JSON_other="{\"other\": ${Escape_CATEGORY_STRING_VALUE_other}}"
        sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -v "${CATEGORY_BRANCHS_LOG_JSON_other}" --skip-value-check "true"
        if [ $? != 0 ]; then
            exit 1
        fi
    fi
fi




# echo "categoryBranchsLogArray_hotfix=${#categoryBranchsLogArray_hotfix[*]}个元素 ${categoryBranchsLogArray_hotfix[*]}"
# echo "categoryBranchsLogArray_feature=${#categoryBranchsLogArray_feature[*]}个元素 ${categoryBranchsLogArray_feature[*]}"
# echo "categoryBranchsLogArray_optimize=${#categoryBranchsLogArray_optimize[*]}个元素 ${categoryBranchsLogArray_optimize[*]}"
# echo "categoryBranchsLogArray_other=${#categoryBranchsLogArray_other[*]}个元素 ${categoryBranchsLogArray_other[*]}"
logSuccessMsg "恭喜:最后获取(.category)markdown:${shouldMarkdown}的 ${PURPLE}.${RESULT_CATEGORY_ARRAY_SALE_BY_KEY} ${GREEN}值(在 ${BLUE}${RESULT_SALE_TO_JSON_FILE_PATH} ${GREEN}文件中)如下:"
cat ${RESULT_SALE_TO_JSON_FILE_PATH} | jq ".${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" | jq '.'
# echo "✅✅✅✅✅✅✅✅✅✅✅✅✅"


# 进一步进行对上诉所得的 category 整理
get_category_all_detail_info_script_path="${CommonFun_HomeDir_Absolute}/branchMaps_20_info/get11_category_all_detail_info.sh"
showCategoryName="true"
debug_log "${YELLOW}正在执行(获取分类的所有信息)《 ${BLUE}sh ${get_category_all_detail_info_script_path} -categoryJsonF \"${RESULT_SALE_TO_JSON_FILE_PATH}\" -categoryArrayKey \"${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}\" -showCategoryName \"${showCategoryName}\" -resultFullKey \"${RESULT_FULL_STRING_SALE_BY_KEY}\" -resultFullSaveToJsonF \"${RESULT_SALE_TO_JSON_FILE_PATH}\" ${YELLOW}》${NC}"
ALL_CATEGORY_BRANCH_STRING=$(sh ${get_category_all_detail_info_script_path} -categoryJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -categoryArrayKey "${RESULT_CATEGORY_ARRAY_SALE_BY_KEY}" -showCategoryName "${showCategoryName}" -resultFullKey "${RESULT_FULL_STRING_SALE_BY_KEY}" -resultFullSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}")
if [ $? != 0 ]; then
    echo "${RED}${ALL_CATEGORY_BRANCH_STRING}${NC}" # 此时值为错误信息
    exit 1
fi



