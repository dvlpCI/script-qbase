#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-12 17:13:36
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-28 00:26:25
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
    # if [[ "$responseResultCode" =~ ^[0-9]+$ ]]; then
    #     responseResultCode=$((responseResultCode + 0)) # 如果是纯数字字符串，则将其转换为数值
    # fi
    # responseResultCode=0

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
    exit_script_with_response_error_message "Error:要上传的安装包文件 -ipa 的参数值 ${ipa_file_path} 不能为空，请检查后再上传！"
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
if [ -z "${pgyerApiKey}" ]; then
    uploadToAllProcessLog+="温馨提示：您的包不会上传到蒲公英pgyer。因为您缺失将ipa上传到pgyer的必备 pgyerApiKey 参数。(附 apiKey 和 channelShortcut 分别如下: pgyerApiKey=${pgyerApiKey} pgyerChannelShortcut=${pgyerChannelShortcut} )。"
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
    # responseJsonString='{
    #     "code": 0,
    #     "message": "上传pgyer成功",
    #     "appNetworkUrl": "https://www.xcxwo.com/app/qrcodeHistory/9680a4ad4436cad0cf4e5f8a9eb937d36d55b653cf425fda298db7818232d818"
    # }'
    
    payerResponseResultCode=$(echo ${responseJsonString} | jq -r '.code')
    payerResponseResultMessage=$(echo ${responseJsonString} | jq -r '.message')
    payerResponseResultAppNetworkUrl=$(echo ${responseJsonString} | jq -r '.appNetworkUrl')
    addDataToLastJsonWithCompontentKey "$payerResponseResultCode" "$payerResponseResultMessage" "$payerResponseResultAppNetworkUrl" "pgyer"

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

    if [[ "${CosUploadToBUCKETDir}" != */ ]]; then
        addDataToLastJsonWithCompontentKey "1" "您的bucketDir的值 ${CosUploadToBUCKETDir} 没有以/结尾" "无法进行上传cos，无地址" "cos"
        postWechatMessage "无法进行上传cos，您的bucketDir的值 ${CosUploadToBUCKETDir} 没有以/结尾......[${ipa_file_path}]"
        return 1
    fi

    coscmdPath=$(which coscmd)
    debug_log "正在执行命令(上传安装包到cos):《 ${coscmdPath} -b ${CosUploadToBUCKETName} -r ${CosUploadToREGION} upload -r ${ipa_file_path} ${CosUploadToBUCKETDir} 》"
    responseJsonString=$(${coscmdPath} -b "${CosUploadToBUCKETName}" -r "${CosUploadToREGION}" upload -r "${ipa_file_path}" "${CosUploadToBUCKETDir}")
    # responseJsonString='{
    #     "code": 0,
    #     "message": "上传cos成功",
    #     "appNetworkUrl": "https://www.xxx.com/app/qrcodeHistory/111"
    # }'
    cosErrorCode=$?
    if [ ${cosErrorCode} = 0 ]   # 上个命令的退出状态，或函数的返回值。
    then
        # 去掉开头的斜杠（/），如果开头是以/开头的
        if [[ "${CosResultHostUrl}" == /* ]]; then
            CosResultHostUrl=${CosResultHostUrl#/}
        fi
        # 去掉结尾的斜杠（/），如果结尾是以/结尾的
        if [[ "${CosResultHostUrl}" == */ ]]; then
            CosResultHostUrl=${CosResultHostUrl%/}
        fi

        # 去掉开头的斜杠（/），如果开头是以/开头的
        if [[ "${CosUploadToBUCKETDir}" == /* ]]; then
            CosUploadToBUCKETDir=${CosUploadToBUCKETDir#/}
        fi
        # 去掉结尾的斜杠（/），如果结尾是以/结尾的
        if [[ "${CosUploadToBUCKETDir}" == */ ]]; then
            CosUploadToBUCKETDir=${CosUploadToBUCKETDir%/}
        fi
        cosResponseResultCode=0
        UPLOAD_FILE_Name=$(basename "$ipa_file_path") 
        cosResponseResultAppNetworkUrl="${CosResultHostUrl}/${CosUploadToBUCKETDir}/${UPLOAD_FILE_Name}"
        cosResponseResultMessage="Success: ${ipa_file_path} 文件上传cos成功，路径为${cosResponseResultAppNetworkUrl}"
    else
        cosResponseResultCode=1
        cosResponseResultMessage="Failure: ${ipa_file_path} 文件上传cos失败，将不继续操作。附失败原因如下:【 ${cosErrorCode}:${responseJsonString} 】，执行的命令如下：《 ${coscmdPath} -b \"${CosUploadToBUCKETName}\" -r \"${CosUploadToREGION}\" upload -r \"${ipa_file_path}\" \"${CosUploadToBUCKETDir}\" 》。 (若要查看本地配置文件，请查看目录： ~/.cos.conf)"
        cosResponseResultAppNetworkUrl="上传cos失败，无地址"
    fi
    
    addDataToLastJsonWithCompontentKey "$cosResponseResultCode" "$cosResponseResultMessage" "$cosResponseResultAppNetworkUrl" "cos"
    postWechatMessage "结束上传cos......[${ipa_file_path}]"
}

function uploadToAppStore() {
    postWechatMessage "正在上传appstore......[${ipa_file_path}]"

    printf "${BLUE}正在执行命令(上传安装包到testFlight上)：《${YELLOW} sh ${qbase_upload_app_to_testflight_script_path} -ipa \"${ipa_file_path}\" -TransporterUserName \"${Transporter_USERNAME}\" -TransporterPassword \"${Transporter_PASSWORD}\" ${BLUE}》...${NC}\n"
    responseJsonString=$(sh ${qbase_upload_app_to_testflight_script_path} -ipa "${ipa_file_path}" -TransporterUserName "${Transporter_USERNAME}" -TransporterPassword "${Transporter_PASSWORD}")
    
    tfResponseResultCode=$(echo ${responseJsonString} | jq -r '.code')
    tfResponseResultMessage=$(echo ${responseJsonString} | jq -r '.message')
    tfResponseResultAppNetworkUrl="https://apps.apple.com/cn/app/testflight"
    addDataToLastJsonWithCompontentKey "$tfResponseResultCode" "$tfResponseResultMessage" "$tfResponseResultAppNetworkUrl" "testFlight"

    postWechatMessage "结束上传appstore......[${ipa_file_path}]"
}



function _getComponentUploadResultCodeAndMessage() {
    compontentResultMessage=""

    compontentKey=$1
    compontentJsonString=$(printf "%s" "${lastResponseJsonString}" | jq -r ".${compontentKey}")
    if [ -z "${compontentJsonString}" ]; then
        return 0; # 没有此项上传需求
    fi
    
    # 上传失败
    compontentResultCode=$(printf "%s" "${compontentJsonString}" | jq -r ".code")
    if [ "${compontentResultCode}" != 0 ]; then
        compontentResultMessage=$(printf "%s" "${compontentJsonString}" | jq -r '.message')
        return 1
    fi
    

    # 上传成功
    if [ "${compontentKey}" == "testFlight" ]; then 
        return 0;
    fi
    # 上传成功，并更新地址给文件
    compontentAppNetworkUrl=$(printf "%s" "${compontentJsonString}" | jq -r '.appNetworkUrl')
    if [ ${#compontentAppNetworkUrl} == 0 ]; then
        compontentResultMessage="上传成功，但 ${compontentKey} 的更新地址获取失败 。"
        return 1
    fi
}

function _updateSuccessAndFailureTypes_And_TotalFailureMessage() {
    compontentKey=$1

    _getComponentUploadResultCodeAndMessage "${compontentKey}"
    if [ $? != 0 ]; then 
        uploadFailureTypeArray+=("${compontentKey}") # 使用赋值操作将变量添加到数组变量
        uploadFailureTotalMessage+="${compontentResultMessage}"
    else
        uploadSuccessTypeArray+=("${compontentKey}") # 使用赋值操作将变量添加到数组变量
    fi
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
        if [ $? != 0 ] || [ -z "${lastAllChangeLogResult}" ] || [ "${lastAllChangeLogResult}" == "null" ]; then
            postWechatMessage "您选择了说明文案从文件中获取，但未正确设置 -updateDesFromFilePath 和 -updateDesFromFileKey 参数，请检查。(附:updateDesString=$updateDesString, updateDesFromFilePath=${updateDesFromFilePath}, updateDesFromFileKey=${updateDesFromFileKey} )。"
            lastAllChangeLogResult=""
        fi
    fi
fi


uploadFailureTotalMessage=""
uploadSuccessTypeArray=()
uploadFailureTypeArray=()

if [ "${ShoudUploadToPgyer}" == "true" ] ; then
    uploadToPgyer
    _updateSuccessAndFailureTypes_And_TotalFailureMessage "pgyer"
fi

if [ "${ShoudUploadToCos}" == "true" ] ; then
    uploadToCos
    _updateSuccessAndFailureTypes_And_TotalFailureMessage "cos"
fi

if [ "${ShoudUploadToAppStrore}" == "true" ] ; then
    uploadToAppStore
    _updateSuccessAndFailureTypes_And_TotalFailureMessage "testFlight"
fi

# uploadFailureCount=${#uploadFailureTypeArray[@]}
# lastResponseJsonString=$(printf "%s" "$lastResponseJsonString" | jq --arg uploadFailureCount "$uploadFailureCount" '. + { "uploadFailureCount": $uploadFailureCount }')
lastResponseJsonString=$(printf "%s" "$lastResponseJsonString" | jq --arg uploadSuccessTypes "${uploadSuccessTypeArray[*]}" '. + { "uploadSuccessTypes": $uploadSuccessTypes }')
lastResponseJsonString=$(printf "%s" "$lastResponseJsonString" | jq --arg uploadFailureTypes "${uploadFailureTypeArray[*]}" '. + { "uploadFailureTypes": $uploadFailureTypes }')
lastResponseJsonString=$(printf "%s" "$lastResponseJsonString" | jq --arg uploadFailureTotalMessage "$uploadFailureTotalMessage" '. + { "uploadFailureTotalMessage": $uploadFailureTotalMessage }')
lastResponseJsonString=$(printf "%s" "$lastResponseJsonString" | jq --arg log "$uploadToAllProcessLog" '. + { "log": $log }')
printf "%s" "${lastResponseJsonString}"
