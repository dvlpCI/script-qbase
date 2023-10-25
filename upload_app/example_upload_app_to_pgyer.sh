#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-25 13:22:18
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
pgyer_api_key_VALUE="da2bc35c7943aa78e66ee9c94fdd0824"
buildChannelShortcut="fzgy"
UpdateDescription="测试蒲公英上传到指定位置，请勿下载"
ShouldUploadFast="false"


log_title "上传ipa到蒲公英"
responseJsonString=$(sh ${CurrentDIR_Script_Absolute}/upload_app_to_pgyer.sh -f "${ipa_file_path}" -k "${pgyer_api_key_VALUE}" -c "${buildChannelShortcut}" -d "${UpdateDescription}" --should-upload-fast "${ShouldUploadFast}")
if [ $? != 0 ]; then
    errorMessage=$(echo ${responseJsonString} | jq -r '.message')
    echo "${RED}${errorMessage}${NC}"
    exit 1
fi
printf "responseJsonString=%s\n" "${responseJsonString}"
qrCodeUrl=$(echo ${responseJsonString} | jq -r '.qrCodeUrl')
echo "${GREEN}上传ipa到蒲公英成功，地址为 ${qrCodeUrl}.${NC}"


