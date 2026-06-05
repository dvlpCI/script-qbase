# 命令执行模式

## 概述

`qbrew_menu.sh` 的 `deal_for_choose()` 根据 JSON 菜单项中的 `execMode` 字段，决定命令在何处以及如何执行：

| `execMode` 值 | 行为 | 是否需权限 |
|---|---|---|
| 其他值（或不设置） | **当前终端直接执行** (`eval`) | ❌ 无 |
| `"edit"` | **当前终端**，zsh vared 编辑后执行 | ❌ 无 |
| `"inNewTabExec"` | 新标签页，**自动执行** | ❌ 无 |
| `"inNewTabEdit"` | 新标签页，**输入命令但不执行**，用户可编辑后按 Enter 执行 | ❌ 无 |

---

## 方式一：`eval`（当前终端执行）

**触发条件**：JSON 菜单项未设置 `execMode`，或值非有效模式。

```bash
eval "${command}"
```

- 在当前终端会话中直接执行
- 命令的所有输出、交互都在当前窗口
- 无权限要求

---

## 方式二：`execute_in_new_terminal_tab`（新标签页自动执行）

**触发条件**：JSON 菜单项中 `"execMode": "inNewTabExec"`。

```bash
execute_in_new_terminal_tab() {
    local command="$1"
    local escaped="${command//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"

    osascript \
        -e 'tell application "Terminal"' \
        -e '    activate' \
        -e '    if (count of windows) is 0 then' \
        -e "        do script \"${escaped}\"" \
        -e '    else' \
        -e "        do script \"${escaped}\" in window 1" \
        -e '    end if' \
        -e 'end tell' > /dev/null
}
```

**原理**：AppleScript 的 `do script` 向 Terminal.app 发送一条命令，**立即执行**。

**特点**：
- 命令在新标签页中自动执行，无等待，无需按 Enter
- 提示符显示命令文本（`% ls`），但命令已执行完毕，无法修改
- 需要转义命令中的 `"` 和 `\`，否则破坏 AppleScript 语法
- **无辅助功能权限要求**

**适用场景**：确定要执行的命令，不需要用户干预。

---

## 方式三：`type_in_new_terminal_tab`（新标签页输入，用户按 Enter 执行）

**触发条件**：JSON 菜单项中 `"execMode": "inNewTabEdit"`。

```bash
type_in_new_terminal_tab() {
    local command="$1"
    local tmpfile
    tmpfile=$(mktemp /tmp/qbase_XXXXXXXX) || return 1
    printf '%s' "$command" > "$tmpfile"

    osascript \
        -e 'tell application "Terminal"' \
        -e '    activate' \
        -e "    set cmd to do shell script \"cat ${tmpfile}; rm ${tmpfile}\"" \
        -e "    set fullCmd to \"printf '\\\\r\\\\e[K'; print -z \" & quoted form of cmd" \
        -e '    if (count of windows) is 0 then' \
        -e '        do script fullCmd' \
        -e '    else' \
        -e '        do script fullCmd in window 1' \
        -e '    end if' \
        -e 'end tell' > /dev/null
}
```

**原理**：
1. 命令写入临时文件，AppleScript 通过 `do shell script` 读取并立即删除
2. `quoted form of cmd` 将命令安全地单引号包裹，避免引号冲突
3. `printf '\r\e[K'` 擦除 `do script` 的回显行（回车到行首 + 清除到行尾）
4. `print -z` 将命令推送到 zsh 的**行编辑器缓冲区**，显示在提示符后

**特点**：
- 提示符显示 `% cd ... && hexo ... "反推"`，**光标在末尾闪烁**
- 用户可以 **← → 移动光标、删除字符、修改命令**，确认后按 Enter 执行
- 想取消则直接删除输入内容即可
- 第一行的 `print -z '...'` 回显被 `printf` 立即擦除，几乎看不到
- **无辅助功能权限要求**
- 需 Terminal 使用 zsh（macOS 默认）

---

## 转义说明

`execute_in_new_terminal_tab()` 由于命令直接嵌入 AppleScript 双引号字符串中，需要手动转义 `"` 和 `\`：

```bash
local escaped="${command//\\/\\\\}"   # \ → \\
escaped="${escaped//\"/\\\"}"         # " → \"
```

例如命令 `cd "My Folder"` 会转义为 `cd \"My Folder\"`，AppleScript 才能正确接收。

`type_in_new_terminal_tab()` 通过临时文件 + `quoted form of cmd` 传递命令，无需手动转义，AppleScript 自动处理单引号包裹。

---

## 对比总表

| 特性 | `eval` | `do script` (execute) | `print -z` (type) |
|---|---|---|---|
| 执行位置 | 当前终端 | 新标签页 | 新标签页 |
| 自动执行 | ✅ 立即 | ✅ 立即 | ❌ 需按 Enter |
| 可编辑命令 | ❌ | ❌ | ✅ |
| 提示符显示 | 仅输出 | `% ls`（执行后） | `% ls`（等待编辑） |
| do script 回显 | — | 可见 | 被 `printf` 擦除 |
| 辅助功能权限 | ❌ | ❌ | ❌ |
| 适用场景 | 快速一次性命令 | 后台任务 | 想确认/修改后再执行 |
