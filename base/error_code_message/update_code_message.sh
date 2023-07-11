#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-25 02:04:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-02-26 01:35:46
 # @FilePath: /AutoPackage-CommitInfo/bulidScriptCommon/base/error_code_message/update_code_message.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 
# sh ./update_code_message.sh
:<<!
更新code和message到指定文件
!

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute2=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}


# shell 参数具名化
show_usage="args: [-codeMessageJsonF, -code, -message]\
                                  [--code-message-json-file=, --result-code=, --result-message]"

while [ -n "$1" ]
do
    case "$1" in
        -codeMessageJsonF|--code-message-json-file) CodeAndMessageResult_JSON_FILE_PATH=$2; shift 2;;
        -code|--result-code) RESULT_CODE=$2; shift 2;;
        -message|--result-message) RESULT_MESSAGE=$2; shift 2;;
        --) break ;;
        *) echo $1,$2,$show_usage; break ;;
    esac
done


sh "${CommonFun_HomeDir_Absolute}/update_json_file_singleString.sh" -jsonF ${CodeAndMessageResult_JSON_FILE_PATH} -k 'package_code' -v "${RESULT_CODE}"
if [ $? != 0 ]; then
    echo "❌Error:更新 package_code 失败"
    exit 1
fi
    
sh "${CommonFun_HomeDir_Absolute}/update_json_file_singleString.sh" -jsonF ${CodeAndMessageResult_JSON_FILE_PATH} -k 'package_message' -v "${RESULT_MESSAGE}"
if [ $? != 0 ]; then
    echo "❌Error:更新 package_message 失败"
    exit 1
fi

# if [ "${RESULT_CODE}" != "package_code_0" ]; then
#     echo "$0 文件为你输出错误结果 ${RESULT_CODE}:${RESULT_MESSAGE}"
# fi