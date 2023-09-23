#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-09-09 12:59:37
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-23 19:03:19
 # @FilePath: example20_notificationstring2wechat.sh
 # @Description: 测试企业微信的通知发送--字符串数组
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
# parent_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
notification_strings_to_wechat_scriptPath=${CurrentDIR_Script_Absolute}/notification_strings_to_wechat.sh
TESTDATA_FILE_PATH="${CurrentDIR_Script_Absolute}/example10_notification2wechat.json"

TEST_ROBOT_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"



log_title "1、发送json文件中的数组内容(长度超过4096) + text"
CONTENTS_JSON_FILE_PATH=${TESTDATA_FILE_PATH}
CONTENTS_JSON_KEY="branch_info_result_slice.Notification_full_slice_text"

echo "${YELLOW}正在执行命令(测试发送数组内容)《 ${BLUE}sh ${notification_strings_to_wechat_scriptPath} -robot \"${TEST_ROBOT_URL}\" -contentJsonF \"${CONTENTS_JSON_FILE_PATH}\" -contentKey \"${CONTENTS_JSON_KEY}\" -msgtype \"text\" ${YELLOW}》${NC}"
sh ${notification_strings_to_wechat_scriptPath} -robot "${TEST_ROBOT_URL}" -contentJsonF "${CONTENTS_JSON_FILE_PATH}" -contentKey "${CONTENTS_JSON_KEY}" -msgtype "text"
if [ $? -ne 0 ]; then error_exit_script; fi




log_title "2、发送json文件中的数组内容(长度超过4096) + markdown"
CONTENTS_JSON_FILE_PATH=${TESTDATA_FILE_PATH}
CONTENTS_JSON_KEY="branch_info_result_slice.Notification_full_slice_markdown"

echo "${YELLOW}正在执行命令(测试发送数组内容)《 ${BLUE}sh ${notification_strings_to_wechat_scriptPath} -robot \"${TEST_ROBOT_URL}\" -contentJsonF \"${CONTENTS_JSON_FILE_PATH}\" -contentKey \"${CONTENTS_JSON_KEY}\" -msgtype \"markdown\" ${YELLOW}》${NC}"
sh ${notification_strings_to_wechat_scriptPath} -robot "${TEST_ROBOT_URL}" -contentJsonF "${CONTENTS_JSON_FILE_PATH}" -contentKey "${CONTENTS_JSON_KEY}" -msgtype "markdown"
if [ $? -ne 0 ]; then error_exit_script; fi


