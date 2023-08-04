#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
# @LastEditors: dvlproad
# @LastEditTime: 2023-08-05 04:00:15
# @Description: 拼接字符串 ./join_paths.sh --path_a "/path/to/dir_a" --path_b "sub_dir_b" --create_ifNoExsit "true"
###

# dir_path_this=$1
# path_rel_this_dir=$2

# 默认参数值
path_a=""
path_b=""
createIfNoExsit=false

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --path_a)
            path_a="$2"
            shift 2
            ;;
        --path_b)
            path_b="$2"
            shift 2
            ;;
        --create_ifNoExsit)
            createIfNoExsit="$2"
            shift 2
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
        esac
    done

    # 检查必要参数是否提供
    if [ -z "$path_a" ] || [ -z "$path_b" ]; then
        echo "缺少必要参数！"
        exit 1
    fi
}

# 路径拼接(①支持尾部及头部斜杠的处理;②支持尾部拼接../)
join_path() {
    local path_a="$1"
    local path_b="$2"
    local absolute_path=""

    # 去除路径末尾的斜杠
    path_a="${path_a%/}"
    path_b="${path_b#/}"

    # 拼接路径
    absolute_path="${path_a}/${path_b}"
    if [[ $absolute_path =~ ^~.* ]]; then
        # 如果 $absolute_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        absolute_path="${HOME}${absolute_path:1}"
    fi

    echo "$absolute_path"
}

# 在Shell中，mkdir -p命令中的-p选项表示创建目录时，如果父目录不存在，则会自动创建父目录。这样可以确保在创建目录时，所有需要的父目录也会被创建。

# 主程序
main() {
    parse_arguments "$@" # 解析命令行参数

    local joined_path="$(join_path "$path_a" "$path_b")"
    echo $joined_path

    if [ -d "${joined_path}" ] || [ -f "${joined_path}" ]; then
        return 0
    fi

    # 文件/文件夹不存在时候，只有需要创建且创建成功的时候才返回0
    if [ "${createIfNoExsit}" == true ]; then
        mkdir "${joined_path}"
        if [ $? == 0 ]; then
            return 0
        fi
    fi

    return 1
}

a=$(main "$@")
if [ $? != 0 ]; then
    echo "❌Error: $a 文件/文件夹不存在，请检查"
    exit 1
else
    # echo "✅"
    echo "$a"
fi
