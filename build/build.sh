#!/usr/bin/env bash
set -euo pipefail

# 参数顺序：版本 操作系统 架构 类型
VERSION="$1"
OS="$2"
ARCH="$3"
TYPE="$4"

echo "========================================"
echo " Building Kilo Portable"
echo " Version : $VERSION"
echo " OS      : $OS"
echo " Arch    : $ARCH"
echo " Type    : $TYPE"
echo "========================================"

# 创建输出目录
mkdir -p dist

# ---------- 将工作流中的变量映射为官方文件名中的字段 ----------
# 架构映射：x86_64 / x64 -> x64， arm64 -> arm64
case "$ARCH" in
  x86_64|x64) ASSET_ARCH="x64" ;;
  arm64)      ASSET_ARCH="arm64" ;;
  *)          echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

# 操作系统映射（用于文件名前缀）
case "$OS" in
  linux)   ASSET_OS="linux" ;;
  windows) ASSET_OS="windows" ;;
  darwin)  ASSET_OS="darwin" ;;
  *)       echo "Unsupported OS: $OS"; exit 1 ;;
esac

# 根据类型拼接后缀
case "$OS-$TYPE" in
  linux-normal)
    SUFFIX=".tar.gz"
    ;;
  linux-musl)
    SUFFIX="-musl.tar.gz"
    ;;
  linux-baseline)
    SUFFIX="-baseline.tar.gz"
    ;;
  linux-baseline-musl)
    SUFFIX="-baseline-musl.tar.gz"
    ;;
  windows-modern)
    SUFFIX=".zip"
    ;;
  windows-legacy)
    SUFFIX="-baseline.zip"
    ;;
  darwin-*)
    SUFFIX=".zip"
    ;;
  *)
    echo "Unsupported type $TYPE for $OS"
    exit 1
    ;;
esac

PKG="kilo-${ASSET_OS}-${ASSET_ARCH}${SUFFIX}"
DOWNLOAD_URL="https://github.com/Kilo-Org/kilocode/releases/download/${VERSION}/${PKG}"

# ---------- 下载 ----------
echo "Downloading: $DOWNLOAD_URL"
curl -fSL --retry 3 "$DOWNLOAD_URL" -o "/tmp/${PKG}"

# ---------- 解压并重新打包 ----------
WORK_DIR="/tmp/kilocode-portable-${OS}-${ARCH}-${TYPE}"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "Extracting..."
if [[ "$PKG" == *.zip ]]; then
  unzip -q "/tmp/${PKG}" -d "$WORK_DIR"
else
  tar -xzf "/tmp/${PKG}" -C "$WORK_DIR"
fi

OUTPUT_NAME="kilocode-portable-${VERSION}-${OS}-${ARCH}-${TYPE}.tar.gz"
echo "Packaging: $OUTPUT_NAME"
tar -czf "dist/${OUTPUT_NAME}" -C "$WORK_DIR" .

echo "Build complete: dist/$OUTPUT_NAME"
