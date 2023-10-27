#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-12 17:13:36
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-27 10:42:14
 # @Description: 上传安装包到 各个平台(pgyer、cos、testFlight)
### 

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..

qbase_upload_app_to_pgyer_script_path="${CurrentDIR_Script_Absolute}/upload_app_to_pgyer.sh"
qbase_upload_app_to_testflight_script_path="${CurrentDIR_Script_Absolute}/upload_app_to_testflight.sh"
qbase_notification2wechat_script_path="${qbase_HomeDir_Absolute}/notification/notification2wechat.sh"

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'




lastResponseJsonString='{

}'


function addDataToLastJsonWithCompontentKey {
    local responseResultCode=$1
    local responseResultMessage=$2
    local responseResultAppNetworkUrl=$3
    local compontentKey=$4

    local compontentJsonString='{}'
    
    # 添加code字段
    compontentJsonString=$(jq --arg code "$responseResultCode" '. + { "code": $code }' <<< "$compontentJsonString")
    
    # 添加message字段
    compontentJsonString=$(jq --arg message "$responseResultMessage" '. + { "message": $message }' <<< "$compontentJsonString")

    # 添加appNetworkUrl字段
    compontentJsonString=$(jq --arg appNetworkUrl "$responseResultAppNetworkUrl" '. + { "appNetworkUrl": $appNetworkUrl }' <<< "$compontentJsonString")

    # printf "payerJsonString的值为:%s\n" "$compontentJsonString"

    lastResponseJsonString=$(jq --argjson pgyer "$compontentJsonString" '. + { "'"$compontentKey"'": $pgyer }' <<< "$lastResponseJsonString")

    # printf "lastResponseJsonString的值为:%s\n" "$lastResponseJsonString"
}

# 调用函数进行测试
lastResponseJsonString='{"existingKey": "existingValue"}'
# addDataToLastJsonWithCompontentKey 100 "success" "http://www.baidu.com" "test"

# payerResponseResultCode=100
# payerResponseResultMessage="success"
# payerResponseResultQRCodeUrl="http://www.baidu.com"
# addDataToLastJsonWithCompontentKey $payerResponseResultCode $payerResponseResultMessage $payerResponseResultQRCodeUrl "pgyer"
# exit


exit_script_with_response_error_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    # 使用 jq 添加键值对，并将变量 processLogValue 的值作为参数传递
    lastResponseJsonString=$(echo "$lastResponseJsonString" | jq --arg log "$uploadToAllProcessLog" '. + { "log": $log }')
    lastResponseJsonString=$(echo "$lastResponseJsonString" | jq --arg message "$1" '. + { "message": $message }')
    printf "%s" "${lastResponseJsonString}"
    exit 1
}

function debug_log() {
	if [ "${isDebugThisScript}" == true ]; then
		echo "$1"
	fi
}



# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -ipa|--ipa-file-path) ipa_file_path=$2; shift 2;;
                -updateDesString|--updateDesString) updateDesString=$2; shift 2;; # 上传安装包时候附带的说明文案，优先使用此值。
                -updateDesFromFilePath|--updateDesFromFilePath) updateDesFromFilePath=$2; shift 2;; # 说明文案使用来源于哪个文件
                -updateDesFromFileKey|--updateDesFromFileKey) updateDesFromFileKey=$2; shift 2;; # 说明文案使用来源于文件的哪个key
                

                -pgyerHelpOwner|--pgyer-owner) pgyerOwner=$2; shift 2;; # 非必传值
                -pgyerHelpChannelKey|--pgyer-ChannelKey) pgyerChannelKey=$2; shift 2;; # 非必传值
                -pgyerApiKey|--pgyer-api-key) pgyerApiKey=$2; shift 2;;
                -pgyerChannelShortcut|--pgyer-channel) pgyerChannelShortcut=$2; shift 2;;
				-pgyerShouldUploadFast|--should-upload-fast) pgyerShouldUploadFast=$2; shift 2;;


                -CosREGION|--Cos-CosUploadToREGION) CosUploadToREGION=$2; shift 2;; # ap-shanghai
                -CosBUCKETName|--Cos-CosUploadToBUCKETName) CosUploadToBUCKETName=$2; shift 2;; # prod-xhw-image-1302324914
                -CosBUCKETDir|--Cos-UploadToRelDir) CosUploadToBUCKETDir=$2; shift 2;; # 文件上传到桶的哪个相对目录下 mcms/download/app/
                -CosResultHostUrl|--Cos-ResultHostUrl) CosResultHostUrl=$2; shift 2;; # 上传结果对应的地址前缀（最后完整url，使用该前缀+上述目录拼接而成）

                -TransporterUserName|--Transporter-username) Transporter_USERNAME=$2; shift 2;; # 用户账号
                -TransporterPassword|--Transporter-password) Transporter_PASSWORD=$2; shift 2;; # 使用的是秘钥，形如 "djjj-bjkz-rghr-aish"

                -LogPostToRobotUrl|--Log-PostTo-RobotUrl) LogPostToRobotUrl=$2; shift 2;; # 上传过程中的日志发送到哪个机器人
                -LogPostTextHeader|--Log-Post-TextHeader) LogPostTextHeader=$2; shift 2;; # 上传过程中对日志进行补充的标题
                --) break ;;
                *) break ;;
        esac
done

uploadToAllProcessLog=""

if [ ! -f "${ipa_file_path}" ]; then
    exit_script_with_response_error_message "Error:要上传的文件 -f 的参数值 ${ipa_file_path} 不能为空，请检查后再上传！"
fi


ShoudUploadToAppStrore=false
app_file_extension="${ipa_file_path##*.}" # 获取文件的后缀名
if [ "$app_file_extension" = "ipa" ]; then
    if [ -z "${Transporter_USERNAME}" ] || [ -z "${Transporter_PASSWORD}" ]; then
        uploadToAllProcessLog+="温馨提示：您的此iOS包不会上传到AppStore。（因为您设置用来上传ipa的 Transporter 用户名和密码缺失，请先补充，所以此次无法自动上传。附:Transporter_USERNAME=${Transporter_USERNAME} Transporter_PASSWORD=${Transporter_PASSWORD} )。"
    else
        ShoudUploadToAppStrore=true
    fi
fi
debug_log "ShoudUploadToAppStrore=${ShoudUploadToAppStrore}"


ShoudUploadToCos=false
if [ -z "${CosUploadToREGION}" ] || [ -z "${CosUploadToBUCKETName}" ] || [ -z "${CosUploadToBUCKETDir}" ] || [ -z "${CosResultHostUrl}" ]; then
    uploadToAllProcessLog+="温馨提示：您的包不会上传到腾讯Cos。（因为您设置用来上传ipa的cos参数有缺失，各值如下: CosREGION=${CosUploadToREGION} CosBUCKETName=${CosUploadToBUCKETName} CosBUCKETDir=${CosUploadToBUCKETDir} CosResultHostUrl=${CosResultHostUrl} )。"
else
    ShoudUploadToCos=true
fi
debug_log "ShoudUploadToCos=${ShoudUploadToCos}"


ShoudUploadToPgyer=false
if [ -z "${pgyerApiKey}" ] || [ -z "${pgyerChannelShortcut}" ]; then
    uploadToAllProcessLog+="温馨提示：您的包不会上传到蒲公英pgyer。（因为您设置用来上传ipa的cos参数有缺失，各值如下: pgyerApiKey=${pgyerApiKey} pgyerChannelShortcut=${pgyerChannelShortcut} )。"
else
    ShoudUploadToPgyer=true
    if [ -z "${pgyerShouldUploadFast}" ]; then
        pgyerShouldUploadFast=false
    fi
fi
debug_log "ShoudUploadToPgyer=${ShoudUploadToPgyer}"




JQ_EXEC=`which jq`




function postWechatMessage() {
    if [ -z "${LogPostToRobotUrl}" ]; then
        return
    fi

    if [ -z "${LogPostTextHeader}" ]; then
        CONTENT1="$1"
    else
        CONTENT1="${LogPostTextHeader}\n$1"
    fi

    msgtype="text"
    atMiddleBracketIdsString="[]"
    # 特别注意:下面额外使用postErrorMessage=$(sh xx.sh a b c) 是为了避免 qbase_notification2wechat_script_path 脚本里面有 echo ，导致影响了本脚本文件最后的输出结果。
    postErrorMessage=$(sh ${qbase_notification2wechat_script_path} -robot "${LogPostToRobotUrl}" -content "${CONTENT1}" -at "${atMiddleBracketIdsString}" -msgtype "${msgtype}")
    if [ $? -ne 0 ]; then 
        exit_script_with_response_error_message "上传安装包的日志发送失败,要发送的信息为 ${CONTENT1}"
    fi
}



function uploadToPgyer() {
    postWechatMessage "正在上传pgyer......(${pgyerOwner})${pgyerChannelShortcut}[${ipa_file_path}]"

    pgyerChangeLog=${lastAllChangeLogResult}
#    echo "替换英文分号前pgyerChangeLog=\n${pgyerChangeLog}" # 注意:如果蒲公英更新说明里有分号;，则分号后的文案不能被提交上去
    pgyerChangeLog=`echo "${pgyerChangeLog//;/；}"`
#    echo "替换英文分号后pgyerChangeLog=\n${pgyerChangeLog}" # 注意:如果蒲公英更新说明里有分号;，则分号后的文案不能被提交上去

    debug_log "=====================您的的蒲公英上传位置为PgyerOwner=${pgyerOwner},pgyerChannelShortcut=${pgyerChannelShortcut},pgyerChannelKey=${pgyerChannelKey}"
    debug_log "${BLUE}正在执行命令(上传安装包到蒲公英上)：《${YELLOW} sh ${qbase_upload_app_to_pgyer_script_path} -f \"${ipa_file_path}\" -k \"${pgyerApiKey}\" --pgyer-channel \"${pgyerChannelShortcut}\" -d \"${pgyerChangeLog}\" --should-upload-fast \"${pgyerShouldUploadFast}\" ${BLUE}》...${NC}\n"
    responseJsonString=$(sh ${qbase_upload_app_to_pgyer_script_path} -f "${ipa_file_path}" -k "${pgyerApiKey}" --pgyer-channel "${pgyerChannelShortcut}" -d "${pgyerChangeLog}" --should-upload-fast "${pgyerShouldUploadFast}")
    
    
    payerResponseResultCode=$(echo ${responseJsonString} | jq -r '.code')
    payerResponseResultMessage=$(echo ${responseJsonString} | jq -r '.message')
    payerResponseResultQRCodeUrl=$(echo ${responseJsonString} | jq -r '.qrCodeUrl')
    addDataToLastJsonWithCompontentKey "$payerResponseResultCode" "$payerResponseResultMessage" "$payerResponseResultQRCodeUrl" "pgyer"

    postWechatMessage "结束上传pgyer......(${pgyerOwner})${pgyerChannelShortcut}[${ipa_file_path}]"
}


function uploadToCos() {
    postWechatMessage "正在上传cos......[${ipa_file_path}]"
    # 官方文档 [COSCMD 工具](https://cloud.tencent.com/document/product/436/10976)
    # 配置文件本地目录： ~/.cos.conf
    #
    # ~/Library/Python/3.8/bin/coscmd -b prod-xhw-image-1302324914 -r ap-shanghai upload -r ~/Desktop/dianzan.svg /mcms/download/app/
    # 结果：
    # https://console.cloud.tencent.com/cos/bucket?bucket=prod-xhw-image-1302324914&region=ap-shanghai&path=%252Fmcms%252Fdownload%252Fapp%252F
    # https://images.xxx.com/mcms/download/app/

    coscmdPath=$(which coscmd)
    debug_log "正在执行命令(上传安装包到cos):《 ${coscmdPath} -b ${CosUploadToBUCKETName} -r ${CosUploadToREGION} upload -r ${ipa_file_path} ${CosUploadToBUCKETDir} 》"
    responseJsonString=$(${coscmdPath} -b "${CosUploadToBUCKETName}" -r "${CosUploadToREGION}" upload -r "${ipa_file_path}" "${CosUploadToBUCKETDir}")
    if [ $? = 0 ]   # 上个命令的退出状态，或函数的返回值。
    then
        cosResponseResultCode=0
        UPLOAD_FILE_Name=$(basename "$ipa_file_path") 
        cosResponseResultAppNetworkUrl="${CosResultHostUrl}/${CosUploadToBUCKETDir}/${UPLOAD_FILE_Name}"
        cosResponseResultMessage="Success: ${ipa_file_path} 文件上传cos成功，路径为${cosResponseResultAppNetworkUrl}"
    else
        cosResponseResultCode=1
        cosResponseResultMessage="Failure: ${ipa_file_path} 文件上传cos失败(配置文件本地目录： ~/.cos.conf)，不继续操作。"
        cosResponseResultAppNetworkUrl="上传cos失败，无地址"
    fi
    
    addDataToLastJsonWithCompontentKey "$cosResponseResultCode" "$cosResponseResultMessage" "$cosResponseResultAppNetworkUrl" "cos"
    postWechatMessage "结束上传cos......[${ipa_file_path}]"
}

function uploadToAppStore() {
    postWechatMessage "正在上传appstore......[${ipa_file_path}]"

    printf "${BLUE}正在执行命令(上传安装包到testFlight上)：《 ${YELLOW}sh ${qbase_upload_app_to_testflight_script_path} -ipa \"${ipa_file_path}\" -TransporterUserName \"${Transporter_USERNAME}\" -TransporterPassword \"${Transporter_PASSWORD}\" ${BLUE}》...${NC}\n"
    responseJsonString=$(sh ${qbase_upload_app_to_testflight_script_path} -ipa "${ipa_file_path}" -TransporterUserName "${Transporter_USERNAME}" -TransporterPassword "${Transporter_PASSWORD}")
    
    tfResponseResultCode=$(echo ${responseJsonString} | jq -r '.code')
    tfResponseResultMessage=$(echo ${responseJsonString} | jq -r '.message')
    tfResponseResultAppNetworkUrl="https://apps.apple.com/cn/app/testflight"
    addDataToLastJsonWithCompontentKey "$tfResponseResultCode" "$tfResponseResultMessage" "$tfResponseResultAppNetworkUrl" "testFlight"

    postWechatMessage "结束上传appstore......[${ipa_file_path}]"
}



# 获取提供给蒲公英的更新说明
if [ -n "${updateDesString}" ]; then
    lastAllChangeLogResult="${updateDesString}"
else
    if [ -z "${updateDesFromFilePath}" ] || [ -z "${updateDesFromFileKey}" ]; then
        postWechatMessage "您将缺失上传说明文案。若要自定义说明文案，方案①请设置 -updateDesString 参数，或者方案②同时设置 -updateDesFromFilePath 和 -updateDesFromFileKey 参数。"
        lastAllChangeLogResult=""
    else
        lastAllChangeLogResult=$(cat ${updateDesFromFilePath} | ${JQ_EXEC} ".${updateDesFromFileKey}")
        if [ -z "${lastAllChangeLogResult}" ] || [ "${lastAllChangeLogResult}" == "null" ]; then
            postWechatMessage "您选择了说明文案从文件中获取，但未正确设置 -updateDesFromFilePath 和 -updateDesFromFileKey 参数，请检查。(附:updateDesString=$updateDesString, updateDesFromFilePath=${updateDesFromFilePath}, updateDesFromFileKey=${updateDesFromFileKey} )。"
            lastAllChangeLogResult=""
        fi
    fi
fi



if [ "${ShoudUploadToPgyer}" == "true" ] ; then
    uploadToPgyer
fi

if [ "${ShoudUploadToCos}" == "true" ] ; then
    uploadToCos
fi

if [ "${ShoudUploadToAppStrore}" == "true" ] ; then
    uploadToAppStore
fi

lastResponseJsonString=$(echo "$lastResponseJsonString" | jq --arg log "$uploadToAllProcessLog" '. + { "log": $log }')
printf "%s" "${lastResponseJsonString}"
