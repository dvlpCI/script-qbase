#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-13 16:31:34
# @FilePath: package/package_remote_version.sh
# @Description: 对指定的 Homebrew 软件包进行远程检查更新
# @Note: 检查更新原理见 [https://dvlproad.github.io/代码管理/库管理/homebrew](https://dvlproad.github.io/%E4%BB%A3%E7%A0%81%E7%AE%A1%E7%90%86/%E5%BA%93%E7%AE%A1%E7%90%86/homebrew)
###

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 -p <包名> [选项]

必需参数:
    -p, --package NAME    指定软件包名称 (例如: qbase)

可选参数:
    -l, --log-file FILE   指定日志文件路径（如果不指定，日志只输出到终端）
    -v, --verbose         显示详细日志信息（包括 INFO 级别）
    -h, --help            显示此帮助信息

说明:
    执行后会先检查本地版本和远程版本，
    若发现新版本会让用户确认是否更新。

核心命令:
    如果你不想使用此脚本，可以直接在终端执行以下命令来手动检查版本：
    
    1. 优先从 version 字段获取版本号：
       curl -s https://raw.githubusercontent.com/<tap_repo>/main/<package>.rb | grep -E '^[[:space:]]*version' | head -1 | sed -E 's/.*"(.*)".*/\1/'
    
    2. 如果 version 字段不存在，则从 url 字段提取版本号：
       curl -s https://raw.githubusercontent.com/<tap_repo>/main/<package>.rb | grep 'url' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
    
    3. 只更新这一个 tap 而不更新其他的命令：
       cd "\$(brew --repository)/Library/Taps/<tap_repo>" && git pull && brew upgrade <package>

输出格式:
    JSON 格式，包含以下字段:
    - status: "update-available" 或 "up-to-date" 或 "error" 或 "updated" 或 "cancelled"
    - package: 包名
    - local_version: 本地版本（可能为 null）
    - remote_version: 远程版本（错误时为 null）
    - has_update: true/false
    - tap_repo: 仓库地址（错误时为 null）
    - error: 错误信息（仅当 status 为 error 时存在）

退出码:
    0: 已是最新版本 或 更新成功 或 取消更新
    1: 发现新版本
    2: 发生错误（包括参数错误）

日志说明:
    - 日志级别: INFO, WARN, ERROR
    - 终端显示: ERROR 显示红色，命令显示紫色
    - 日志文件: 所有级别都记录（如果指定了 --log-file）
    - 详细模式: 需要 -v/--verbose 才会在终端显示 INFO 日志

示例:
    $0 -p qbase                          # 检查版本，发现新版本会提示更新
    $0 -p qbase -v                       # 检查版本并显示详细日志
    $0 -p qbase -l ./check.log           # 检查版本并记录日志到文件
    $0 -p qbase -v -l ./check.log        # 检查版本，显示详细日志并记录到文件
EOF
}

# 颜色定义
if [ -t 1 ] && [ -t 2 ]; then
    # stdout 和 stderr 都是终端，启用颜色
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    PURPLE='\033[0;35m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    PURPLE=''
    NC=''
fi

# --------------------- 日志函数（终端） ---------------------
# 日志相关的初始变量
VERBOSE=false
LOG_FILE=""

# 日志函数（私有）
_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 写入日志文件（所有级别，不带颜色）
    if [ -n "$LOG_FILE" ]; then
        printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE"
    fi
    
    # 终端输出（ERROR/WARN/KEY 级别有默认颜色，INFO 无默认颜色。消息内部可再用其他颜色高亮特定内容）
    case "$level" in
        ERROR)
            printf "${RED}[%s] [%s] %s${NC}\n" "$timestamp" "$level" "$message" >&2
            ;;
        WARN)
            printf "${YELLOW}[%s] [%s] %s${NC}\n" "$timestamp" "$level" "$message" >&2
            ;;
        KEY)
            printf "${GREEN}[%s] [%s] %s${NC}\n" "$timestamp" "$level" "$message" >&2
            ;;
        INFO)
            # INFO 只在 verbose 模式下显示
            if [ "$VERBOSE" = true ]; then
                printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >&2
            fi
            ;;
    esac
}

log_error() { _log "ERROR" "$1"; }
log_warn() { _log "WARN" "$1"; }
log_info() { _log "INFO" "$1"; }
log_key() { _log "KEY" "$1"; }

# --------------------- 耗时操作计时函数 ---------------------
# 耗时操作计时的初始变量
TIMER_PID=""

# Ctrl+C 中断处理
trap 'cleanup_timer; exit 130' INT

# 用法: start_timer "提示信息"; <执行命令>; stop_timer
start_timer() {
    TIMER_MSG="${1:-执行中}"
    printf "  %s" "$TIMER_MSG" >&2
    (
        while true; do
            printf "." >&2
            sleep 1
        done
    ) &
    TIMER_PID=$!
}

stop_timer() {
    if [ -n "$TIMER_PID" ]; then
        kill $TIMER_PID 2>/dev/null
        wait $TIMER_PID 2>/dev/null
    fi
    printf " 完成\n" >&2
}

cleanup_timer() {
    if [ -n "$TIMER_PID" ]; then
        kill $TIMER_PID 2>/dev/null
        wait $TIMER_PID 2>/dev/null
    fi
}


# --------------------- main 相关 ---------------------
# ---------- 1、初始化变量 ----------
PACKAGE_NAME=""

# ---------- 2、核心命令 ----------
# 执行更新命令
do_update() {
    local tap_repo="$1"
    local package_name="$2"
    local tap_path="$(brew --repository)/Library/Taps/$tap_repo"
    
    log_key "开始更新软件包: $package_name"
    log_info "执行命令: cd \"$tap_path\" && git pull && brew upgrade $package_name"
    
    start_timer
    cd "$tap_path" && git pull && brew upgrade "$package_name"
    stop_timer
    
    return $?
}

# ---------- 3.1、具名参数的解析、判断等 ----------
# 解析具名参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--package)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
        log_error "错误: -p/--package 参数缺少值"
        exit 2
            fi
            PACKAGE_NAME="$2"
            shift 2
            ;;
        -l|--log-file)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
        log_error "错误: -l/--log-file 参数缺少值"
        exit 2
            fi
            LOG_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            # 未知参数，立即报错退出
            log_error "错误: 未知参数 '$1'"
            log_error "使用 '$(basename "$0") --help' 查看帮助"
            exit 2
            ;;
    esac
done

# 检查必需参数 -p
if [ -z "$PACKAGE_NAME" ]; then
log_error "错误: 缺少必需参数 -p/--package"
log_error "使用 '$(basename "$0") --help' 查看帮助"
exit 2
fi

# 检查可选参数 -l
if [ -n "$LOG_FILE" ]; then
    LOG_DIR=$(dirname "$LOG_FILE")
    if [ ! -d "$LOG_DIR" ]; then
        log_error "错误: 日志目录不存在: $LOG_DIR"
        log_error "使用 '$(basename "$0") --help' 查看帮助"
        exit 2
    fi
fi

# 输出参数
log_info "========== 脚本开始执行 =========="
log_info "软件包: $PACKAGE_NAME"
log_info "参数: $*"
log_info "日志文件: $LOG_FILE"

# ---------- 3.2、业务逻辑 ----------
log_key "开始检查软件包版本: $PACKAGE_NAME"

# 获取软件包信息
log_info "执行命令: brew info $PACKAGE_NAME"
start_timer "正在获取包信息"
BREW_INFO=$(brew info "$PACKAGE_NAME" 2>/dev/null)
stop_timer

if [ -z "$BREW_INFO" ]; then
    ERROR_MSG="未找到软件包 '$PACKAGE_NAME'，请先安装或检查包名"
    log_error "$ERROR_MSG"
    echo "{\"status\":\"error\",\"error\":\"$ERROR_MSG\",\"package\":\"$PACKAGE_NAME\",\"local_version\":null,\"remote_version\":null,\"has_update\":false,\"tap_repo\":null}"
    exit 2
fi

log_info "brew info 执行成功"

# 提取仓库地址
log_info "从 brew info 提取仓库地址"
TAP_REPO=$(echo "$BREW_INFO" | grep -E '^From:' | head -1 | sed -E 's/.*github\.com\/([^\/]+\/[^\/]+)\/blob.*/\1/')

if [ -z "$TAP_REPO" ]; then
    ERROR_MSG="无法从 brew info 中提取仓库地址，请确保 '$PACKAGE_NAME' 是通过 tap 安装的"
    log_error "$ERROR_MSG"
    log_info "brew info 输出内容:"
    echo "$BREW_INFO" | while IFS= read -r line; do log_info "brew info: $line"; done
    echo "{\"status\":\"error\",\"error\":\"$ERROR_MSG\",\"package\":\"$PACKAGE_NAME\",\"local_version\":null,\"remote_version\":null,\"has_update\":false,\"tap_repo\":null}"
    exit 2
fi

log_info "成功提取仓库地址: $TAP_REPO"

# 获取远程版本
FORMULA="${PACKAGE_NAME}.rb"
FORMULA_URL="https://raw.githubusercontent.com/$TAP_REPO/main/$FORMULA"
log_info "获取远程 formula: $FORMULA_URL"

log_info "尝试从 version 字段获取版本号"
start_timer "正在获取版本"
REMOTE_VERSION=$(curl -s "$FORMULA_URL" | grep -E '^[[:space:]]*version' | head -1 | sed -E 's/.*"(.*)".*/\1/')
stop_timer

if [ -z "$REMOTE_VERSION" ]; then
    log_warn "从 version 字段获取失败，尝试从 url 字段提取版本号"
    start_timer "正在获取版本"
    REMOTE_VERSION=$(curl -s "$FORMULA_URL" | grep -E '^[[:space:]]*url' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    stop_timer
    if [ -n "$REMOTE_VERSION" ]; then
        log_info "从 url 字段成功提取版本号: $REMOTE_VERSION"
    else
        log_error "从 url 字段提取也失败"
    fi
else
    log_info "从 version 字段获取到版本号: $REMOTE_VERSION"
fi

if [ -z "$REMOTE_VERSION" ]; then
    ERROR_MSG="无法获取远程版本，请检查仓库地址或 formula 文件格式"
    log_error "$ERROR_MSG"
    log_error "Formula URL: $FORMULA_URL"
    echo "{\"status\":\"error\",\"error\":\"$ERROR_MSG\",\"package\":\"$PACKAGE_NAME\",\"local_version\":null,\"remote_version\":null,\"has_update\":false,\"tap_repo\":\"$TAP_REPO\"}"
    exit 2
fi

# 获取本地版本
log_info "获取本地版本: brew list --versions $PACKAGE_NAME"
LOCAL_VERSION=$(brew list --versions "$PACKAGE_NAME" 2>/dev/null | awk '{print $2}')

if [ -n "$LOCAL_VERSION" ]; then
    log_key "本地版本: $LOCAL_VERSION"
else
    log_warn "未找到本地版本（软件包可能未安装）"
fi

# 判断是否有更新
HAS_UPDATE=false
UPDATE_ACTION="noneed"  # noneed:无需更新 confirm:确认更新 cancel:取消更新
if [ -n "$LOCAL_VERSION" ] && [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    HAS_UPDATE=true
    log_key "⚠️ 发现新版本: $LOCAL_VERSION -> $REMOTE_VERSION"
    
    # 让用户确认是否更新
    while true; do
        read -r -p "是否确认更新? (yes/no): " confirm_update
        case "$confirm_update" in
            yes|y)
                UPDATE_ACTION="confirm"
                break
                ;;
            no|n)
                UPDATE_ACTION="cancel"
                break
                ;;
            *)
                echo "请输入 yes/y 或 no/n"
                ;;
        esac
    done
elif [ -n "$LOCAL_VERSION" ]; then
    log_key "✅ 已是最新版本: $LOCAL_VERSION"
else
    log_warn "⚠️ 无法比较版本（本地版本不存在）"
fi

# 根据操作类型执行不同逻辑
UPDATE_SUCCESS=false
if [ "$UPDATE_ACTION" = "confirm" ]; then
    log_key "开始执行更新操作..."
    if do_update "$TAP_REPO" "$PACKAGE_NAME"; then
        UPDATE_SUCCESS=true
        log_key "✅ 更新成功！版本已从 $LOCAL_VERSION 更新到 $REMOTE_VERSION"
        
        # 更新成功后，重新获取本地版本确认
        NEW_LOCAL_VERSION=$(brew list --versions "$PACKAGE_NAME" 2>/dev/null | awk '{print $2}')
        if [ -n "$NEW_LOCAL_VERSION" ]; then
            LOCAL_VERSION="$NEW_LOCAL_VERSION"
            log_info "更新后版本验证: $LOCAL_VERSION"
        fi
    else
        log_error "❌ 更新失败"
    fi
elif [ "$UPDATE_ACTION" = "cancel" ]; then
    log_key "已取消更新"
else
    log_key "无需更新"
fi

# 输出 JSON
if [ "$UPDATE_ACTION" = "confirm" ] && [ "$UPDATE_SUCCESS" = true ]; then
    STATUS="updated"
    EXIT_CODE=0
elif [ "$UPDATE_ACTION" = "confirm" ] && [ "$UPDATE_SUCCESS" = false ]; then
    STATUS="error"
    EXIT_CODE=2
elif [ "$UPDATE_ACTION" = "cancel" ]; then
    STATUS="cancelled"
    EXIT_CODE=0
elif [ "$UPDATE_ACTION" = "noneed" ]; then
    STATUS="up-to-date"
    EXIT_CODE=0
else
    STATUS="error"
    EXIT_CODE=2
fi

# 转义 JSON 中的特殊字符
LOCAL_VERSION_ESCAPED=$(echo "$LOCAL_VERSION" | sed 's/"/\\"/g')
REMOTE_VERSION_ESCAPED=$(echo "$REMOTE_VERSION" | sed 's/"/\\"/g')
TAP_REPO_ESCAPED=$(echo "$TAP_REPO" | sed 's/"/\\"/g')

cat << EOF
{
  "status": "$STATUS",
  "package": "$PACKAGE_NAME",
  "local_version": "${LOCAL_VERSION_ESCAPED:-null}",
  "remote_version": "$REMOTE_VERSION_ESCAPED",
  "has_update": $HAS_UPDATE,
  "tap_repo": "$TAP_REPO_ESCAPED"
}
EOF

log_key "JSON 输出完成，退出码: $EXIT_CODE"
log_key "========== 脚本结束 =========="
exit $EXIT_CODE