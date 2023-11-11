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
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CategoryFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}  # 使用 %/* 方法可以避免路径上有..
qbase_branchMapFile_checkMap_scriptPath=${CategoryFun_HomeDir_Absolute}/branchMapFile_checkMap.sh



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

    
branchNamesString=$(echo ${branchMapArray} | ${JQ_EXEC} -r '.[].name') # -r 去除字符串引号
branchNameArray=(`echo ${branchNamesString}`)
branchCount=${#branchNameArray[@]}
#echo "branchCount=${branchCount}"
if [ ${branchCount} == 0 ]; then
    echo "branchCount个数为${branchCount}"
    exit 0
fi

missingPropertyBranchNameArray=()
errorMessageArray=()
for ((i=0;i<branchCount;i++))
do
    iBranchMap=$(echo ${branchMapArray} | ${JQ_EXEC} -r ".[$((i))]") # -r 去除字符串引号
    branchName=$(echo ${iBranchMap} | ${JQ_EXEC} -r ".name") # -r 去除字符串引号

    errorMessage=$(sh ${qbase_branchMapFile_checkMap_scriptPath} -checkBranchMap "${iBranchMap}" -pn "${PackageNetworkType}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}")
    if [ $? != 0 ]; then
        missingPropertyBranchNameArray[${#missingPropertyBranchNameArray[@]}]=${branchName}
        iResultMessage=""
        if [ ${#errorMessageArray[@]} -gt 0 ]; then
            iResultMessage+="\n"
        fi
        iResultMessage+="${RED}$((i+1)).${BLUE}${branchName} ${RED}缺失 ${errorMessage} ${RED}；"
        errorMessageArray[${#errorMessageArray[@]}]=${iResultMessage}
    fi
done
#echo "缺失分支属性的分支名分别为 missingPropertyBranchNameArray=${missingPropertyBranchNameArray[*]}"
if [ "${#missingPropertyBranchNameArray[@]}" -gt 0 ]; then
    # 【分支类型type，该类型值为hotfix/feature/optimize/other 中一种【分别对应hotfix(线上修复)/feature(产品需求)/optimize(技术优化)/other(其他)】】
    echo "${RED}Error❌:您有${#missingPropertyBranchNameArray[@]}个分支的json文件有缺失标明的部分，请前往补充后再执行打包。详细缺失信息如下：\n${errorMessageArray[*]}"
    exit 1
fi


logSuccessMsg "恭喜：在 ${PackageNetworkType} 环境下的分支信息完整性【时间time】和【类型type】检查结束，且都成功通过了"