#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-27 10:05:32
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
# ipa_file_path="/Users/qian/Pictures/shuma_bg2.webp"
updateDesString="测试蒲公英上传到指定位置，请勿下载"

# 蒲公英的配置
pgyerApiKey="da2bc35c7943aa78e66ee9c94fdd0824"
pgyerChannelShortcut="fzgy"
pgyerShouldUploadFast="false"

# Cos的配置
CosUploadToREGION="ap-shanghai"
CosUploadToBUCKETName="prod-xhw-image-1302324914"
CosUploadToBUCKETDir="/mcms/download/app/"
CosResultHostUrl="https://images.xihuanwu.com"

# TestFlight的配置
Transporter_USERNAME=""
Transporter_PASSWORD=""

# 日志机器人的配置
LogPostToRobotUrl="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"
LogPostTextHeader="这是上传过程中对日志进行补充的标题"




# 示例1
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


# 示例2:cos
echo "\n\n"
log_title "上传ipa到cos"
sh ${CurrentDIR_Script_Absolute}/upload_app_to_all.sh -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -CosREGION "${CosUploadToREGION}" -CosBUCKETName "${CosUploadToBUCKETName}" -CosBUCKETDir "${CosUploadToBUCKETDir}" -CosResultHostUrl "${CosResultHostUrl}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}"

# 示例3
echo "\n\n"
log_title "上传ipa到各个平台"
responseJsonString=$(sh ${CurrentDIR_Script_Absolute}/upload_app_to_all.sh -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -pgyerHelpOwner "${pgyerOwner}" -pgyerHelpChannelKey "${pgyerChannelKey}" \
    -pgyerApiKey "${pgyerApiKey}" -pgyerChannelShortcut "${pgyerChannelShortcut}" -pgyerShouldUploadFast "${pgyerShouldUploadFast}" \
    -CosREGION "${CosUploadToREGION}" -CosBUCKETName "${CosUploadToBUCKETName}" -CosBUCKETDir "${CosUploadToBUCKETDir}" -CosResultHostUrl "${CosResultHostUrl}" \
    -TransporterUserName "${Transporter_USERNAME}" -TransporterPassword "${Transporter_PASSWORD}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
    )
if [ $? != 0 ]; then
    echo "${RED}上传ipa到各个平台失败的结果显示如下:${BLUE} ${responseJsonString} ${BLUE}。${NC}"
    exit 1
fi
printf "responseJsonString=%s\n" "${responseJsonString}"
pgyerQRCodeUrl=$(printf "%s" "${responseJsonString}" | jq -r '.pgyer.appNetworkUrl')
echo "${GREEN}上传ipa到蒲公英成功，地址为 ${pgyerQRCodeUrl}.${NC}"