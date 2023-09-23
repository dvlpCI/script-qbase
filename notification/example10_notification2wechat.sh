#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-09-09 12:59:37
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-24 00:02:55
 # @FilePath: /example10_notification2wechat.sh
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
# parent_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
notification2wechatScriptPath=${CurrentDIR_Script_Absolute}/notification2wechat.sh
TESTDATA_FILE_PATH="${CurrentDIR_Script_Absolute}/example10_notification2wechat.json"

TEST_ROBOT_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"



log_title "1.使用本地直接指定的机器人🤖，发送字符串"
    CONTENT1="1---cos地址：https://a/b/123.txt\n官网：https://www.pgyer.com/lkproapp。\n更新内容：\n更新说明略\n分支信息:\ndev_fix:功能修复"

    echo "-----------------------1.1 text发送"
    msgtype="text"
    atMiddleBracketIdsString="[\"@all\", \"lichaoqian\"]"
    sh ${notification2wechatScriptPath} -robot "${TEST_ROBOT_URL}" -content "${CONTENT1}" -at "${atMiddleBracketIdsString}" -msgtype "${msgtype}"
    if [ $? -ne 0 ]; then error_exit_script; fi

    echo "-----------------------1.2 markdown发送"
    msgtype="markdown"
    atMiddleBracketIdsString="[\"@all\", \"lichaoqian\"]"
    sh ${notification2wechatScriptPath} -robot "${TEST_ROBOT_URL}" -content "${CONTENT1}" -at "${atMiddleBracketIdsString}" -msgtype "${msgtype}"
    if [ $? -ne 0 ]; then error_exit_script; fi




log_title "2.使用文件中指定的机器人🤖，发送字符串"
    FILE_ROBOT_URL=$(cat $TESTDATA_FILE_PATH | jq -r '.robot_data.value')
    FILE_ROBOT_AT=$(cat $TESTDATA_FILE_PATH | jq '.robot_data.mentioned_list')
    # printf "✅ FILE_ROBOT_AT=${FILE_ROBOT_AT}\n"
    
    CONTENT2="2---cos地址：https://a/b/123.txt\n官网：https://www.pgyer.com/lkproapp。\n更新内容：\n更新说明略\n分支信息:\ndev_fix:功能修复"

    echo "-----------------------2.1 text发送"
    msgtype="text"
    sh ${notification2wechatScriptPath} -robot "${FILE_ROBOT_URL}" -content "${CONTENT2}" -at "${FILE_ROBOT_AT}" -msgtype "${msgtype}"
    if [ $? -ne 0 ]; then error_exit_script; fi

    echo "-----------------------2.2 markdown发送（经测试无法@人❌，但这不是错误。所以使用markdown发送的时候，发完一条后，最后再加一条如text格式的可以@人的消息）"
    msgtype="markdown"
    sh ${notification2wechatScriptPath} -robot "${FILE_ROBOT_URL}" -content "${CONTENT2}" -at "${FILE_ROBOT_AT}" -msgtype "${msgtype}"
    if [ $? -ne 0 ]; then error_exit_script; fi

    echo "\n\n"




shouldTest_Json="true"
if [ "${shouldTest_Json}" == "true" ]; then
    log_title "3、发送json文件中的内容(长度4096内) + text"
    CONTENT=$(cat $TESTDATA_FILE_PATH | jq -r '.branch_info_result_text.current.Notification_full')
    sh ${notification2wechatScriptPath} -robot "${TEST_ROBOT_URL}" -content "${CONTENT}" -at "${atMiddleBracketIdsString}" -msgtype "text"
    if [ $? -ne 0 ]; then error_exit_script; fi

    log_title "4、发送json文件中的内容(长度4096内) + markdown"
    CONTENT=$(cat $TESTDATA_FILE_PATH | jq -r '.branch_info_result_markdown.current.Notification_full')
    sh ${notification2wechatScriptPath} -robot "${TEST_ROBOT_URL}" -content "${CONTENT}" -at "${atMiddleBracketIdsString}" -msgtype "markdown"
    if [ $? -ne 0 ]; then error_exit_script; fi
    CONTENT=$(cat $TESTDATA_FILE_PATH | jq -r '.branch_info_result_markdown.lastOnline.Notification_full')
    sh ${notification2wechatScriptPath} -robot "${TEST_ROBOT_URL}" -content "${CONTENT}" -at "${atMiddleBracketIdsString}" -msgtype "markdown"
    if [ $? -ne 0 ]; then error_exit_script; fi
fi

