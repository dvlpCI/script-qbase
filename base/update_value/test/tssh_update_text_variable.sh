#!/bin/bash
:<<!
测试对字符串变量按指定要求转义 转义换行符/换行符
sh ./tssh_update_text_variable.sh
!


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute}/..
CommonFun_HomeDir_Absolute3=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
CommonFun_HomeDir_Absolute2=${CommonFun_HomeDir_Absolute3%/*}
CommonFun_HomeDir_Absolute=${CommonFun_HomeDir_Absolute2%/*}


# echo "---------------------------------------------3对json文件添加新【常量值含换行符】"
# ADD_WRAP_UPDATE_VALUE_1='{"data2": "第1行\n第2行"}'         #无变量，外层可以直接用单引号

# echo "-----------------------3.1对从未存在换行符的json文件添加新值含换行符"
# # 本来已经存在换行符的json文件
# echo "--------3.1.①从未存在换行符的json文件 的原始值"
# Old_NOExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_no_exsit_old.json"
# cat ${Old_NOExistWrap_FILE_PATH}
# # 对【本来已经存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容
# echo "--------3.1.②对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的原始值"
# New_AddFrom_NOExistWrap_FILE_PATH="${CurrentDIR_Script_Absolute}/data_wrap_no_exsit_new.json"
# cat ${New_AddFrom_NOExistWrap_FILE_PATH}


# echo "--------3.1.③对【从未存在换行符的json文件】添加【新的含换行符json值】后，新文件的内容 的新值"
# echo > ${New_AddFrom_NOExistWrap_FILE_PATH} #清空文件内容
# cat ${Old_NOExistWrap_FILE_PATH} | jq --argjson jsonString "${ADD_WRAP_UPDATE_VALUE_1}" \
#     '.wrap2 = $jsonString' > ${New_AddFrom_NOExistWrap_FILE_PATH}
# cat ${New_AddFrom_NOExistWrap_FILE_PATH}


#sed -i '' "s#${ReplaceText}#${ToText//n//n}#g" "../bulidScript/app_info.json"
#sed -i '' "s#${ReplaceText}#${ToText/n/\n}#g" "../bulidScript/app_info.json"
#
#FILE_PATH="../bulidScript/app_info.json"
#ReplaceText="package cos url"
#
#ToText="User1okUser2okUser3"
#测试替换ok

#ToText="/Users/qian/Project\n测试第一个换行符后的内容有没正确替换"                                 # 测试\n是否替换成功(本字符串只能测试第一个\n)
#
#ToText="/Users/qian/Project\n测试第一个换行符后的内容有没正确替换\n测试第二个换行符后的内容有没正确替换"  # 测试\n是否替换成功(本字符串用于测试多个换行符\n，而不是只有第一个才生效)

#ToText='关/注'
#ToText="/Users/qian/Project/CQCI/AutoPackage-CommitInfo/bulidScript/app_branch_info.json"

shouldTest_base="true"
if [ "${shouldTest_base}" == "true" ]; then
    echo "--------------------------------------------------1换行符本地变量"
    WillUpdateText="第1.1行n第1.1行\n第1.2行n第1.2行\n\n第2.1行n第2.1行\n第2.2行n第2.2行"
    echo "--------------------------1.1直接使用原始命令，替换所有"
    echo "-------------1.1.①直接使用原始命令，直接输出(替换所有)"
    echo ${WillUpdateText//\\n/\\\\n}
    echo "-------------1.1.②直接使用原始命令，赋值变量后输出(替换所有)"
    result112=${WillUpdateText//\\n/\\\\n}
    echo "${result112}"

    echo "-------------1.1.③使用封装的方法，赋值变量后输出(替换所有)"
    source ${CurrentDIR_Script_Absolute%/*}/function_update_text_variable.sh
    SpecialCharacterType="NewlineCharacter" # NewlineCharacter / EscapeCharacter
    OnlyEscapeFirst="false"
    escapeNewlineCharacter "${WillUpdateText}" "${OnlyEscapeFirst}"
    result113=${escapeNewlineCharacterResult}
    echo "${result113}"

    echo "\n\n"
fi





shouldTest_jsonFile="true"
if [ "${shouldTest_jsonFile}" == "true" ]; then
    echo "--------------------------------------------------2换行符JSON文件"
    TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/tsdata_update_text_variable.json
    
    echo "--------------------------2.1直接使用原始命令，替换所有"
    # 注意📢1：使用jquery取值的时候，不要使用 jq -r 属性，否则会导致以下问题：
    # 导致的问题①：取出来的数值换行符\n会直接换行，导致要echo输出的时候，无法转义成功
    fileValueWithoutEscape=$(cat ${TEST_JSON_FILE_PATH} | jq ".data2")
    echo "-------------2.1.①直接使用原始命令，直接输出(替换所有)"
    echo ${fileValueWithoutEscape//\\n/\\\\n}
    echo "-------------2.1.②直接使用原始命令，赋值变量后输出(替换所有)"
    result212=${fileValueWithoutEscape//\\n/\\\\n}
    echo "${result212}"

    echo "-------------2.1.③使用封装的方法，赋值变量后输出(替换所有)"
    source ${CurrentDIR_Script_Absolute%/*}/function_update_text_variable.sh
    getValueFromFile_escapeAllNewlineCharacter "${TEST_JSON_FILE_PATH}" "data2"
    result213=${fileValueWithEscapeNewlineCharacterResult}
    echo "${result213}"


    echo "--------------------------2.2取出的值，未修改，直接设置回去"
    # 注意📢2：因为上面使用jquery取值的时候没使用 jq -r 属性，所以 fileValueWithoutEscape 会保留前后的双引号。
    # 所以①：设置 json 的时候，不要再重复添加前后的双引号了。
    # 所以②：更新 json 值到文件 file 的时候，直接使用【没使用 jq -r 属性取出来的值】，不要去转义后，再添加。
    BRANCH_OUTLINES_LOG_JSON="{\"data2\": ${fileValueWithoutEscape}}"
    sh "${CommonFun_HomeDir_Absolute}/update_json_file.sh" -f "${TEST_JSON_FILE_PATH}" -k "test_result" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
    # 注意📢3：使用jquery取值的时候，不要使用 jq -r 属性
    cat ${TEST_JSON_FILE_PATH} | jq '.test_result' | jq '.data2'


    echo "--------------------------2.3取出的值，修改后，设置回去"
    fileValue_withEscape=$(cat ${TEST_JSON_FILE_PATH} | jq ".data2")

    fileValue_origin_withDoubleQuote=$(cat ${TEST_JSON_FILE_PATH} | jq ".data2")
    #echo "======fileValue_origin_withDoubleQuote=${fileValue_origin_withDoubleQuote}"
    echo "======fileValue_origin_withDoubleQuote_echo=${fileValue_origin_withDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
    
    # 注意3：修改不能使用 jq -r 获取json文件的值，所以修改该值的时候，需要先去除前后的引号
    fileValue_origin_noDoubleQuote=${fileValue_origin_withDoubleQuote: 1:${#fileValue_origin_withDoubleQuote}-2}
    #echo "======fileValue_origin_noDoubleQuote=${fileValue_origin_noDoubleQuote}"
    echo "======fileValue_origin_noDoubleQuote_echo   =${fileValue_origin_noDoubleQuote//\\n/\\\\n}" # 这里转义换行符只是为了 echo 显示而已，没其他用处
    
    fileValue_origin_noDoubleQuote+="\n结束"
    BRANCH_OUTLINES_LOG_JSON="{\"data3\": \"${fileValue_origin_noDoubleQuote}\"}"
    sh "${CommonFun_HomeDir_Absolute}/update_json_file.sh" -f "${TEST_JSON_FILE_PATH}" -k "test_result" -v "${BRANCH_OUTLINES_LOG_JSON}" --skip-value-check "true"
    # 注意📢4：使用jquery取值的时候，不要使用 jq -r 属性
    cat ${TEST_JSON_FILE_PATH} | jq '.test_result' | jq '.data3'


    
    echo "：：：：：：结论(非常重要)：：：：：：使用jquery取值的不要使用 jq -r 属性，且需要先去除前后的双引号再去操作字符串。这样的好处有：\
    好处①：设置 json 的时候，仍然保留原本的在前后都要加双引号的操作。\
    好处②：当要对所取到的值修改后再更新回json文件时候，可以成功"
    echo "\n\n"
fi

TEST_JSON_FILE_PATH=${CurrentDIR_Script_Absolute}/tsdata_update_text_variable.json
function updateText3() {
    missingDeclareBranchNameArray=("develop" "master" "dev_all")
    BRANCH_DETAIL_INFO_FILE_PATH="~/.jenkins/workspace/wish_android_测试/bulidScript/app_branch_info.json"
    PackageErrorMessage="您所开发的有${#missingDeclareBranchNameArray[@]}个分支(详见文尾附2)，未在${BRANCH_DETAIL_INFO_FILE_PATH}文件中标明功能(标明方法见文尾,👉🏻提示:如有添加请检查是不是name写错了)。从而会导致自动化打包时候无法获取，从而提供所打包的所含功能说明。故请前往补充后再执行打包。\n附1：标明方法①(推荐)前往项目的 featureBrances ，在该目录下添加一个描述该分支的json文件信息；标明方法②(不推荐)直接在${BRANCH_DETAIL_INFO_FILE_PATH}文件中的 featureBrances 属性里添加。\n附2：缺少标注功能的分支分别为${missingDeclareBranchNameArray[*]}分支。"
    
    sh ${CommonFun_HomeDir_Absolute}/sed_text.sh -appInfoF ${TEST_JSON_FILE_PATH} -r "unknow data3" -t "${PackageErrorMessage}"
}

updateText3