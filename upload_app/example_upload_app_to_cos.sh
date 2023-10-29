#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 22:17:02
 # @Description: 上传ipa到蒲公英xcxwo（可设置渠道）
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

ipa_file_path="${CurrentDIR_Script_Absolute}/App1Enterprise/App1Enterprise.ipa"
updateDesString="测试蒲公英上传到指定位置，请勿下载"

# Cos的配置
CosUploadToREGION="ap-shanghai"
CosUploadToBUCKETName="prod-xhw-image-1302324914"
CosUploadToBUCKETDir="/mcms/download/app"
CosResultHostUrl="https://images.xihuanwu.com"


# 日志机器人的配置
LogPostToRobotUrl="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"
LogPostTextHeader="这是上传过程中对日志进行补充的标题"


exit_with_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    printf "%s" "$1"
    exit 1
}


# 示例2:cos
function testUploadToCos() {
    ipa_file_path="/Users/qian/Pictures/shuma_bg2.webp"
    
    log_title "上传ipa到cos"
    responseJsonString=$(sh ${CurrentDIR_Script_Absolute}/upload_app_to_all.sh -ipa "${ipa_file_path}" \
        -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
        -CosREGION "${CosUploadToREGION}" -CosBUCKETName "${CosUploadToBUCKETName}" -CosBUCKETDir "${CosUploadToBUCKETDir}" -CosResultHostUrl "${CosResultHostUrl}" \
        -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}")
    if [ $? != 0 ]; then
        echo "${RED}上传ipa到各个平台失败的结果显示如下:${BLUE} ${responseJsonString} ${BLUE}。${NC}"
        exit 1
    fi
    printf "responseJsonString=%s\n" "${responseJsonString}"

    cosAppNetworkUrl=$(printf "%s" "${responseJsonString}" | jq -r '.cos.appNetworkUrl')
    echo "${YELLOW}上传ipa到cos的地址为${BLUE} ${cosAppNetworkUrl} ${YELLOW}。${NC}"
}


testUploadToCos