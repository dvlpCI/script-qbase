#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-11 00:49:42
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

workspace="/Users/lichaoqian/Project/XXX/mobile_flutter_wish"
BranceMaps_From_Directory_PATH="${workspace}/bulidScript/featureBrances"
BranchMapAddToJsonFile="${workspace}/bulidScript/app_branch_info.json"
BranchMapAddToKey="feature_brances"
requestBranchNameArray=("chore/pack" "bugfix/online_hing")


log_title "获取branchMaps"
echo "${YELLOW}正在执行命令:《 ${BLUE}sh ${CurrentDIR_Script_Absolute}/addBranchMaps_toJsonFile.sh -branchMapsFromDir \"${BranceMaps_From_Directory_PATH}\" -branchMapsAddToJsonF \"${BranchMapAddToJsonFile}\" -branchMapsAddToKey \"${BranchMapAddToKey}\" -requestBranchNamesString \"${requestBranchNameArray[*]}\" ${YELLOW}》${NC}"
errorMessage=$(sh ${CurrentDIR_Script_Absolute}/addBranchMaps_toJsonFile.sh -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -requestBranchNamesString "${requestBranchNameArray[*]}")
if [ $? != 0 ]; then
    echo "${RED}${errorMessage}${NC}"
    exit 1
fi
echo "${GREEN}获取branchMaps成功，详情查看 ${BLUE}${BranchMapAddToJsonFile}${NC}"


