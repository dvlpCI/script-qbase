#!/bin/bash
###
# @Author: dvlproad
# @Date: 2026-05-17
# @Description: 通用项目初始化脚本 — 创建 ~/.{project_name}/ 目录结构并复制示例文件
#   可被任意项目复用，通过 --manifest 指定清单文件
# @Usage:
#   sh qbase_init.sh \
#       --project-name "qbase" \
#       --version "0.9.38" \
#       --manifest "/path/to/init_manifest.json" \
#       [--action only_check] [--force] [--clean]
# @Options:
#   --project-name NAME   指定项目名（决定 ~/.NAME/ 目录）
#   --version VERSION     当前版本号（写入 ~/.NAME/.version）
#   --manifest PATH       清单 JSON 文件路径（决定要创建的目录和复制的示例文件）
#   --action ACTION       执行动作：init（默认）或 only_check
#   --force               覆盖已有文件（自动备份旧文件为 .bak.时间戳）
#   --clean               覆盖不备份（必须搭配 --force）
# @Note:
#   示例文件的 source 是相对于 manifest 所在目录的相对路径。
#   init/ 目录下不再嵌套子目录，示例文件和清单放在同一层。
#   后续若单项目示例文件超过 10 个，可考虑增设 data/ 子目录。
###

BOLD='\033[1m'
NC="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"

log_color_info() { printf "%b\n" "$1" >&2; }
log_error() { log_color_info "${RED}$1${NC}"; }
log_success() { log_color_info "${GREEN}$1${NC}"; }
log_skip() { log_color_info "${YELLOW}$1${NC}"; }
log_info() { log_color_info "${BLUE}$1${NC}"; }

# ---------- 参数解析 ----------
PROJECT_NAME=""
VERSION=""
MANIFEST_PATH=""
ACTION="init"
FORCE=false
CLEAN=false

while [ $# -gt 0 ]; do
    case "$1" in
        --project-name) PROJECT_NAME="$2"; shift 2 ;;
        --version) VERSION="$2"; shift 2 ;;
        --manifest) # 保留 --manifest 而不自动推导的原因：
                     # qbase_init.sh 是通用脚本，可被其他库（如 qtool）调用。
                     # 若自动取脚本所在目录的 init_manifest.json，其他库从 qbase
                     # 路径调用时会找到 qbase 的 manifest 而非自身的。
                     # 因此调用方必须显式传入 --manifest。
                     MANIFEST_PATH="$2"; shift 2 ;;
        --action) ACTION="$2"; shift 2 ;;
        --force) FORCE=true; shift 1 ;;
        --clean) CLEAN=true; shift 1 ;;
        *)
            log_error "未知参数: $1"
            exit 1
            ;;
    esac
done

if [ -z "${PROJECT_NAME}" ]; then
    log_error "Error: --project-name 不能为空"
    exit 1
fi
if [ -z "${VERSION}" ]; then
    log_error "Error: --version 不能为空"
    exit 1
fi
if [ -z "${MANIFEST_PATH}" ]; then
    log_error "Error: --manifest 不能为空"
    exit 1
fi
if [ ! -f "${MANIFEST_PATH}" ]; then
    log_error "Error: manifest 文件不存在: ${MANIFEST_PATH}"
    exit 1
fi
if [ "${CLEAN}" == true ] && [ "${FORCE}" == false ]; then
    log_error "Error: --clean 必须搭配 --force 使用"
    exit 1
fi
if [ "${ACTION}" != "init" ] && [ "${ACTION}" != "only_check" ]; then
    log_error "Error: --action 的值必须是 init 或 only_check，当前值: ${ACTION}"
    exit 1
fi

MANIFEST_DIR="$(cd "$(dirname "${MANIFEST_PATH}")" && pwd)"

# ---------- 路径定义 ----------
PROJECT_USER_DIR="${HOME}/.${PROJECT_NAME}"
VERSION_FILE="${PROJECT_USER_DIR}/.version"

# ========== 函数定义 ==========

precheck() {
    PCH_old_version=""
    if [ -f "${VERSION_FILE}" ]; then
        PCH_old_version=$(cat "${VERSION_FILE}")
    fi

    PCH_version_changed=false
    if [ -n "${PCH_old_version}" ] && [ "${PCH_old_version}" != "${VERSION}" ]; then
        PCH_version_changed=true
    fi

    PCH_user_dir_exists=true
    if [ ! -d "${PROJECT_USER_DIR}" ]; then
        PCH_user_dir_exists=false
    fi

    PCH_missing_dirs=""
    dirs=$(jq -r '.dirs[]' "${MANIFEST_PATH}")
    for dir in $dirs; do
        dir_path="${PROJECT_USER_DIR}/${dir}"
        if [ ! -d "${dir_path}" ]; then
            if [ -z "${PCH_missing_dirs}" ]; then
                PCH_missing_dirs="${dir}"
            else
                PCH_missing_dirs="${PCH_missing_dirs} ${dir}"
            fi
        fi
    done

    PCH_missing_files=""
    examples_count=$(jq '.examples | length' "${MANIFEST_PATH}")
    for ((i = 0; i < examples_count; i++)); do
        source_file=$(jq -r ".examples[${i}].source" "${MANIFEST_PATH}")
        target_subdir=$(jq -r ".examples[${i}].target_subdir" "${MANIFEST_PATH}")
        dest_path="${PROJECT_USER_DIR}/${target_subdir}/${source_file}"
        if [ ! -f "${dest_path}" ]; then
            if [ -z "${PCH_missing_files}" ]; then
                PCH_missing_files="${dest_path}"
            else
                PCH_missing_files="${PCH_missing_files} ${dest_path}"
            fi
        fi
    done
}

report_precheck() {
    has_issue=false

    if [ "${PCH_user_dir_exists}" == false ]; then
        log_info "📂 ${PROJECT_USER_DIR}/ 目录不存在"
        has_issue=true
    fi

    for dir in $PCH_missing_dirs; do
        log_info "📂 ${PROJECT_USER_DIR}/${dir}/ 目录不存在"
        has_issue=true
    done

    if [ -n "${PCH_old_version}" ] && [ "${PCH_version_changed}" == true ]; then
        log_info "📄 .version 版本: ${PCH_old_version}，当前 ${PROJECT_NAME} 版本: ${VERSION}"
        has_issue=true
    fi

    for file_path in $PCH_missing_files; do
        log_info "📄 ${file_path} 不存在"
        has_issue=true
    done

    if [ "${has_issue}" == false ]; then
        log_success "✅ ~/.${PROJECT_NAME}/ 检查通过，一切正常。"
    fi
}

ensure_dirs() {
    local dirs
    dirs=$(jq -r '.dirs[]' "${MANIFEST_PATH}")
    log_success "✅ 已创建 ~/.${PROJECT_NAME}/ 目录："
    for dir in $dirs; do
        mkdir -p "${PROJECT_USER_DIR}/${dir}"
        log_color_info "   · ${PROJECT_USER_DIR}/${dir}/"
    done
}

copy_example_file() {
    local source_file="$1"
    local target_subdir="$2"

    local src_path="${MANIFEST_DIR}/${source_file}"
    if [ ! -f "${src_path}" ]; then
        log_info "⚠️  源文件不存在(可能已移除): ${src_path}"
        return 0
    fi

    local dest_dir="${PROJECT_USER_DIR}/${target_subdir}"
    local dest_path="${dest_dir}/${source_file}"

    if [ -f "${dest_path}" ]; then
        if [ "${FORCE}" == false ]; then
            log_skip "⏭️  跳过 ${source_file}（已存在，使用 --force 可覆盖）"
            return 1
        fi

        if [ "${CLEAN}" == false ]; then
            local timestamp
            timestamp=$(date "+%Y-%m-%d.%H%M%S")
            local bak_path="${dest_path}.bak.${timestamp}"
            cp "${dest_path}" "${bak_path}"
            log_info "📦 旧文件已备份: ${bak_path}"
            # 可打开对照数据结构变化： diff ${bak_path} ${dest_path}
        fi

        cp "${src_path}" "${dest_path}"
        log_success "✅ 已覆盖: ${dest_path}"
    else
        cp "${src_path}" "${dest_path}"
        log_success "✅ 已复制: ${dest_path}"
    fi
    return 0
}

write_version_file() {
    echo "${VERSION}" > "${VERSION_FILE}"
    log_success "✅ 已记录版本: ${VERSION_FILE} → ${VERSION}"
}

# ========== 预检（纯取值，不输出） ==========
precheck

# ========== 分支 ==========
if [ "${ACTION}" == "only_check" ]; then
    report_precheck
    exit 0
fi

log_info "========================================="
log_info "  ${PROJECT_NAME} 初始化"
log_info "========================================="
log_color_info ""

if [ "${PCH_version_changed}" == true ]; then
    log_info "💡 ${PROJECT_NAME} 版本从 ${PCH_old_version} 更新到 ${VERSION}"
fi

if [ "${PCH_user_dir_exists}" == false ]; then
    ensure_dirs
else
    log_info "📂 ~/.${PROJECT_NAME}/ 已存在"
fi

examples_count=$(jq '.examples | length' "${MANIFEST_PATH}")
if [ "${examples_count}" -gt 0 ]; then
    log_color_info ""
    log_info "📋 复制示例文件到 ~/.${PROJECT_NAME}/ 下："
    for ((i = 0; i < examples_count; i++)); do
        source_file=$(jq -r ".examples[${i}].source" "${MANIFEST_PATH}")
        target_subdir=$(jq -r ".examples[${i}].target_subdir" "${MANIFEST_PATH}")
        copy_example_file "${source_file}" "${target_subdir}"
    done
fi

log_color_info ""
# 📝 后续可扩展 init_manifest.json 来声明更多示例文件

write_version_file

log_color_info ""
log_success "✨ ${PROJECT_NAME} 初始化完成！"
