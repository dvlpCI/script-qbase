#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-23 15:06:53
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
workspace="$CommonFun_HomeDir_Absolute"

Develop_Branchs_FILE_PATH="${workspace}/branchMaps_10_resouce_get/example/app_branch_info.json"
ignoreCheckBranchNameArray="(master development dev_publish_out dev_publish_in dev_all)"
PackageNetworkType="test1"

log_title "获取branchMaps"
echo "${YELLOW}正在执行命令(检查提测、测试、通过后等不同阶段分支的详细信息,如提测时json中的提测时间字段必须有值):《 ${BLUE}sh ${CurrentDIR_Script_Absolute}/branchMapsFile_checkMap.sh -branchMapsJsonF \"${Develop_Branchs_FILE_PATH}\" -ignoreCheckBranchNames \"${ignoreCheckBranchNameArray[*]}\" -pn \"${PackageNetworkType}\" ${YELLOW}》${NC}"
errorMessage=$(sh ${CurrentDIR_Script_Absolute}/branchMapsFile_checkMap.sh -branchMapsJsonF "${Develop_Branchs_FILE_PATH}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}" -pn "${PackageNetworkType}")
if [ $? != 0 ]; then
    echo "${RED}${errorMessage}${NC}"
    exit 1
fi
echo "${GREEN}恭喜：检查branchMaps通过，在 ${PackageNetworkType} 环境下未缺失信息。${NC}"


