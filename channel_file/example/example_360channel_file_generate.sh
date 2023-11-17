#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:43:04
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-17 18:41:08
 # @Description: 360加固的多渠道文件生成
### 
# 渠道配置文件脚本
# 1、渠道值自定义简化与接收转化
# 2、渠道固定值的自动匹配与新增值的智能转义信息完善
# 3、多渠道文件生成与合规校验
# 4、打自定义渠道包的脚本优化



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

qtool_360channel_file_scriptPath=${CategoryFun_HomeDir_Absolute}/360channel_file_generate.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

log_title "1.使用 arrayString 生成多渠道配置文件"
argArrayString='"CHANNEL 华为 huawei" "CHANNEL 小米 xiaomi" "CHANNEL 公交 gongjiao"'
# channelsFileName=$(date +"%m%d_%H%M%S")
channelsFileName="360channels_byArrayString"
outputFilePath="${CurrentDIR_Script_Absolute}/${channelsFileName}.txt"
shouldCheckOutput="true"
echo "${YELLOW}正在执行测试命令(使用 arrayString 生成多渠道配置文件):《${BLUE} sh $qtool_360channel_file_scriptPath -arrayString '${argArrayString}' -outputFile \"${outputFilePath}\" -shouldCheckOutput \"${shouldCheckOutput}\" ${YELLOW}》${NC}"
generateResult=$(sh $qtool_360channel_file_scriptPath -arrayString "${argArrayString}" -outputFile "${outputFilePath}" -shouldCheckOutput "${shouldCheckOutput}")
if [ $? != 0 ]; then
  echo "${RED}${generateResult}${NC}"  # 此时此值是错误信息
  exit 1
fi
echo "${GREEN}您的360加固多渠道配置文件(byArrayString):${BLUE} ${generateResult} ${GREEN}。${NC}"
open "${outputFilePath}"



echo "\n"
log_title "2.使用 jsonString 生成多渠道配置文件"
argsJsonString='
[
  "CHANNEL 华为 huawei",
  "CHANNEL 小米 xiaomi",
  "CHANNEL 抖音 douyin"
]'
# channelsFileName=$(date +"%m%d_%H%M%S")
channelsFileName="360channels_byJsonString"
outputFilePath="${CurrentDIR_Script_Absolute}/${channelsFileName}.txt"
shouldCheckOutput="true"
echo "${YELLOW}正在执行测试命令(使用 jsonString 生成多渠道配置文件):《${BLUE} sh $qtool_360channel_file_scriptPath -jsonString '${argsJsonString}' -outputFile \"${outputFilePath}\" -shouldCheckOutput \"${shouldCheckOutput}\" ${YELLOW}》${NC}"
generateResult=$(sh $qtool_360channel_file_scriptPath -jsonString "${argsJsonString}" -outputFile "${outputFilePath}" -shouldCheckOutput "${shouldCheckOutput}")
if [ $? != 0 ]; then
  echo "${RED}${generateResult}${NC}"  # 此时此值是错误信息
  exit 1
fi
echo "${GREEN}您的360加固多渠道配置文件(byJsonString):${BLUE} ${generateResult} ${GREEN}。${NC}"
open "${outputFilePath}"

