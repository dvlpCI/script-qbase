#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-11 22:20:43
# @Description:
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

# 计算倒数第一个参数的位置
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
    if [ $argCount -ge 2 ]; then
        second_last_index=$((argCount - 1))
        second_last_arg=${!second_last_index} # 获取倒数第二个参数
    fi
fi
# echo "========second_last_arg=${second_last_arg}"
# echo "========       last_arg=${last_arg}"

verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
    verbose=true
    if [ "$second_last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
else # 最后一个元素不是 verbose
    verbose=false
    if [ "$last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
fi

args=()
if [ "${verbose}" == true ]; then
    args+=("-verbose")
fi
if [ "${isTestingScript}" == true ]; then
    args+=("test")
fi

function _verbose_log() {
    if [ "$verbose" == true ]; then
        echo "$1"
    fi
}

# 特别注意：这是qbase。所以无法(强烈不建议)使用 get_package_info.sh 文件，因为qbase.sh处理成qbase二进制文件后，其会被存放到任意路径。就不是相对qbase.sh的路径了。
# 特别注意：这是qbase。所以无法(强烈不建议)使用 get_package_info.sh 文件，因为qbase.sh处理成qbase二进制文件后，其会被存放到任意路径。就不是相对qbase.sh的路径了。
# 特别注意：这是qbase。所以无法(强烈不建议)使用 get_package_info.sh 文件，因为qbase.sh处理成qbase二进制文件后，其会被存放到任意路径。就不是相对qbase.sh的路径了。
# qbaseScriptDir_Absolute="$(cd "$(dirname "$0")" && pwd)"
# get_package_info_script_path=${qbaseScriptDir_Absolute}/package/get_package_info.sh
# echo "正在执行命令(获取脚本包的版本号):《 sh ${get_package_info_script_path} -package \"qbase\" -param \"version\" \"${args[@]}\" 》"
# qbase_latest_version=$(sh ${get_package_info_script_path} -package "qbase" -param "version" "${args[@]}")
# # echo "✅✅✅✅ qbase_latest_version=${qbase_latest_version}"

# # echo "正在执行命令(获取脚本包的根路径):《 sh ${get_package_info_script_path} -package \"qbase\" -param \"homedir_abspath\" \"${args[@]}\" 》"
# qbase_homedir_abspath=$(sh ${get_package_info_script_path} -package "qbase" -param "homedir_abspath" "${args[@]}")
# # echo "✅✅✅✅ qbase_homedir_abspath=${qbase_homedir_abspath}"

function getMaxVersionNumber_byDir() {
    # 指定目录
    dir_path="$1"

    # 获取目录下所有文件的列表
    files=("$dir_path"/*)

    # 从文件列表中筛选出版本号
    versions=()
    for file in "${files[@]}"; do
        version=$(basename "$file" | cut -d "-" -f 2)
        versions+=("$version")
    done

    # 选择最新的版本号
    latest_version=$(echo "${versions[@]}" | tr ' ' '\n' | sort -r | head -n 1)
    echo "${latest_version}"
}

function getHomeDir_abspath_byVersion() {
    # 指定目录
    dir_path="$1"
    latest_version="$2"

    # 输出最新版本的路径
    curretnVersionDir_abspath="$dir_path/$latest_version/bin" # 放在bin目录下
    if [[ $curretnVersionDir_abspath =~ ^~.* ]]; then
        # 如果 $curretnVersionDir_abspath 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        curretnVersionDir_abspath="${HOME}${curretnVersionDir_abspath:1}"
    fi
    echo "$curretnVersionDir_abspath"

    if [ ! -d "${curretnVersionDir_abspath}" ]; then
        return 1
    fi
}
function getqscript_allVersionHomeDir_abspath() {
    requstQScript=$1
    homebrew_Cellar_dir="$(echo $(which $requstQScript) | sed 's/\/bin\/.*//')"
    if [ -z "${homebrew_Cellar_dir}" ]; then
        return 1
    fi

    if [[ "${homebrew_Cellar_dir}" == */ ]]; then
        homebrew_Cellar_dir="${homebrew_Cellar_dir::-1}"
    fi
    homebrew_Cellar_dir=${homebrew_Cellar_dir}/Cellar

    qscript_allVersion_homedir="${homebrew_Cellar_dir}/$requstQScript"
    echo "${qscript_allVersion_homedir}"
}


if [ "${isTestingScript}" == true ]; then   # 如果是测试脚本中
    qbase_latest_version="local_qbase"
    qbase_homedir_abspath="$(cd "$(dirname "$0")" && pwd)" # 本地测试
else
    qtargetScript_allVersion_homedir=$(getqscript_allVersionHomeDir_abspath "qbase")
    qbase_latest_version=$(getMaxVersionNumber_byDir "${qtargetScript_allVersion_homedir}")
    qbase_homedir_abspath=$(getHomeDir_abspath_byVersion "${qtargetScript_allVersion_homedir}" "${qbase_latest_version}")
    if [ $? != 0 ]; then
        exit 1
    fi
fi

function get_path_json() {
    target_category_file_abspath=$1
    showType=$2
    saveModuleOptionKeysToFile=$3 # 保存内容到哪个文件，可为空
    if [ -z "${target_category_file_abspath}" ]; then
        echo "参数不能为空"
        exit 1
    fi
    
    # 读取文件内容
    content=$(cat "${target_category_file_abspath}")

    requestCategoryKey="support_script_path"
    categoryMaps=$(echo "$content" | jq -r ".${requestCategoryKey}")
    if [ -z "${categoryMaps}" ] || [ "${categoryMaps}" == "null" ]; then
        printf "${RED}请先在 ${target_category_file_abspath} 文件中设置 .${requestCategoryKey} ${NC}\n"
        exit 1
    fi

    # branchBelongMapCount2=$(echo "$content" | jq ".${requestCategoryKey}" | jq ".|length")
    # # echo "=============branchBelongMapCount2=${branchBelongMapCount2}"
    # if [ ${branchBelongMapCount2} -eq 0 ]; then
    #     echo "友情提醒💡💡💡：没有找到可选的分支模块类型"
    #     return 1
    # fi
    if [ "${showType}" == "forUseChoose" ]; then
        echo "已知模块选项、已知基础选项："
    fi

    # 使用jq命令解析json数据
    categoryCount=$(echo "$content" | jq -r ".${requestCategoryKey}|length")
    # echo "===================${categoryCount}"
    if [ "${showType}" == "onlyMdFile" ]; then
        markdownString=""
        markdownString+="# 模块区分与负责人\n \n"
        markdownString+="## 一、模块区分与负责人\n"
        markdownString+="| $(printf '%-4s' "序号") | $(printf '%-8s' "标记") | $(printf '%-17s' "模块") | $(printf '%-4s' "功能") | $(printf '%-10s' "初始者") | $(printf '%-10s' "主开发") | $(printf '%-10s' "二开发") |\n"
        markdownString+="| ---- | -------- | ----------------- | ---- | ---------- | ---------- | ---------- |\n"

        printf "${NC}正在计算md内容，请耐心等待(预计需要5s)....${NC}\n"
    fi

    # 创建一个空数组
    itemKeys=()
    for ((categoryIndex = 0; categoryIndex < categoryCount; categoryIndex++)); do
        categoryMap_String=$(echo "$content" | jq -r ".${requestCategoryKey}[$categoryIndex]")
        # echo "$((categoryIndex+1)) categoryMap_String=${categoryMap_String}"

        categoryDes=$(echo "$categoryMap_String" | jq -r '.des')
        categoryValuesCount=$(echo "$categoryMap_String" | jq -r ".values|length")
        if [ "${showType}" == "forUseChoose" ]; then
            printf "===================${categoryDes}(共${categoryValuesCount}个)===================\n"
        fi

        for ((categoryValueIndex = 0; categoryValueIndex < categoryValuesCount; categoryValueIndex++)); do

            categoryValueMap_String=$(echo "$categoryMap_String" | jq -r ".values[$categoryValueIndex]")
            # echo "$((categoryValueIndex+1)) categoryValueMap_String=${categoryValueMap_String}"

            itemDes=$(echo "$categoryValueMap_String" | jq -r '.des')
            itemKey=$(echo "$categoryValueMap_String" | jq -r '.key')
            itemValue=$(echo "$categoryValueMap_String" | jq -r '.value')

            itemKeys+=("${itemKey}")

            if [ "${showType}" == "forUseChoose" ]; then
                # printf "%10s: %-20s [%s %s %s] %s\n" "$option" "$short_des" "${createrName}" "${mainerName}" "${backuperName}" "${detail_des}"
                # 格式化字符串
                format_str="%10s: %-20s %s\n"
                consoleString=$(printf "$format_str" "$itemKey" "$itemDes" "${itemValue}")
                printf "${consoleString}\n"
            fi

            if [ "${showType}" == "onlyMdFile" ]; then
                # 构建Markdown表格
                # markdownString+="| %-8s    | %-8s | %-17s | %-4s | %-10s | %-10s |\n" "$categoryIndex.$categoryValueIndex" "$option" "$short_des" "$option" "$createrName" "$mainerName"
                multiline_detail_des=$(echo "$itemValue" | sed 's/;/<br>/g')
                markdownString+="| $(printf '%-4s' "$((categoryIndex+1)).$((categoryValueIndex+1))") | $(printf '%-8s' "$itemKey") | $(printf '%-17s' "$itemDes") | $(printf '%-4s' "$itemValue") |\n"
            fi
        done
    done

    if [ "${saveModuleOptionKeysToFile}" != null ]; then
        echo "${itemKeys[@]}" > ${saveModuleOptionKeysToFile} # 创建文件，并写入内容到该文件。如果该文件已经存在，则会覆盖原有内容。
    fi
}


function get_merger_recods_after_rebaseBranch() {    
    rebaseFromBranch=$1

    _verbose_log "${YELLOW}正在执行命令(获取分支最后一次提交commit的时间)：《 sh ${qbase_homedir_abspath}/branch/rebasebranch_last_commit_date.sh -rebaseBranch \"${rebaseFromBranch}\" ${YELLOW}》${NC}"
    lastCommitDate=$(sh ${qbase_homedir_abspath}/branch/rebasebranch_last_commit_date.sh -rebaseBranch "${rebaseFromBranch}")
    if [ $? != 0 ]; then
        echo "${lastCommitDate}" # 此时值为错误信息
        return 1
    fi
    _verbose_log "${GREEN}恭喜获得:${BLUE}main${GREEN} 分支最后一次提交commit的时间: ${BLUE}${lastCommitDate} ${GREEN}。${NC}"


    _verbose_log "${YELLOW}正在执行命令(获取指定日期之后的所有合入记录(已去除 HEAD -> 等)):《 ${BLUE} sh ${qbase_homedir_abspath}/branch/get_merger_recods_after_date.sh --searchFromDateString \"${lastCommitDate}\" ${YELLOW}》${NC}"
    mergerRecordResult=$(sh ${qbase_homedir_abspath}/branch/get_merger_recods_after_date.sh --searchFromDateString "${lastCommitDate}")
    _verbose_log "${GREEN}恭喜获得:指定日期之后的所有合入记录: ${BLUE}${mergerRecordResult} ${GREEN}。${NC}"

    echo "${mergerRecordResult}"

}

function quickCmdExec() {
    # echo "✅快捷命令及其参数分别为 ${BLUE}$1${BLUE} : ${CYAN}$2${CYAN}${NC}"
    if [ "$1" == "get_merger_recods_after_rebaseBranch" ]; then
        get_merger_recods_after_rebaseBranch "$2"
        
    else 
        echo "${RED}抱歉：暂不支持 ${BLUE}$2 ${RED} 快捷命令，请检查${NC}"
        cat "$qbase_homedir_abspath/qbase.json" | jq '.quickCmd'
    fi
}


function get_path() {
    if [ "$1" == "home" ]; then
        echo "$qbase_homedir_abspath"
    else
        specified_value=$1
        map=$(cat "$qbase_homedir_abspath/qbase.json" | jq --arg value "$specified_value" '.support_script_path[].values[] | select(.key == $value)')
        if [ -z "${map}" ]; then
            echo "${RED}error: not found specified_value: ${BLUE}$specified_value ${NC}"
            cat "$qbase_homedir_abspath/qbase.json" | jq '.support_script_path'
            exit 1
        fi
        relpath=$(echo "${map}" | jq -r '.value')
        relpath="${relpath//.\//}"  # 去掉开头的 "./"
        echo "$qbase_homedir_abspath/$relpath"

    fi
}

# 输出sh的所有参数
# echo "传递给脚本的参数列表："
# echo "$@"

# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
helpCmdStrings=("-help" "help")
if echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${qbase_latest_version}"
elif [ "$1" == "-path" ]; then
    get_path "$2"
elif [ "$1" == "-quick" ]; then
    if [ -z "$2" ]; then
        echo "❌Error：要执行的快捷命令不能为空"
        exit 1
    fi
    quickCmdExec "$2" "$3"
# elif echo "${helpCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
elif [ "$1" == "-help" ]; then
    echo '{"-quickCmd":"'"快捷命令"'","-support_script_path":"'"支持的脚本"'"}'
else
    echo "${qbase_latest_version}"
fi



