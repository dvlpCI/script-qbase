#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-09-09 12:59:37
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-09-27 14:17:07
 # @FilePath: /example_execScript_by_configJsonFile.sh
 # @Description: 测试企业微信的通知发送--文本长度正常时候
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

# 延迟20毫秒的函数
function delay() {
  local delay=1
  sleep "$delay"
}


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
parent_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qbase_execScript_by_configJsonFile_script_path=${parent_dir_Absolute}/dealScript_by_scriptConfig.py




log_title "1.执行自己的脚本"
echo "${YELLOW}正在执行命令(执行自己的脚本):《${BLUE} python3 ${qbase_execScript_by_configJsonFile_script_path} \"${CurrentDIR_Script_Absolute}/example_execScript_by_configJsonFile.json\" ${YELLOW}》${NC}"
python3 ${qbase_execScript_by_configJsonFile_script_path} "${CurrentDIR_Script_Absolute}/example_execScript_by_configJsonFile.json"
if [ $? != 0 ]; then error_exit_script; fi

log_title "2.执行命令脚本"
echo "${YELLOW}正在执行命令(执行自己的脚本):《${BLUE} python3 ${qbase_execScript_by_configJsonFile_script_path} \"${CurrentDIR_Script_Absolute}/example_execBin_by_configJsonFile.json\" ${YELLOW}》${NC}"
python3 ${qbase_execScript_by_configJsonFile_script_path} "${CurrentDIR_Script_Absolute}/example_execBin_by_configJsonFile.json"
if [ $? != 0 ]; then error_exit_script; fi