#!/bin/bash
:<<!
脚本的测试使用如下命令：

sh ./get10_branch_self_detail_info.sh -commonFunHomeDir "${CommonFun_HomeDir_Absolute}"
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
# CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
# echo "CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute} ✅"


qbase_function_log_msg_script_path="${CommonFun_HomeDir_Absolute}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultValueToJsonFile

markdownFun_script_file_Absolute="${CommonFun_HomeDir_Absolute}/markdown/function_markdown.sh"
if [ ! -f "${markdownFun_script_file_Absolute}" ];then
    echo "❌Error:您的处理markdown的脚本文件 ${markdownFun_script_file_Absolute} 不存在，请检查！"
fi

source "${markdownFun_script_file_Absolute}" # 为了使用 markdown_fontColor 等 markdown 方法



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

# isRelease=true
function debug_log() {
    if [ "${isRelease}" == true ]; then
        echo "$1"
    fi
}

debug_log_escaped_jsonString() {
    if [ "${isRelease}" == true ]; then
        echo "✅当前的值转义后为: ${BLUE}${1}${NC}"
    fi
}

function exit_script() {
    exit 1
}

#! /bin/bash
JQ_EXEC=`which jq`


function getBranchPersonnelInformation() {
    PersonnelJsonMap=$1
    PersonnelKey=$2
    
    specialPersonMap=$(echo ${PersonnelJsonMap} | ${JQ_EXEC} -r --arg PersonnelKey "$PersonnelKey" '.[$PersonnelKey]')
    personnelLogResult=''
    if [ "${specialPersonMap}" != "null" ] && [ -n "${specialPersonMap}" ]; then
        branchTesterName=$(echo ${specialPersonMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
        if [ "${branchTesterName}" != "null" ] && [ -n "${branchTesterName}" ]; then
            personnelLogResult+="@${branchTesterName}"
        fi
    fi
}



# 获取指定单个branch的分支概要信息 {name:xxx,outline:yyy},并添加到指定的key中,而不是覆盖（测试此方法，请使用 tssh_branch_detail_info_result.sh 中已实现的单例测试)
function getSingleBranchDescription() {
    #echo "$FUNCNAME"
    while [ -n "$1" ]
    do
        case "$1" in
            -branchMap|--branchMap) branchMap=$2; shift 2;;
            -shouldMD|--should-markdown) shouldMarkdown=$2; shift 2;;
            -resultSaveToJsonF|--result-save-to-json-file-path) RESULT_BRANCH_SALE_TO_JSON_FILE_PATH=$2; shift 2;; # 为简化换行符的保真(而不是显示成换行,导致后面计算数组个数麻烦),将结果保存在的JSON文件
            -resultArrayKey|--result-array-save-by-key) RESULT_ARRAY_SALE_BY_KEY=$2; shift 2;;   # 数组结果,用什么key保存到上述文件
            -testS|--test-state) TEST_STATE=$2; shift 2;;   # 这个分支的当前测试状态(测试中、测试通过显示不同颜色)
            --) break ;;
            *) echo $1,$2; break ;;
        esac
    done


    if [ "${TEST_STATE}" == 'test_prefect' ]; then
        markdownFontColor="info"
    elif [ "${TEST_STATE}" == 'test_pass' ]; then
        markdownFontColor="info"
    elif [ "${TEST_STATE}" == 'test_submit' ]; then
        markdownFontColor="warning"
    else
        markdownFontColor="warning"
    fi
    
    branchDesResult=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".des") # -r 去除字符串引号
    branchOutlinesString=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".outlines") # -r 去除字符串引号
    if [ -z "${branchDesResult}" ] && [ -z "${branchOutlinesString}" ]; then
        Normal_BRANCH_DESCRIPT_STRING_VALUE=""
        Escape_BRANCH_DESCRIPT_STRING_VALUE="[]"
        echo "------------分支描述和概要都是空-------------\n${branchMap}"
        return 0
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
    
    if [ -n "${branchOutlinesString}" ]; then
        branchOutlinesCount=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".outlines|length")
        #echo "branchOutlinesCount=${branchOutlinesCount}"
        
        outlineIndexs="①,②,③,④,⑤,⑥,⑦,⑧,⑨,⑩"
        outlineIndexArray=(${outlineIndexs//,/ }) # 使用,替换空格，并形成数组
        #echo "***********************outlineIndexArray=${outlineIndexArray[*]}"
        
        for ((branchOutlineIndex=0;branchOutlineIndex<branchOutlinesCount;branchOutlineIndex++))
        do
            iBranchOutline_String=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".outlines[$branchOutlineIndex]")
            #echo "$((branchOutlineIndex+1)) iBranchOutline_String=${iBranchOutline_String}"
            
            if [ $branchOutlineIndex -lt ${#outlineIndexArray[@]} ]; then
                iBranchOutlineIndex=${outlineIndexArray[branchOutlineIndex]}
            else
                iBranchOutlineIndex="⑩"
            fi
            iBranchOutlineTitle=$(echo ${iBranchOutline_String} | ${JQ_EXEC} -r ".title")
            iBranchOutlineUrl=$(echo ${iBranchOutline_String} | ${JQ_EXEC} -r ".url")
            if [ -n "${iBranchOutlineUrl}" ] && [ "${iBranchOutlineUrl}" != "null" ]; then
                if [ "${shouldMarkdown}" == "true" ]; then
                    iBranchOutlineLog="${iBranchOutlineIndex}[${iBranchOutlineTitle}](${iBranchOutlineUrl})"
                else
                    iBranchOutlineLog="${iBranchOutlineIndex}${iBranchOutlineTitle} ${iBranchOutlineUrl}"
                fi
            else
                iBranchOutlineLog="${iBranchOutlineIndex}${iBranchOutlineTitle}"
            fi
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
}


function getSingleBranchLog_flag() {
    iBranchMap=$1
    TEST_STATE=$2
    shouldMarkdown=$3

    #负责测试的人员信息
    getBranchPersonnelInformation "${iBranchMap}" "tester" # branchMap 变量需要添加引号，避免有空格影响了传入的参数的个数
    tester_info_string=${personnelLogResult}

    #提交测试的时间
    branchSubmitTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".submit_test_time") # -r 去除字符串引号

    branchLogFlag='null'
    if [ "${TEST_STATE}" == 'test_prefect' ]; then
        # ①添加标记📌，方便区分分支测试进展
        branchLogFlag="✅"
    
    elif [ "${TEST_STATE}" == 'test_pass' ]; then
        branchLogFlag="👌🏻"
        
    elif [ "${TEST_STATE}" == 'test_submit' ]; then
        branchLogFlag="❓"
        
        branchLogFlag+="【"  #开始标记
        # 已提测多长时间
        days_cur_to_MdDate_script_path=$(qbase -path "days_cur_to_MdDate")
        testDays=$(sh ${days_cur_to_MdDate_script_path} --Md_date "${branchSubmitTestTime}")
        #echo "${branchName}分支已提测${testDays}天"
        if [ $testDays -gt 1 ]; then
            branchLogFlag+="${testDays}天"
        else
            branchLogFlag+="今天" # 方便知道这是今天新增的提测
        fi
        
        testerName=${tester_info_string}
        if [ -n "${testerName}" ]; then
            testerName=$(markdown_fontColor "${shouldMarkdown}" "${testerName}" "warning")
            branchLogFlag+="${testerName}"
        fi
        branchLogFlag+="】"  #结束标记
    fi
}


function getSingleBranchLog_time() {
    iBranchMap=$1
    testState=$2
    showBranchTimeLog=$3
    shouldMarkdown=$4


    #创建分支的时间
    branchCodingTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".create_time") # -r 去除字符串引号
    #提交测试的时间
    branchSubmitTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".submit_test_time") # -r 去除字符串引号
    #通过测试的时间
    branchPassTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".pass_test_time") # -r 去除字符串引号
    #合入预生产的时间
    branchMergerPreproductTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".merger_pre_time") # -r 去除字符串引号


    branchTimeLogResult=''
    if [ ${showBranchTimeLog} == 'all' ]; then
        if [ ${testState} == 'test_prefect' ]; then
            branchTimeLogResult+="[${branchSubmitTestTime}已提测]"
            branchTimeLogResult+="[${branchPassTestTime}已测试通过]"
            branchTimeLogResult+="[${branchMergerPreproductTime}已合入预生产分支]"
        elif [ ${testState} == 'test_pass' ]; then
            branchTimeLogResult+="[${branchSubmitTestTime}已提测]"
            branchTimeLogResult+="[${branchPassTestTime}已测试通过]"
        elif [ ${testState} == 'test_submit' ]; then
            branchTimeLogResult+="[${branchSubmitTestTime}已提测]"
        elif [ ${testState} == 'coding' ]; then
            branchTimeLogResult+="[${branchCodingTime}开发中]"
        fi
    elif [ ${showBranchTimeLog} == 'only_last' ]; then
        if [ ${testState} == 'test_prefect' ]; then
            branchTimeLogResult+="[✅${branchMergerPreproductTime}]"
        elif [ ${testState} == 'test_pass' ]; then
            branchTimeLogResult+="[👌🏻${branchPassTestTime}]"
        elif [ ${testState} == 'test_submit' ]; then
            branchTimeLogResult+="[❓${branchSubmitTestTime}]"
        elif [ ${testState} == 'coding' ]; then
            branchTimeLogResult+="[${branchCodingTime}开发中]"
        fi
    elif [ ${showBranchTimeLog} == 'none' ]; then
        branchTimeLogResult=''
    fi
    branchTimeLogResult=$(markdown_fontColor "${shouldMarkdown}" "${branchTimeLogResult}" "comment")
}

function getSingleBranchLog_at() {
    iBranchMap=$1
    shouldMarkdown=$2

    #负责测试的人员信息
    getBranchPersonnelInformation "${iBranchMap}" "tester" # branchMap 变量需要添加引号，避免有空格影响了传入的参数的个数
    tester_info_string=${personnelLogResult}

    #答疑者的人员信息
    getBranchPersonnelInformation "${iBranchMap}" "answer" # branchMap 变量需要添加引号，避免有空格影响了传入的参数的个数
    answer_info_string=${personnelLogResult}

    branchAtLogResult=''
    #答疑者的人员信息
    if [ -n "${answer_info_string}" ]; then
        personnelLogResult=$(markdown_fontColor "${shouldMarkdown}" "${answer_info_string}" "comment")
        branchAtLogResult+="${personnelLogResult}"
    fi
    
    #负责测试的人员信息
    if [ -n "${tester_info_string}" ]; then
        personnelLogResult=$(markdown_fontColor "${shouldMarkdown}" "${tester_info_string}" "comment")
        branchAtLogResult+="${personnelLogResult}"
    fi
}

function getSingleBranchLog_testState () {
    iBranchMap=$1

    # 1、获取测试状态，后面好根据不同的测试状态显示不同的样式
    testStateResult="coding" # 开发中
    #提交测试的时间
    branchSubmitTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".submit_test_time") # -r 去除字符串引号
    if [ "${branchSubmitTestTime}" != "null" ] && [ -n "${branchSubmitTestTime}" ]; then
        branchTimeLogResult+="[${branchSubmitTestTime}已提测]"
        testStateResult='test_submit'
    fi
    
    #通过测试的时间
    branchPassTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".pass_test_time") # -r 去除字符串引号
    if [ "${branchPassTestTime}" != "null" ] && [ -n "${branchPassTestTime}" ]; then
        branchTimeLogResult+="[${branchPassTestTime}已测试通过]"
        testStateResult='test_pass'
    fi
    
    #合入预生产的时间
    branchMergerPreproductTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".merger_pre_time") # -r 去除字符串引号
    if [ "${branchMergerPreproductTime}" != "null" ] && [ -n "${branchMergerPreproductTime}" ]; then
        branchTimeLogResult+="[${branchMergerPreproductTime}已合入预生产分支]"
        testStateResult='test_prefect'
    fi

    if [ "${testStateResult}" == "unknow" ]; then # 目前无此项，默认创建完分支即进入开发中状态
        echo "${RED}❌测试状态未获取到，请检查\n${BLUE} ${iBranchMap} ${RED}\n使其至少含有${BLUE} submit_test_time \ pass_test_time \ merger_pre_time ${RED}中的一个，且有值。${NC}"
        return 1
    fi
}


# 获取指定单个branch的分支信息,并添加(而不是覆盖)保存到指定文件的指定key中
# shell 参数具名化
show_usage="args: [-commonFunHomeDir, -branchInfoF, -envInfoF, -requestFors, -comScriptHomeDir, -resultSaveToJsonF]\
                                  [--common-fun-home-dir-absolute=, --branch-info-json-file=, --environment-json-file=, -request-for-log-types=, --common-script-home-dir=, --result-save-to-json-file-path=]"


while [ -n "$1" ]
do
    case "$1" in
        -iBranchMap|--iBranchMap) iBranchMap=$2; shift 2;;
        -showFlag|--show-branchLog-Flag) showBranchLogFlag=$2; shift 2;;
        -showName|--show-branchName) showBranchName=$2; shift 2;;
        -showTime|--show-branchTimeLog) showBranchTimeLog=$2; shift 2;;
        -showAt|--show-branchAtLog) showBranchAtLog=$2; shift 2;;
        -shouldMD|--should-markdown) shouldMarkdown=$2; shift 2;;
        -resultSaveToJsonF|--result-save-to-json-file-path) RESULT_SALE_TO_JSON_FILE_PATH=$2; shift 2;; # 为简化换行符的保真(而不是显示成换行,导致后面计算数组个数麻烦),将结果保存在的JSON文件
        -resultArrayKey|--result-array-save-by-key) RESULT_ARRAY_SALE_BY_KEY=$2; shift 2;;   # 数组结果,用什么key保存到上述文件
        --) break ;;
        *) break ;;
    esac
done


if [ -z "${iBranchMap}" ]; then
    Normal_BRANCH_LOG_STRING_VALUE=''
    echo "${RED}Error:要获取的分支的map数据为空，请检查 ${BLUE}-iBranchMap ${RED}参数！${NC}"
    exit_script
fi

if [ -z "${shouldMarkdown}" ] ; then
    shouldMarkdown="false"
fi

# 1、获取测试状态，后面好根据不同的测试状态显示不同的样式
getSingleBranchLog_testState "${iBranchMap}"
if [ $? != 0 ]; then
    exit_script
fi
testState=${testStateResult}
debug_log "✅哈哈哈 1测试状态:${testState}"

# 2、获取各种信息，待后面组装使用
# ①添加标记📌，方便区分分支测试进展（需要 tester_info_string）
getSingleBranchLog_flag "${iBranchMap}" "${testState}" "${shouldMarkdown}"
if [ $? != 0 ]; then
    exit_script
fi
flag_info_string=${branchLogFlag}
debug_log "✅哈哈哈 2①:${flag_info_string}"

# ②分支名
branchName=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
# branchName=$(markdown_code "${shouldMarkdown}" "${branchName}")
if [ "${testState}" == 'test_prefect' ]; then
    markdownFontColor="info"
elif [ "${testState}" == 'test_pass' ]; then
    markdownFontColor="info"
elif [ "${testState}" == 'test_submit' ]; then
    markdownFontColor="warning"
elif [ "${testState}" == 'coding' ]; then
    markdownFontColor="warning"
else
    markdownFontColor="warning"
fi
branchName=$(markdown_fontColor "${shouldMarkdown}" "${branchName}" "${markdownFontColor}")
debug_log "✅哈哈哈 2②:${branchName}"

# ③分支描述 {name:xxx,outline:yyy} ,并添加(而不是覆盖)保存到指定文件的指定key中
getSingleBranchDescription -branchMap "${iBranchMap}" --test-state "${testState}" --should-markdown "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultArrayKey "${RESULT_ARRAY_SALE_BY_KEY}"
if [ $? != 0 ]; then
    exit_script
fi 
des_info_string=${Normal_BRANCH_DESCRIPT_STRING_VALUE}
# debug_log "✅哈哈哈 2③:${des_info_string}"
# printf "%s" "${des_info_string}"
# logResultObjectStringToJsonFile "${des_info_string}"
# exit

# ④时间线
getSingleBranchLog_time "${iBranchMap}" "${testState}" "${showBranchTimeLog}" "${shouldMarkdown}"
if [ $? != 0 ]; then
    exit_script
fi
timeline_info_string=${branchTimeLogResult}
debug_log "✅哈哈哈 2④:${timeline_info_string}"

# ⑤人员信息
getSingleBranchLog_at "${iBranchMap}" "${shouldMarkdown}"
if [ $? != 0 ]; then
    exit_script
fi
at_info_string=${branchAtLogResult}
debug_log "✅哈哈哈 2⑤:${at_info_string}"




Normal_BRANCH_LOG_STRING_VALUE='' # 赋值前先清空
# ①添加标记📌，方便区分分支测试进展
if [ ${showBranchLogFlag} == 'true' ] && [ -n "${flag_info_string}" ] && [ "${flag_info_string}" != 'null' ]; then
    Normal_BRANCH_LOG_STRING_VALUE+="${flag_info_string}"
fi
debug_log_escaped_jsonString "${Normal_BRANCH_LOG_STRING_VALUE}"

# ②是否添加分支名
if [ "${showBranchName}" == "true" ]; then
    Normal_BRANCH_LOG_STRING_VALUE+="${branchName}:"
fi
debug_log_escaped_jsonString "${Normal_BRANCH_LOG_STRING_VALUE}"

# ④是否添加时间线
if [ -n "${timeline_info_string}" ] && [ "${timeline_info_string}" != 'null' ]; then
    if [ ${showBranchTimeLog} == 'all' ]; then
        Normal_BRANCH_LOG_STRING_VALUE="${Normal_BRANCH_LOG_STRING_VALUE}${timeline_info_string}"   # 显示所有时间的时候，时间放后面
    elif [ ${showBranchTimeLog} == 'only_last' ]; then
        Normal_BRANCH_LOG_STRING_VALUE="${timeline_info_string}${Normal_BRANCH_LOG_STRING_VALUE}"  # 只显示最后时间的时候，时间放前面
    fi
fi
debug_log_escaped_jsonString "${Normal_BRANCH_LOG_STRING_VALUE}"

# ⑤是否添加at人员
#需求方demander\开发者developer\测试人员tester\答疑者answer
if [ ${showBranchLogFlag} == 'true' ] && [ -n "${at_info_string}" ] && [ "${at_info_string}" != 'null' ]; then
    Normal_BRANCH_LOG_STRING_VALUE+="${at_info_string}"
fi
debug_log_escaped_jsonString "${Normal_BRANCH_LOG_STRING_VALUE}"

# ③添加分支描述
# 之前的内容存在，且超过10个字符，才需要换行
if [ -n "${Normal_BRANCH_LOG_STRING_VALUE}" ] && [ ${#Normal_BRANCH_LOG_STRING_VALUE} -gt 10 ]; then
    if [ "${shouldMarkdown}" == "true" ]; then
        Normal_BRANCH_LOG_STRING_VALUE+="\n"
    else
        Normal_BRANCH_LOG_STRING_VALUE+="\n"
    fi
fi
Normal_BRANCH_LOG_STRING_VALUE+="${des_info_string}"
debug_log_escaped_jsonString "${Normal_BRANCH_LOG_STRING_VALUE}"


resultValue="${Normal_BRANCH_LOG_STRING_VALUE}"
# resultValue="{\"name\": \"${branchName}\", \"outline\": \"${Normal_BRANCH_LOG_STRING_VALUE}\"}"


# 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。
printf "%s" "${resultValue}"
# logResultValueToJsonFile "${resultValue}"