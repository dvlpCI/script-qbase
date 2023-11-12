#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-08-03 11:44:37
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-08 23:41:11
 # @Description: 获取指定日期之后的所有合入记录(已去除 HEAD -> 等)
 # @Example: sh ./get_merger_recods_after_date.sh --searchFromDateString "2022-12-26 10:45:24"
### 

#responseResult=$(git log --graph --pretty=format:'%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges )
#responseResult=$(git log --pretty=format:'%s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --after "10-12-2022" --merges)

#responseResult=$(git log --pretty=format:'%C(yellow)%H' --after "10-12-2022" --no-merges )

#git log --pretty=format:'-%C(yellow)%d%Creset %s' --after "2022-10-16"

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
                -date|--searchFromDateString) searchFromDateString=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done


#echo "------下面开始获取本分支在${searchFromDateString}后包含的所有分支名------"
#[git log命令参数详解](http://news.558idc.com/288248.html)
debug_log "正在执行命令(获取本分支合入的分支(会含标签,记得去除)):《 git log --pretty=format:'%C(yellow)%d' --after \"${searchFromDateString}\" 》"
responseResult=$(git log --pretty=format:'%C(yellow)%d' --after "${searchFromDateString}")
debug_log "恭喜通过《 git log --pretty=format:'%C(yellow)%d' --after \"${searchFromDateString}\" 》，得到本分支合入的所有其他分支和标签为:${BLUE}${responseResult} ${NC}。${NC}"
arr=(${responseResult})
num=${#arr[@]}
#echo "${arr[*]}"
#echo "num=$num"
    
    
noBranchNames=("HEAD" "origin/HEAD" "->")
# noBranchNames[${#noBranchNames[@]}]="${currentBranch}"
#echo "noBranchNames=${noBranchNames[*]}, noBranchNameCount=${#noBranchNames[@]}"
for ((i=0;i<num;i+=1))
{
    mergeBranchName=${arr[i]}
    mergeBranchName=$(echo $mergeBranchName | sed "s/(//g" | sed "s/)//g" | sed "s/,//g") #去除左右括号
    # mergeBranchName=${mergeBranchName##*/} # 取最后的component
    #echo "$((i+1)) mergeBranchName=${mergeBranchName}"
    if [ "${mergeBranchName}" == "tag:" ]; then
        #echo "$((i+1)) mergeBranchName=${mergeBranchName}=========跳过本身及其下一个"
        i=$((i+1));
        continue;
    fi
    
    # if [[ "${noBranchNames[*]}" =~ ${mergeBranchName} ]]; then
    if echo "${noBranchNames[@]}" | grep -wq "${mergeBranchName}" &>/dev/null; then
        debug_log "${mergeBranchName}:pass 不是分支名，过滤掉"
        continue
    elif [[ "${noBranchNames[*]}" == *"$mergeBranchName"* ]]; then # 避免识别 noBranchNames=("HEAD" "->") 和 mergeBranchName="->"  时候识别不到(可在 a_function_test.sh 中测试)
        debug_log "${mergeBranchName}:pass 不是分支名，过滤掉"
        continue

    else
        #echo "${mergeBranchName}:ok"
        matchMergeBranchNames[${#matchMergeBranchNames[@]}]=${mergeBranchName}
    fi
}

#[shell 数组去重](https://www.jianshu.com/p/1043e40c0502)
matchMergeBranchNames=($(awk -v RS=' ' '!a[$1]++' <<< ${matchMergeBranchNames[@]}))

echo "${matchMergeBranchNames[*]}"






