#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-12 17:13:36
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-26 14:32:56
 # @Description: 上传安装包到 testFlight (只使用于iOS)
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -ipa|--ipa-file-path) ipa_file_path=$2; shift 2;;
                -TransporterUserName|--Transporter-username) Transporter_USERNAME=$2; shift 2;; # 用户账号
                -TransporterPassword|--Transporter-password) Transporter_PASSWORD=$2; shift 2;; # 使用的是秘钥，形如 "djjj-bjkz-rghr-aish"
                --) break ;;
                *) break ;;
        esac
done

if [ -z "${ipa_file_path}" ] || [ -f "${ipa_file_path}" ]; then
    printf "用来上传ipa的 Transporter 用户名和密码缺失，请先补充，此次无法自动上传。"
    exit 1
fi

if [ -z "${Transporter_USERNAME}" ] || [ -z "${Transporter_PASSWORD}" ]; then
    printf "用来上传ipa的 Transporter 用户名和密码缺失，请先补充，此次无法自动上传。"
    exit 1
fi


processLog=""

iTMSTransporter_EXEC=$(which iTMSTransporter)
if [ -z "${iTMSTransporter_EXEC}" ]; then
    processLog+="友情提示⚠️：which iTMSTransporter 执行无结果，将检查 Xcode 中的 iTMSTransporter，若存在，则使用之。"
    iTMSTransporter_EXEC_XcodeApp="/Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/itms/bin/iTMSTransporter"
    if [ -f "${iTMSTransporter_EXEC_XcodeApp}" ]; then
        iTMSTransporter_EXEC=${iTMSTransporter_EXEC_XcodeApp}
    fi
fi

if [ -z "${iTMSTransporter_EXEC}" ]; then
    processLog+="友情提示⚠️：which iTMSTransporter 执行无结果，将检查 TransporterApp 中的 iTMSTransporter，若存在，则使用之。"
    iTMSTransporter_EXEC_TransporterApp="/Applications/Transporter.app/Contents/itms/bin/iTMSTransporter"
    if [ -f "${iTMSTransporter_EXEC_TransporterApp}" ]; then
        iTMSTransporter_EXEC=${iTMSTransporter_EXEC_TransporterApp}
    fi
fi

processLog+="正在执行上传命令(到testFlight)：《${iTMSTransporter_EXEC} -m upload -assetFile \"${ipa_file_path}\" -u '${Transporter_USERNAME}' -p '${Transporter_PASSWORD}' -asc_provider 'U8PA5WCJPR'》..."
${iTMSTransporter_EXEC} -m upload -assetFile "${ipa_file_path}" -u "${Transporter_USERNAME}" -p "${Transporter_PASSWORD}" -asc_provider 'U8PA5WCJPR'
if [ $? != 0 ]; then
    responseResultCode=1
    responseResultMessage="上传到AppStore的脚本执行失败..............(请手动将 ${ipa_file_path} 通过 Transporter.app 上传)"
else
    responseResultCode=0
    responseResultMessage="上传到AppStore的脚本执行成功"
fi

responseResult='{

}'

# 使用 jq 添加键值对，并将变量 processLogValue 的值作为参数传递
# 必须使用 printf "%s" "$responseResult" ，否则当 responseResult 中某个key 的值有斜杠时候会出现错误
# responseResult=$(printf "%s" "$responseResult" | jq --arg processLog "$processLog" '. + { "processLog": $processLog }')
responseResult=$(printf "%s" "$responseResult" | jq --arg code "$responseResultCode" '. + { "code": $code }')
responseResult=$(echo "$responseResult" | jq --arg message "$responseResultMessage" '. + { "message": $message }')
# responseResult=$(printf "%s" "$responseResult" | jq --arg qrCode "$qrCodeUrl" '. + { "qrCodeUrl": $qrCode }')
printf "%s" "${responseResult}"

