#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-12 22:21:17
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
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qbase_package_path_and_cmd_menu_scriptPath=${CategoryFun_HomeDir_Absolute}/package_path_and_cmd_menu.sh


function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}


log_title "测试 cmd 脚本路径的获取"
qpackageJsonF=$qbase_homedir_abspath/qbase.json
keyType=cmd
key="first_commit_info_after_date"
relpath=$(sh $qbase_package_path_and_cmd_menu_scriptPath -file ${qpackageJsonF} -keyType $keyType -key $key)
if [ $? != 0 ]; then
    echo "$relpath" # 此时此值是错误信息
    exit 1
fi

relpath="${relpath//.\//}"  # 去掉开头的 "./"
echo "$qbase_homedir_abspath/$relpath"


