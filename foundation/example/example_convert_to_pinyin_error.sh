#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-18 01:50:35
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-18 16:38:01
 # @FilePath: convert_to_pinyin.sh
 # @Description: 将中文转拼音（未实现，本脚本有错误）
### 

#!/bin/bash

is_chinese2() {
    python -c "import sys; import unicodedata; sys.exit(0 if unicodedata.category(sys.argv[1]) == 'Lo' else 1)" "$1"
    return $?
}

is_chinese() {
    char=$1
    # 判断字符是否在中文的 Unicode 编码范围内
    # if echo "$char" | awk '/[\x4e00-\x9fff]/'; then
    if is_chinese2 "$char"; then
        echo "\"$char\":中文字符✅"
        return 0  # 是中文字符
    else
        echo "\"$char\":不是中文字符❌"
        return 1  # 不是中文字符
    fi
}

is_chinese "哈"
is_chinese "1"
is_chinese "a" 