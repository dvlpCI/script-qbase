#!/bin/bash
#企业微信的通知发送-字符串
#sh noti_new_package_base.sh -robot "${ROBOT_URL}" -content "${LongLog}" -at "${MentionedList}" -msgtype "${msgtype}"

#ROBOT_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"
#branchInfoJsonFile=
#LongLog=$(cat $branchInfoJsonFile | jq '.branch_info_Notification')
#sh noti_new_package_base.sh -robot "${ROBOT_URL}" -content "cos地址：https://a/b/123.txt\n官网：https://www.pgyer.com/lkproapp。\n更新内容：\n更新说明略\n分支信息:\ndev_fix:功能修复" -at "all"

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

# shell 参数具名化
show_usage="args: [-robot ,-content, -at, -msgtype]\
                                  [--robot-url=, --content=, --at=, -msgtype=]"
                                  
while [ -n "$1" ]
do
        case "$1" in
                -robot|--robot-url) ROBOT_URL=$2; shift 2;;
                -content|--content) Content=$2; shift 2;;
                -at|--at) MentionedList=$2; shift 2;;
                -msgtype|--msgtype) msgtype=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
parent_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
interceptString_script_path=${parent_dir_Absolute}/foundation/intercept_string.sh


#echo "\n\n\n正在发送通知......"
#echo "ROBOT_URL=${ROBOT_URL}"
#echo "MentionedList=${MentionedList}"
#echo "Content=${Content}"


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}


function notiMessage() {
    while [ -n "$1" ]
    do
        case "$1" in
                -robot|--robot-url) NotificationROBOTURL=$2; shift 2;;
                -content|--content) Content=$2; shift 2;;
                -at|--at) MentionedList=$2; shift 2;;
                -msgtype|--msgtype) MessageTYPE=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
    done

#    echo "$FUNCNAME 入参Content=${Content}"
#    echo "$FUNCNAME 入参MentionedList=${MentionedList[*]}"
#    echo "$FUNCNAME 入参NotificationROBOTURL=${NotificationROBOTURL}"
    
    #MentionedListJsonStrings="[\"lichaoqian\", \"linzehua\", \"hongzhiqing\", \"hongjiaxing\"]"
    #echo "测试@的人1：${MentionedListJsonStrings}"

    #TestMentionedArray=("lichaoqian" "linzehua" "hongzhiqing" "hongjiaxing")
    #source ${bulidScriptCommon_dir_Absolute}/a_function.sh ${bulidScriptCommon_dir_Absolute}
    #getJsonStringFromArray "${TestMentionedArray[*]}" "true"
    #echo "测试@的人2：${arrayJsonResultString}"
    
    MentionedListJsonStrings=${MentionedList[*]}
    #echo "实际@的人3：${MentionedListJsonStrings}"
    
#    return

    #responseResult=$(\
    #curl $NotificationROBOTURL \
    #   -H 'Content-Type: application/json' \
    #   -d '
    #   {
    #        "msgtype": "text",
    #        "text": {
    #            "content": "hello world",
    #            "mentioned_list":["wangqing","@all"],
    #        }
    #   }'
    #)

    if [ "${MessageTYPE}" != "markdown" ]; then
        MessageTYPE="text"
    fi
    
    #echo "Content_old=${Content}"
    FirstCharacter=$(echo ${Content: 0: 1})
    #echo "FirstCharacter=${FirstCharacter}"
    if [ "${FirstCharacter}" != "[" ] && [ "${FirstCharacter}" != "{" ] && [ "${FirstCharacter}" != "\"" ]; then
        # 不是数组[]，不是字典{}，也不是字符串""的时候，应该前后都加双引号，才能保证 curl 中的参数书写正确
        Content="\"${Content}\""
    fi
    #echo "Content_new=${Content}"
    
    responseResult=$(\
    curl $NotificationROBOTURL \
       -H "Content-Type: application/json" \
       -d "{
            \"msgtype\": \"${MessageTYPE}\",
            \"${MessageTYPE}\": {
                \"content\": ${Content},
                \"mentioned_list\":${MentionedListJsonStrings}
                 }
           }"
    )
#     "mentioned_list":["wangqing","@all"],
#    "mentioned_mobile_list":["13800001111","@all"]


    #[Shell 中curl请求变量参数](https://www.jianshu.com/p/102bd1c48e02)
    #curl-X POST --header'Content-Type: application/json'
    #--header'Accept: application/json'
    #--header'authtype: local'
    #--header"username: $admin_user"
    #--header"password:${admin_token}"
    #-d"{\"email\": \"$payment_email\", \"paymentAccount\": \"$payment_account\", \"paymentServer\": \"${server_name}\", \"remarks\": \"vendor for${wx_service_name}\", \"vendor\": \"xxx\" }" "http://xxxxx.com/api/001api"-w"\nhttp_code=%{http_code}\n"-v -o${result_log} |grep'http_code=200'


    if [ $? = 0 ]   # 上个命令的退出状态，或函数的返回值。
    then
    #    echo "responseResult=$responseResult"
        responseResultCode=$(echo ${responseResult} | jq  '.errcode') # mac上安装brew后，执行brew install jq安装jq
        #echo "responseResultCode=${responseResultCode}"
        if [ $responseResultCode = 0 ];then
            echo "-------- 脚本${0} Success: 新版本通知成功，继续操作 --------"
        else
            responseErrorMessage=$(echo ${responseResult} | jq  '.errmsg')
    #        echo "responseErrorMessage=${responseErrorMessage}"
            echo "-------- 脚本${0} Failure: 新版本通知失败responseErrorMessage=${responseErrorMessage}，不继续操作 --------"
#            source ./a_function.sh ./
#            PackageErrorCode=-1
#            PackageErrorMessage="新版本通知失败responseErrorMessage=${responseErrorMessage}，不继续操作"
#            updatePackageErrorCodeAndMessage ${PackageErrorCode} "${PackageErrorMessage}"
            return 1
        fi
        
    else
        echo "-------- 脚本${0} Failure: 新版本通知失败responseResultCode=${responseResultCode}，不继续操作 --------"
        return 1
    fi
}

maxLength=2000

length=${#Content}        # 获取字符串的长度
debug_log "🚗🚗🚗 截取前，您的长度是$length"
resultString=$(sh $interceptString_script_path -string "$Content" -maxLength $maxLength)
resultLength=${#resultString}        # 获取字符串的长度
debug_log "$resultString"
debug_log "${YELLOW}🚗🚗🚗 截取并拼接后，您的长度是 $resultLength ，内容如上。${NC}"
if [ $resultLength -gt $maxLength ]; then
    echo "${RED}🚗🚗🚗 截取并拼接后，您的长度大于4096，其值为$resultLength${NC}"
    exit
fi

echo "\n"
#echo "正在执行发送通知的命令：《notiMessage \"${ROBOT_URL}\" \"${resultString}\" ${MentionedList}》"
notiMessage -robot "${ROBOT_URL}" -content "${resultString}" -at "${MentionedList[*]}" -msgtype "${msgtype}"
if [ $? != 0 ]; then
    notiMessage "发送通知失败，详情请查看日志" ${MentionedList}
fi
