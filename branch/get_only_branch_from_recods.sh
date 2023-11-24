#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-08-03 11:44:37
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-24 02:59:10
 # @Description: 从提交记录中获取分支名，即进行去除 "HEAD" "origin/HEAD" "->" 以及 tag: 等操作
 # @Example: sh ./get_only_branch_from_recods.sh -recordsString "${recordsString}"
### 


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}


# shell 参数具名化           
while [ -n "$1" ]
do
    case "$1" in
        -recordsString|--recordsString) recordsString=$2; shift 2;;
        -branchShouldRemoveOrigin|branchShouldRemoveOrigin) branchShouldRemoveOrigin=$2; shift 2;;  # 是否移除每个分支前面的 origin/（取分支信息的时候一定不能是true，否则会变成取本地，而本地可能又没该分支的错误现象）
        --) break ;;
        *) break ;;
    esac
done


recordArray=(${recordsString})
recordCount=${#recordArray[@]}
#echo "${recordArray[*]}"
#echo "recordCount=$recordCount"
    
    
noBranchNames=("HEAD" "origin/HEAD" "->")
# noBranchNames[${#noBranchNames[@]}]="${currentBranch}"
#echo "noBranchNames=${noBranchNames[*]}, noBranchNameCount=${#noBranchNames[@]}"

branchRecordArray=()
for ((i=0;i<recordCount;i+=1))
{
    iRecordString=${recordArray[i]}
    iRecordString=$(echo "$iRecordString" | sed "s/(//g" | sed "s/)//g" | sed "s/,//g") #去除左右括号
    # iRecordString=${iRecordString##*/} # 取最后的component
    #echo "$((i+1)) iRecordString=${iRecordString}"
    if [ "${iRecordString}" == "tag:" ]; then
        #echo "$((i+1)) iRecordString=${iRecordString}=========跳过本身及其下一个"
        i=$((i+1));
        continue;
    fi
    
    # if [[ "${noBranchNames[*]}" =~ ${iRecordString} ]]; then
    if echo "${noBranchNames[@]}" | grep -wq "${iRecordString}" &>/dev/null; then
        debug_log "${iRecordString}:pass 不是分支名，过滤掉"
        continue
    elif [[ "${noBranchNames[*]}" == *"$iRecordString"* ]]; then # 避免识别 noBranchNames=("HEAD" "->") 和 iRecordString="->"  时候识别不到(可在 a_function_test.sh 中测试)
        debug_log "${iRecordString}:pass 不是分支名，过滤掉"
        continue

    else
        #echo "${iRecordString}:ok"
        branchRecordArray[${#branchRecordArray[@]}]=${iRecordString}
    fi
}

#[shell 数组去重](https://www.jianshu.com/p/1043e40c0502)
branchRecordArray=($(awk -v RS=' ' '!a[$1]++' <<< ${branchRecordArray[@]}))
branchesString=${branchRecordArray[*]}

# 是否移除每个分支前面的 origin/
lowercase_branchShouldRemoveOrigin=$(echo "$branchShouldRemoveOrigin" | tr '[:upper:]' '[:lower:]') # 将值转换为小写形式
if [[ "${lowercase_branchShouldRemoveOrigin}" == "true" ]]; then
    needRemoveText="origin/"
    # 移除所有的needRemoveText变量的值（# 将 sed 命令中的替换分隔符从 / 更改为 |，以避免与 URL 中的斜杠冲突）
    branchesString=$(printf "%s" "$branchesString" | sed -e "s|${needRemoveText}||g") 
fi

printf "%s" "${branchesString}"






