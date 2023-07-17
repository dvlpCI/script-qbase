#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-27 22:37:52
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-07-15 21:03:40
 # @FilePath: example/value_get_and_update/ts_value_update_in_file_whereText.sh
 # @Description: 测试文本更改
### 


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
Base_HomeDir_Absolute=${Example_HomeDir_Absolute%/*}

script_file_path=${Base_HomeDir_Absolute}/value_update_in_file/sed_text.sh
TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/data/tsdata_update_text_variable.json



# sed -i '' "s#${ReplaceText}#${ToText//n//n}#g" "${TEST_JSON_FILE_PATH}"
# sed -i '' "s#${ReplaceText}#${ToText/n/\n}#g" "${TEST_JSON_FILE_PATH}"

# ReplaceText="package cos url"
# ToText="User1okUser2okUser3"
# # 测试替换ok
# sed -i '' "s#${ReplaceText}#${ToText/ok/换行符}#g" "${TEST_JSON_FILE_PATH}"   #只替换第一个ok,而不是所有的ok
# sed -i '' "s#${ReplaceText}#${ToText//ok/换行符}#g" "${TEST_JSON_FILE_PATH}"  #替换所有的ok,而不只是第一个ok
# # 测试连接符ok
# sed -i '' "s#${ReplaceText}#${ToText//ok/换行符\\\\\n}#g" "${TEST_JSON_FILE_PATH}"  #测试换行符后，能换行显示并用换行连接符\链接
# sed -i '' "s#${ReplaceText}#${ToText//ok/\\\n\\\\\n}#g" "${TEST_JSON_FILE_PATH}"

# # 测试替换\n
# ReplaceText="package cos url"
# ToText="/Users/qian/Project\n测试第一个换行符后的内容有没正确替换"                                 # 测试\n是否替换成功(本字符串只能测试第一个\n)
# sed -i '' "s#${ReplaceText}#${ToText/\\n/abc}#g" "${TEST_JSON_FILE_PATH}"             # \n替换成abc，而n不能替换
# sed -i '' "s#${ReplaceText}#${ToText/\\n/\\\n}#g" "${TEST_JSON_FILE_PATH}"            # \n替换成真正的\n，而n不能替换

# ReplaceText="package cos url"
# ToText="/Users/qian/Project\n测试第一个换行符后的内容有没正确替换\n测试第二个换行符后的内容有没正确替换"  # 测试\n是否替换成功(本字符串用于测试多个换行符\n，而不是只有第一个才生效)
# sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n}#g"" ${TEST_JSON_FILE_PATH}"    #[shell(bash)替换字符串大全](https://blog.csdn.net/coraline1991/article/details/120235471)
# sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g"" ${TEST_JSON_FILE_PATH}"

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function logTitle() {
    printf "${PURPLE}------- $1 -------${NC}\n"
}

logTitle "1"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串1" -t "关/注"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_1'

logTitle "3"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串3" -t "要点1n\nn要点2:关/注"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_3'

logTitle "4"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串4" -t "failure:编译打包失败，未生成release/wish.apk"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_4'

logTitle "5"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串5" -t "您当前打包的需求较上次有所缺失，请先补全，再打包，至少缺失旧包dev_fix。\n可能原因如下:dev_fix未合并进来，或者是有新的提交也会造成这个问题。"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_5'

logTitle "6"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串6" -t "更新说明略\n分支信息:\ndev_fix:功能修复"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_6'

logTitle "file_path"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "~/Project/a.txt" -t "/Users/qian/Project/CQCI/AutoPackage-CommitInfo/bulidScript/app_branch_info.json"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_file_path'
