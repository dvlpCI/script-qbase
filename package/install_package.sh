#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 01:35:46
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


# Checks if the specified command is available
# If the command is not available, it will be installed
cmd=$1
if ! command -v $cmd &> /dev/null; then
    echo "$cmd command not found, installing..."
    install_package_distinguish_all $cmd
fi