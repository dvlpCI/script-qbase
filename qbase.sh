#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-11 16:37:58
 # @Description: 
### 

# 本地测试
function local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qbaseScriptDir_Absolute=${CurrentDIR_Script_Absolute}
    echo "$qbaseScriptDir_Absolute"
}

function getCurretnVersionDirPath() {
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

  # 输出最新版本的路径
  build_tools_home_dir="$dir_path/$latest_version"
  echo "$build_tools_home_dir"

  if [ ! -d "${build_tools_home_dir}" ]; then
    return 1
  fi
}

# 粗略计算，容易出现arm64芯片上的路径不对等问题
# qbaseScriptDir_Absolute="/usr/local/Cellar/qtool/${bjfVersion}/lib"

# 精确计算
# which_qbase_bin_dir_path=$(which qtool)
# which_qbase_source_dir_path="$(echo "$which_qbase_bin_dir_path" | sed 's/bin/Cellar/')"
# echo "which_qbase_bin_dir_path: $which_qbase_bin_dir_path"
# echo "which_qbase_source_dir_path: $which_qbase_source_dir_path"

function getqscriptCurrentVersionHomeDir_abspath() {
    requstQScript=$1
    homebrew_Cellar_dir="$(echo $(which $requstQScript) | sed 's/\/bin\/.*//')"
    if [ -z "${homebrew_Cellar_dir}" ]; then
        return 1
    fi
    
    if [[ "${homebrew_Cellar_dir}" == */ ]]; then
        homebrew_Cellar_dir="${homebrew_Cellar_dir::-1}"
    fi
    homebrew_Cellar_dir=${homebrew_Cellar_dir}/Cellar

    qtoolCurrentVersionHomeDir_relpath=$(getCurretnVersionDirPath "${homebrew_Cellar_dir}/qtool")
    if [[ "${qtoolCurrentVersionHomeDir_relpath}" == /?* ]]; then
        qtoolCurrentVersionHomeDir_relpath="${qtoolCurrentVersionHomeDir_relpath:1}"
    fi
    qbaseScriptDir_Absolute="${homebrew_Cellar_dir}/${qtoolCurrentVersionHomeDir_relpath}"
    echo "$qbaseScriptDir_Absolute"
}



if [ -n "$1" ] && [ "$1" == "test" ] ; then
    qtool_version_homedir_relpath=$(local_test) # 本地测试
else
    qtool_version_homedir_relpath=$(getqscriptCurrentVersionHomeDir_abspath "qbase")
    if [ $? != 0 ]; then
        exit 1
    fi
fi
echo "${qtool_version_homedir_relpath}"