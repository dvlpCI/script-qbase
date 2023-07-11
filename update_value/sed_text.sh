#!/bin/bash
#sed -i '' "s#${ReplaceText}#${ToText//n//n}#g" "../bulidScript/app_info.json"
#sed -i '' "s#${ReplaceText}#${ToText/n/\n}#g" "../bulidScript/app_info.json"
#
#FILE_PATH="../bulidScript/app_info.json"
#ReplaceText="package cos url"
#
#ToText="User1okUser2okUser3"
#测试替换ok
#sed -i '' "s#${ReplaceText}#${ToText/ok/换行符}#g" "../bulidScript/app_info.json"   #只替换第一个ok,而不是所有的ok
#sed -i '' "s#${ReplaceText}#${ToText//ok/换行符}#g" "../bulidScript/app_info.json"  #替换所有的ok,而不只是第一个ok
#测试连接符ok
#sed -i '' "s#${ReplaceText}#${ToText//ok/换行符\\\\\n}#g" "../bulidScript/app_info.json"  #测试换行符后，能换行显示并用换行连接符\链接
#sed -i '' "s#${ReplaceText}#${ToText//ok/\\\n\\\\\n}#g" "../bulidScript/app_info.json"
#
#测试替换\n
#ToText="/Users/qian/Project\n测试第一个换行符后的内容有没正确替换"                                 # 测试\n是否替换成功(本字符串只能测试第一个\n)
#sed -i '' "s#${ReplaceText}#${ToText/\\n/abc}#g" "../bulidScript/app_info.json"             # \n替换成abc，而n不能替换
#sed -i '' "s#${ReplaceText}#${ToText/\\n/\\\n}#g" "../bulidScript/app_info.json"            # \n替换成真正的\n，而n不能替换
#
#ToText="/Users/qian/Project\n测试第一个换行符后的内容有没正确替换\n测试第二个换行符后的内容有没正确替换"  # 测试\n是否替换成功(本字符串用于测试多个换行符\n，而不是只有第一个才生效)
#sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n}#g" ${FILE_PATH}    #[shell(bash)替换字符串大全](https://blog.csdn.net/coraline1991/article/details/120235471)
#sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g" ${FILE_PATH}
#
#
#ToText='关/注'
#ToText="/Users/qian/Project/CQCI/AutoPackage-CommitInfo/bulidScript/app_branch_info.json"
#sh sed_text.sh -appInfoF ${FILE_PATH} -r "${ReplaceText}" -t "${ToText}"
#
#sh sed_text.sh -appInfoF "../bulidScript/app_info.json" -r "package cos url" -t "关/注"
#sh sed_text.sh -appInfoF "../bulidScript/app_info.json" -r "package cos url" -t "/Users/qian/Project/CQCI/AutoPackage-CommitInfo/bulidScript/app_branch_info.json"
#sh sed_text.sh -appInfoF "../bulidScript/app_info.json" -r "package cos url" -t "要点1n\nn要点2:关/注"
#sh sed_text.sh -appInfoF "../bulidScript/app_info.json" -r "package unknow message" -t "failure:编译打包失败，未生成release/wish.apk"
#sh sed_text.sh -appInfoF "../bulidScript/app_info.json" -r "package unknow message" -t "您当前打包的需求较上次有所缺失，请先补全，再打包，至少缺失旧包dev_fix。\n可能原因如下:dev_fix未合并进来，或者是有新的提交也会造成这个问题。"
#sh sed_text.sh -appInfoF "../bulidScript/app_info.json" -r "package unknow update" -t "更新说明略\n分支信息:\ndev_fix:功能修复"
#
#打印替换的结果：
#cat ${FILE_PATH} | jq '.package_url_result' | jq '.package_cos_url' | sed 's/\"//g'
#packageCosUrl=$(cat ${FILE_PATH} | jq '.package_url_result' | jq '.package_cos_url' | sed 's/\"//g')
#echo $packageCosUrl

:<<!
替换"app_info.json"中的文字，为指定文字
兼容：①要替换为的文字，可以有斜杠/
!


JQ_EXEC=`which jq`
FILE_PATH=$1 #"app_info.json"

CurrentDirName=${PWD##*/}


# shell 参数具名化
show_usage="args: [-appInfoF, -r , -t]\
                                  [--app-info-json-file=, --replaceText=, --toText=]"

while [ -n "$1" ]
do
        case "$1" in
                -appInfoF|--app-info-json-file) FILE_PATH=$2; shift 2;;
                -r|--replaceText) ReplaceText=$2; shift 2;;
                -t|--toText) ToText=$2; shift 2;;
                -slashNReplaceDealType|--slashNReplaceDealType) slashNReplaceDealType=$2; shift 2;; # "onlyFirst" "allNoConnector" "allAndConnector"
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

if [ ! -f "${FILE_PATH}" ];then
    echo "❌:您的$PWD/${FILE_PATH}文件不存在，请检查！"
    exit 1
fi

if [ ${#ReplaceText} == 0 ];then
    echo "❌:您要替换成【${ToText}】的ReplaceText=${ReplaceText}，不能为空，所以无法替换，请检查！"
    exit 1
fi

#[在shell脚本中验证JSON文件的语法](https://qa.1r1g.com/sf/ask/2966952551/)
#cat app_info.json
fullJsonString=$(cat ${FILE_PATH} | json_pp)
fullJsonLength=${#fullJsonString}
#echo "fullJsonLength=${#fullJsonLength}"
if [ ${fullJsonLength} == 0 ]; then
    PackageErrorCode=-1
    PackageErrorMessage="${FILE_PATH}不是标准的json格式，请检查"
    sed -i '' "s/package_code_0/${PackageErrorCode}/g" ${FILE_PATH}
    sed -i '' "s/可以打包/${PackageErrorMessage}/g" ${FILE_PATH}
    #sh sed_text.sh -appInfoF ${FILE_PATH} -r "package unknow message" -t "${PackageErrorMessage}"
    echo ${PackageErrorCode}:${PackageErrorMessage}
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
    sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n}#g" ${FILE_PATH}  # 将\n替换成真正的\n，而n不能替换【注换行符是特殊字符，所以此命令中的${ToText/\\n/\\\n}不能独立出来】
    if [ $? != 0 ]; then
        echo "❌执行sed命令失败:《sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n}#g\" \"${FILE_PATH}\"》"
        exit_script
    fi
elif [ "${slashNReplaceDealType}" == "allAndConnector" ]; then
    #echo "替换所有换行符，而不是只替换第一个"，且会在每个换行尾部使用连接符来多行书写
    sed -i '' "s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g" ${FILE_PATH}   # ⚠️json文件中使用连接符,会导致json文件格式错误，解析失败，所以此类型暂不支持使用
    if [ $? != 0 ]; then
        echo "❌执行sed命令失败:《sed -i '' \"s#${ReplaceText}#${ToText//\\n/\\\n\\\\\n}#g\" \"${FILE_PATH}\"》"
        exit_script
    fi
else
    #echo "只替换第一个换行符，而不是替换所有"
    #sed -i '' "s/${ReplaceText}/${ToText}/g" ${FILE_PATH}
    #sed -i '' "s#${ReplaceText}#${ToText/\\n/abc}#g" ${FILE_PATH}    #\n替换成abc，而n不能替换
    sed -i '' "s#${ReplaceText}#${ToText/\\n/\\\n}#g" ${FILE_PATH}   # 将\n替换成真正的\n，而n不能替换【注换行符是特殊字符，所以此命令中的${ToText/\\n/\\\n}不能独立出来】
    if [ $? != 0 ]; then
        echo "❌执行sed命令失败:《sed -i '' \"s#${ReplaceText}#${ToText/\\n/\\\n}#g\" \"${FILE_PATH}\"》"
        exit_script
    fi
fi

if [ $? != 0 ]; then
    echo "❌替换失败，请检查。详情为替换${FILE_PATH}中的《${ReplaceText}》为《${ToText}》失败。(PS:换行符和连接符的处理方式是${slashNReplaceDealType})"
    exit_script
fi


