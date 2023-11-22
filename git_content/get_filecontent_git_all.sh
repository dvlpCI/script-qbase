#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-22 23:35:57
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-23 01:30:25
 # @FilePath: get_filecontent_git_all.sh
 # @Description: 获取网络文件的内容-git
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -fileUrl|--fiel-url) FILR_URL=$2; shift 2;; # 获取分支信息的文件源，请确保该文件夹内的json文件都是合规的
        -access-token|--access-token) access_token=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [[ "${FILR_URL}" != http* ]]; then
    echo "Error❌: 您的 -fileUrl 参数的值 ${FILR_URL} 不是一个正确的网络文件url地址，请检查."
    exit 1
fi

# 没传令牌时候：如果成功即成功；如果失败，则提示可能需要传入 -access-token 令牌参数。
if [ -z "${access_token}" ]; then
    echo "${YELLOW}正在执行命令(获取网络地址对应的内容):《${BLUE} curl -s \"$FILR_URL\" ${YELLOW}》${NC}"
    FileContent=$(curl -s "$FILR_URL")
    if [ $? != 0 ]; then
        echo "Error❌: 无法获取文件列表。您可能需要添加 -access-token 身份验证令牌参数才能查看此地址内容。详细的错误信息如下:\n${FileContent}"
        exit 1
    fi
    exit 0
fi

function getFileContent_github() {
    # 有传令牌时候：如果成功即成功；如果失败，则根据错误提示，指明错误原因
    echo "${YELLOW}正在执行命令(获取网络地址对应的内容):《${BLUE} curl -s --header \"Private-Token: $access_token\" \"$FILR_URL\" ${YELLOW}》${NC}"
    FileContent=$(curl -s --header "Private-Token: $access_token" "$FILR_URL")
    if [ $? != 0 ]; then
        echo "Error❌: 无法获取文件列表。请检查您的身份验证令牌 ${access_token} 是否正确。"
        exit 1
    fi

    # 检查字符串是否包含指定字符串变量
    errorFlagString="users/sign_in"
    if [[ $FileContent == *"$errorFlagString"* ]]; then
        echo "Error❌: 获取网络地址内容失败。执行的命令为 《 curl -s --header \"Private-Token: $access_token\" \"$FILR_URL\"》。得到的值为 $FileContent"
        # echo "所获得的错误内容如下:\n${FileContent}"
        exit 1
    fi
}

function getFileContent_gitee() {
    getFileContent_github
}

function getFileContent_gitlab() {
    getFileContent_github
}

if [[ "${FILR_URL}" == *"https://github.com"* ]]; then
    getFileContent_github

elif [[ "${FILR_URL}" == *"https://gitee"* ]]; then   # https://gitee.com/profile/personal_access_tokens/
    getFileContent_gitee

elif [[ "${FILR_URL}" == *"https://gitlab"* ]]; then
    getFileContent_gitlab

else
    echo "您输入的文件源地址 ${FILR_URL} 不是 git 地址"
    exit 1
fi

printf "%s" "${FileContent}"