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
JQ_EXEC=`which jq`

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

    branchName=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
    if echo "${ignoreCheckBranchNameArray[@]}" | grep -wq "${branchName}" &>/dev/null; then
        return 0
    fi
    
    #分支类型
    branchType=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".type") # -r 去除字符串引号
    if [ "${branchType}" == "null" ] || [ -z "${branchType}" ]; then
        typeErrorMessageArray[${#typeErrorMessageArray[@]}]="分支类型 type"
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

    branchName=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
    # if [ -n "${ignoreCheckBranchNameArray}" ] && [[ "${ignoreCheckBranchNameArray[*]}" =~ ${branchName} ]]; then
    if echo "${ignoreCheckBranchNameArray[@]}" | grep -wq "${branchName}" &>/dev/null; then
        # echo "${GREEN}${BLUE}${branchName} ${NC}是可忽略检查的分支${ignoreCheckBranchNameArray[*]}之一"
        return 0
    fi

    
    # echo "✅ PackageNetworkType = $PackageNetworkType"
    

    # 1、---------------------------检查在测试【测试】环境时候的属性
    #提交测试的时间
    branchSubmitTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".submit_test_time") # -r 去除字符串引号
    #echo "$FUNCNAME branchSubmitTestTime=${branchSubmitTestTime}"
    if [ "${branchSubmitTestTime}" == "null" ] || [ -z "${branchSubmitTestTime}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="提测时间 submit_test_time"
    fi
    #负责测试的人员信息
    branchTesterInfo=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".tester") # -r 去除字符串引号
    if [ "${branchTesterInfo}" == "null" ] || [ -z "${branchTesterInfo}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="测试负责人信息 tester"
    else
        branchTesterName=$(echo ${branchTesterInfo} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
        if [ "${branchTesterName}" == "null" ] || [ -z "${branchTesterName}" ]; then
            timeErrorMessageArray[${#timeErrorMessageArray[@]}]="测试负责人姓名 tester.name"
        fi
    fi
    if [ "${PackageNetworkType}" == "test1" ]; then
        # echo "检查在测试【测试】环境时候的属性，检查完毕"
        return
    fi
        

    # 2、---------------------------检查在测试【预生产、生产】环境时候的属性
    #通过测试的时间
    branchPassTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".pass_test_time") # -r 去除字符串引号
    if [ "${branchPassTestTime}" == "null" ] || [ -z "${branchPassTestTime}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="测试环境通过时间 pass_test_time"
    fi
    #合入预生产的时间
    branchMergerPreproductTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".merger_pre_time") # -r 去除字符串引号
    if [ "${branchMergerPreproductTime}" == "null" ] || [ -z "${branchMergerPreproductTime}" ]; then
        timeErrorMessageArray[${#timeErrorMessageArray[@]}]="合入预生产时间 merger_pre_time"
    fi
}






# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -checkBranchMap|--check-branchMap) checkBranchMap=$2; shift 2;;
        -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
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



checkBranchMapType -checkBranchMap "${checkBranchMap}" -pn "${PackageNetworkType}" -ignoreBranchNames "${ignoreCheckBranchNameArray}"
if [ $? != 0 ]; then
    exit_script
fi
# missingPropertyCount=${#typeErrorMessageArray[@]}
# echo "Error:在 ${PackageNetworkType} 环境下缺失type的分支信息如下："
# for ((i=0;i<missingPropertyCount;i+=1))
# {
#     missingProperty=${typeErrorMessageArray[i]}
#     echo "$((i+1)).${missingProperty}"
# }
# exit

checkBranchMapTime -checkBranchMap "${checkBranchMap}" -pn "${PackageNetworkType}" -ignoreBranchNames "${ignoreCheckBranchNameArray}"
if [ $? != 0 ]; then
    exit_script
fi

allErrorMessageArray=()
allErrorMessageArray+=("${typeErrorMessageArray[@]}")
allErrorMessageArray+=("${timeErrorMessageArray[@]}")
missingPropertyCount=${#allErrorMessageArray[@]}
if [ "$missingPropertyCount" -gt 0 ]; then
    ResultMessage="Error:在 ${PackageNetworkType} 环境下缺失 type 或 time 的所有分支信息如下："
    for ((i=0;i<missingPropertyCount;i+=1))
    {
        missingProperty=${allErrorMessageArray[i]}
        ResultMessage+="\n$((i+1)).${missingProperty}"
    }
    printf "%s" "${ResultMessage}"
    exit 1
fi



logSuccessMsg "恭喜：在 ${PackageNetworkType} 环境下的分支信息完整性【时间time】和【类型type】检查结束，且都成功通过了"
