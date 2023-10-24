#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-10-24 21:34:47
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-10-24 23:37:56
 # @FilePath: /script-qbase/get_file_text/example/example_get_file_some_text.sh
 # @Description: 获取文本中的某些文本(eg:toast文本等)
### 

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)" # 当前脚本所在目录
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
test_script_path="${CommonFun_HomeDir_Absolute}/get_file_some_text.py"


codeProjectAbsPath="$CurrentDIR_Script_Absolute"
projectAbsRootPath="$CurrentDIR_Script_Absolute"
# codeProjectAbsPath="/Users/qian/Project/XXX/mobile_flutter_wish/wish"
# projectAbsRootPath=$(dirname "$codeProjectAbsPath")

codeDir="$codeProjectAbsPath/lib"

codeSuffixs=("dart" "java" "cpp")
# codeSuffixsString=$(printf "%s," "${codeSuffixs[@]}")
# codeSuffixsString=${codeSuffixsString%,}  # 去除最后一个逗号
codeSuffixsString=$(IFS=','; echo "${codeSuffixs[*]}") # 将 codeSuffixs 转换为以逗号分隔的字符串

toastCodePrefixSuffixs=("ToastUtil.showMessage(\"---dvlp---\");" "ToastUtil.showMessage('---dvlp---');")
toastCodePrefixSuffixsString=$(printf "%s###dvlp###" "${toastCodePrefixSuffixs[@]}")
toastCodePrefixSuffixsString=${toastCodePrefixSuffixsString%###dvlp###}  # 去除最后一个逗号

resultSaveToSheetFilePath="$projectAbsRootPath/APP提示语清单表.xlsx"

# 注意这里要使用 python3.9 (请确保已经安装了 Python 3.9)
python3.9 "$test_script_path" -codeDir "$codeDir" -codeSuffixsString "$codeSuffixsString" -toastCodePrefixSuffixsString "$toastCodePrefixSuffixsString" -resultSaveToSheetFilePath "$resultSaveToSheetFilePath"