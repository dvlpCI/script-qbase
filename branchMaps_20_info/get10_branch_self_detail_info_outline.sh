#!/bin/bash
# 获取指定单个branch的分支概要信息 {name:xxx,outline:yyy},并添加到指定的key中,而不是覆盖（测试此方法，请使用 tssh_branch_detail_info_result.sh 中已实现的单例测试)

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

getOutlineSpend_scriptPath=${CurCategoryFun_HomeDir_Absolute}/get10_branch_self_detail_info_outline_spend.sh

qbase_function_log_msg_script_path="${qbase_homedir_abspath}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultValueToJsonFile

markdownFun_script_file_Absolute="${qbase_homedir_abspath}/markdown/function_markdown.sh"
if [ ! -f "${markdownFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理markdown的脚本文件 ${markdownFun_script_file_Absolute} 不存在，请检查！"
fi

source "${markdownFun_script_file_Absolute}" # 为了使用 markdown_fontColor 等 markdown 方法


function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}


while [ -n "$1" ]
do
    case "$1" in
        -branchMap|--branchMap) branchMap=$2; shift 2;;
        -shouldMD|--should-markdown) shouldMarkdown=$2; shift 2;;
        -resultSaveToJsonF|--result-save-to-json-file-path) RESULT_BRANCH_SALE_TO_JSON_FILE_PATH=$2; shift 2;; # 为简化换行符的保真(而不是显示成换行,导致后面计算数组个数麻烦),将结果保存在的JSON文件
        -resultArrayKey|--result-array-save-by-key) RESULT_ARRAY_SALE_BY_KEY=$2; shift 2;;   # 数组结果,用什么key保存到上述文件
        -testS|--test-state) TEST_STATE=$2; shift 2;;   # 这个分支的当前测试状态(测试中、测试通过显示不同颜色)
        --) continue ;;
        *) break ;;
    esac
done

if [ -z "${branchMap}" ]; then
    echo "您的 -branchMap 参数不能为空，请检查"
    exit 0
fi

if [ "${TEST_STATE}" == 'test_prefect' ]; then
    markdownFontColor="info"
elif [ "${TEST_STATE}" == 'test_pass' ]; then
    markdownFontColor="info"
elif [ "${TEST_STATE}" == 'test_submit' ]; then
    markdownFontColor="warning"
else
    markdownFontColor="warning"
fi

branchDesResult=$(echo "${branchMap}" | jq -r ".des") # -r 去除字符串引号
branchOutlinesString=$(echo "${branchMap}" | jq -r ".outlines") # -r 去除字符串引号
if [ -z "${branchDesResult}" ] && [ -z "${branchOutlinesString}" ]; then
    Normal_BRANCH_DESCRIPT_STRING_VALUE="无描述和概要"
    Escape_BRANCH_DESCRIPT_STRING_VALUE="[]"
    printf "%s" "${Normal_BRANCH_DESCRIPT_STRING_VALUE}"
    exit 0
fi


#echo "------------分支描述或概要至少一个有值-------------"
Normal_BRANCH_DESCRIPT_STRING_VALUE=''
Escape_BRANCH_DESCRIPT_STRING_VALUE="["
# 🖍：非常重要的注释(一定不要删)：经在json_string下的test里的测试脚本 test_sh_json_string.sh 中，对数组元素进行 markdown，应该在遍历markdown的过程中就遍历转义并拼接的字符串，而不能在遍历markdown的结束后，使用新的markdown元素组成的数组来遍历转义并拼接。
if [ -n "${branchDesResult}" ] && [ "${branchDesResult}" != "详见outlines" ]; then
    branchDesResult=$(markdown_fontColor "${shouldMarkdown}" "${branchDesResult}" "${markdownFontColor}")
    Normal_BRANCH_DESCRIPT_STRING_VALUE+="${branchDesResult}\n" # 字符串拼接，不用转义
    Escape_BRANCH_DESCRIPT_STRING_VALUE+="\"${branchDesResult}\","  # 要转义
fi

debug_log "分支的所有描述如下：${branchOutlinesString}"
if [ -n "${branchOutlinesString}" ]; then
    branchOutlinesCount=$(echo "${branchMap}" | jq -r ".outlines|length")
    # echo "branchOutlinesCount=${branchOutlinesCount}"
    
    outlineIndexs="①,②,③,④,⑤,⑥,⑦,⑧,⑨,⑩"
    outlineIndexArray=(${outlineIndexs//,/ }) # 使用,替换空格，并形成数组
    #echo "***********************outlineIndexArray=${outlineIndexArray[*]}"
    
    for ((branchOutlineIndex=0;branchOutlineIndex<branchOutlinesCount;branchOutlineIndex++))
    do
        iBranchOutline_String=$(echo "${branchMap}" | jq -r ".outlines[$branchOutlineIndex]")
        # echo "$((branchOutlineIndex+1)) iBranchOutline_String=${iBranchOutline_String}"
        
        if [ $branchOutlineIndex -lt ${#outlineIndexArray[@]} ]; then
            iBranchOutlineIndex=${outlineIndexArray[branchOutlineIndex]}
        else
            iBranchOutlineIndex="⑩"
        fi
        iBranchOutlineTitle=$(echo "${iBranchOutline_String}" | jq -r ".title")
        iBranchOutlineUrl=$(echo "${iBranchOutline_String}" | jq -r ".url")
        if [ -n "${iBranchOutlineUrl}" ] && [ "${iBranchOutlineUrl}" != "null" ]; then
            if [ "${shouldMarkdown}" == "true" ]; then
                iBranchOutlineLog="${iBranchOutlineIndex}[${iBranchOutlineTitle}](${iBranchOutlineUrl})"
            else
                iBranchOutlineLog="${iBranchOutlineIndex}${iBranchOutlineTitle} ${iBranchOutlineUrl}"
            fi
        else
            iBranchOutlineLog="${iBranchOutlineIndex}${iBranchOutlineTitle}"
        fi
        weekSpendHours=$(sh "$getOutlineSpend_scriptPath" -outline "${iBranchOutline_String}")
        if [ $? != 0 ]; then
            weekSpendHours=0
            # echo "${weekSpendHours}"
        fi
        iBranchOutlineLog+="[${weekSpendHours}]"
        #echo "$((branchOutlineIndex+1)) iBranchOutlineLog=${iBranchOutlineLog}"
        iBranchOutlineLog=$(markdown_fontColor "${shouldMarkdown}" "${iBranchOutlineLog}" "${markdownFontColor}")

        # 重点，因为\n没法直接保真，所以要转义下(已在test_sh_brances_info_log.sh中测试过)
        Normal_BRANCH_DESCRIPT_STRING_VALUE+="${iBranchOutlineLog}\n" # 字符串拼接，不用转义
        Escape_BRANCH_DESCRIPT_STRING_VALUE+="\"${iBranchOutlineLog}\","  # 要转义
    done
fi

# 去除最后两个字符,即换行符"\n"
if [ ${#Normal_BRANCH_DESCRIPT_STRING_VALUE} -gt 1 ]; then 
    Normal_BRANCH_DESCRIPT_STRING_VALUE=${Normal_BRANCH_DESCRIPT_STRING_VALUE: 0:${#Normal_BRANCH_DESCRIPT_STRING_VALUE}-2}
fi

#     # 去除最后一个字符,即逗号","
#     if [ -n "${Escape_BRANCH_DESCRIPT_STRING_VALUE}" ] && [ "${Escape_BRANCH_DESCRIPT_STRING_VALUE}" != "[" ]; then
#         Escape_BRANCH_DESCRIPT_STRING_VALUE=${Escape_BRANCH_DESCRIPT_STRING_VALUE: 0:${#Escape_BRANCH_DESCRIPT_STRING_VALUE}-1}
#     fi
#     Escape_BRANCH_DESCRIPT_STRING_VALUE+="]"

#     #echo "=======当前分支的描述如下：\n无转义Normal_BRANCH_DESCRIPT_STRING_VALUE=${Normal_BRANCH_DESCRIPT_STRING_VALUE}\n有转义Escape_BRANCH_DESCRIPT_STRING_VALUE=${Escape_BRANCH_DESCRIPT_STRING_VALUE}"


#     if [ -f "${RESULT_BRANCH_SALE_TO_JSON_FILE_PATH}" ] && [ -n "${Escape_BRANCH_DESCRIPT_STRING_VALUE}" ]; then
# #        BRANCH_OUTLINES_LOG_JSON="{\"${branchName}\": ${Escape_BRANCH_DESCRIPT_STRING_VALUE}}"
#         BRANCH_OUTLINES_ELEMENT_LOG_JSON="{\"name\": \"${branchName}\", \"outline\": ${Escape_BRANCH_DESCRIPT_STRING_VALUE}}"
#         BRANCH_OUTLINES_LOG_JSON="[${BRANCH_OUTLINES_ELEMENT_LOG_JSON}]"
#         debug_log "正在执行命令(测试分支信息的保存)：《 sh ${JsonUpdateFun_script_file_Absolute} -f \"${RESULT_BRANCH_SALE_TO_JSON_FILE_PATH}\" -k \"${RESULT_ARRAY_SALE_BY_KEY}\" -v \"${BRANCH_OUTLINES_LOG_JSON}\" --skip-value-check \"true\" 》"
#         sh ${JsonUpdateFun_script_file_Absolute} -f "${RESULT_BRANCH_SALE_TO_JSON_FILE_PATH}" -k "${RESULT_ARRAY_SALE_BY_KEY}" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
#         if [ $? != 0 ]; then
#             return 1
#         fi
#         if [ "${isRelease}" == true ]; then
#             echo "恭喜:最后获取(.branch此时更新为)markdown:${shouldMarkdown}的 ${PURPLE}.${RESULT_ARRAY_SALE_BY_KEY} ${GREEN}值(在 ${BLUE}${RESULT_BRANCH_SALE_TO_JSON_FILE_PATH} ${GREEN}文件中)如下:"
#             cat ${RESULT_BRANCH_SALE_TO_JSON_FILE_PATH} | jq ".${RESULT_ARRAY_SALE_BY_KEY}" | jq '.'
#         fi
#     fi


printf "%s" "${Normal_BRANCH_DESCRIPT_STRING_VALUE}"