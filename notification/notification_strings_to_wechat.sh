#!/bin/bash
###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-02-27 21:38:10
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-09-23 18:55:14
# @FilePath: notification/notification_strings_to_wechat.sh
# @Description: 企业微信的通知发送-字符串数组
###

JQ_EXEC=$(which jq)

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
notification2wechatScriptPath=${CurrentDIR_Script_Absolute}/notification2wechat.sh


while [ -n "$1" ]
do
    case "$1" in
        -robot|--robot-url) ROBOT_URL=$2; shift 2;;
        -contentJsonF | --contents-json-file) CONTENTS_JSON_FILE_PATH=$2 shift 2;;
        -contentKey | --contents-json-key) CONTENTS_JSON_KEY=$2 shift 2;;
        -at|--at) MentionedList=$2; shift 2;;
        -msgtype|--msgtype) msgtype=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done



function debug_log() {
    if [ "${isRelease}" == true ]; then
        echo "$1"
    fi
}

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function postMessage() {
    Content=$1
    sh ${notification2wechatScriptPath} -robot "${ROBOT_URL}" -content "${Content}" -at "${MentionedList}" -msgtype "${msgtype}"
}



if [ ! -f "${CONTENTS_JSON_FILE_PATH}" ]; then
    echo "${RED}要添加哪个文件不能为空${NC}\n"
    exit_script
fi


# echo "测试输出结果命令：《cat ${CONTENTS_JSON_FILE_PATH} | ${JQ_EXEC} \".${CONTENTS_JSON_KEY}|length\"》"
contentCount=$(cat ${CONTENTS_JSON_FILE_PATH} | ${JQ_EXEC} ".${CONTENTS_JSON_KEY}|length")
# echo "--------contentCount=${contentCount}"
if [ "${contentCount}" == 0 ]; then
    echo "友情提示💡💡💡：${CONTENTS_JSON_KEY}没有内容"
    exit_script
fi

NEW_WAIT_INTERCEPT_STRING=""
for ((i = 0; i < contentCount; i++)); do
    iContent=$(cat ${CONTENTS_JSON_FILE_PATH} | ${JQ_EXEC} ".${CONTENTS_JSON_KEY}" | ${JQ_EXEC} ".[${i}]")
    if [ $? != 0 ]; then
        echo "${RED}Error❌:从 ${BLUE}${CONTENTS_JSON_FILE_PATH} ${RED}中获取 ${BLUE}.${CONTENTS_JSON_KEY} ${RED}失败，请检查文件内容是否正确！${NC}"
        exit_script
    fi
    iContent_noQuote=${iContent:1:${#iContent}-2} # 去除前后的双引号,方便添加或修改
    # echo "--------iContent_noQuote=${iContent_noQuote}"

    newTextLength=$((${#NEW_WAIT_INTERCEPT_STRING} + ${#iContent_noQuote} + 1))
    # echo "--------如果添加新文本后 NEW_WAIT_INTERCEPT_STRING 长度会变为${newTextLength}"
    if [ ${newTextLength} -lt 2048 ]; then #企业微信通知最大长度为4096
        # 没超过长度限制的话，可以一直添加
        NEW_WAIT_INTERCEPT_STRING="${NEW_WAIT_INTERCEPT_STRING}${iContent_noQuote}\n"
    else
        # 如果添加上去，则长度会超过限制，所以先将添加前的文本发送出去，然后本次的这个就作为新的值,然后继续找下一个最大的发送长度
        postMessage "${NEW_WAIT_INTERCEPT_STRING}"
        NEW_WAIT_INTERCEPT_STRING="${iContent_noQuote}\n"
    fi
done

postMessage "${NEW_WAIT_INTERCEPT_STRING}"
