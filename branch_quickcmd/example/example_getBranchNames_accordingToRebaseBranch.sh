#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-08-03 01:52:44
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-14 13:39:52
 # @FilePath: example_branch_check_self_name.sh
 # @Description: 测试
### 
# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..


qbase_getBranchNames_accordingToRebaseBranch_scriptPath="${CategoryFun_HomeDir_Absolute}/getBranchNames_accordingToRebaseBranch.sh"


REBASE_BRANCH="master"
add_value="1"
ONLY_NAME="false"
resultBranchResponseJsonString=$(sh ${qbase_getBranchNames_accordingToRebaseBranch_scriptPath} -rebaseBranch "${REBASE_BRANCH}" -addValue "${add_value}" -addType "${add_type}" -onlyName "${ONLY_NAME}")
if [ $? != 0 ]; then
    echo "${resultBranchResponseJsonString}"
    exit 1
fi
resultBranchNames=$(printf "%s" "${resultBranchResponseJsonString}" | jq -r '.mergerRecords')
if [ -z "${resultBranchNames}" ]; then
    echo "${RED}您当前目录($PWD)下的项目，没有新的提交记录，更不用说分支了，请检查确保cd到正确目录，或者提交了代码。${NC}"
    exit 1
fi
echo "${GREEN}恭喜：获取当前分支【在rebase指定分支后】的所有分支名的结果如下：${BLUE} $resultBranchNames ${GREEN}。${NC}"

