# script-qbase
脚本基础库



## 若要发布新版本

请使用 [script-to-qbase/SKILL.md](https://github.com/dvlproad/AI-qskills/blob/main/script-to-qbase/SKILL.md)



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



## 二、必须了解的数据结构

### 1、环境变量集合/菜单 [example_env_keys_menu.json](example_env_keys_menu.json)

```json
{
  "using_choice_id": "此字段暂时无用",
  "envs_choices": [
    {
      "id": "default",
      "env_key": "QTOOL_DEAL_PROJECT_CHOICES_PATH"
    },
    {
      "env_key": "QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH",
      "env_des": "操作项目时候使用的项目配置信息用哪个/你想操作哪个项目",
      "env_choices": [
        {
          "env_des": "qtool的工程",
          "env_value": "/Users/lichaoqian/Project/CQCI/script-branch-json-file/test/tool_input.json"
        },
        {
          "env_name": "获取分支信息的工程",
          "env_value": "/Users/lichaoqian/Project/CQCI/AutoPackage-CommitInfo/test/tool_input.json"
        }
      ]
    }
  ]
}
```

### 2、命令集合/菜单 [custom_command_menu_example.json](menu/example/custom_command_menu_example.json)

详见：[menu/qbrew_menu.md](menu/qbrew_menu.md) 中的介绍

```json
{
    "custom": [
        {
            "type": "command",
            "des": "自定义命令的操作",
            "values": [
                {
                    "des": "增加自定义的命令",
                    "key": "add custom command",
                    "command": "open $QBASE_CUSTOM_MENU"
                }
            ]
        },
        {
            "type": "normal",
            "des": "自定义要执行的普通脚本",
            "values": [
                {
                    "des": "输出当前目录下的文件",
                    "key": "ls",
                    "command": "ls"
                },
                {
                    "des": "查看 ~/.ssh 文件夹",
                    "key": "open ~/.ssh",
                    "command": "open ~/.ssh"
                },
                {
                    "des": "查看 homebrew 的 Taps 文件夹",
                    "key": "open /opt/homebrew/Library",
                    "command": "open /opt/homebrew/Library"
                }
            ]
        },
        {
            "type": "usual",
            "des": "自定义要执行的日常脚本",
            "values": [
                {
                    "des": "打开上传包的网站(pgyer)",
                    "key": "打开上传包的网站(pgyer)",
                    "command": "open https://www.pgyer.com/"
                }
            ]
        }
    ]
}
```

### 3、命令事项的演示 [qbrew_menu_example.json](menu/example/qbrew_menu_example.json)

详见：[menu/qbrew_menu.md](menu/qbrew_menu.md) 中的介绍

```json
{
    "action_sript_file_rel_this_dir": "../qbrew_menu.sh",
    "action_sript_file_des": "打印json文件里的指定的分类为菜单，供用户选择，并在用户选择后了分类里的事项后，立即执行该事项command字段指定的命令",
    "actions_envs_des": "要打印的菜单分类",
    "actions_envs_values": [
        {
            "env_id": "menu_category",
            "env_name": "",
            "env_action_ids": [
                "-file",
                "-categoryType",
                "-execChoosed"
            ]
        }
    ],
    "actions": [
        {
            "id": "-file",
            "des": "对哪个json文件进行操作",
            "actionType": "fixed",
            "resultForParam": "-file",
            "fixedType": "file-path-rel-this-file",
            "fixedValue": "./custom_command_menu_example.json"
        },
        {
            "id": "-categoryType",
            "des": "可选?：对该文件的哪个分类进行操作",
            "actionType": "fixed",
            "resultForParam": "-categoryType",
            "fixedType": "fixed-value",
            "fixedValue": "custom"
        },
        {
            "id": "-execChoosed",
            "des": "可选：是否直接执行选中的命令，true:是",
            "actionType": "fixed",
            "resultForParam": "-execChoosed",
            "fixedType": "fixed-value",
            "fixedValue": "true"
        }
    ]
}
```

## 三、命令用法

| 命令 | 说明 |
|------|------|
| `qbase -path` | 获取脚本路径 |
| `qbase -quick` | 执行快捷命令 |
| `qbase -path-eg` | 查看脚本路径菜单（需密码） |
| `qbase -quick-eg` | 查看快捷命令菜单 |
| `qbase custom` | 打印自定义命令菜单，并在选择后进行脚本操作 |
| `qbase check-version` | 对 qbase 软件包进行检查更新 |
| `qbase --help` | 帮助 |

> 查看脚本路径需要密码：`qian`、`chaoqian` 或 `lichaoqian`

所有脚本调用方式统一为：

```bash
qbase -quick 脚本关键字 [具名参数/参数...]
```

## 四、相关文档

| 文档 | 说明 |
|------|------|
| [menu/qbrew_menu.md](./menu/qbrew_menu.md) | qbrew_menu.sh 菜单脚本的详细逻辑说明 |
| [branch.md](./branch.md) | 分支管理功能详解（筛选、获取、检查、展示） |

## 五、功能模块

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


### 日志

```shell
# 2>/dev/null 只将标准错误输出重定向到 /dev/null，保留标准输出。
# >/dev/null 2>&1 将标准输出和标准错误输出都重定向到 /dev/null，即全部丢弃。
```





## 版本记录

### 0.9.12 (2026-04-19)

- 【Feature】dealScript_by_scriptConfig.py 改为使用具名参数，方便拓展
- 【Optimize】dealScript_by_scriptConfig.py 中指向的文件如果不存在，改为会尝试帮你创建一个json文件出来
- 【Feature】在 dealScript_by_scriptConfig.py 传递 extra_command_args = QBASE_FLAG_ARGS + COMMON_FLAG_ARGS

### 2026-04-18

- 让 `python3 dealScript_by_scriptConfig.py` 既可被导入、又能直接运行时必须 `if __name__ == "__main__":`
- `qbase_quickcmd.sh` 增加对 python 脚本的执行

### 0.8.0 (2026-04-11)

增加 package_remote_version.sh（检查/更新 Homebrew 包版本）

