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

# 根据 OS 设置下载 URL 和文件名规则
case "$OS" in
  linux)
    # Linux 资产通常为 kilocode-linux-x64.tar.gz 或 kilocode-linux-arm64.tar.gz
    if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "x64" ]; then
      ARCH_DIR="x64"
    else
      ARCH_DIR="$ARCH"
    fi
    if [ "$TYPE" = "musl" ]; then
      # 如果没有 musl 专用包，可回退到 glibc 版本，这里假设官方提供了 musl 后缀的包
      PKG="kilocode-linux-${ARCH_DIR}-musl.tar.gz"
    else
      PKG="kilocode-linux-${ARCH_DIR}.tar.gz"
    fi
    DOWNLOAD_URL="https://github.com/Kilo-Org/kilocode/releases/download/${VERSION}/${PKG}"
    ;;

  windows)
    # Windows 资产为 kilocode-win32-x64.zip
    PKG="kilocode-win32-x64.zip"
    DOWNLOAD_URL="https://github.com/Kilo-Org/kilocode/releases/download/${VERSION}/${PKG}"
    ;;

  darwin)
    PKG="kilocode-darwin-${ARCH}.tar.gz"
    DOWNLOAD_URL="https://github.com/Kilo-Org/kilocode/releases/download/${VERSION}/${PKG}"
    ;;

  vscode)
    echo "vscode type not supported in portable build"
    exit 1
    ;;

  *)
    echo "Unknown OS: $OS"
    exit 1
    ;;
esac

echo "Downloading: $DOWNLOAD_URL"
curl -fSL --retry 3 "$DOWNLOAD_URL" -o "/tmp/${PKG}"

# 解压并重新打包
WORK_DIR="/tmp/kilocode-portable-${OS}-${ARCH}-${TYPE}"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "Extracting..."
if [[ "$PKG" == *.zip ]]; then
  unzip -q "/tmp/${PKG}" -d "$WORK_DIR"
else
  tar -xzf "/tmp/${PKG}" -C "$WORK_DIR"
fi

# 创建最终压缩包，放在 dist/ 下
OUTPUT_NAME="kilocode-portable-${VERSION}-${OS}-${ARCH}-${TYPE}.tar.gz"
echo "Packaging: $OUTPUT_NAME"
tar -czf "dist/${OUTPUT_NAME}" -C "$WORK_DIR" .

echo "Build complete: dist/$OUTPUT_NAME"
