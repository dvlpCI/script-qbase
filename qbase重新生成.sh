#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-04-18 17:40:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-04-20 23:00:31
 # @FilePath: qbase_help.sh
 # @Description: qbase的help
### 

# 定义颜色常量(qbase 不是所要执行的直接脚本，所以不要使用颜色)
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qbase_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qbase_HomeDir_Absolute=${CurrentDIR_Script_Absolute}


# 检查 realpath 命令是否安装，未安装则提示用什么命令在终端进行安装
if ! command -v shc &> /dev/null; then
    echo "${RED}温馨提示：您当前的系统中未安装 shc 命令，正在为您自动安装，如安装失败，请使用《${BLUE} brew install shc ${RED}》命令在终端进行安装。${NC}"
    brew install shc
    exit 1
fi

shc -r -f ${qbase_HomeDir_Absolute}/qbase.sh #注意:要有-r选项, -f 后跟要加密的脚本名.
if [ $? != 0 ]; then
    echo "${RED}Error：把shell脚本转换为一个可执行的二进制文件失败，请检查 。${NC}"
    exit 1
fi

# script-name.x是加密后的可执行的二进制文件. (双加或者 ./script-name 即可运行.)
# script-name.x.c是生成script-name.x的原文件(c语言)
# 删除 cript-name.x.c
rm -rf ${qbase_HomeDir_Absolute}/qbase.sh.x.c
# 重命名
mv ${qbase_HomeDir_Absolute}/qbase.sh.x ${qbase_HomeDir_Absolute}/qbase

echo "${GREEN}Success：把shell脚本转换为一个可执行的二进制文件成功。${NC}"
