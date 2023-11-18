#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:43:04
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-18 16:53:56
 # @Description: 测试中文转拼音
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

qbase_convert_to_pinyin_scriptPath=${CategoryFun_HomeDir_Absolute}/convert_to_pinyin.py


pinyinString=$(python3 $qbase_convert_to_pinyin_scriptPath -originString "你好世界123abc✅")
if [ $? != 0 ]; then
    echo "${pinyinString}"
    exit 1
fi
echo "${GREEN}恭喜您的中文转拼音的测试结果是:${BLUE} ${pinyinString} ${GREEN}.${NC}"