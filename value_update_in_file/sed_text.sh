#!/bin/bash
:<<!
替换任意指定文件中的文字为指定文字，通过获取旧文本位置
兼容：①要替换为的文字，可以有斜杠/

-slashNReplaceDealType|--slashNReplaceDealType: 换行的处理方式: 
"onlyFirst"                 只处理首行
"allNoConnector"(默认值)     处理所有行，且行和行之间【不必】使用连接符
"allAndConnector"           处理所有行，且行和行之间【需要】使用连接符
!

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# shell 参数具名化
show_usage="args: [-f, -r , -t, -slashNReplaceDealType]\
                                  [--file-path=, --replaceText=, --toText=, --slashNReplaceDealType=]"

while [ -n "$1" ]
do
        case "$1" in
                -f|--file-path) FILE_PATH=$2; shift 2;;
                -r|--replaceText) ReplaceText=$2; shift 2;;
                -t|--toText) ToText=$2; shift 2;;
                -slashNReplaceDealType|--slashNReplaceDealType) slashNReplaceDealType=$2; shift 2;; # "onlyFirst" "allNoConnector" "allAndConnector"
                -verbose|--show-verbose) showVerbose=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

#echo "===========替换《${ReplaceText}》为《${ToText}》"

if [ "${#slashNReplaceDealType}" == 0 ]; then
    slashNReplaceDealType="allNoConnector" # "onlyFirst" "allNoConnector" "allAndConnector"
fi


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function logMsg() {
    if [ "${showVerbose}" == true ]; then
        printf "${YELLOW}$1${NC}\n"
    fi
}

if [ ! -f "${FILE_PATH}" ];then
    echo "❌:您的${FILE_PATH}文件不存在，请检查！"
    exit_script
fi

if [ ${#ReplaceText} == 0 ];then
    echo "❌:您要替换成【${ToText}】的ReplaceText=${ReplaceText}，不能为空，所以无法替换，请检查！"
    exit_script
fi


#ToText="关/注"
#echo "替换斜杠前：${ToText}"
#ToText="/Users/qian/Project/CQCI/AutoPackage-CommitInfo/bulidScript/app_branch_info.json"
ToText=${ToText//\//\\/} # Fix：替换字符串中的所有斜杠为转义斜杠，修复执行sed的时候因为有字符串有斜杠而出错
#echo "替换斜杠后：${ToText}"

#建议使用#，而不使用/,避免要替换的文本开头就是/
if [ "${slashNReplaceDealType}" == "allNoConnector" ]; then
    #echo "替换所有换行符，而不是只替换第一个"，且不在每个换行尾部使用连接符来多行书写
    logMsg "正在执行命令(替换文本，且自动处理首个换行符):《 sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n}#g\" ${FILE_PATH} 》"
    sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n}#g" ${FILE_PATH}  # 将\n替换成真正的\n，而n不能替换【注换行符是特殊字符，所以此命令中的${ToText/\\n/\\\n}不能独立出来】
    if [ $? != 0 ]; then
        echo "❌执行sed命令失败:《sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n}#g\" \"${FILE_PATH}\"》"
        exit_script
    fi
elif [ "${slashNReplaceDealType}" == "allAndConnector" ]; then
    #echo "替换所有换行符，而不是只替换第一个"，且会在每个换行尾部使用连接符来多行书写
    logMsg "正在执行命令(替换文本，且自动处理所有换行符):《 sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g\" \"${FILE_PATH}\" 》"
    sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g" ${FILE_PATH}   # ⚠️json文件中使用连接符,会导致json文件格式错误，解析失败，所以此类型暂不支持使用
    if [ $? != 0 ]; then
        echo "❌执行sed命令失败:《sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g\" \"${FILE_PATH}\"》"
        exit_script
    fi
else
    #echo "只替换第一个换行符，而不是替换所有"
    #sed -i '' "s/${ReplaceText}/${ToText}/g" ${FILE_PATH}
    #sed -i '' "s#${ReplaceText}#${ToText/\\n/abc}#g" ${FILE_PATH}    #\n替换成abc，而n不能替换
    logMsg "正在执行命令(替换文本):《 sed -i '' \"s#${ReplaceText}#${ToText/\\n/\\\n}#g\" \"${FILE_PATH}\" 》"
    sed -i '' "s#${ReplaceText}#${ToText/\\n/\\\n}#g" ${FILE_PATH}   # 将\n替换成真正的\n，而n不能替换【注换行符是特殊字符，所以此命令中的${ToText/\\n/\\\n}不能独立出来】
    if [ $? != 0 ]; then
        echo "❌执行sed命令失败:《 sed -i '' \"s#${ReplaceText}#${ToText/\\n/\\\n}#g\" \"${FILE_PATH}\"》"
        exit_script
    fi
fi

if [ $? != 0 ]; then
    echo "❌替换失败，请检查。详情为替换${FILE_PATH}中的《${ReplaceText}》为《${ToText}》失败。(PS:换行符和连接符的处理方式是${slashNReplaceDealType})"
    exit_script
fi


