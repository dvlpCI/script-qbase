#!/bin/bash
:<<!
脚本的测试使用如下命令：
./get11_category_all_detail_info.sh 
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

markdownFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/markdown/function_markdown.sh"
JsonUpdateFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/update_value/update_json_file.sh"


if [ ! -f "${markdownFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理markdown的脚本文件 ${markdownFun_script_file_Absolute} 不存在，请检查！"
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


# 获取指定分类category数组的分支信息
function getCategoryBranchsLog() {
    while [ -n "$1" ]
    do
            case "$1" in
                    #-categoryBranchsLogArray|--categoryBranchsLog-array) categoryBranchsLogArrayString=$2; shift 2;;
                    -categoryJsonF|--category-json-file-path) CATEGORY_JSON_FILE_PATH=$2; shift 2;; # 分类category数组所在的文件
                    -categoryArrayKey|--category-array-key) CATEGORY_ARRAY_KEY=$2; shift 2;;   # 分类category数组在文件中使用的key
                    
                    -categoryName|--category-name) categoryName=$2; shift 2;;

                    -showCategoryName|--show-category-name) showCategoryName=$2; shift 2;;
                    -lastLogIndexInAll|--lastLogIndexInAll) lastLogIndexInAll=$2; shift 2;;
                    --) break ;;
            esac
    done

    # 初始赋值，避免其他类也使用此方法，导致数组错误
    categoryBranchsLogsResult=''
    Escape_CATEGORY_BRANCH_ARRAY_STRING='' # 有逗号分隔的待添加到数组中的值
    lastLogIndexInAllReslut=${lastLogIndexInAll}

    if [ ! -f "${CATEGORY_JSON_FILE_PATH}" ]; then
        echo "$FUNCNAME ❌Error:您存放分类分支信息的文件${CATEGORY_JSON_FILE_PATH}，不存在，请检查文件！"
        return 1
    fi

    #echo "正在执行命令(获取分类分组信息)：《cat ${CATEGORY_JSON_FILE_PATH} | ${JQ_EXEC} ".${CATEGORY_ARRAY_KEY}.${categoryName}"》"
    #echo "正在执行命令(获取分类分支个数)：《cat ${CATEGORY_JSON_FILE_PATH} | ${JQ_EXEC} ".${CATEGORY_ARRAY_KEY}.${categoryName}" | ${JQ_EXEC} -r ".|length"》"
    categoryBranchsLogCount=$(cat ${CATEGORY_JSON_FILE_PATH} | ${JQ_EXEC} ".${CATEGORY_ARRAY_KEY}.${categoryName}" | ${JQ_EXEC} ".|length")
    #echo "${CATEGORY_JSON_FILE_PATH}文件中在${CATEGORY_ARRAY_KEY}下的${categoryName}分类的分支个数=============${categoryBranchsLogCount}个"
    if [ ${categoryBranchsLogCount} -eq 0 ]; then
        debug_log "提示💡💡💡： ${CATEGORY_JSON_FILE_PATH} 文件中在 ${CATEGORY_ARRAY_KEY} 下没有 ${BLUE}${categoryName}${NC} 属性的数据"
        return 0
    fi

    if [ "${showCategoryName}" == "true" ]; then
        categoryHeaderString="=======${categoryName}======="
        categoryBranchsLogsResult="${categoryHeaderString}\n"
        Escape_CATEGORY_BRANCH_ARRAY_STRING="\"${categoryHeaderString}\","
    fi

    # 要先判空才能获取
    categoryBranchsLogArray=$(cat ${CATEGORY_JSON_FILE_PATH} | ${JQ_EXEC} -r ".${CATEGORY_ARRAY_KEY}.${categoryName}")
    for ((categoryIndex=0;categoryIndex<categoryBranchsLogCount;categoryIndex++))
    do
        # iBranchLog=${categoryBranchsLogArray[categoryIndex]} # Error：多个时候，只能取到第一个
        # 由base目录下update_value/test文件夹里的 tssh_update_text_variable.sh 脚本，我们知道
        # 我们知道使用jquery取值的不要使用 jq -r 属性，且需要先去除前后的双引号再去操作字符串。这样的好处有：
        # 好处①：设置 json 的时候，仍然保留原本的在前后都要加双引号的操作。
        # 好处②：当要对所取到的值修改后再更新回json文件时候，可以成功"
        iBranchLog_withEscape=$(cat ${CATEGORY_JSON_FILE_PATH} | ${JQ_EXEC} ".${CATEGORY_ARRAY_KEY}.${categoryName}" | ${JQ_EXEC} ".[${categoryIndex}]")
        # help echo
        # echo "======iBranchLog_withEscape=${iBranchLog_withEscape}"
        # echo "======iBranchLog_withEscape_echo=${iBranchLog_withEscape//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
        iBranchLog_withEscape_noDoubleQuote=${iBranchLog_withEscape: 1:${#iBranchLog_withEscape}-2}
        # echo "======iBranchLog_withEscape_noDoubleQuote=${iBranchLog_withEscape_noDoubleQuote}"
        # echo "======iBranchLog_withEscape_noDoubleQuote_echo=${iBranchLog_withEscape_noDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
        iBranchLog=${iBranchLog_withEscape_noDoubleQuote}

        #echo "${categoryName}分类中的第$((categoryIndex+1))个分支的信息 iBranchsLog=${iBranchLog}"
        iBranchLog="$((lastLogIndexInAll+1)).${iBranchLog}"
        categoryBranchsLogsResult+="${iBranchLog}\n"
        Escape_CATEGORY_BRANCH_ARRAY_STRING+="\"${iBranchLog}\","

        lastLogIndexInAll=$((lastLogIndexInAll+1))
    done
    
    # 去除最后两个字符,即换行符"\n"
    if [ -n "${categoryBranchsLogsResult}" ]; then
        categoryBranchsLogsResult=${categoryBranchsLogsResult: 0:${#categoryBranchsLogsResult}-2}
    fi
    #echo "${CATEGORY_JSON_FILE_PATH}文件中在${CATEGORY_ARRAY_KEY}下的${categoryName}分类的分支信息=============${categoryBranchsLogsResult}" #不能写这一行，否则会多一部分,因为这里我们使用echo做函数返回值，所以不能写此行，除非你是在调试中用于临时查看一些信息
    

    lastLogIndexInAllReslut=${lastLogIndexInAll}
    return 0
}




# 通过分类顺序，获取所有分支信息
while [ -n "$1" ]
do
        case "$1" in
                -categoryJsonF|--category-json-file-path) CATEGORY_JSON_FILE_PATH=$2; shift 2;; # 分类category数组所在的文件
                -categoryArrayKey|--category-array-key) CATEGORY_ARRAY_KEY=$2; shift 2;;   # 分类category数组在文件中使用的key
                -showCategoryName|--show-category-name) showCategoryName=$2; shift 2;;
                -resultFullKey|--result-full-string-save-by-key) RESULT_FULL_STRING_SALE_BY_KEY=$2; shift 2;;   # 总字符串结果,用什么key保存到上述文件
                -resultFullSaveToJsonF|--result-full-save-to-json-file-path) RESULT_SALE_TO_JSON_FILE_PATH=$2; shift 2;; # 为简化换行符的保真(而不是显示成换行,导致后面计算数组个数麻烦),将结果保存在的JSON文件
                --) break ;;
        esac
done

if [ -z "${CATEGORY_JSON_FILE_PATH}" ]; then
    echo "缺少参数: -categoryJsonF|--category-json-file-path"
    exit 1
fi

if [ -z "${RESULT_SALE_TO_JSON_FILE_PATH}" ]; then
    echo "缺少参数: -resultFullSaveToJsonF|--result-full-save-to-json-file-path"
    exit 1
fi


# 总分类字符串
ALL_CATEGORY_BRANCH_STRING=''
Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING=''

if [ ! -f "${CATEGORY_JSON_FILE_PATH}" ]; then
    echo "$FUNCNAME ❌Error:您存放分类分支信息的文件${CATEGORY_JSON_FILE_PATH}，不存在，请检查文件！"
    return 1
fi


lastLogIndex=0
# 获取 hotfix 分类的信息
debug_log "${YELLOW}正在执行《 ${BLUE}getCategoryBranchsLog -categoryJsonF \"${CATEGORY_JSON_FILE_PATH}\" -categoryArrayKey \"${CATEGORY_ARRAY_KEY}\" -categoryName 'hotfix' -lastLogIndexInAll \"${lastLogIndex}\" -showCategoryName \"${showCategoryName}\" ${YELLOW}》${NC}"
getCategoryBranchsLog -categoryJsonF "${CATEGORY_JSON_FILE_PATH}" -categoryArrayKey "${CATEGORY_ARRAY_KEY}" -categoryName 'hotfix' -lastLogIndexInAll "${lastLogIndex}" -showCategoryName "${showCategoryName}"
# echo "✅✅✅✅ ${categoryBranchsLogsResult} ✅✅✅✅"
# exit

if [ $? == 0 ] && [ -n "${categoryBranchsLogsResult}" ]; then
    if [ -n "${ALL_CATEGORY_BRANCH_STRING}" ]; then
        ALL_CATEGORY_BRANCH_STRING+='\n'
    fi
    ALL_CATEGORY_BRANCH_STRING+="${categoryBranchsLogsResult}"
    Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING+="${Escape_CATEGORY_BRANCH_ARRAY_STRING}" # 已符合转义并加了逗号,
fi
lastLogIndex=${lastLogIndexInAllReslut}

getCategoryBranchsLog -categoryJsonF "${CATEGORY_JSON_FILE_PATH}" -categoryArrayKey "${CATEGORY_ARRAY_KEY}" -categoryName 'feature' -lastLogIndexInAll "${lastLogIndex}" -showCategoryName "${showCategoryName}"
if [ $? == 0 ] && [ -n "${categoryBranchsLogsResult}" ]; then
    if [ -n "${ALL_CATEGORY_BRANCH_STRING}" ]; then
        ALL_CATEGORY_BRANCH_STRING+='\n'
    fi
    ALL_CATEGORY_BRANCH_STRING+=${categoryBranchsLogsResult}
    Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING+="${Escape_CATEGORY_BRANCH_ARRAY_STRING}" # 已符合转义并加了逗号,
fi
lastLogIndex=${lastLogIndexInAllReslut}

getCategoryBranchsLog -categoryJsonF "${CATEGORY_JSON_FILE_PATH}" -categoryArrayKey "${CATEGORY_ARRAY_KEY}" -categoryName 'optimize' -lastLogIndexInAll "${lastLogIndex}" -showCategoryName "${showCategoryName}"
if [ $? == 0 ] && [ -n "${categoryBranchsLogsResult}" ]; then
    if [ -n "${ALL_CATEGORY_BRANCH_STRING}" ]; then
        ALL_CATEGORY_BRANCH_STRING+='\n'
    fi
    ALL_CATEGORY_BRANCH_STRING+=${categoryBranchsLogsResult}
    Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING+="${Escape_CATEGORY_BRANCH_ARRAY_STRING}" # 已符合转义并加了逗号,
fi
lastLogIndex=${lastLogIndexInAllReslut}

getCategoryBranchsLog -categoryJsonF "${CATEGORY_JSON_FILE_PATH}" -categoryArrayKey "${CATEGORY_ARRAY_KEY}" -categoryName 'other' -lastLogIndexInAll "${lastLogIndex}" -showCategoryName "${showCategoryName}"
if [ $? == 0 ] && [ -n "${categoryBranchsLogsResult}" ]; then
    if [ -n "${ALL_CATEGORY_BRANCH_STRING}" ]; then
        ALL_CATEGORY_BRANCH_STRING+='\n'
    fi
    ALL_CATEGORY_BRANCH_STRING+=${categoryBranchsLogsResult}
    Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING+="${Escape_CATEGORY_BRANCH_ARRAY_STRING}" # 已符合转义并加了逗号,
fi
lastLogIndex=${lastLogIndexInAllReslut}

if [ -z "${ALL_CATEGORY_BRANCH_STRING}" ]; then
    ALL_CATEGORY_BRANCH_STRING="tips: no any branchs info"
fi
# echo "通过分类顺序，获取到的所有分支信息ALL_CATEGORY_BRANCH_STRING=\n${ALL_CATEGORY_BRANCH_STRING}"
printf %s "${ALL_CATEGORY_BRANCH_STRING}"

# if [ -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ] && [ -n "${RESULT_FULL_STRING_SALE_BY_KEY}" ]; then
#     RESULT_FULL_SALE_BY_HOME_KEY=$(echo ${RESULT_FULL_STRING_SALE_BY_KEY%.*})  # %.* 表示从右边开始，删除第一个 . 号及右边的字符
#     RESULT_FULL_SALE_BY_PATH_KEY=$(echo ${RESULT_FULL_STRING_SALE_BY_KEY##*.}) # *. 表示从左边开始删除最后（最右边）一个 . 号及左边的所有字符
#     #echo "结果字符串的保存位置=${RESULT_FULL_SALE_BY_HOME_KEY}------${RESULT_FULL_SALE_BY_HOME_KEY}"
#     LAST_BRANCHS_INFO_JSON="{\"${RESULT_FULL_SALE_BY_PATH_KEY}\": \"${ALL_CATEGORY_BRANCH_STRING}\"}"
#     sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_FULL_SALE_BY_HOME_KEY}" -v "${LAST_BRANCHS_INFO_JSON}" --skip-value-check "true"

#     # 去除最后一个字符,即逗号","
#     if [ -n "${Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING}" ] && [ "${Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING}" != "[" ]; then
#         Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING=${Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING: 0:${#Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING}-1}
#     fi
#     Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING="[${Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING}]" # 内部已符合转义并加了逗号,现在补充上前后的[]
#     Escape_ALL_CATEGORY_BRANCH_ARRAY_JSON="{\"${RESULT_FULL_SALE_BY_PATH_KEY}_slice\": ${Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING}}"
#     sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_FULL_SALE_BY_HOME_KEY}" -v "${Escape_ALL_CATEGORY_BRANCH_ARRAY_JSON}" --skip-value-check "true"
# fi

LAST_BRANCHS_INFO_STRING=""
LAST_BRANCHS_INFO_STRING+=${ALL_CATEGORY_BRANCH_STRING}
Escape_LAST_BRANCH_ARRAY_ONLY_STRING+=${Escape_ALL_CATEGORY_BRANCH_ARRAY_STRING}

if [ "${showBranchTable}" == "true" ]; then
    sh ${CurrentDIR_Script_Absolute}/branch_info_table.sh "${branchMapArray}"
    tableString=${BranchTableInfoResult}
    LAST_BRANCHS_INFO_STRING="${tableString}\n${LAST_BRANCHS_INFO_STRING}"
fi
# tableString="我是测试的表格数据(测试通过✅)"
# Escape_LAST_BRANCH_ARRAY_ONLY_STRING="\"${tableString}\",${Escape_LAST_BRANCH_ARRAY_ONLY_STRING}"

if [ -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ] && [ -n "${RESULT_FULL_STRING_SALE_BY_KEY}" ]; then
    RESULT_FULL_SALE_BY_HOME_KEY=$(echo ${RESULT_FULL_STRING_SALE_BY_KEY%.*})  # %.* 表示从右边开始，删除第一个 . 号及右边的字符
    RESULT_FULL_SALE_BY_PATH_KEY=$(echo ${RESULT_FULL_STRING_SALE_BY_KEY##*.}) # *. 表示从左边开始删除最后（最右边）一个 . 号及左边的所有字符
    #echo "结果字符串的保存位置=${RESULT_FULL_SALE_BY_HOME_KEY}------${RESULT_FULL_SALE_BY_HOME_KEY}"
    LAST_BRANCHS_INFO_JSON="{\"${RESULT_FULL_SALE_BY_PATH_KEY}\": \"${LAST_BRANCHS_INFO_STRING}\"}"
    sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_FULL_SALE_BY_HOME_KEY}" -v "${LAST_BRANCHS_INFO_JSON}" --skip-value-check "true"
    if [ $? != 0 ]; then
        exit 1
    fi
    logSuccessMsg "恭喜:最后获取(.full)markdown:${shouldMarkdown}的 ${PURPLE}.${RESULT_FULL_SALE_BY_HOME_KEY}.${RESULT_FULL_SALE_BY_PATH_KEY} ${GREEN}值(在 ${BLUE}${RESULT_SALE_TO_JSON_FILE_PATH} ${GREEN}文件中)如下:"
    cat ${RESULT_SALE_TO_JSON_FILE_PATH} | jq ".${RESULT_FULL_SALE_BY_HOME_KEY}.${RESULT_FULL_SALE_BY_PATH_KEY}" | jq '.'

    # 去除最后一个字符,即逗号","
    RESULT_FULL_SLIECE_SALE_BY_PATH_KEY="${RESULT_FULL_SALE_BY_PATH_KEY}_slice"
    if [ -n "${Escape_LAST_BRANCH_ARRAY_ONLY_STRING}" ] && [ "${Escape_LAST_BRANCH_ARRAY_ONLY_STRING}" != "[" ]; then
        Escape_LAST_BRANCH_ARRAY_ONLY_STRING=${Escape_LAST_BRANCH_ARRAY_ONLY_STRING: 0:${#Escape_LAST_BRANCH_ARRAY_ONLY_STRING}-1}
    fi
    Escape_LAST_BRANCH_ARRAY_STRING="[${Escape_LAST_BRANCH_ARRAY_ONLY_STRING}]" # 内部已符合转义并加了逗号,现在补充上前后的[]
    Escape_LAST_BRANCH_ARRAY_JSON="{\"${RESULT_FULL_SLIECE_SALE_BY_PATH_KEY}\": ${Escape_LAST_BRANCH_ARRAY_STRING}}"
    sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_FULL_SALE_BY_HOME_KEY}" -v "${Escape_LAST_BRANCH_ARRAY_JSON}" --skip-value-check "true"
    if [ $? != 0 ]; then
        exit 1
    fi
    logSuccessMsg "恭喜:最后获取(.full_slice)markdown:${shouldMarkdown}的 ${PURPLE}.${RESULT_FULL_SALE_BY_HOME_KEY}.${RESULT_FULL_SLIECE_SALE_BY_PATH_KEY} ${GREEN}值(在 ${BLUE}${RESULT_SALE_TO_JSON_FILE_PATH} ${GREEN}文件中)如下:"
    cat ${RESULT_SALE_TO_JSON_FILE_PATH} | jq ".${RESULT_FULL_SALE_BY_HOME_KEY}.${RESULT_FULL_SLIECE_SALE_BY_PATH_KEY}" | jq '.'
fi


# fileValue_origin_withDoubleQuote=${Escape_LAST_BRANCH_ARRAY_ONLY_STRING}
#echo "======fileValue_origin_withDoubleQuote=${fileValue_origin_withDoubleQuote}"
# echo "======fileValue_origin_withDoubleQuote_echo=${fileValue_origin_withDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
# Escape_LAST_BRANCH_ARRAY_ONLY_STRING_noDoubleQuote=${Escape_LAST_BRANCH_ARRAY_ONLY_STRING: 1:${#Escape_LAST_BRANCH_ARRAY_ONLY_STRING}-2} # 去掉前后的双引号
