#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-27 22:37:52
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 00:51:01
 # @FilePath: example/value_get_and_update/ts_value_update_in_file_whereText.sh
 # @Description: 测试文本更改
### 


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*}

script_file_path=${CategoryFun_HomeDir_Absolute}/sed_text.sh
TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/data/example_value_update_in_file.json



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
    printf "${PURPLE}$1${NC}\n"
}

logTitle "-----------   一、更新字符串   -----------"
logTitle "1 单行字符串+有斜杠"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串1" -t "关/注"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_1'

logTitle "3 单行字符串+有斜杠"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串3" -t "failure:编译打包失败，未生成release/wish.apk"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_3'

logTitle "4 多行字符串(有换行符)+有斜杠"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串4" -t "要点1n\nn要点2:关/注"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_4'

logTitle "5 多行字符串(有换行符)"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串5" -t "您当前打包的需求较上次有所缺失，请先补全，再打包，至少缺失旧包dev_fix。\n可能原因如下:dev_fix未合并进来，或者是有新的提交也会造成这个问题。"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_5'

logTitle "6 多行字符串(有换行符)"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "这是未替换前的字符串6" -t "更新说明略\n分支信息:\ndev_fix:功能修复"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_6'

logTitle "update file_path"
sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "~/Project/a.txt" -t "/Users/qian/Project/CQCI/AutoPackage-CommitInfo/bulidScript/app_branch_info.json"
cat "${TEST_JSON_FILE_PATH}" | jq '.data_string_file_path'


echo "            --------           "
logTitle "-----------   二、更新数组(TODO:无效)   -----------"
logTitle "6 多行字符串(有换行符)"
# | @json表达式将该数组值转义，并输出为字符串。
# -r选项用于输出原始字符串，而不是带引号的字符串。如果不使用-r选项，则输出的字符串会带有双引号。如果你需要在Shell脚本中使用这个字符串，最好使用-r选项。
cat "${TEST_JSON_FILE_PATH}" | jq '.data_array_1_new | @json'
# oldArray=$(cat "${TEST_JSON_FILE_PATH}" | jq '.data_array_1_new')

cat "${TEST_JSON_FILE_PATH}" | jq '.data_array_1_res'
# hopeNewArray=$(cat "${TEST_JSON_FILE_PATH}" | jq '.data_array_1_res | @json')
hopeNewArray=$(jq -r '.data_array_1_res | @json' $TEST_JSON_FILE_PATH)
# hopeNewArray="[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]" # 要替换进去
if [ "${hopeNewArray}" != "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]" ]; then
    printf "${RED}❌Error:获取的值没转义不能进行替换，其值为 ${YELLOW}${hopeNewArray}${NC}\n"
else
    sh ${script_file_path} -f "${TEST_JSON_FILE_PATH}" -r "$(cat ${TEST_JSON_FILE_PATH} | jq '.data_array_1_new')" -t "${hopeNewArray}"
    if [ $? != 0 ]; then
        echo "${RED}更新脚本执行失败，将退出。请检查.${NC}"
        exit 1
    fi
    cat "${TEST_JSON_FILE_PATH}" | jq '.data_array_1_new'
    cat "${TEST_JSON_FILE_PATH}" | jq '.data_array_1_new | @json'
fi


# 已知JSON文件 TEST_JSON_FILE_PATH 的内容如下：
# {
#   "data_array_1_new": [{"dev_script_pack":"打包提示优化"},{"dev_fix":"修复"}],
#   "data_array_2_org": ["data_array_string1"]
# }
# 请在Mac上使用shell脚本实现将 TEST_JSON_FILE_PATH 中的 data_array_1_new 键所对的值修改为如下字符串
# "[{\"dev_script_pack\":\"打包提示优化\"},{\"dev_fix\":\"修复\"}]"
# 
# 定义要修改的字符串
# new_value='[{"dev_script_pack":"打包提示优化22"},{"dev_fix":"修复"}]'
# # 使用 jq 修改 JSON 文件
# # jq --argjson new_value "$new_value" '.data_array_1_new = $new_value' "$TEST_JSON_FILE_PATH" > temp.json && mv temp.json "$TEST_JSON_FILE_PATH"
# # 使用 sed 修改 JSON 文件
# sed -i '' 's/"data_array_1_new": .*/"data_array_1_new": '"$new_value"'/g' "$TEST_JSON_FILE_PATH"
# # sed -i '' 's/"data_array_1_new": \[[^]]*\]/"data_array_1_new": '"$new_value"'/g' "$TEST_JSON_FILE_PATH"
# if [ $? != 0 ]; then
#     echo "失败❌:Error"
# fi