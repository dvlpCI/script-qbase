#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-11 16:51:53
 # @Description: 检查提测、测试、通过后等不同阶段分支的详细信息,如提测时json中的提测时间字段必须有值 的demo
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
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..
workspace=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qbase_branchMapFile_checkMap_scriptPath=${CategoryFun_HomeDir_Absolute}/branchMapFile_checkMap.sh
qbase_branchMapsFile_checkMap_scriptPath=${CategoryFun_HomeDir_Absolute}/branchMapsFile_checkMap.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}


log_title "检查branchMap在各环境下的属性"
Example_BranchMap_FILE_PATH="${Example_HomeDir_Absolute}/example_branchMapFile_checkMap.json"
checkBranchMap=$(cat "${Example_BranchMap_FILE_PATH}" | jq '.')
PackageNetworkType="product"
errorMessage=$(sh ${qbase_branchMapFile_checkMap_scriptPath} -checkBranchMap "${checkBranchMap}" -pn "${PackageNetworkType}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}")
if [ $? != 0 ]; then
    echo "${RED}Error:在 ${PackageNetworkType} 环境下缺失 type 或 time 的所有分支信息如下：\n${errorMessage}${NC}"
else
    echo "${GREEN}恭喜：检查branchMap在${BLUE} ${PackageNetworkType} ${GREEN}环境下的属性未缺失信息。${NC}"
fi



log_title "检查branchMaps在各环境下的属性"
Develop_Branchs_FILE_PATH="${Example_HomeDir_Absolute}/example_branchMapsFile_checkMap.json"
BranchMapsInJsonKey="package_merger_branchs"
ignoreCheckBranchNameArray="(master development dev_publish_out dev_publish_in dev_all)"
PackageNetworkType="product"
echo "${YELLOW}正在执行命令(检查提测、测试、通过后等不同阶段分支的详细信息,如提测时json中的提测时间字段必须有值):《${BLUE} sh ${qbase_branchMapsFile_checkMap_scriptPath} -branchMapsJsonF \"${Develop_Branchs_FILE_PATH}\" -branchMapsJsonK \"${BranchMapsInJsonKey}\" -ignoreCheckBranchNames \"${ignoreCheckBranchNameArray[*]}\" -pn \"${PackageNetworkType}\" ${YELLOW}》${NC}"
errorMessage=$(sh ${qbase_branchMapsFile_checkMap_scriptPath} -branchMapsJsonF "${Develop_Branchs_FILE_PATH}" -branchMapsJsonK "${BranchMapsInJsonKey}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}" -pn "${PackageNetworkType}")
if [ $? != 0 ]; then
    echo "${RED}${errorMessage}${NC}"
    exit 1
fi
echo "${GREEN}恭喜：检查branchMaps通过，在 ${PackageNetworkType} 环境下未缺失信息。${NC}"


