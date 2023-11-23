#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-23 00:54:34
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-23 14:27:55
 # @FilePath: get_filePath_mapping_branchName_from_dir.sh
 # @Description: 在指定目录下获取符合分支名指向的文件及其json内容，未找到返回错误信息
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

qbase_get_all_json_file_content_inDir_scriptPath=${qbase_homedir_abspath}/git_content/get_all_json_file_content_inDir.sh

