#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-08-03 11:44:37
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-24 02:45:36
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


CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_get_only_branch_from_recods_scriptPath=${qbase_homedir_abspath}/branch/get_only_branch_from_recods.sh


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

recordsString=${responseResult}
branchesString=$(sh $qbase_get_only_branch_from_recods_scriptPath -recordsString "${recordsString}")

echo "${branchesString}"






