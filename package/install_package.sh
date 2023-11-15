#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 01:55:55
# @FilePath: package/install_package.sh
# @Description: 检查安装环境，且未安装时候需要进行安装
###

# 定义安装软件包的函数
function _install_package_in_darwin() {
    local cmd=$1
    # 判断 CPU 架构
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "正在执行安装命令：《 arch -arm64 brew install $cmd 》"
        arch -arm64 brew install $cmd
    else
        # arch -x86_64 brew install $cmd
        echo "正在执行安装命令：《 brew install $cmd 》"
        brew install $cmd
    fi
}

function _install_package_in_linux() {
    local cmd=$1
    if [[ -n $(command -v apt-get) ]]; then
        sudo apt-get update
        sudo apt-get install -y $cmd
    elif [[ -n $(command -v yum) ]]; then
        sudo yum install -y $cmd
    elif [[ -n $(command -v dnf) ]]; then
        sudo dnf install -y $cmd
    else
        echo "Unable to install $cmd, please install it manually."
        exit 1
    fi
}


function install_package_distinguish_all() {
    local cmd=$1
    if [ "$cmd" == "realpath" ]; then
        cmd=coreutiles
    fi

    # 判断系统类型
    if [[ "$(uname -s)" == "Darwin" ]]; then
        _install_package_in_darwin $cmd
    else
        # 输出错误信息
        echo "Unsupported platform: $(uname -s)"
        exit 1
    fi


    # if [[ "$OSTYPE" == "darwin"* ]]; then
    #     _install_package_in_darwin $cmd
    # elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    #     _install_package_in_linux $cmd
    # else
    #     echo "Unsupported operating system, please install $cmd manually."
    #     exit 1
    # fi
}


function log_msg() {
    if [ "${verbose}" == true ]; then
        echo "$1"
    fi
}

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

verboseStrings=("verbose" "-verbose" "--verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if [[ " ${verboseStrings[*]} " == *" $last_arg "* ]]; then
    verbose=true
else # 最后一个元素不是 verbose
    verbose=false
fi

# Checks if the specified command is available
# If the command is not available, it will be installed
cmd=$1
if ! command -v $cmd &> /dev/null; then
    log_msg "$cmd 工具未安装，正在安装..."
    install_package_distinguish_all $cmd
else
    log_msg "$cmd 工具已安装"
fi