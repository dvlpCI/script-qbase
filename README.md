# script-qbase
脚本基础库





## 安装

* [Mac终端上Homebrew的常用命令](https://www.jianshu.com/p/536abd711af2)

```shell
# 1、引入
brew tap dvlpCI/qbase

# 2、安装
brew install qbase
# 如果上述命令执行失败，可能需要进入如下命令，删干净 qbase 相关问题
open /usr/local/var/homebrew/

# 3、更新
brew upgrade qbase

# 4、删除
brew uninstall qbase
```



## Shell 结果要点

### 1、结果

```shell
// printf "%s" 会保留\n等
printf "%s" "${responseJsonString}"
```


### 2、日志

```shell
# 使用>&2将echo输出重定向到标准错误，作为日志

function debug_log() {
	echo "$1" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
}



# 2>/dev/null 只将标准错误输出重定向到 /dev/null，保留标准输出。
# >/dev/null 2>&1 将标准输出和标准错误输出都重定向到 /dev/null，即全部丢弃。
```

```
为了避免jq在处理json文件中的内容有\的问题时候，请使用
$(printf "%s" "$categoryData" | jq "length") 而不是 $(echo "$categoryData" | jq "length")

示例：
catalogCount=$(printf "%s" "$categoryData" | jq "length")
# echo "catalogCount=${catalogCount}"
for ((i = 0; i < ${catalogCount}; i++)); do
	iCatalogMap=$(printf "%s" "$categoryData" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
	if [ $? != 0 ] || [ -z "${iCatalogMap}" ]; then
		echo "❌${RED}Error1:执行命令jq出错了，常见错误：您的内容文件中，有斜杠，但使用jq时候却没使用printf \"%s\"，而是使用echo。解决方法1：去掉斜杠；解决方法2：一个斜杠，应该用四个斜杠标识；更好的解决方法：使用printf \"%s\"。请检查>>>>>>>${NC}\n ${iCatalogMap} ${RED}\n<<<<<<<<<<<<<请检查以上内容。${NC} "
		# echo "cat \"$qbrew_json_file_path\" | jq \".${qbrew_categoryType}\" | jq -r \".[${i}]\" | jq -r \".values\""
		exit 1
	fi
done
```