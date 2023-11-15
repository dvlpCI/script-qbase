#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-15 21:11:32
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-16 00:18:53
 # @FilePath: ./foundation/json2array.sh
 # @Description: 将 json 字符串转为 array 数组
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}


# jsonString='
# [
#     {
#         "des": "获取当前分支【在rebase指定分支后】的所有分支名",
#         "key": "getBranchNamesAccordingToRebaseBranch",
#         "rel_path": "./branch_quickcmd/getBranchNames_accordingToRebaseBranch.sh",
#         "example": "qbase -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch \"master\" --add-rel_path 1 -onlyName true --verbose"
#     },
#     {
#         "des": "获取所有指定分支名的branchMap组成branchMaps输出到指定文件中(1添加前，可增加检查每个branchMap在指定环境下的属性缺失，2如果添加成功可设置是否删除已获取的文件)，如有缺失输出缺失错误",
#         "key": "getBranchMapsAccordingToBranchNames",
#         "rel_path": "./branch_quickcmd/getBranchMapsAccordingToBranchNames.sh",
#         "example": "qbase -quick getBranchMapsAccordingToBranchNames -branchMapsFromDir \"${BranceMaps_From_Directory_PATH}\" -branchMapsAddToJsonF \"${BranchMapAddToJsonFile}\" -branchMapsAddToKey \"${BranchMapAddToKey}\" -requestBranchNamesString \"${requestBranchNamesString}\"  -checkPropertyInNetwork \"${CheckPropertyInNetworkType}\" -ignoreCheckBranchNames \"${ignoreCheckBranchNameArray}\" -shouldDeleteHasCatchRequestBranchFile \"${shouldDeleteHasCatchRequestBranchFile}\""
#     },
#     {
#         "des": "获取指定文件中的所有分支信息，并进行整理及整理后发送通知",
#         "key": "getBranchMapsInfoAndNotifiction",
#         "rel_path": "./branch_quickcmd/getBranchMapsInfoAndNotifiction.sh",
#         "example": "qbase -quick getBranchMapsInfoAndNotifiction "
#     }
# ]
# '
# jsonString='
# [
#     "abc",
#     "",
#     "./branch_quickcmd/getBranchMapsAccordingToBranchNames.sh", 
#     "efg"
# ]
# '
jsonString=$1

# jsonDump=$(printf "%s" "$jsonString" | jq -r '.')
# printf "您要处理的数据是如下:\n%s\n" "$jsonDump" && exit 1

array=()
count=$(printf "%s" "$jsonString" | jq -r '.|length')
for ((i=0;i<count;i++))
do
    element=$(printf "%s" "$jsonString" | jq -r ".[$((i))]") # -r 去除字符串引号
    # echo "✅ $((i+1)). element=${element}"
    array[${#array[@]}]=${element}
done

# newCount=${#array[@]}
# echo "newCount=${newCount}"
printf "%s" "${array[*]}"


