#!/bin/bash
:<<!
检查提测、测试、通过后等不同阶段分支的详细信息,如提测时json中的提测时间字段必须有值

脚本的测试使用如下命令：
#Develop_Branchs_FILE_PATH="../example_packing_info/app_branch_info.json"
#ignoreCheckBranchNameArray="(master development dev_publish_out dev_publish_in dev_all)"
#sh branchMapsFile_checkMap.sh -branchMapsJsonF "${Develop_Branchs_FILE_PATH}" -ignoreBranchNames "${ignoreCheckBranchNameArray}" -pn "test1"
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

#echo "===========进入脚本$0 检查分支的详细信息的完整性(如提交测试时候需要测试时间)==========="


# 获取指定branch数组的分支信息
function checkBranchTimeForArray() {
    while [ -n "$1" ]
    do
        case "$1" in
            -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
            -branchMapArray|--branchMapArray) branchMapArray=$2; shift 2;;
            -ignoreBranchNames|--ignoreCheckBranchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done
#    echo "$FUNCNAME 要忽略检查【时间time】的分支为ignoreBranchNameArray=${ignoreCheckBranchNameArray[*]}"

    # echo "branchMapArray=${branchMapArray}"
    if [ -z "${branchMapArray}" ] || [ "${branchMapArray}" == "null" ]; then
        return 0
    fi
    
    branchNamesString=$(echo ${branchMapArray} | ${JQ_EXEC} -r '.[].name') # -r 去除字符串引号
    branchNameArray=(`echo ${branchNamesString}`)
    branchCount=${#branchNameArray[@]}
    #echo "branchCount=${branchCount}"
    if [ ${branchCount} == 0 ]; then
        echo "branchCount个数为${branchCount}"
        return 0
    fi
    
    # echo "✅ PackageNetworkType = $PackageNetworkType"
    if [ "${PackageNetworkType}" == "test1" ]; then
        for ((i=0;i<branchCount;i++))
        do            
            iBranchMap=$(echo ${branchMapArray} | ${JQ_EXEC} -r ".[$((i))]") # -r 去除字符串引号
                    
            branchName=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号

#            if [ -n "${ignoreCheckBranchNameArray}" ] && [[ "${ignoreCheckBranchNameArray[*]}" =~ ${branchName} ]]; then
            if echo "${ignoreCheckBranchNameArray[@]}" | grep -wq "${branchName}" &>/dev/null; then
                # echo "${GREEN}$((i+1)).${BLUE}${branchName} ${NC}是可忽略检查的分支${ignoreCheckBranchNameArray[*]}之一"
                continue
            fi
            #提交测试的时间
            branchSubmitTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".submit_test_time") # -r 去除字符串引号
            #echo "$FUNCNAME branchSubmitTestTime=${branchSubmitTestTime}"
            if [ "${branchSubmitTestTime}" == "null" ] || [ -z "${branchSubmitTestTime}" ]; then
                missingTestingInfoBranchNameArray[${#missingTestingInfoBranchNameArray[@]}]=${branchName}
                errorMessageArray[${#errorMessageArray[@]}]="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失提测时间 ${BLUE}submit_test_time ${RED}；"
                continue
            fi
            #负责测试的人员信息
            branchTesterInfo=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".tester") # -r 去除字符串引号
            if [ "${branchTesterInfo}" == "null" ] || [ -z "${branchTesterInfo}" ]; then
                missingTestingInfoBranchNameArray[${#missingTestingInfoBranchNameArray[@]}]=${branchName}
                errorMessageArray[${#errorMessageArray[@]}]="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失测试负责人信息 ${BLUE}tester ${RED}；"
                continue
            else
                branchTesterName=$(echo ${branchTesterInfo} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
                if [ "${branchTesterName}" == "null" ] || [ -z "${branchTesterName}" ]; then
                    missingTestingInfoBranchNameArray[${#missingTestingInfoBranchNameArray[@]}]=${branchName}
                    errorMessageArray[${#errorMessageArray[@]}]="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失测试负责人姓名 ${BLUE}tester.name ${RED}；"
                    continue
                fi
            fi
            # echo "${GREEN}$((i+1)).${BLUE}${branchName} ${GREEN}通过，未缺失信息。"
        done
        if [ -n "${missingTestingInfoBranchNameArray}" ]; then
            PackageErrorMessage="您所开发的有${#missingTestingInfoBranchNameArray[@]}个分支,未在其json文件中标明【提交测试的时间】或【负责测试的人员信息】，请前往补充后再执行打包。缺失信息的分支名分别为 ${BLUE}${missingTestingInfoBranchNameArray[*]} ${RED}。\n详细缺失信息如下：\n${errorMessageArray[*]}"
            echo "${RED}Error❌:${PackageNetworkType} 环境下的分支信息完整性【时间time】检查结束,但失败!失败原因如下：${PackageErrorMessage} ${NC}"
            return 1
        else
            echo "--------------------${PackageNetworkType}环境下的分支信息完整性【时间time】检查结束,且成功!"
        fi

        
        
    elif [ "${PackageNetworkType}" == "preproduct" ] || [ "${PackageNetworkType}" == "product" ]; then
        for ((i=0;i<branchCount;i++))
        do
            iBranchMap=$(echo ${branchMapArray} | ${JQ_EXEC} -r ".[$((i))]") # -r 去除字符串引号
                    
            branchName=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号

#            if [ -n "${ignoreCheckBranchNameArray}" ] && [[ "${ignoreCheckBranchNameArray[*]}" =~ ${branchName} ]]; then
            if echo "${ignoreCheckBranchNameArray[@]}" | grep -wq "${branchName}" &>/dev/null; then
                # echo "${GREEN}$((i+1)).${BLUE}${branchName} ${GREEN}是可忽略检查的分支"
                continue
            fi
            
            #通过测试的时间
            branchPassTestTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".pass_test_time") # -r 去除字符串引号
            if [ "${branchPassTestTime}" == "null" ] || [ -z "${branchPassTestTime}" ]; then
                missingTestPassInfoBranchNameArray[${#missingTestPassInfoBranchNameArray[@]}]=${branchName}
                errorMessageArray[${#errorMessageArray[@]}]="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失提测时间 ${BLUE}submit_test_time ${RED}；"
                continue
            fi
            
            #合入预生产的时间
            branchMergerPreproductTime=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".merger_pre_time") # -r 去除字符串引号
            if [ "${branchMergerPreproductTime}" == "null" ] || [ -z "${branchMergerPreproductTime}" ]; then
                missingTestPassInfoBranchNameArray[${#missingTestPassInfoBranchNameArray[@]}]=${branchName}
                errorMessageArray[${#errorMessageArray[@]}]="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失合入预生产时间 ${BLUE}merger_pre_time ${RED}；"
                continue
            fi
            # echo "$((i+1)).${BLUE}${branchName} ${RED}, branchPassTestTime=${branchPassTestTime}, branchMergerPreproductTime=${branchMergerPreproductTime}"
        done
        if [ -n "${missingTestPassInfoBranchNameArray}" ]; then
            PackageErrorMessage="您所开发的有${#missingTestPassInfoBranchNameArray[@]}个分支,未在其json文件中标明【通过测试的时间】或【合入预生产分支的时间】，请前往补充后再执行打包。缺失信息的分支名分别为 ${BLUE}${missingTestPassInfoBranchNameArray[*]} ${RED}。\n详细缺失信息如下：\n${errorMessageArray[*]}"
            echo "${RED}Error❌:${PackageNetworkType} 环境下的分支信息完整性【时间time】检查结束,但失败!失败原因如下：${PackageErrorMessage} ${NC}"
            return 1
        else
            echo "--------------------${PackageNetworkType}环境下的分支信息完整性【时间time】检查结束,且成功!"
        fi
    else
        echo "--------------------${PackageNetworkType}环境下的分支信息完整性【时间time】检查结束:不需要检查,因为脚本中未设置该环境的检查!"
    fi
    
    return 0
}


# 获取指定branch数组的分支信息
function checkBranchTypeForArray() {
    while [ -n "$1" ]
    do
        case "$1" in
            -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
            -branchMapArray|--branchMapArray) branchMapArray=$2; shift 2;;
            -ignoreBranchNames|--ignoreCheckBranchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done
#    echo "$FUNCNAME 要忽略检查【类型type】的分支为ignoreBranchNameArray=${ignoreCheckBranchNameArray[*]}"

    #echo "branchMapArray=${branchMapArray}"
    if [ -z "${branchMapArray}" ] || [ "${branchMapArray}" == "null" ]; then
        return 0
    fi
    
    
    branchNamesString=$(echo ${branchMapArray} | ${JQ_EXEC} -r '.[].name') # -r 去除字符串引号
    branchNameArray=(`echo ${branchNamesString}`)
    branchCount=${#branchNameArray[@]}
    #echo "branchCount=${branchCount}"
    if [ ${branchCount} == 0 ]; then
        # echo "branchCount个数为${branchCount}"
        return 0
    fi
    
    
    for ((i=0;i<branchCount;i++))
    do
        iBranchMap=$(echo ${branchMapArray} | ${JQ_EXEC} -r ".[$((i))]") # -r 去除字符串引号
                
        branchName=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号
        if [ -n "${ignoreCheckBranchNameArray}" ] && [[ "${ignoreCheckBranchNameArray[*]}" =~ ${branchName} ]]; then
            continue
        fi
        #分支类型
        branchType=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".type") # -r 去除字符串引号
        #echo "$FUNCNAME branchType=${branchType}"
        if [ "${branchType}" == "null" ] || [ -z "${branchType}" ]; then
            missingDeclareBranchTypeArray[${#missingDeclareBranchTypeArray[@]}]=${branchName}
            errorMessageArray[${#errorMessageArray[@]}]="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失分支类型 ${BLUE}type ${RED}；"
            continue
        fi
    done
#    echo "缺失分支类型的分支名分别为 missingDeclareBranchTypeArray=${missingDeclareBranchTypeArray[*]}"
    if [ -n "${missingDeclareBranchTypeArray}" ]; then
        PackageErrorMessage="您所开发的有${#missingDeclareBranchTypeArray[@]}个分支,未在其json文件中标明【分支类型type，该类型值为hotfix/feature/optimize/other 中一种【分别对应hotfix(线上修复)/feature(产品需求)/optimize(技术优化)/other(其他)】】，请前往补充后再执行打包。缺失信息的分支名分别为 ${BLUE}${missingDeclareBranchTypeArray[*]} ${RED}。\n详细缺失信息如下：\n${errorMessageArray[*]}"
        echo "${RED}Error❌:${PackageNetworkType} 环境下的分支信息完整性【类型type】检查结束,但失败。失败原因如下：${PackageErrorMessage} ${NC}"
        return 1
    else
        echo "--------------------${PackageNetworkType}环境下的分支信息完整性【类型type】检查结束,且成功!"
    fi
    
    return 0
}





# shell 参数具名化
show_usage="args: [-pn, -branchInfoF, -ignoreCheckBranchs]\
                                  [--package-network-type=, --branch-info-json-file=, --ignoreCheck-branchNameArray=]"

while [ -n "$1" ]
do
    case "$1" in
        -branchMapsJsonF|--branch-maps-json-file) BranchMaps_JsonFilePath=$2; shift 2;;
        -branchMapsJsonK|--branch-maps-json-key) BranchMapsInJsonKey=$2; shift 2;;
        -ignoreCheckBranchNames|--ignoreCheck-branchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
        -pn|--package-network-type) PackageNetworkType=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [ ! -f "${BranchMaps_JsonFilePath}" ]; then
    echo "${RED}Error❌:缺少${BLUE} -branchMapsJsonF ${RED}参数，请检查！${NC}"
    exit 1
fi

if [ -z "${PackageNetworkType}" ]; then
    echo "${RED}Error❌:缺少${BLUE} -pn ${RED}参数，请检查！${NC}"
    exit 1
fi


# echo "${YELLOW}《 ${BLUE}cat \"${BranchMaps_JsonFilePath}\" | ${JQ_EXEC} -r \".${BranchMapsInJsonKey}\" ${YELLOW}》${NC}"
branchMapArray=$(cat "${BranchMaps_JsonFilePath}" | ${JQ_EXEC} -r ".${BranchMapsInJsonKey}") # -r 去除字符串引号
if [ $? != 0 ]; then
    echo "${RED}Error❌:检查分支的详细信息的完整性失败啦。在文件${BLUE} ${BranchMaps_JsonFilePath} ${RED}中获取${BLUE} ${BranchMapsInJsonKey} ${RED}字段的值失败。请检查！${NC}"
    exit_script
fi
# echo "branchMapArray=${branchMapArray}"
if [ -z "${branchMapArray}" ] || [ "${branchMapArray}" == "null" ]; then
    echo "${RED}Error❌:未找到要进行分支完整性检查的分支数组，请检查文件${BLUE} ${BranchMaps_JsonFilePath} ${RED}和其${BLUE} ${BranchMapsInJsonKey} ${RED}字段的值！${NC}"
    exit_script
fi


# echo "正在执行方法(检查分支的时间)：《 checkBranchTimeForArray -pn ${PackageNetworkType} -branchMapArray \"${branchMapArray}\" -ignoreBranchNames \"${ignoreCheckBranchNameArray}\" 》"
errorMsg=$(checkBranchTimeForArray -pn ${PackageNetworkType} -branchMapArray "${branchMapArray}" -ignoreBranchNames "${ignoreCheckBranchNameArray}")
if [ $? != 0 ]; then
    echo "$errorMsg"
    exit_script
fi

errorMsg=$(checkBranchTypeForArray -pn ${PackageNetworkType} -branchMapArray "${branchMapArray}" -ignoreBranchNames "${ignoreCheckBranchNameArray}")
if [ $? != 0 ]; then
    echo "$errorMsg"
    exit_script
fi


logSuccessMsg "恭喜：在 ${PackageNetworkType} 环境下的分支信息完整性【时间time】和【类型type】检查结束，且都成功通过了"
