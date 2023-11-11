#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-23 14:58:17
 # @Description: 时间计算的demo
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
parent_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
addBranchMaps_toJsonFile_script_path=${parent_dir_Absolute}/addBranchMaps_toJsonFile.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}



BranceMaps_From_Directory_PATH="${CurrentDIR_Script_Absolute}/featureBrances"
BranchMapAddToJsonFile="${CurrentDIR_Script_Absolute}/app_branch_info.json"
BranchMapAddToKey="package_merger_branchs"
requestBranchNameArray=("chore/branch_get" "optimize/dev_script_pack")
CheckPropertyInNetworkType="product"
ignoreCheckBranchNameArray="(master development dev_publish_out dev_publish_in dev_all)"
shouldDeleteHasCatchRequestBranchFile=false
                            

log_title "获取branchMaps"
echo "${YELLOW}正在执行命令:《 ${BLUE}sh ${addBranchMaps_toJsonFile_script_path} -branchMapsFromDir \"${BranceMaps_From_Directory_PATH}\" -branchMapsAddToJsonF \"${BranchMapAddToJsonFile}\" -branchMapsAddToKey \"${BranchMapAddToKey}\" -requestBranchNamesString \"${requestBranchNameArray[*]}\" -checkPropertyInNetwork \"${CheckPropertyInNetworkType}\" -ignoreCheckBranchNames \"${ignoreCheckBranchNameArray}\" -shouldDeleteHasCatchRequestBranchFile \"${shouldDeleteHasCatchRequestBranchFile}\" ${YELLOW}》${NC}"
errorMessage=$(sh ${addBranchMaps_toJsonFile_script_path} -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -requestBranchNamesString "${requestBranchNameArray[*]}" -checkPropertyInNetwork "${CheckPropertyInNetworkType}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray}" -shouldDeleteHasCatchRequestBranchFile "${shouldDeleteHasCatchRequestBranchFile}")
if [ $? != 0 ]; then
    echo "${RED}${errorMessage}${NC}"
    exit 1
fi
echo "${GREEN}获取branchMaps成功，详情查看${BLUE} ${BranchMapAddToJsonFile} ${GREEN}。${NC}"


