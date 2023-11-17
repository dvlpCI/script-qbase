#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:50:27
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-16 18:52:51
 # @Description: 检查360加固的多渠道配置文件是否合规
### 
#!/bin/bash

# 接收文件路径作为参数
file_path=$1

# 检查文件是否存在
if [ ! -f "$file_path" ]; then
  echo "您要检查的360加固配置文件不存在: $file_path"
  exit 1
fi

# 逐行检查文件内容是否符合规范
while IFS= read -r line; do
  # 打印每一行的内容
  echo "行内容: $line"

  # 切割行内容为数组
  IFS=' ' read -ra elements <<< "$line"

  # 检查元素数量是否为3
  if [ "${#elements[@]}" -ne 3 ]; then
    echo "不符合规范: 元素数量不为3"
    exit 1
  fi

  # 检查第一个元素是否为CHANNEL
  if [ "${elements[0]}" != "CHANNEL" ]; then
    echo "不符合规范: 第一个元素不是CHANNEL"
    exit 1
  fi

  # 提取最后一个元素，并检查最后一个元素是否只包含字母和数字
  last_element="${elements[2]}"
  if [[ ! "$last_element" =~ ^[[:alnum:]]+$ ]]; then
    echo "不符合规范: 最后一个元素不只包含字母和数字"
    exit 1
  fi

  echo "符合规范"
done < "$file_path"

# 文件内容符合规范，退出状态为0
exit 0