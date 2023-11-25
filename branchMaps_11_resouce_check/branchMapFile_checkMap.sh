#!/bin/bash
:<<!
检查提测、测试、通过后等不同阶段分支的详细信息,如提测时json中的提测时间字段必须有值

脚本的测试使用如下命令：
#Develop_Branchs_FILE_PATH="../example_packing_info/app_branch_info.json"
#ignoreCheckBranchNameArray="(master development dev_publish_out dev_publish_in dev_all)"
#sh branchMapFile_checkMap.sh -branchMapsJsonF "${Develop_Branchs_FILE_PATH}" -ignoreBranchNames "${ignoreCheckBranchNameArray}" -pn "test1"
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
    echo "${GREEN}$1${NC}"
}

function debug_log() {
    if [ "${isRelease}" == true ]; then
        echo "$1"
    fi
}

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

#! /bin/bash
JQ_EXEC=$(which jq)

responseJsonString='{

}'
update_response_with_code_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    while [ -n "$1" ]; do
        case "$1" in
            -code|--code) code=$2; shift 2;;
            -message|--message) message=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done
    responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg code "$code" '. + { "code": $code }')
    responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
    printf "%s" "${responseJsonString}"
}


# 获取指定branch数组的分支信息----检查【类型type】
function checkBranchMapType() {
    while [ -n "$1" ]
    do
        case "$1" in
            -checkBranchMap|--check-branchMap) iBranchMap=$2; shift 2;;
            -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
            -ignoreBranchNames|--ignoreCheckBranchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done
    typeErrorMessageArray=()

    branchName=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
    if echo "${ignoreCheckBranchNameArray[@]}" | grep -wq "${branchName}" &>/dev/null; then
        return 0
    fi
    
    #分支类型
    branchType=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".type") # -r 去除字符串引号
    if [ "${branchType}" == "null" ] || [ -z "${branchType}" ]; then
        typeErrorMessageArray[${#typeErrorMessageArray[@]}]="缺失分支类型 type"
    fi
}


# 获取指定branch数组的分支信息----检查【时间time】
function checkBranchMapTime() {
    while [ -n "$1" ]
    do
        case "$1" in
            -checkBranchMap|--check-branchMap) iBranchMap=$2; shift 2;;
            -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
            -ignoreBranchNames|--ignoreCheckBranchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done

    timeErrorMessageArray=()

    branchName=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
    # if [ -n "${ignoreCheckBranchNameArray}" ] && [[ "${ignoreCheckBranchNameArray[*]}" =~ ${branchName} ]]; then
    if echo "${ignoreCheckBranchNameArray[@]}" | grep -wq "${branchName}" &>/dev/null; then
        # echo "${GREEN}${BLUE}${branchName} ${NC}是可忽略检查的分支${ignoreCheckBranchNameArray[*]}之一"
        return 0
    fi

    
    # echo "✅ PackageNetworkType = $PackageNetworkType"
    

    # 1、---------------------------检查在测试【测试】环境时候的属性
    #提交测试的时间
    branchSubmitTestTime=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".submit_test_time") # -r 去除字符串引号
    #echo "$FUNCNAME branchSubmitTestTime=${branchSubmitTestTime}"
    if [ "${branchSubmitTestTime}" == "null" ] || [ -z "${branchSubmitTestTime}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="缺失提测时间 submit_test_time"
    fi
    #负责测试的人员信息
    branchTesterInfo=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".tester") # -r 去除字符串引号
    if [ "${branchTesterInfo}" == "null" ] || [ -z "${branchTesterInfo}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="缺失测试负责人信息 tester"
    else
        branchTesterName=$(echo "${branchTesterInfo}" | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
        if [ "${branchTesterName}" == "null" ] || [ -z "${branchTesterName}" ]; then
            timeErrorMessageArray[${#timeErrorMessageArray[@]}]="缺失测试负责人姓名 tester.name"
        fi
    fi
    if [ "${PackageNetworkType}" == "test1" ]; then
        # echo "检查在测试【测试】环境时候的属性，检查完毕"
        return
    fi
        

    # 2、---------------------------检查在测试【预生产、生产】环境时候的属性
    #通过测试的时间
    branchPassTestTime=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".pass_test_time") # -r 去除字符串引号
    if [ "${branchPassTestTime}" == "null" ] || [ -z "${branchPassTestTime}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="缺失测试环境通过时间 pass_test_time"
    fi
    #合入预生产的时间
    branchMergerPreproductTime=$(echo "${iBranchMap}" | ${JQ_EXEC} -r ".merger_pre_time") # -r 去除字符串引号
    if [ "${branchMergerPreproductTime}" == "null" ] || [ -z "${branchMergerPreproductTime}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="缺失合入预生产时间 merger_pre_time"
    fi
}



# 检查日期格式是否正确(只能是月日或者年月日)
function getYmdTime() {
    checkedTime="$1"
    # 检查日期格式是否正确
    if [[ $checkedTime =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$ ]]; then
        echo "${checkedTime}"
    elif [[ $checkedTime =~ ^[0-9]{2}\.[0-9]{2}$ ]]; then
        currentYear=$(date +%Y) # 获取当前年份
        checkedTime="${currentYear}.${checkedTime}"
        echo "${checkedTime}"
    else
        echo "您的 ${checkedTime} 日期不是正确的月日或者年月日格式，请检查。"
        exit 1
    fi
}

function formatterDayIndex() {
    # 将星期几转换为中文
    case "$1" in
        Monday) current_day="周一" ;;
        Tuesday) current_day="周二" ;;
        Wednesday) current_day="周三" ;;
        Thursday) current_day="周四" ;;
        Friday) current_day="周五" ;;
        Saturday) current_day="周六" ;;
        Sunday) current_day="周日" ;;
    esac
    echo "${current_day}"
}


# 缺失各周时长消耗的outline（为了打印出来方便写周报）
function checkBranchMapOutlineSpends() {
    while [ -n "$1" ]
    do
        case "$1" in
            -checkBranchMap|--check-branchMap) iBranchMap=$2; shift 2;;
            -checkSpendToDate|--target-date) target_date=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done

    spendErrorMessageArray=()  # 缺失各周时长消耗的outline

    branchName=$(echo "${checkBranchMap}" | jq -r ".name")

    create_time=$(echo "${checkBranchMap}" | jq -r ".create_time") # -r 去除字符串引号
    # echo "create_time=${create_time} ✅"
    create_time=$(getYmdTime "${create_time}")
    if [ $? != 0 ]; then
        echo "${create_time}"
        return
    fi
    # 计算create_time所在的周数
    create_week=$(date -j -f "%Y.%m.%d" "$create_time" +%U)
    create_day=$(date -j -f "%Y.%m.%d" "$create_time" +%A)
    create_day=$(formatterDayIndex "${create_day}")
    # echo "${create_time}位于第 $create_week 周的[${create_day}]"

    # 获取target_date所在的周数
    current_week=$(date -j -f "%Y.%m.%d" "$target_date" +%U)
    current_day=$(formatterDayIndex "${target_date}")
    # echo "${target_date}位于第 $current_week 周的[${current_day}]"

    # 计算create_time到当前时间之间的周数
    create_time_to_now_weekCount=$((current_week-create_week+1))
    # echo "✅ create_time_to_now_weekCount=${create_time_to_now_weekCount}"

    # 解析JSON数据
    outlines=$(echo "$checkBranchMap" | jq -r '.outlines')
    outlinesCount=$(echo "$outlines" | jq -r 'length')
    # echo "✅ outlinesCount=${outlinesCount}"
    for((i=0;i<outlinesCount;i++));
    do
        iOutline=$(echo "${outlines}" | jq -r '.['$i']')
        # echo "iOutline=${iOutline}"
        iOutline_title=$(echo "${iOutline}" | jq -r '.title')
        # echo "iOutline_title=${iOutline_title}"
        iOutline_spends=$(echo "${iOutline}" | jq -r '.weekSpend')
        iOutline_spendCount=$(echo "${iOutline_spends}" | jq -r '. | length')
        if [ -z "${iOutline_spends}" ] || [ "${iOutline_spends}" == "null" ]; then
            iOutlineErrorMessage="\"${iOutline_title}\"在这${create_time_to_now_weekCount}周里各消耗时长都未填写，请为其补上 weekSpendHours 属性及其数组值"
            spendErrorMessageArray[${#spendErrorMessageArray[@]}]=${iOutlineErrorMessage}
            continue
        fi

        # 有填写就行，不用每周都填，因为可能有个需求是前一个月的，后面停了一段时间，现在才又开始，所以以下代码注释掉
        # iOutline_spendsMessage=$(echo "${iOutline_spends}" | jq -r '. | @json')
        # # 比较 iOutline_spendCount 和 create_time_to_now_weekCount
        # if [ "$iOutline_spendCount" -ne $create_time_to_now_weekCount ]; then
        #     spendErrorMessageArray[${#spendErrorMessageArray[@]}]="\"${iOutline_title}\"在这${create_time_to_now_weekCount}周里各消耗时长分别是${iOutline_spendsMessage},数据个数不对"
        #     continue
        # fi

        # for((j=0;j<iOutline_spendCount;j++));
        # do
        #     iOutline_spendHour=$(echo "${iOutline_spends}" | jq -r '.['$j']')
        #     # echo "iOutline_spendHour=${iOutline_spendHour}"
        #     if [ "${iOutline_spendHour}" -gt 40 ]; then
        #         spendErrorMessageArray[${#spendErrorMessageArray[@]}]="\"${iOutline_title}\"在这${create_time_to_now_weekCount}周里您的消耗时长分别是${iOutline_spendsMessage},耗时太长，请留意"
        #     fi
        # done
    done

    missingSpendOutineCount=${#spendErrorMessageArray[@]}
    if [ "${missingSpendOutineCount}" -ne 0 ]; then
        # echo "❌Error:您有 ${missingSpendOutineCount} 个事项缺失各周时长消耗的填写。请检查，使其${create_time_to_now_weekCount}周都有值。"
        # echo "缺失的spend的outline如下："
        for((i=0;i<missingSpendOutineCount;i++));
        do
            missingOutlineErrorMessage=${spendErrorMessageArray[i]}
            # echo "$((i+1)). ${missingOutlineErrorMessage}"
        done
        return
    fi
    echo "恭喜:所有outline的spends的个数与周数相匹配"
}



# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -checkBranchMap|--check-branchMap) checkBranchMap=$2; shift 2;;
        -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
        -skipCheckType|--skip-check-type) skipCheckType=$2; shift 2;;
        -skipCheckTime|--skip-check-time) skipCheckTime=$2; shift 2;;
        -checkSpendToDate|--target-date) target_date=$2; shift 2;;
        -ignoreCheckBranchNames|--ignoreCheck-branchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done


if [ -z "${checkBranchMap}" ]; then
    echo "${RED}Error❌:缺少要检查的分支map${BLUE} -checkBranchMap ${RED}参数，请检查！${NC}"
    exit 1
fi

if [ -z "${PackageNetworkType}" ]; then
    echo "${RED}Error❌:缺少要检查的环境${BLUE} -pn ${RED}参数，请检查！${NC}"
    exit 1
fi


# echo "checkBranchMap=${checkBranchMap}"

if [ "${skipCheckType}" == "true" ]; then
    echo "跳过：您的 -skipCheckType 属性值为true，所以本次不会检查分支中type的填写情况。"
else
    checkBranchMapType -checkBranchMap "${checkBranchMap}" -pn "${PackageNetworkType}" -ignoreBranchNames "${ignoreCheckBranchNameArray}"
    if [ $? != 0 ]; then
        exit_script
    fi
fi
# missingPropertyCount=${#typeErrorMessageArray[@]}
# echo "Error:在 ${PackageNetworkType} 环境下缺失type的分支信息如下："
# for ((i=0;i<missingPropertyCount;i+=1))
# {
#     missingProperty=${typeErrorMessageArray[i]}
#     echo "$((i+1)).${missingProperty}"
# }
# exit

if [ "${skipCheckTime}" == "true" ]; then
    echo "跳过：您的 -skipCheckTime 属性值为true，所以本次不会检查分支中各time的填写情况。"
else
    checkBranchMapTime -checkBranchMap "${checkBranchMap}" -pn "${PackageNetworkType}" -ignoreBranchNames "${ignoreCheckBranchNameArray}"
    if [ $? != 0 ]; then
        exit_script
    fi
fi


if [ -z "${target_date}" ]; then
    echo "跳过：您未设置 -checkSpendToDate 属性，所以本次不会检查分支中各outline的各周时间消耗情况。"
else
    # 缺失各周时长消耗的outline
    checkBranchMapOutlineSpends -checkBranchMap "${checkBranchMap}" -checkSpendToDate "${target_date}"
    if [ $? != 0 ]; then
        exit_script
    fi
fi


allErrorMessageArray=()
allErrorMessageArray+=("${typeErrorMessageArray[@]}")
allErrorMessageArray+=("${timeErrorMessageArray[@]}")
allErrorMessageArray+=("${spendErrorMessageArray[@]}")
missingPropertyCount=${#allErrorMessageArray[@]}
if [ "$missingPropertyCount" -gt 0 ]; then
    ResultMessage=""
    outlineIndexs="①,②,③,④,⑤,⑥,⑦,⑧,⑨,⑩"
    outlineIndexArray=(${outlineIndexs//,/ }) # 使用,替换空格，并形成数组
    for ((i=0;i<missingPropertyCount;i+=1))
    {
        if [ "$missingPropertyCount" -lt ${#outlineIndexArray[@]} ]; then
            smallIndex=${outlineIndexArray[i]}
        else
            smallIndex="⑩"
        fi
        missingProperty=${allErrorMessageArray[i]}
        # if [ $i -gt 0 ]; then
        #     ResultMessage+="\n"
        # fi
        ResultMessage+="${smallIndex}.${missingProperty};"
    }
    printf "%s" "${ResultMessage}"
    exit 1
fi



logSuccessMsg "恭喜：在 ${PackageNetworkType} 环境下的分支信息完整性【时间time】和【类型type】检查结束，且都成功通过了"
