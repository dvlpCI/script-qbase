#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 22:06:54
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

# 蒲公英的配置
pgyerApiKey="da2bc35c7943aa78e66ee9c94fdd0824"
pgyerChannelShortcut="fzgy"
pgyerShouldUploadFast="false"


exit_with_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    printf "%s" "$1"
    exit 1
}


# 示例1
function testUploadToPgyer() {
    log_title "上传ipa到蒲公英"
    responseJsonString=$(sh ${CurrentDIR_Script_Absolute}/upload_app_to_pgyer.sh -f "${ipa_file_path}" -k "${pgyerApiKey}" -c "${pgyerChannelShortcut}" -d "${updateDesString}" --should-upload-fast "${pgyerShouldUploadFast}")
    if [ $? != 0 ]; then
        errorMessage=$(echo ${responseJsonString} | jq -r '.message')
        echo "${RED}上传ipa到蒲公英失败的结果显示如下：${errorMessage}${NC}"
        exit 1
    fi
    printf "responseJsonString=%s\n" "${responseJsonString}"
    pgyerQRCodeUrl=$(printf "%s" ${responseJsonString} | jq -r '.qrCodeUrl')
    echo "${GREEN}上传ipa到蒲公英成功，地址为 ${pgyerQRCodeUrl}.${NC}"
}



testUploadToPgyer