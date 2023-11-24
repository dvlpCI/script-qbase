#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-25 01:50:29
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-25 02:00:49
 # @FilePath: /script-qbase/log/example/b.sh
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
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..


function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}


# 执行 a.sh 并捕获输出
output=$(sh "${Example_HomeDir_Absolute}/a.sh")

# 获取标准错误流中的日志信息
log_messages=$(echo "$output" >&2)

# 获取标准输出中的成功结果信息
success_result=$(echo "$output" | grep "Success:")

# 获取标准错误流中的失败结果信息
error_result=$(echo "$output" | grep "Error:" >&2)

# 输出日志信息到终端
echo "Log messages from a.sh:"
echo "$log_messages"

# 输出成功结果信息到终端
echo "Success result from a.sh:"
echo "$success_result"

# 输出失败结果信息到终端
echo "Error result from a.sh:"
echo "$error_result"