# script-qbase
脚本基础库



## 一、安装、删除与更新

### 1、安装、删除

* [Mac终端上Homebrew的常用命令](https://www.jianshu.com/p/536abd711af2)

```shell
# 1、引入
brew tap dvlpCI/qbase

# 2、安装
brew install qbase
# 如果上述命令执行失败，可能需要进入如下命令，删干净 qbase 相关问题
open /usr/local/var/homebrew/

# 3、删除
brew uninstall qbase
```

### 2、更新

```bash
# 1、先更新本地的软件包索引（知道有哪些新版本）
brew update

# 2、再根据更新后的本地索引，升级到索引中的最新版本
brew upgrade qbase
```

#### 问：qbase库的版本更新问题

问1、brew upgrade xxx 更新不到网络上已发布的最新版本的原因

问2、不通过 brew update ，如何知道远程有没有新版本，并更新？

答案见：[https://dvlproad.github.io/代码管理/库管理/homebrew](https://dvlproad.github.io/%E4%BB%A3%E7%A0%81%E7%AE%A1%E7%90%86/%E5%BA%93%E7%AE%A1%E7%90%86/homebrew)



## 二、功能模块

### 基础工具

| 目录               | 用途                                            |
| ------------------ | ----------------------------------------------- |
| `foundation/`      | 基础工具（字符串匹配、数组/JSON转换、拼音转换） |
| `date/`            | 日期计算（天数差、日期格式转换）                |
| `package/`         | 包处理（获取包信息、安装、版本检查与更新）      |
| `markdown/`        | Markdown处理                                    |
| `pythonModuleSrc/` | Python公共模块                                  |
| `base/wrap/`       | 结果包装处理                                    |

### 数据处理

| 目录 | 用途 |
|------|------|
| `value_get_in_json_file/` | 从JSON文件获取值 |
| `value_update_in_file/` | 更新文件中指定值（JSON/shell/sed） |
| `value_update_in_code/` | 更新代码中变量值 |
| `excel_data_compare/` | Excel数据对比 |
| `json_formatter/` | JSON格式化 |

### 发布 / 通知

| 目录 | 用途 |
|------|------|
| `upload_app/` | 应用上传（蒲公英、TestFlight、COS） |
| `notification/` | 微信/企业微信通知 |

### Git / 分支管理

| 目录                           | 用途                                          |
| ------------------------------ | --------------------------------------------- |
| `branch/`                      | Git分支操作（选择分支、获取合并记录、rebase） |
| `branchMaps_10_resouce_get/`   | 获取分支映射信息                              |
| `branchMaps_11_resouce_check/` | 校验分支映射文件                              |
| `branchMaps_20_info/`          | 分支详情信息查询                              |



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





## 版本记录

### 0.8.0 (2026-04-11)

增加 package_remote_version.sh（检查/更新 Homebrew 包版本）

