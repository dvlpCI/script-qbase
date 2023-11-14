#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-11 03:20:19
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


log_title "getAppVersionAndBuildNumber"
resultBranchNames=$(sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getAppVersionAndBuildNumber test)
echo "${GREEN}《给app的版本号和build号》的结果如下：${BLUE} $resultBranchNames ${NC}"


echo "\n"
log_title "getBranchNamesAccordingToRebaseBranch"
# sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch main --add-value 1 -onlyName true --verbose
# 要使用输出值的时候，不用添加 --verbose
echo "${YELLOW}正在执行命令:《${BLUE} sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch main --add-value 1 -onlyName true test --verbose ${YELLOW}》${NC}"
resultBranchNames=$(sh ${qbase_HomeDir_Absolute}/qbase.sh -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch main --add-value 1 -onlyName true)
echo "${GREEN}《获取当前分支【在rebase指定分支后】的所有分支名》的结果如下：${BLUE} $resultBranchNames ${NC}"
