#!/bin/bash
:<<!
将字符串支持指定的 企业微信 markdown 格式
!

# markdown 添加 字体颜色fontColor 支持
# <font color="info">绿色</font>
# <font color="comment">灰色</font>
# <font color="warning">橙红色</font>
function markdown_fontColor() {
    shouldMarkdown=$1
    fontColor=$3
    if [ -z "${fontColor}" ]; then
        fontColor="info"
    fi
    # 方式1：
#    connectionString $2 "<font color=$fontColor>" "prefix"
    
    # 方式2(推荐)：
    reulstMessage=$2
    reulstMessage=$(connectionString "${shouldMarkdown}" "${reulstMessage}" "<font color=$fontColor>" "prefix")
    reulstMessage=$(connectionString "${shouldMarkdown}" "${reulstMessage}" "</font>" "suffix")
    echo "${reulstMessage}"
}


# markdown 添加 行内代码段（暂不支持跨行）code 支持
function markdown_code() {
    shouldMarkdown=$1
    reulstMessage=$2
    reulstMessage=$(connectionString "${shouldMarkdown}" "${reulstMessage}" "\`" "prefix")
    reulstMessage=$(connectionString "${shouldMarkdown}" "${reulstMessage}" "\`" "suffix")
    echo "${reulstMessage}"
}

# markdown 添加 引用quote 支持
function markdown_quote() {
    shouldMarkdown=$1
    reulstMessage=$2
    echo $(connectionString "${shouldMarkdown}" "${reulstMessage}" ">" "prefix")
}


function connectionString() {
    shouldMarkdown=$1   # 是否使用markdown格式
    originString=$2
        
    if [ "${shouldMarkdown}" != "true" ]; then
        echo ${originString}
        return
    fi
    
    addString=$3
    addPostion=$4
            
    # 使用 echo 将值返回的时候，多余的echo不要写，除非你是调试
#    echo "originString=$originString"
#    echo "addString=$addString"
#    echo "addPostion=$addPostion"
    if [ "${addPostion}" == "prefix" ]; then
        echo "${addString}${originString}"
    elif [ "${addPostion}" == "suffix" ]; then
        echo "${originString}${addString}"
    fi
}

function log2() {
    echo "--------------"
}
