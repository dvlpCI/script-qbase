#!/bin/bash
:<<!
脚本的测试使用如下命令：

sh ./get10_branch_self_detail_info.sh -commonFunHomeDir "${CommonFun_HomeDir_Absolute}"
!


CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..



qbase_function_log_msg_script_path="${qbase_homedir_abspath}/log/function_log_msg.sh"
source $qbase_function_log_msg_script_path # 为了使用 logResultValueToJsonFile 、 logResultValueToJsonFile

markdownFun_script_file_Absolute="${qbase_homedir_abspath}/markdown/function_markdown.sh"
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
    elif [ "${TEST_STATE}" == 'coding' ]; then
        branchLogFlag="🏃"
    else
        branchLogFlag="🖍"
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
        -shouldShowSpendHours|--should-show-spend-hours) shouldShowSpendHours=$2; shift 2;;
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
else
    shouldMarkdown=$(echo "$shouldMarkdown" | tr '[:upper:]' '[:lower:]') # 将值转换为小写形式
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
getSingleBranchDescription_scriptPath=${CurCategoryFun_HomeDir_Absolute}/get10_branch_self_detail_info_outline.sh
des_info_string=$(sh "$getSingleBranchDescription_scriptPath" -branchMap "${iBranchMap}" --test-state "${testState}" -shouldShowSpendHours "${shouldShowSpendHours}" --should-markdown "${shouldMarkdown}" -resultSaveToJsonF "${RESULT_SALE_TO_JSON_FILE_PATH}" -resultArrayKey "${RESULT_ARRAY_SALE_BY_KEY}")
if [ $? != 0 ]; then
    exit_script
fi 
des_info_string+=" " # 添加空格，避免分支描述中有网页地址，导致以text输出的时候，地址的其他内容被当成地址的一部分
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