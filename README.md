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

