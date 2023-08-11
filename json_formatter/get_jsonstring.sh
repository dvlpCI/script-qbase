#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-02-26 02:41:53
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-08-11 21:28:49
 # @FilePath: json_formatter/get_jsonstring.sh
 # @Description: 获取json字符串
### 


# 接收两个参数，参数1:数组的字符串(必填)；参数2:是否转义(可空，默认false)
function getJsonStringWithEscapeFromArrayString() {
#echo "\n以下为>>>>>>>>>>>>$0执行将数组转为json字符串的操作>>>>>>>>>>>>"
#    echo "入参:$1"

    local arrayArg
    # arrayArg=(` echo "$@" `)
   arrayArg=($1)
    
   shouldEscape=$2
   if [ -z "$2" ]; then
       shouldEscape="false" # 是否要转义
   fi
   #echo "是否要转义shouldEscape=${shouldEscape}"
    

    #echo "arrayArg=${arrayArg[*]}"
    arrayLength=${#arrayArg[*]}
    #echo "arrayLength=${arrayLength}"
    if [ ${arrayLength} == 0 ]; then
        return 1
    fi


    if [ ${arrayLength} == 1 ]; then
        devBranceMap=${arrayArg[0]}
        #echo "------------------0:${devBranceMap}"
        arrayJsonResultString="["
        arrayJsonResultString+=${devBranceMap}
        arrayJsonResultString+="]"
    else
        for ((i=0;i<${arrayLength};i++))
        do
            devBranceMap=${arrayArg[i]}
            #echo "------------------${i}:${devBranceMap}"
            if [ ${i} == 0 ]; then
                arrayJsonResultString="["
            fi
            
           if [ "${shouldEscape}" == "true" ]; then
               arrayJsonResultString+="\""
           fi
            arrayJsonResultString+=${devBranceMap}
           if [ "${shouldEscape}" == "true" ]; then
               arrayJsonResultString+="\""
           fi
            
            if [ ${i} -lt $((arrayLength-1)) ]; then
                arrayJsonResultString+=","
            fi
            
            if [ ${i} == $((arrayLength-1)) ]; then
                arrayJsonResultString+="]"
            fi
        done
    fi
    
    echo "${arrayJsonResultString}" #这是函数的返回值，所以本方法中不要有多余的echo，且echo中不要有多余的东西
    #echo "<<<<<<<<<<<<以上为$0执行将数组转为json字符串的操作<<<<<<<<<<<<\n"
    return 0
}


# shell 参数具名化                     
while [ -n "$1" ]
do
        case "$1" in
                -arrayString|--array-string) arrayString=$2; shift 2;;
                -escape|--should-escape) shouldEscape=$2; shift 2;;
                --) break ;;
                *) break ;;
        esac
done



array=(${arrayString}) #记得外层加()转成数组

getJsonStringWithEscapeFromArrayString "${array[*]}" "${shouldEscape}"