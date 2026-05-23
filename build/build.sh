#!/bin/bash
set -euo pipefail

# ======================================
# 🔧 配置区（仅需修改这里）
# ======================================
PROJECT_NAME="kiloco"
OUTPUT_DIR="dist"
TEMP_DIR="tmp"
UPSTREAM_REPO="Kilo-Org/kiloco"
UPSTREAM_BASE_URL="https://github.com/${UPSTREAM_REPO}/releases/download"

# 运行时版本（Windows用）
BUN_VERSION="latest"
NODE_VERSION="v18.20.4"

# 文件名模板
FILENAME_TEMPLATE="${PROJECT_NAME}-{{VERSION}}-portable-{{OS}}-{{TYPE}}-{{ARCH}}.tar.gz"

# ======================================
# 🛠️ 工具函数
# ======================================
trap 'echo -e "\n❌ 构建失败：第 $LINENO 行出错"; cleanup; exit 1' ERR
cleanup() { rm -rf "$TEMP_DIR" "kiloco"; echo "🧹 清理完成"; }
trap cleanup EXIT

download_file() {
  local url="$1" output="$2" retries=3 delay=5
  echo "🔻 下载: $url"
  for _ in $(seq 1 $retries); do
    if wget --progress=bar:force:noscroll "$url" -O "$output"; then return 0; fi
    sleep $delay
  done
  echo "❌ 下载失败" && exit 1
}

render_filename() {
  local t="$1" v="$2" os="$3" type="$4" arch="$5"
  echo "$t" | sed "s/{{VERSION}}/$v/g" | sed "s/{{OS}}/$os/g" | sed "s/{{TYPE}}/$type/g" | sed "s/{{ARCH}}/$arch/g"
}

# ======================================
# 📦 Linux 构建逻辑
# ======================================
build_linux() {
  local version="$1" arch="$2" build_type="$3"
  local type="glibc"
  [ "$build_type" = "musl" ] && type="musl"

  local url="${UPSTREAM_BASE_URL}/${version}/kiloco-linux-${arch}-${type}.tar.gz"
  local file=$(render_filename "$FILENAME_TEMPLATE" "$version" "linux" "$type" "$arch")

  echo "========================================"
  echo "🐧 构建 Linux $arch $type | $version"
  echo "========================================"

  mkdir -p "$TEMP_DIR" "$OUTPUT_DIR" "kiloco/bin"
  download_file "$url" "$TEMP_DIR/kiloco.tar.gz"
  tar -xzf "$TEMP_DIR/kiloco.tar.gz" -C "$TEMP_DIR"

  local bin=$(find "$TEMP_DIR" -name "kiloco" -type f -print -quit)
  cp "$bin" "kiloco/bin/kiloco"
  chmod +x "kiloco/bin/kiloco"

  tar -czf "${OUTPUT_DIR}/${file}" kiloco/
  echo "✅ 构建完成: $file"
}

# ======================================
# 🪟 Windows 构建逻辑
# ======================================
build_windows() {
  local version="$1" arch="$2" runtime="$3"
  local file=$(render_filename "$FILENAME_TEMPLATE" "$version" "windows" "$runtime" "$arch")

  echo "========================================"
  echo "🪟 构建 Windows $arch $runtime | $version"
  echo "========================================"

  mkdir -p "$TEMP_DIR/win" "$OUTPUT_DIR"
  download_file "${UPSTREAM_BASE_URL}/${version}/kiloco-windows-x64.zip" "$TEMP_DIR/win/kiloco.zip"
  unzip -q "$TEMP_DIR/win/kiloco.zip" -d "$TEMP_DIR/win"

  # 生成启动脚本
  cat > "$TEMP_DIR/win/kiloco.bat" << 'EOF'
@echo off
kiloco.exe %*
EOF

  tar -czf "${OUTPUT_DIR}/${file}" -C "$TEMP_DIR/win" .
  echo "✅ 构建完成: $file"
}

# ======================================
# 🚀 主入口
# ======================================
if [ $# -lt 3 ]; then
  echo "用法: $0 <版本> <架构> <类型>"
  echo "示例: $0 v1.0.0 x64 normal"
  exit 1
fi

VERSION="$1"
ARCH="$2"
TYPE="$3"
[ "$ARCH" = "x86_64" ] && ARCH="x64"

case "$TYPE" in
  normal|musl) build_linux "$VERSION" "$ARCH" "$TYPE" ;;
  modern|legacy) build_windows "$VERSION" "$ARCH" "$TYPE" ;;
  *) echo "❌ 无效类型" && exit 1 ;;
esac

ls -lh "$OUTPUT_DIR"
