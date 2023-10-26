#!/bin/bash
# 脚本说明：上传ipa到蒲公英xcxwo（可设置渠道）

# 使用示例:请在终端执行如下命令：
# sh s3_uploadipa_xcxwo_app1.sh -f "${ipa_file_path}" -k ${xcxwo_api_key_VALUE} -c ${buildChannelShortcut} -d ${UpdateDescription}
:<<!
1、外界参数介绍：
外界参数1：必填：ipa_file_path 当前要导出的 .ipa 文件路径,
                同时会在 .ipa 文件所在同级目录下创建一个文件名为 QRCode 的文件夹，作为上传过程前所需要生成的文件的输出目录
外界参数2：必填：xcxwo_api_key_VALUE    蒲公英api的key值
外界参数4：选填：buildChannelShortcut   有值时候,只上传到指定渠道(需事先在蒲公英上建立此渠道短链，否则会提示The channel shortcut URL is invalid)

2、使用示例:请在终端执行如下命令：
sh s3_uploadipa_xcxwo_app1.sh -f "./outputApp1Enterprise/Debug-iphoneos13.2/archive/App1Enterprise/App1Enterprise.ipa" -k da2bc35c7943aa78e66ee9c94fdd0824 -c dev1-dev_f1 -d "测试蒲公英上传到指定位置，请勿下载"
sh s3_uploadapp_xcxwo.sh --ipa-file-path "./outputApp1Enterprise/Debug-iphoneos13.2/archive/App1Enterprise/App1Enterprise.ipa" --pgyer-api-key da2bc35c7943aa78e66ee9c94fdd0824 --channel dev1-dev_1_noexsit --update-description "测试蒲公英上传到指定位置，请勿下载"
!

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 以下代码为测试上传安装后的返回值
# responseJsonString='{
#     "key1": "value1", "qrCodeUrl": "https://www.baidu.com", "message": "success"
# }'
# # 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。
# printf "%s" "${responseJsonString}"
# exit 0


exit_script_with_response_error_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    responseResult='{
        "code": 1
    }'
    # 使用 jq 添加键值对，并将变量 processLogValue 的值作为参数传递
    responseResult=$(echo "$responseResult" | jq --arg message "$1" '. + { "message": $message }')
    # responseResult=$(echo "$responseResult" | jq --arg processLog "$processLog" '. + { "processLog": $processLog }')
    printf "%s" "${responseResult}"
    exit 1
}

function debug_log() {
	if [ "${isDebugThisScript}" == true ]; then
		echo "$1"
	fi
}

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"

CUR_DIR=$PWD    #$PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
# 如果本脚本有地方使用了 CUR_DIR，且调用本脚本的脚本和本脚本不在同一个目录下，那么，本脚本的调用只能外部使用本脚本，不能使用 source,而只能使用 sh

#:<<!
## 1.先判断输入的命令和参数是否正确
#if [[ $# < 2 ]] # 传递到脚本或函数的参数个数
#then
#    echo "脚本${0}执行失败：Error:参数数量必须至少2个(ipa路径必须+环境必须+分支可选)，您当前为$#个，请检查您的参数个数，再重新输入"
#    exit_script
#fi
#
#ipa_file_path=$1
#APPENVIRONMENT=$2
#FEATUREBRANCH=$3
#!
# shell 参数具名化
show_usage="args: [-f , -k , -c , -d]\
                                  [--ipa-file-path=, --pgyer-api-key=, --pgyer-channel=, --update-description=]"

while [ -n "$1" ]
do
        case "$1" in
                -f|--ipa-file-path) ipa_file_path=$2; shift 2;;
                -k|--pgyer-api-key) xcxwo_api_key_VALUE=$2; shift 2;;
                -c|--pgyer-channel) buildChannelShortcut=$2; shift 2;;
                -d|--update-description) UpdateDescription=$2; shift 2;;
				-fast|--should-upload-fast) ShouldUploadFast=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

if [ ! -f "${ipa_file_path}" ]; then
	exit_script_with_response_error_message "${RED}Error:要上传到蒲公英的安装包文件不存在，请检查 ${BLUE}-f ${RED}参数的值 ${BLUE}${ipa_file_path} ${RED}。${NC}"
fi

PgyerChannelWordCount=$(echo "${buildChannelShortcut}" | awk '{print NF}')
if [ "${buildChannelShortcut}" == "null" ] || [ -z "${buildChannelShortcut}" ] || [ ${PgyerChannelWordCount} != 1 ]; then
    exit_script_with_response_error_message "蒲公英渠道号PgyerChannel的单词数只能是一个，且不能为null。您当前渠道值为:${buildChannelShortcut}，渠道单词数为:${PgyerChannelWordCount}"
fi

debug_log "-------- 脚本的入参如下 --------"
debug_log "ipa_file_path=$ipa_file_path"
debug_log "xcxwo_api_key_VALUE=$xcxwo_api_key_VALUE"
#xcxwo_api_key_VALUE=da2bc35c7943aa78e66ee9c94fdd0824  # 蒲公英_api_key的值，请进入https://www.xcxwo.com/doc/view/api#uploadApp中的接口查看。
debug_log "buildChannelShortcut=$buildChannelShortcut"
debug_log "UpdateDescription=$UpdateDescription"
debug_log "-------- 脚本的入参如上 --------"



# [上传ipa](https://www.xcxwo.com/doc/view/api#uploadApp)

processLog+="\n${PURPLE}>>>>>>>>>>>>>>> step7：begin upload app to 蒲公英 >>>>>>>>>>>>>>>>>>>>>>>>>>>>${NC}"
debug_log "ipa路径IPA_FILE_FULLPATH:   ${ipa_file_path}"


if [ -n "${buildChannelShortcut}" ] # 当串的长度大于0时为真(串非空):只上传到当前指定渠道
then
    DOT="."
    if [[ $FEATUREBRANCH == *$DOT* ]]
    then
        errorMessage="分支${FEATUREBRANCH}包含.，所以其不能作为渠道，请在外部入参前替换其中的.为_"
        exit_script_with_response_error_message "${errorMessage}"
    fi
   
    # 需事先在蒲公英上建立此渠道短链，否则会提示The channel shortcut URL is invalid
    processLog="${PURPLE}上传目标${BLUE} ${ipa_file_path} ${PURPLE}：只会上传到蒲公英的上的【指定渠道】:${BLUE} ${buildChannelShortcut} ${PURPLE}。${NC}"
    if [ "${ShouldUploadFast}" == true ]; then
    	# echo "${YELLOW}正在执行《 ${BLUE}sh ${CurrentDIR_Script_Absolute}/uploadfast_app_to_pgyer.sh -k $xcxwo_api_key_VALUE -c \"${buildChannelShortcut}\" -d \"${UpdateDescription}\" \"${ipa_file_path}\" ${YELLOW}》...${NC}"
    	sh ${CurrentDIR_Script_Absolute}/uploadfast_app_to_pgyer.sh -k $xcxwo_api_key_VALUE -c "${buildChannelShortcut}" -d "${UpdateDescription}" "${ipa_file_path}"
    	if [ $? != 0 ]; then
			echo "快传,上传成功"
			exit 0
		else
			errorMessage="${RED}快传,上传失败${NC}"
			exit_script_with_response_error_message "${errorMessage}"
		fi
    else
	    responseResult=$(curl -F "file=@${ipa_file_path}" -F "_api_key=${xcxwo_api_key_VALUE}" -F "buildChannelShortcut=${buildChannelShortcut}" -F "buildUpdateDescription=${UpdateDescription}" https://www.xcxwo.com/apiv2/app/upload)
	fi
else
    echo "${PURPLE}上传目标${BLUE} ${ipa_file_path} ${PURPLE}：会上传到蒲公英的上的【所有渠道】${NC}"
    if [ "${ShouldUploadFast}" == true ]; then
		# echo "${YELLOW}正在执行《 ${BLUE}sh ${CurrentDIR_Script_Absolute}/uploadfast_app_to_pgyer.sh -k $xcxwo_api_key_VALUE -d \"${UpdateDescription}\" \"${ipa_file_path}\" ${YELLOW}》...${NC}"    
		sh ${CurrentDIR_Script_Absolute}/uploadfast_app_to_pgyer.sh -k $xcxwo_api_key_VALUE -d "${UpdateDescription}" "${ipa_file_path}"
		if [ $? != 0 ]; then
			successMessage="快传,上传成功"
			exit 0
		else
			errorMessage="${RED}快传,上传失败${NC}"
			exit_script_with_response_error_message "${errorMessage}"
		fi

    else
    	responseResult=$(curl -F "file=@${ipa_file_path}" -F "_api_key=${xcxwo_api_key_VALUE}" -F "buildUpdateDescription=${UpdateDescription}" https://www.xcxwo.com/apiv2/app/upload)
    fi
fi

# 以下代码为测试上传安装后的返回值
# responseResult='{
#     "code": 0, 
#     "data": {"buildQRCodeURL": "https://www.baidu.com"}, 
#     "message": "success"
# }'

#echo '{"foo": 0,"bar":1}' | jq .
#responseResult='{"foo": 0,"bar":1}'
#responseResult='{"code":1212,"message":"The channel shortcut URL is invalid"}'
# echo $responseResult | jq .
#echo '============================='

if [ $? = 0 ]   # 上个命令的退出状态，或函数的返回值。
then
    debug_log "responseResult=$responseResult"
    responseResultCode=$(printf "%s" "${responseResult}" | jq -r '.code') # mac上安装brew后，执行brew install jq安装jq
    # if [ $? != 0 ]; then
    # 	echo "${RED}Error❌${responseResultCode}:安装包文件上传脚本执行失败，完整的返回结果responseResult=${BLUE}$responseResult${NC}"
    # 	exit_script
    # fi

    debug_log "responseResultCode=$responseResultCode"
    if [ "$responseResultCode" = 0 ];then
        qrCodeUrl=$(printf "%s" "${responseResult}" | jq -r '.data.buildQRCodeURL')
        processLog+="\n${GREEN}恭喜:安装包文件上传上传成功 ，继续操作，二维码地址:${BLUE} ${qrCodeUrl} ${GREEN}...${NC}"
    else
        processLog+="${RED}Error❌:安装包文件上传失败，完整的返回结果responseResult=${BLUE}$responseResult${NC}"
        responseErrorMessage=$(printf "%s" "${responseResult}" | jq  '.message')
        #echo "responseErrorMessage=$responseErrorMessage"
        if [ "$responseResultCode" = 1212 ];then
            # "The channel shortcut URL is invalid"
            errorMessage="${RED}Error❌:请先在蒲公英控制台上添加渠道 ${buildChannelShortcut} ，使得地址 https://www.xcxwo.com/$buildChannelShortcut 可以正常访问。${NC}"
        elif [ "$responseResultCode" = 1002 ];then
            # "_api_key not found"
            errorMessage="${RED}Error❌:${responseErrorMessage},请检查${xcxwo_api_key_VALUE}是否有效,蒲公英_api_key的值，请进入https://www.xcxwo.com/doc/view/api#uploadApp中的接口查看。${NC}"
        else
            errorMessage="${RED}Error❌:responseResultCode=${responseResultCode} ${NC}.${NC}"
        fi
        processLog+="-------- Failure: upload ipa 上传失败，不继续操作 --------"
        exit_script_with_response_error_message "${errorMessage}"
    fi

else
    processLog+="-------- Failure: upload ipa 上传失败，不继续操作 --------"
    errorMessage="responseResult=$responseResult"
    exit_script_with_response_error_message "${errorMessage}"
fi
processLog+="\n"
processLog+="\n${PURPLE}<<<<<<<<<<<<<<<< step7：end upload app to 蒲公英 <<<<<<<<<<<<<<<<<<<<<<<<<<<<${NC}"

responseResult='{
    "code": 1, 
    "message": "上传成功"
}'
# 使用 jq 添加键值对
responseResult='{
    "message": "上传成功"
}'
# processLog="\这是要转义\n\哈哈"
# 对 processLogValue 进行斜杠转义
# processLog=$(echo "$processLog" | sed 's/\\/\\\\/g')

# 使用 jq 添加键值对，并将变量 processLogValue 的值作为参数传递
# 必须使用 printf "%s" "$responseResult" ，否则当 responseResult 中某个key 的值有斜杠时候会出现错误
# responseResult=$(printf "%s" "$responseResult" | jq --arg processLog "$processLog" '. + { "processLog": $processLog }')
responseResult=$(printf "%s" "$responseResult" | jq --arg code "$responseResultCode" '. + { "code": $code }')
responseResult=$(printf "%s" "$responseResult" | jq --arg qrCode "$qrCodeUrl" '. + { "qrCodeUrl": $qrCode }')
printf "%s" "${responseResult}"

# 结果：

