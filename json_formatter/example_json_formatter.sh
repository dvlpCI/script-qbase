#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-26 02:41:53
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-11 21:29:45
 # @FilePath: /script-qbase/json_formatter/example_json_formatter.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
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



log_title "1"
NORMAL_ARRAY=("第一个" "第二个" "第三个")
result1=$(sh ${CurrentDIR_Script_Absolute}/get_jsonstring.sh -arrayString "${NORMAL_ARRAY[*]}" -escape "true")
echo "$result1"