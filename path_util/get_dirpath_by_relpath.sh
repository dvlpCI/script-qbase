#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-05 04:28:39
# @Description: 获取相对于指定文件/目录的相对目录的绝对路径
# 使用: ./get_dirpath_by_relpath.sh --file_or_dir_path "/path/to/file_a" --rel_path "sub_dir_b"
###

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"


# 默认参数值
file_or_dir_path=""
rel_path=""

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --file_or_dir_path)
            file_or_dir_path="$2"
            shift 2
            ;;
        --rel_path)
            rel_path="$2"
            shift 2
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
        esac
    done

    # 检查必要参数是否提供
    if [ -z "$file_or_dir_path" ] || [ -z "$rel_path" ]; then
        echo "缺少必要参数！"
        exit 1
    fi
}


parse_arguments "$@" # 解析命令行参数
if [ -f "${file_or_dir_path}" ]; then
    dir_path="$(dirname $file_or_dir_path)"
else
    dir_path="${file_or_dir_path}"
fi
echo $(sh ${CurrentDIR_Script_Absolute}/join_paths.sh --path_a "${dir_path}" --path_b "${rel_path}")

