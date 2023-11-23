#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-07 16:03:56
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 17:36:54
 # @Description: 测试获取目录下的所有文件路径--git
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
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qbase_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qbase_get_all_json_file_content_inDir_scriptPath=${CategoryFun_HomeDir_Absolute}/get_all_json_file_content_inDir.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}


function testGithub {
    log_title "1.github"
    # github token 获取方式:进入 https://github.com/settings/tokens 创建（个人设置 -- 底部的Developer Settings -- 配置repo来支持repo中的数据读权限)
    access_token="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"
    DIRECTORY_URL="https://github.com/dvlpCI/script-qbase/tree/test/test1/branchMaps_10_resouce_get/example/featureBrances"
    requestBranchName="test/test1"
}

function testGitee {
    log_title "2.gitee"
    requestBranchName="dev_script_pack"
    DIRECTORY_URL="https://gitee.com/dvlpCI/AutoPackage-CommitInfo/tree/master/example_packing_info/featureBrances"
}

function testGitlab {
    log_title "3.gitlab"
    requestBranchName="chore/pack"
    access_token="glpat-xTEsz89Km9N1dessU56p"
    DIRECTORY_URL="https://gitlab.xihuanwu.com/bojuehui/mobile/mobile_flutter_wish/-/tree/master/bulidScript/featureBrances"
}

function execAndPrintfResult() {
    echo "${YELLOW}正在执行测试命令(获取git上指定目录下所有的json文件的内容):《${BLUE} sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl \"${DIRECTORY_URL}\" -access-token \"${access_token}\" -inBranchName \"${requestBranchName}\" ${YELLOW}》${NC}"
    # sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${requestBranchName}"
    # exit 1
    allFileContent_JsonStrings=$(sh $qbase_get_all_json_file_content_inDir_scriptPath -dirUrl "${DIRECTORY_URL}" -access-token "${access_token}" -inBranchName "${requestBranchName}")
    if [ $? != 0 ]; then
        echo "${RED}${allFileContent_JsonStrings}${NC}" #此时此值是错误原因
        exit 1
    fi
    allFileContent_Count=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | length')
    echo "${GREEN}恭喜:指定目录 ${DIRECTORY_URL} 下的所有json文件共有 ${allFileContent_Count} 个，它们内容组成的值如下:${NC}"
    echo "${allFileContent_JsonStrings}" | jq '.'


    # jsonStringWhereJsonMappingBranchName=$(printf "%s" "${allFileContent_JsonStrings}" | jq '. | map(select(.name == "'"${requestBranchName}"'"))')

    jsonStringWhereJsonMappingBranchName=""
    jsonStringWhereJsonMappingBranchName+="["
    for((i=0;i<$allFileContent_Count;i++));
    do
        iFileContentJsonString=$(printf "%s" "${allFileContent_JsonStrings}" | jq ".[${i}]")
        # echo "$((i+1)).${iFileContentJsonString}"
        # 判断文件是否映射到指定的分支名
        branchName=$(printf "%s" "${iFileContentJsonString}" | jq -r '.name') # 去除双引号，才不会导致等下等号判断对不上
        if [ $? != 0 ]; then
            branchFileAbsolutePathOrUrl=$(printf "%s" "${iFileContentJsonString}" | jq -r '.fileUrl')
            echo "${RED}Error❌:获取文件${BLUE} ${branchFileAbsolutePathOrUrl} ${RED}中的 ${BLUE}.name ${RED}失败，其可能不是json格式，请检查并修改或移除，以确保获取分支信息的源文件夹${BLUE} $DIRECTORY_URL ${RED}内的所有json文件都是合规的。${NC}";
            continue
        fi
        # echo "$((i+1)).${branchName}"
        # last_field="${requestBranchName##*/}" # 获取元素的最后一个字段
        if [ "$requestBranchName" != "$branchName" ]; then
            continue
        fi

        if [ "${jsonStringWhereJsonMappingBranchName}" != "[" ]; then
            jsonStringWhereJsonMappingBranchName+=", "
        fi
        jsonStringWhereJsonMappingBranchName+=${iFileContentJsonString}
    done
    jsonStringWhereJsonMappingBranchName+="]"
    # echo "jsonStringWhereJsonMappingBranchName============${jsonStringWhereJsonMappingBranchName}"


    jsonWhereJsonMappingBranchName_count=$(printf "%s" "${jsonStringWhereJsonMappingBranchName}" | jq '. | length')
    # echo "jsonWhereJsonMappingBranchName_count=${jsonWhereJsonMappingBranchName_count}"
    if [ "${jsonWhereJsonMappingBranchName_count}" == 0 ]; then
        echo "您目录 ${DIRECTORY_URL} 下的所有json文件提取成功了，但是未找到匹配 ${requestBranchName} 分支名的json文件，请检查。"
        exit 1
    else
        echo "${GREEN}恭喜:您找到匹配 ${requestBranchName} 分支名的json文件共有 ${jsonWhereJsonMappingBranchName_count} 个，它们组成的json数组如下:${NC}"
        printf "%s" "${jsonStringWhereJsonMappingBranchName}" | jq "."
    fi
}




testGithub && execAndPrintfResult
# testGitee && execAndPrintfResult
# testGitlab && execAndPrintfResult

