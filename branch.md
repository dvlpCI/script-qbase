# Branch 分支管理

本文档介绍分支相关的功能，包括分支筛选、信息获取、检查和展示。

---

## 零、模块层级关系

### 目录结构

```
branch/                              ← 分支操作（筛选、记录、时间）
    │
    ├── branchMaps_10_resouce_get/   ← 获取：读取分支信息 JSON 文件
    │
    └── branchMaps_11_resouce_check/ ← 检查：校验 JSON 完整性
              ↓
    └── branchMaps_20_info/          ← 展示：生成格式化输出
              │
              ├── get10_xxx          ← 获取单个分支详情
              ├── get11_xxx          ← 按分类整理（被 get20 调用）
              └── get20_xxx          ← 主入口，调用 get10 + get11
```

### 调用关系

| 关系 | 说明 |
|------|------|
| `branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh` | 调用 `branchMaps_11` 的检查脚本 |
| `branchMaps_20_info/get20_xxx.sh` | 调用同目录下的 `get10_` 和 `get11_` 脚本 |

### 使用建议

| 场景 | 推荐使用 |
|------|----------|
| 只需要获取分支信息文件 | `branchMaps_10/` |
| 需要检查信息完整性 | `branchMaps_10/` + `branchMaps_11/` |
| 需要生成展示结果 | `branchMaps_20/` 一步到位 |

---

## 一、分支筛选与记录

### 1.1 select_branch_byNames - 按条件筛选分支

根据分支名筛选符合条件的分支，支持按创建时间、最后提交时间、提交次数过滤。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-branchNames` | 要筛选的分支名列表（空格分隔） |
| `-ignoreBranchNameOrRules` | 要忽略的分支（支持分支名或规则如 `test/*`） |
| `-create-startDate` | 创建时间早于此值不显示 |
| `-create-endDate` | 创建时间晚于此值不显示 |
| `-lastCommit-startDate` | 最后提交时间不在此之后不显示 |
| `-lastCommit-endDate` | 最后提交时间晚于此值不显示 |

**示例：**

```bash
# 基本用法：筛选指定分支
sh select_branch_byNames.sh -branchNames "feature/user_login feature/payment bugfix/crash"

# 忽略某些分支
sh select_branch_byNames.sh \
  -branchNames "feature/user_login feature/payment feature/test" \
  -ignoreBranchNameOrRules "feature/test test/*"

# 按创建时间筛选（只显示2024年后创建的分支）
sh select_branch_byNames.sh \
  -branchNames "feature/user_login feature/payment feature/report" \
  -create-startDate "2024-01-01 00:00:00"

# 按最后提交时间筛选（只显示最近7天有提交的分支）
sh select_branch_byNames.sh \
  -branchNames "feature/user_login feature/payment feature/report" \
  -lastCommit-startDate "2024-03-01 00:00:00"
```

**输出效果：**

```json
{
  "errors": [],
  "eligibles": [
    {
      "branch_name": "feature/user_login",
      "author": "zhangsan",
      "last_committer": "zhangsan",
      "commit_count": 15
    },
    {
      "branch_name": "feature/payment",
      "author": "lisi",
      "last_committer": "lisi",
      "commit_count": 8
    }
  ],
  "ineligibles": [],
  "ignores": ["feature/test"]
}
```

**字段说明：**

| 字段 | 说明 |
|------|------|
| `errors` | 获取信息失败的分支及原因 |
| `eligibles` | 符合筛选条件的分支 |
| `ineligibles` | 不符合时间条件但信息获取成功的分支 |
| `ignores` | 被忽略规则过滤掉的分支 |

---

### 1.2 get_only_branch_from_recods - 从记录中提取分支名

从 git 提交记录中提取分支名，过滤掉非分支信息。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-recordsString` | 原始记录字符串 |
| `-branchShouldRemoveOrigin` | 是否移除 `origin/` 前缀（true/false） |

**示例：**

```bash
# 从 git show-branch 结果中提取分支名
records=$(git show-branch -r --list)
branches=$(sh get_only_branch_from_recods.sh -recordsString "$records")

# 保留 origin/ 前缀
branches=$(sh get_only_branch_from_recods.sh \
  -recordsString "$records" \
  -branchShouldRemoveOrigin "false")

# 移除 origin/ 前缀
branches=$(sh get_only_branch_from_recods.sh \
  -recordsString "$records" \
  -branchShouldRemoveOrigin "true")
```

**输出效果：**

```
origin/feature/user_login origin/feature/payment origin/develop origin/master
```

---

### 1.3 rebasebranch_last_commit_date - 获取分支最后提交时间

获取指定分支的最后一次提交时间。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-rebaseBranch` | 要查询的分支名 |

**示例：**

```bash
# 获取 master 分支的最后提交时间
last_date=$(sh rebasebranch_last_commit_date.sh -rebaseBranch "master")
echo "master 最后提交时间: $last_date"

# 获取 develop 分支的最后提交时间
last_date=$(sh rebasebranch_last_commit_date.sh -rebaseBranch "develop")
```

**输出效果：**

```
2024-03-15 14:30:25
```

---

## 二、分支信息获取

### 2.1 addBranchMaps_toJsonFile - 添加分支信息到文件

将分支信息从指定目录读取并添加到目标 JSON 文件。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-branchMapsFromDir` | 分支信息文件所在目录 |
| `-branchMapsAddToJsonF` | 目标 JSON 文件路径 |
| `-branchMapsAddToKey` | 添加到目标文件的 key |
| `-requestBranchNamesString` | 要获取的分支名列表 |
| `-checkPropertyInNetwork` | 检查环境类型（test1/test2/production） |
| `-ignoreCheckBranchNames` | 忽略检查的分支名 |
| `-shouldDeleteHasCatchRequestBranchFile` | 成功后是否删除源文件 |

**示例：**

```bash
# 基本用法：从目录获取分支信息并添加到文件
sh addBranchMaps_toJsonFile.sh \
  -branchMapsFromDir "/path/to/branchInfos" \
  -branchMapsAddToJsonF "/path/to/output.json" \
  -branchMapsAddToKey "branch_maps" \
  -requestBranchNamesString "feature/user_login feature/payment"

# 启用属性检查（test1 环境）
sh addBranchMaps_toJsonFile.sh \
  -branchMapsFromDir "/path/to/branchInfos" \
  -branchMapsAddToJsonF "/path/to/output.json" \
  -branchMapsAddToKey "branch_maps" \
  -requestBranchNamesString "feature/user_login feature/payment" \
  -checkPropertyInNetwork "test1" \
  -ignoreCheckBranchNames "master develop"
```

**输出效果：**

```
正在执行命令(获取json内容)《sh ... 》
所得json结果为:
[{"name":"feature/user_login","type":"feature",...}]

分支源添加到文件后的更多详情可查看: /path/to/output.json 的 branch_maps
```

---

### 2.2 get_filePath_mapping_branchName_from_dir - 根据分支名查找信息文件

在指定目录中查找分支名对应的 JSON 信息文件。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-branchMapsFromDir` | 分支信息文件所在目录 |
| `-requestBranchName` | 要查找的分支名 |

**示例：**

```bash
# 查找单个分支的信息
result=$(sh get_filePath_mapping_branchName_from_dir.sh \
  -branchMapsFromDir "/path/to/branchInfos" \
  -requestBranchName "feature/user_login")

# 查看结果
echo "$result" | jq '.'
```

**输出效果：**

```json
[
  {
    "name": "feature/user_login",
    "fileUrl": "/path/to/branchInfos/feature_user_login.json",
    "type": "feature",
    "create_time": "2024.03.01",
    "submit_test_time": "2024.03.10",
    "tester": {
      "name": "wangwu"
    }
  }
]
```

---

### 2.3 get_allBranchJson_inBranchNames_byJsonDir - 从远程仓库获取分支信息

从 GitHub/Gitee/GitLab 获取指定分支的 JSON 信息文件。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-requestBranchNames` | 要获取的分支名列表（空格分隔） |
| `-access-token` | 访问令牌（GitHub/GitLab 需要） |
| `-oneOfDirUrl` | 包含分支目录的 URL |
| `-dirUrlBranchName` | 目录所在的分支名 |

**调用关系：**

```
get_allBranchJson_inBranchNames_byJsonDir.sh
    ├── get_only_branch_from_recods.sh         ← 提取分支名
    ├── select_branch_byNames.sh               ← 筛选分支
    └── getBranchMapsInfoAndNotifiction.sh     ← 整理并发送通知
```

**使用流程：**

```bash
# 1. 获取本地分支列表
git branch -r | grep -v HEAD | sed 's/origin\///'

# 2. 筛选符合条件的分支
branchNames=$(sh select_branch_byNames.sh \
  -branchNames "origin/feature/a origin/feature/b" \
  -ignoreBranchNameOrRules "unuse/* test/*" \
  -lastCommit-startDate "2024-01-01")

# 3. 从远程获取分支信息
allBranchJsonStrings=$(sh get_allBranchJson_inBranchNames_byJsonDir.sh \
  -requestBranchNames "${branchNames//$'\n'/ }" \
  -access-token "ghp_xxx" \
  -oneOfDirUrl "https://github.com/user/repo/tree/main/branchInfos" \
  -dirUrlBranchName "main")
```

**输出效果：**

```json
{
  "branchJsons": [
    {
      "name": "feature/user_login",
      "type": "feature",
      "create_time": "2024.03.01",
      "submit_test_time": "2024.03.10",
      "outlines": [
        { "title": "登录模块开发", "weekSpend": [16, 24] }
      ]
    }
  ]
}
```

**支持的平台：**

| 平台 | 需要 Token | API |
|------|-----------|-----|
| GitHub | 是 | `api.github.com` |
| Gitee | 否 | `gitee.com/api` |
| GitLab | 是 | `gitlab.com/api` |

---

## 三、分支信息检查

### 3.1 branchMapFile_checkMap - 检查分支信息完整性

检查单个分支 JSON 文件的信息完整性。

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-checkBranchMap` | 要检查的分支 JSON |
| `-pn` | 打包环境类型（test1/test2/production） |
| `-skipCheckType` | 是否跳过类型检查（true/false） |
| `-skipCheckTime` | 是否跳过时间检查（true/false） |
| `-checkSpendToDate` | 检查到哪个日期的周报 |
| `-ignoreCheckBranchNames` | 忽略检查的分支名 |

**示例：**

```bash
# 检查 test1 环境
branch_json='{"name":"feature/user_login","type":"feature","submit_test_time":"2024.03.10"}'
sh branchMapFile_checkMap.sh \
  -checkBranchMap "$branch_json" \
  -pn "test1"

# 检查 production 环境（含所有时间节点）
sh branchMapFile_checkMap.sh \
  -checkBranchMap '{"name":"feature/payment","type":"feature","submit_test_time":"2024.03.10","pass_test_time":"2024.03.15","merger_pre_time":"2024.03.18","tester":{"name":"zhangsan"}}' \
  -pn "production"

# 检查周报消耗时间（到指定日期）
sh branchMapFile_checkMap.sh \
  -checkBranchMap "$branch_json" \
  -pn "test1" \
  -checkSpendToDate "2024.03.15"
```

**输出效果：**

成功：
```
恭喜：在 test1 环境下的分支信息完整性【时间time】和【类型type】检查结束，且都成功通过了
```

失败：
```
①.缺失提测时间 submit_test_time;②.缺失测试负责人信息 tester
```

---

### 3.2 branchMapsFile_checkMaps - 批量检查分支信息

批量检查多个分支的信息完整性。

**示例：**

```bash
# 检查多个分支
sh branchMapsFile_checkMaps.sh \
  -branchMapsJsonF "/path/to/branchMaps.json" \
  -branchMapsKey ".branch_maps" \
  -pn "test1"
```

---

## 四、分支信息展示 (branchMaps_20_info)

### 4.1 目录结构

```
branchMaps_20_info/
├── get20_branchMapsInfo_byHisJsonFile.sh          # 主入口：批量获取并分类
├── get10_branch_self_detail_info.sh              # 获取单个分支完整信息
├── get10_branch_self_detail_info_outline.sh      # 获取分支的 outlines 描述
├── get10_branch_self_detail_info_outline_spend.sh # 获取 outline 的耗时
├── get11_category_all_detail_info.sh             # 按 type 分类整理信息
└── test/                                          # 测试用例
    ├── example10_get_branch_self_detail_info.sh
    ├── example11_get_category_all_detail_info.sh
    ├── example20_get_branchMapsInfo_byHisJsonFile.sh
    └── data/
```

### 4.2 调用关系

#### 4.2.1 调用关系图

```
get20_branchMapsInfo_byHisJsonFile.sh    ← 主入口
    ├── get10_branch_self_detail_info.sh     ← 获取单个分支信息
    │       └── get10_branch_self_detail_info_outline.sh  ← outlines 描述
    │               └── get10_branch_self_detail_info_outline_spend.sh  ← 耗时
    └── get11_category_all_detail_info.sh     ← 分类整理
```

#### 4.2.2 调用关系示例

以主入口 `get20` 为例，说明其输出是如何由各子模块组合而成的：

```
get20_branchMapsInfo_byHisJsonFile.sh 的输出结构
│
├── get10_branch_self_detail_info.sh      ← 生成单条分支信息
│   ├── 状态标记 (get10 内部生成)：🖍/🏃coding/❓test_submit/👌🏻test_pass/✅test_prefect
│   ├── 分支名 (get10 内部生成)：dev_login_err
│   ├── 时间线 (get10 内部生成)：[02.09开发中]
│   ├── @人员 (get10 内部生成)：@producter1@test1
│   └── outlines 描述
│       ├── get10_branch_self_detail_info_outline.sh  ← 生成 outlines 列表
│       │   ├── 编号 (outline 内部生成)：①
│       │   ├── 标题 (outline 内部生成)：功能点一
│       │   ├── 链接 (outline 内部生成)：https://xxx.com/
│       │   └── 耗时
│       │       └── get10_branch_self_detail_info_outline_spend.sh  ← 计算耗时
│       │           └── 输出示例："12"
│       │
│       └── 输出示例："①功能点一[4h]\n②功能点二[12h]"
│   │
│   └── 输出示例："🏃dev_login_err:[02.09开发中]@producter1@test1\n①功能点一[4h]\n②功能点二[12h]"
│
├── get11_category_all_detail_info.sh    ← 分类整理
│   ├── 按 type 分组 (hotfix/feature/optimize/other)
│   ├── 添加分类标题
│   ├── 输出示例格式：
│   │   "=======hotfix=======\n{get10 生成的分支信息}\n=======feature=======\n{get10 生成的分支信息}\n..."
│   └── 输出示例：
│       "=======hotfix=======\n1.❓【34天@test1】dev_login_err:[02.09已提测]@producter1@test1\n①登录失败错误提示\n②登录失败错误提示2\n=======feature=======\n3.✅dev_ui_revision:[02.17已合入预生产]@qian@qian\n①首页UI改版\n..."
│
└── 最终输出示例（JSON）：
    {
      "category": {
        "feature": ["✅dev_ui_revision:[02.17已合入预生产]@qian@qian\n①首页UI改版[8h]"],
        "hotfix": ["🏃dev_login_err:[02.09开发中]@producter1@test1\n①功能点一[4h]\n②功能点二[12h]"],
        "optimize": [...],
        "other": []
      }
    }
```

### 4.3 测试数据说明

**单分支测试数据** (`test/data/example10_get_branch_self_detail_info.json`)：

```json
{
  "create_time": "02.09",
  "submit_test_time": "null",
  "pass_test_time": "null",
  "merger_pre_time": "null",
  "type": "hotfix",
  "name": "dev_login_err",
  "outlines": [
    { "url": "https://www.baidu.com/", "title": "功能点一" },
    { "url": "https://www.baidu.com/", "title": "功能点二", "weekSpend": [{ "hour": 4 }] },
    { "title": "修复点一", "weekSpend": [{ "hour": 12 }] }
  ],
  "answer": { "name": "producter1" },
  "tester": { "name": "test1" }
}
```

**多分支测试数据** (`test/data/example20_get_branchMapsInfo_byHisJsonFile.json`)：

包含 6 个分支，涵盖不同 type 和不同测试状态：

- 2 个 hotfix（开发中、已通过）
- 3 个 feature（已完成）
- 1 个 optimize（已完成）



---

### 4.4 主入口 - get20_branchMapsInfo_byHisJsonFile.sh

**功能：** 批量处理多个分支，按类型分类，结果保存到文件

**参数：**

| 参数 | 说明 |
|------|------|
| `-branchMapsInJsonF` | 分支信息源文件 |
| `-branchMapsInKey` | 分支数组在文件中的 key（如 `.package_merger_branchs`） |
| `-showFlag` | 是否显示状态标记 |
| `-showName` | 是否显示分支名 |
| `-showTime` | 时间显示方式（all/only_last/none） |
| `-showAt` | 是否显示 @ 人员 |
| `-shouldShowSpendHours` | 是否显示耗时 |
| `-shouldMD` | 是否输出 Markdown |
| `-resultSaveToJsonF` | 结果保存文件 |
| `-resultBranchKey` | 分支数组保存 key |
| `-resultCategoryKey` | 分类结果保存 key |
| `-resultFullKey` | 完整字符串保存 key |

**测试用例：** `test/example20_get_branchMapsInfo_byHisJsonFile.sh`

**效果（输出到 JSON 文件）：**

```json
{
  "category": {
    "hotfix": [
      "🏃dev_login_err:[02.09开发中]@producter1@test1\n①功能点一 [?h]\n②功能点二 [4h]\n③修复点一[12h] "
    ],
    "feature": [
      "✅dev_ui_revision:[02.17已提测][02.17已测试通过][02.17已合入预生产分支]@qian@qian\n①首页UI改版[?h]\n②个人中心UI改版[?h] "
    ],
    "optimize": [...],
    "other": []
  }
}
```

#### 4.4.1 获取单个分支 - get10_branch_self_detail_info.sh

**功能：** 组合生成单个分支的完整展示信息

**参数：**

| 参数 | 说明 |
|------|------|
| `-iBranchMap` | 分支 JSON 对象 |
| `-showFlag` | 是否显示状态标记（true/false） |
| `-showName` | 是否显示分支名（true/false） |
| `-showTime` | 时间显示方式（all/only_last/none） |
| `-showAt` | 是否显示 @ 人员（true/false） |
| `-shouldShowSpendHours` | 是否显示耗时（true/false） |
| `-shouldMD` | 是否输出 Markdown 格式 |

**状态标记：**

| 状态 | 标记 | 条件 |
|------|------|------|
| 开发中 | 🏃 | 只有 create_time |
| 已提测 | ❓【X天@测试】 | 有 submit_test_time |
| 已通过 | 👌🏻 | 有 pass_test_time |
| 已完成 | ✅ | 有 merger_pre_time |

**测试用例：** `test/example10_get_branch_self_detail_info.sh`

**效果：**

```
🏃dev_login_err:[02.09开发中]@producter1@test1
①功能点一 https://www.baidu.com/[?h]
②功能点二 https://www.baidu.com/[4h]
③修复点一[12h]
```

##### 4.4.1.1 获取 outlines 描述 - get10_branch_self_detail_info_outline.sh

**功能：** 获取分支的 outlines（功能点列表），支持编号、链接、耗时显示

**参数：**

| 参数 | 说明 |
|------|------|
| `-branchMap` | 分支完整 JSON |
| `-testS` | 测试状态（coding/test_submit/test_pass/test_prefect） |
| `-shouldShowSpendHours` | 是否显示耗时（true/false） |
| `-shouldMD` | 是否输出 Markdown 格式 |

**效果：**

```
①功能点一 https://www.baidu.com/[?h]
②功能点二 https://www.baidu.com/[4h]
③修复点一[12h]
```

###### 4.3.1.1.1 获取耗时 - get10_branch_self_detail_info_outline_spend.sh

**功能：** 从单个 outline 中计算总耗时小时数

**参数：**

| 参数 | 说明 |
|------|------|
| `-outline` | outline JSON 对象 |

**效果：**

```bash
sh get10_branch_self_detail_info_outline_spend.sh -outline '{"weekSpend":[{"hour":4},{"hour":8}]}'
# 输出: 12
```

#### 4.4.2 分类整理 - get11_category_all_detail_info.sh

**功能：** 将分支信息按 `type`（hotfix/feature/optimize/other）分类整理，加上分类标题

**参数：**

| 参数 | 说明 |
|------|------|
| `-categoryJsonF` | 包含分类信息的 JSON 文件 |
| `-categoryArrayKey` | 分类数组在文件中的 key |
| `-showCategoryName` | 是否显示分类名称（true/false） |
| `-resultFullKey` | 完整结果保存的 key |
| `-resultFullSaveToJsonF` | 结果保存文件 |

**测试用例：** `test/example11_get_category_all_detail_info.sh`

**效果：**

```
=======hotfix=======
1.❓【34天@test1】dev_login_err:[02.09已提测]@producter1@test1
①登录失败错误提示
2.👌🏻dev_login_err:[02.09已提测][2.16已测试通过]@producter1@test1
①修复提示语
=======feature=======
3.✅dev_ui_revision:[02.17已提测][02.17已测试通过][02.17已合入预生产分支]@qian@qian
①首页UI改版
①个人中心UI改版
=======optimize=======
6.✅dev_dokit:[12.14已提测][12.22已测试通过][12.22已合入预生产分支]@qian@tester3
Flutter升级3.3.9
```

---

## 五、分支信息结构

### 5.1 分支 JSON 结构

```json
{
  "name": "feature/user_login",
  "type": "feature",
  "create_time": "2024.03.01",
  "submit_test_time": "2024.03.10",
  "pass_test_time": "2024.03.15",
  "merger_pre_time": "2024.03.18",
  "tester": {
    "name": "zhangsan"
  },
  "answer": {
    "name": "lisi"
  },
  "outlines": [
    {
      "title": "登录模块开发",
      "weekSpend": [16, 24, 16, 8]
    }
  ]
}
```

### 5.2 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 分支名 |
| `type` | string | 是 | 类型：hotfix/feature/optimize/other |
| `create_time` | string | 是 | 创建时间（格式：YYYY.MM.DD） |
| `submit_test_time` | string | 测试阶段必填 | 提测时间 |
| `pass_test_time` | string | 预生产前必填 | 测试通过时间 |
| `merger_pre_time` | string | 发布前必填 | 合入预生产时间 |
| `tester` | object | 提测时必填 | 测试人员信息 |
| `tester.name` | string | 是 | 测试人员姓名 |
| `answer` | object | 否 | 答疑者信息 |
| `outlines` | array | 否 | 工作事项列表 |
| `outlines[].title` | string | 是 | 事项标题 |
| `outlines[].weekSpend` | array | 周报必填 | 各周耗时（小时） |

### 5.3 type 类型说明

| 类型 | 说明 | 场景 |
|------|------|------|
| `hotfix` | 热修复 | 线上紧急问题修复 |
| `feature` | 需求功能 | 产品新功能开发 |
| `optimize` | 技术优化 | 性能优化、重构等 |
| `other` | 其他 | 不属于以上类型的分支 |

---

## 六、典型工作流

### 6.1 提测流程

```bash
# 1. 确保分支信息文件存在
# /path/to/branchInfos/feature_user_login.json

# 2. 检查信息完整性（test1 环境）
sh branchMapFile_checkMap.sh \
  -checkBranchMap "$(cat /path/to/branchInfos/feature_user_login.json)" \
  -pn "test1"

# 3. 添加到汇总文件
sh addBranchMaps_toJsonFile.sh \
  -branchMapsFromDir "/path/to/branchInfos" \
  -branchMapsAddToJsonF "/path/to/branchMaps.json" \
  -branchMapsAddToKey "branch_maps" \
  -requestBranchNamesString "feature/user_login" \
  -checkPropertyInNetwork "test1"

# 4. 生成展示信息
sh get10_branch_self_detail_info.sh \
  -iBranchMap "$(cat /path/to/branchInfos/feature_user_login.json)" \
  -showFlag "true" \
  -showName "true" \
  -showTime "all" \
  -showAt "true"
```

### 6.2 周报生成流程

```bash
# 1. 批量生成各分支信息
sh get20_branchMapsInfo_byHisJsonFile.sh \
  -branchMapsInJsonF "/path/to/branchMaps.json" \
  -branchMapsInKey ".branch_maps" \
  -showFlag "true" \
  -showName "true" \
  -showTime "only_last" \
  -shouldMD "true" \
  -resultSaveToJsonF "/path/to/output.json" \
  -resultBranchKey "branches" \
  -resultCategoryKey "category"

# 2. 查看分类后的信息
cat /path/to/output.json | jq '.category'
```

---

## 七、常见问题

### Q1: 提示 "获取分支创建的时间失败"

**原因：** 本地不存在该分支

**解决：** 使用远程分支名（带 `origin/` 前缀）或先执行 `git fetch`

### Q2: 提示 "缺失提测时间 submit_test_time"

**原因：** 分支 JSON 中缺少 `submit_test_time` 字段

**解决：** 在对应的 JSON 文件中添加 `submit_test_time` 字段

### Q3: 时间格式不正确

**原因：** `create_time` 必须是 `YYYY.MM.DD` 或 `MM.DD` 格式

**解决：** 修改 JSON 文件中的时间格式

---

## 五、快速命令 (branch_quickcmd)

独立快捷命令脚本集。

### 5.1 目录结构

```
branch_quickcmd/
├── getBranchMapsInfoAndNotifiction.sh           # 发送分支信息通知
├── getBranchNames_accordingToRebaseBranch.sh    # 根据 rebase 分支获取分支名
└── example/                                    # 示例
    ├── example_getBranchMapsInfoAndNotifiction.sh
    ├── example_getBranchNames_accordingToRebaseBranch.sh
    └── data/
```

### 5.2 调用关系

#### 5.2.1 调用关系图

```
getBranchMapsInfoAndNotifiction.sh              ← 主入口：整合信息并发送通知
    ├── branchMaps_20_info/
    │   └── get20_branchMapsInfo_byHisJsonFile.sh   ← 整理分支信息
    │       ├── get10_branch_self_detail_info.sh      ← 获取单个分支信息
    │       │   └── get10_branch_self_detail_info_outline.sh  ← outlines 描述
    │       │       └── get10_branch_self_detail_info_outline_spend.sh  ← 耗时
    │       └── get11_category_all_detail_info.sh     ← 分类整理
    ├── notification/
    │   └── notification2wechat.sh              ← 错误通知
    └── notification/
        └── notification_strings_to_wechat.sh    ← 成功通知

getBranchNames_accordingToRebaseBranch.sh    ← 独立，不调用其他脚本
```

#### 5.2.2 调用关系示例

以主入口 `getBranchMapsInfoAndNotifiction.sh` 为例，说明其执行流程：

```
getBranchMapsInfoAndNotifiction.sh 的执行流程
│
├── 1. 读取分支信息 JSON 文件
│   └── 输入: branchMapsInJsonF 指定文件
│
├── 2. 调用 get20_branchMapsInfo_byHisJsonFile.sh 整理信息
│   ├── get10_branch_self_detail_info.sh      ← 生成单条分支信息
│   │   ├── 状态标记：🏃/❓/👌🏻/✅
│   │   ├── 分支名
│   │   ├── 时间线
│   │   ├── @人员
│   │   └── outlines 描述
│   │       ├── get10_branch_self_detail_info_outline.sh
│   │       │   ├── 编号：①
│   │       │   ├── 标题
│   │       │   ├── 链接
│   │       │   └── 耗时
│   │       │       └── get10_branch_self_detail_info_outline_spend.sh
│   │       │
│   │       └── 输出示例："①功能点一[4h]\n②功能点二[12h]"
│   │
│   └── get11_category_all_detail_info.sh    ← 分类整理
│       ├── 按 type 分组 (hotfix/feature/optimize/other)
│       ├── 添加分类标题
│       └── 输出示例：
│           "=======feature=======\n{get10 生成的分支信息}\n..."
│
├── 3. 结果写入原 JSON 文件
│   └── 保存到 branch_info_result.Notification.current 路径下
│       ├── branch: 单个分支信息数组
│       ├── category: 分类后的信息
│       └── full: 完整字符串
│
├── 4. 发送通知
│   ├── 成功时 → notification_strings_to_wechat.sh
│   │   └── 输出 Markdown/Text 格式的分支信息
│   │
│   └── 失败时 → notification2wechat.sh
│       └── 输出错误信息
│
└── 最终输出效果（JSON 文件内容）：
    {
      "branch_info_result": {
        "Notification": {
          "current": {
            "branch": [
              "🏃dev_login_err:[02.09开发中]@test1\n①功能点一[4h]"
            ],
            "category": {
              "feature": ["✅dev_ui:[02.17已合入]@qian\n①UI改版[8h]"],
              "hotfix": ["🏃dev_err:[02.09开发中]@test1\n①功能点一[4h]"]
            },
            "full": {
              "full": ">>>>>>>>您当前打包的分支信息如下(v1.7.2)>>>>>>>>>\n=======feature=======\n✅dev_ui:[02.17已合入]@qian\n①UI改版[8h]\n..."
            }
          }
        }
      }
    }
```

#### 5.2.3 通知发送流程

```
getBranchMapsInfoAndNotifiction.sh
│
├─ 成功路径
│   └─ sh notification_strings_to_wechat.sh
│       ├─ headerText: ">>>>>>>>您当前打包的分支信息如下(xxx)>>>>>>>>>\n"
│       ├─ contentJsonF: 原 JSON 文件
│       ├─ contentJsonKey: branch_info_result.Notification.current.full_slice
│       ├─ robot: 企业微信机器人 URL
│       ├─ at: @ 人员列表
│       └─ msgtype: markdown/text
│
└─ 失败路径
    └─ sh notification2wechat.sh
        ├─ robot: 企业微信机器人 URL
        ├─ content: 错误信息
        ├─ at: @ 人员列表
        └─ msgtype: markdown/text
```

### 5.3 脚本说明

#### 5.3.1 getBranchMapsInfoAndNotifiction.sh - 发送分支信息通知

**功能：** 读取分支信息 JSON，整理后发送到企业微信/钉钉

**参数：**

| 参数 | 说明 |
|------|------|
| `-branchMapsInJsonF` | 分支信息 JSON 文件路径 |
| `-branchMapsInKey` | 分支数组在文件中的 key |
| `-showCategoryName` | 是否显示分类名 |
| `-showFlag` | 是否显示状态标记 |
| `-showName` | 是否显示分支名 |
| `-showTime` | 时间显示方式（all/only_last/none） |
| `-showAt` | 是否显示 @ 人员 |
| `-shouldMD` | 是否使用 Markdown 格式 |
| `-robot` | 机器人 URL |
| `-at` | @ 的人员列表 |

**使用示例：**

```bash
qbase -quick getBranchMapsInfoAndNotifiction \
  -branchMapsInJsonF /path/to/v1.7.2.json \
  -branchMapsInKey online_branches \
  -showCategoryName true \
  -showFlag true \
  -showName true \
  -showTime none \
  -showAt true \
  -shouldMD true \
  -robot https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx \
  -at ["lichaoqian"]
```

#### 5.3.2 getBranchNames_accordingToRebaseBranch.sh - 获取分支名

**功能：** 根据 rebase 分支获取当前分支所含的所有分支名

**参数：**

| 参数 | 说明 |
|------|------|
| `-rebaseBranch` | 必填：要 rebase 的分支名 |
| `-addValue` | 可选：增减的时间秒数（支持正负值） |
| `-onlyName` | 可选：是否只取最后部分（不为 true 时为全名） |

**使用示例：**

```bash
qbase -quick getBranchNamesAccordingToRebaseBranch \
  -rebaseBranch "master" \
  --add-rel_path 1 \
  -onlyName true \
  --verbose
```

### 5.4 测试数据

**输入文件** (`example/example_input_getBranchMapsInfoAndNotifiction.json`)：

```json
{
  "actions": [
    { "id": "-quick", "fixedValue": "getBranchMapsInfoAndNotifiction" },
    { "id": "-branchMapsInJsonF" },
    { "id": "-branchMapsInKey", "fixedValue": "online_branches" },
    { "id": "-showCategoryName", "fixedValue": true },
    { "id": "-showFlag", "fixedValue": true },
    { "id": "-showName", "fixedValue": true },
    { "id": "-showTime", "fixedValue": "none" },
    { "id": "-showAt", "fixedValue": true },
    { "id": "-shouldMD", "fixedValue": true },
    { "id": "-robot", "fixedValue": "https://qyapi.weixin.qq.com/..." },
    { "id": "-at", "fixedValue": "[\"lichaoqian\"]" }
  ]
}
```
