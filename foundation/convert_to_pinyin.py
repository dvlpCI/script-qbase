'''
Author: dvlproad dvlproad@163.com
Date: 2023-11-18 13:05:15
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-18 16:53:25
FilePath: /foundation/convert_to_pinyin.py
Description: 将中文转成拼音
'''
#!/usr/bin/env python3
import argparse
import sys
from pypinyin import pinyin, Style

# 执行本脚本前，请在shell中加入以下内容，避免出错
# if ! python -c "import pypinyin" >/dev/null 2>&1; then
#     echo "pypinyin module not found. Installing..."
#     pip3 install pypinyin
# fi


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 创建命令行参数解析器
parser = argparse.ArgumentParser()
parser.add_argument('-originString', dest='originString', help='原始字符串')
args = parser.parse_args(sys.argv[1:])  # 解析命令行参数
# 从命令行参数获取相应的值
chinese_string = args.originString

# chinese_string = sys.argv[1]
# chinese_string = "你好世界123abc✅"
converted = []

def debug_log(message):
    message
    # print(f"{message}")
        
for char in chinese_string:
    if '\u4e00' <= char <= '\u9fff':  # 判断是否为中文字符
        debug_log(f"\"{char}\":中文字符");
        pinyin_list = pinyin(char, style=Style.NORMAL, errors="ignore")
        if pinyin_list:
            converted.extend([p[0] for p in pinyin_list])
    elif char.isalnum(): # 先排除掉了中文字符，这里才不会出现把中文字符也归为此类
        # print(f"\"{char}\":字母或者数字");
        if char.isdigit():
            debug_log(f"\"{char}\":数字");
        elif char.isalpha():
            debug_log(f"\"{char}\":字母");
        converted.append(char)
    else:
        debug_log(f"\"{char}\":其他(将废弃)");

converted_string = "".join(converted)
print(converted_string)