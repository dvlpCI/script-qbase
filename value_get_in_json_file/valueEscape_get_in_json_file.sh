#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-28 19:51:47
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-28 22:28:47
 # @Description: 从指定文件中，获取指定key的值，且该值转义所有换行符
### 


while [ -n "$1" ]
do
    case "$1" in
        -jsonF|--json-file) JSON_FILE_PATH=$2; shift 2;;
        -k|--key) VALUE_KEY=$2; shift 2;;
        --) break ;;
        *) echo $1,$2; break ;;
    esac
done


# 注意使用jquery取值的时候，不要使用 jq -r 属性，否则取出来的数值\n会直接换行，导致无法转义成功
fileValueWithoutEscape=$(cat ${JSON_FILE_PATH} | jq ".${VALUE_KEY}")
fileValueWithEscapeNewlineCharacterResult=${fileValueWithoutEscape//\\n/\\\\n}
printf "%s" "${fileValueWithEscapeNewlineCharacterResult}"



