#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-16 02:31:21
 # @Description: 日期的相关计算方法--用来获取新时间(通过旧时间的加减)
 # @使用示例: sh ./date/calculate_newdate.sh --old-date $old_date --add-value "1" --add-type "second"
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qbase_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qbase_HomeDir_Absolute=${CurrentDIR_Script_Absolute}

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

qbase_cmd=${qbase_HomeDir_Absolute}/qbase.sh
$qbase_cmd -package qbase -packageCodeDirName bin -path "get_package_util"
if [ $? != 0 ]; then
    error_exit_script
fi
$qbase_cmd -package qtool -packageCodeDirName lib -path "branchCheck_selfName"
if [ $? != 0 ]; then
    error_exit_script
fi


log_title "qbase_quickCmd"
qbase_qbase_quickcmd_scriptPath=$qbase_HomeDir_Absolute/qbase_quickCmd.sh
key="getPath calculate_newdate"
key="$qbase_HomeDir_Absolute qbase execCmd calculate_newdate"
oldDate=$(date "+%Y-%m-%d %H:%M:%S")
add_value=10

echo "------------qbase_quickCmd------------1"
echo "${YELLOW}正在执行测试命令(测试qbase_quickcmd)...《${BLUE} $qbase_qbase_quickcmd_scriptPath $key -old-date \"$oldDate\" --add-value \"$add_value\" ${YELLOW}》${NC}"
searchFromDateString=$($qbase_qbase_quickcmd_scriptPath $key -old-date "$oldDate" --add-value "$add_value")
if [ $? != 0 ]; then
    echo "${RED}${searchFromDateString}${NC}"
    exit 1
fi
echo "${searchFromDateString}"

echo "------------qbase_quickCmd------------2"
# 此写法详见 foundation/json2array.sh 中的部分示例
argsJsonString='
[
    "--old-date",
    "'"$oldDate"'",
    "--add-value",
    "'"$add_value"'",
    "--add-type",
    "second"
]
'
echo "${YELLOW}正在执行测试命令(测试qbase_quickcmd带-argsJsonString)...《${BLUE} sh $qbase_qbase_quickcmd_scriptPath ${key} -argsJsonString \"${argsJsonString}\" ${YELLOW}》${NC}"
searchFromDateString=$(sh $qbase_qbase_quickcmd_scriptPath ${key} -argsJsonString "${argsJsonString}")
if [ $? != 0 ]; then
    echo "${RED}${searchFromDateString}${NC}"
    exit 1
fi
echo "${searchFromDateString}"


echo "\n"
log_title "getAppVersionAndBuildNumber"
appVersionAndBuildNumberJson=$(sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getAppVersionAndBuildNumber test)
echo "${GREEN}《给app的版本号和build号》的结果如下：${BLUE} $appVersionAndBuildNumberJson ${NC}"
packageVersion=$(echo ${appVersionAndBuildNumberJson} | jq -r ".version")
packageBuildNumber=$(echo ${appVersionAndBuildNumberJson} | jq -r ".buildNumber")


echo "\n"
log_title "getBranchNamesAccordingToRebaseBranch"
# sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch main --add-value 1 -onlyName true --verbose
# 要使用输出值的时候，不用添加 --verbose
echo "${YELLOW}正在执行命令:《${BLUE} sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch main --add-value 1 -onlyName true test --verbose ${YELLOW}》${NC}"
appVersionAndBuildNumberJson=$(sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch main --add-value 1 -onlyName true)
echo "${GREEN}《获取当前分支【在rebase指定分支后】的所有分支名》的结果如下：${BLUE} $appVersionAndBuildNumberJson ${NC}"
