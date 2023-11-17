#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:43:04
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-17 11:16:16
 # @Description: 360加固的多渠道文件生成
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -arrayString|--arrayString) argArrayString=$2; shift 2;;
        -jsonString|--jsonString) argsJsonString=$2; shift 2;;
        -outputFile|--output-file-path) outputFilePath=$2; shift 2;;
        -shouldCheckOutput|--shouldCheckOutput) shouldCheckOutput=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [ -z "$outputFilePath" ]; then
  echo "❌Error:您的 -file 参数值 ${outputFilePath} 不能为空，否则无法创建用来填写配置信息的文件，无法请检查。"
  exit 1
fi

if [ -f "$outputFilePath" ]; then
  > "$outputFilePath"  # 清空文件内容
  # echo "🤝温馨提示:您的 -file 指向的 ${outputFilePath} 文件内容已存在，会先进行清空，以将整个文件用来填写配置信息的文件。"
fi

# 获取父目录路径
parent_directory=$(dirname "$outputFilePath")
# 创建父目录（如果不存在）
mkdir -p "$parent_directory"
# 创建文件
touch "$outputFilePath"
if [ ! -f "$outputFilePath" ]; then
  echo "❌Error:您的 -file 指向的 ${outputFilePath} 文件创建失败，请检查。"
  exit 1
fi

if [ -z "$argArrayString" ] && [ -z "$argsJsonString" ]; then
  echo "❌Error:您的 -arrayString 和 -jsonString 参数不能同时为空，要且只能设置其中一个。"
  exit 1
fi

if [ -n "$argArrayString" ] && [ -n "$argsJsonString" ]; then
  echo "❌Error:您的 -arrayString 和 -jsonString 参数不能同时设置，要且只能设置其中一个。"
  exit 1
fi




if [ -n "${argsJsonString}" ]; then
  # argsJsonString --> argArray --> argArrayString
  # echo "🚗 您正在通过 -jsonString 生成360加固的多渠道文件，请稍等..."
  # 使用jq验证JSON格式
  echo "$argsJsonString" | jq empty > /dev/null 2>&1
  if [ $? -ne 0 ]; then
      echo "❌Error:您的 -jsonString 参数值 ${argsJsonString} 字符串不符合JSON格式，请检查"
      exit 1
  fi

  # 🚗📢:使用下面的方法会丢失空元素，详情可看 foundation/string2array_example.sh 进行错误示例的查看
  # argArray=($(sh $qbase_homedir_abspath/foundation/json2array.sh "${argsJsonString}"))
  # 所以，直接使用源码来处理
  echo "🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️ 正在处理 argsJsonString = ${argsJsonString}"
  argArray=()
  count=$(printf "%s" "$argsJsonString" | jq -r '.|length')
  if [ $? != 0 ]; then
    echo "❌Error:提取 count失败，可能原因为您的 -jsonString 参数值 ${argsJsonString} 字符串不符合JSON格式，请检查"
    exit 1
  fi
  # echo "✅✅✅argsJsonString 的 count=${count}"
  for ((i=0;i<count;i++))
  do
      element=$(printf "%s" "$argsJsonString" | jq -r ".[$((i))]") # -r 去除字符串引号
      # echo "✅ $((i+1)). element=${element}"
      if [ -z "$element" ] || [ "$element" == " " ]; then
          element="null"
      fi
      argArray[${#argArray[@]}]=${element}
  done
  argArrayString=${argArray[*]}
  # echo "1.解析json字符串 ${argsJsonString} 得到的结果是===============argArrayString=${argArrayString}"
elif [ -n "${argArrayString}" ]; then
  # argArrayString --> argArray --> argArrayString
  # echo "🚗 您正在通过 -arrayString 生成360加固的多渠道文件，请稍等..."
  argArray=("${argArrayString}")

  # 使用set命令将输入字符串拆分为多个参数，并使用eval命令执行这个命令
  eval set -- "$argArrayString"
  argArray=("$@") # 使用"$@"将将拆分结果存储到数组中

else
  echo "❌Error:您的 -arrayString 和 -jsonString 参数不能同时为空，要且只能设置其中一个。"
  exit 1
fi



# 清空输出文件，并逐行写入对应的值到输出文件
> "$outputFilePath"
for ((i=0; i<${#argArray[@]}; i++)); do
  # echo "✅正在写入第$((i+1))个: ${argArray[$i]}"
  echo "${argArray[$i]}" >> "$outputFilePath"
done

if [ "${shouldCheckOutput}" == "true" ]; then
  checkResult=$(sh $CurrentDIR_Script_Absolute/360channel_file_check.sh "$outputFilePath")
  if [ $? != 0 ]; then
    echo "${checkResult}" # 此时此值是错误结果
    exit 1
  fi
fi

echo "恭喜:您的360加固多渠道配置文件内容生成成功。"