#!/bin/bash
set -euo pipefail

# 关键：仓库是kilocode，二进制文件名是kilo
PROJECT_NAME="kilo"
OUTPUT_DIR="dist"
TEMP_DIR="tmp"
UPSTREAM_REPO="Kilo-Org/kilocode"
UPSTREAM_BASE_URL="https://github.com/${UPSTREAM_REPO}/releases/download"

cleanup() {
  rm -rf "$TEMP_DIR" "$PROJECT_NAME"
}
trap cleanup EXIT

download_file() {
  local url="$1"
  local output="$2"
  echo "🔻 Download: $url"
  wget --progress=bar:force:noscroll -t 3 "$url" -O "$output"
}

# 文件名渲染（和你opencode‑portable格式统一）
render_filename() {
  local version="$1" os="$2" libc="$3" arch="$4"
  echo "${PROJECT_NAME}-${version}-portable-${os}-${libc}-${arch}.tar.gz"
}

# Linux构建（严格匹配官方包名）
build_linux() {
  local version="$1" arch="$2" build_type="$3"
  local libc="glibc"
  [ "$build_type" = "musl" ] && libc="musl"

  local suffix=""
  [ "$libc" = "musl" ] && suffix="-musl"
  local pkg_name="${PROJECT_NAME}-linux-${arch}${suffix}.tar.gz"
  local filename=$(render_filename "$version" "linux" "$libc" "$arch")

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR" "$PROJECT_NAME/bin"
  download_file "${UPSTREAM_BASE_URL}/${version}/${pkg_name}" "$TEMP_DIR/pkg.tar.gz"
  tar xf "$TEMP_DIR/pkg.tar.gz" -C "$TEMP_DIR"

  local bin=$(find "$TEMP_DIR" -name "$PROJECT_NAME" -type f | head -n1)
  cp "$bin" "$PROJECT_NAME/bin/"
  chmod +x "$PROJECT_NAME/bin/$PROJECT_NAME"

  tar czf "${OUTPUT_DIR}/${filename}" "$PROJECT_NAME/"
  echo "✅ Built: $filename"
}

# Windows构建（严格匹配官方kilo‑windows‑x64.zip）
build_windows() {
  local version="$1" arch="$2" runtime="$3"
  local filename=$(render_filename "$version" "windows" "$runtime" "$arch")
  local pkg_name="${PROJECT_NAME}-windows-x64.zip"

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR/win"
  download_file "${UPSTREAM_BASE_URL}/${version}/${pkg_name}" "$TEMP_DIR/win/pkg.zip"
  unzip -q "$TEMP_DIR/win/pkg.zip" -d "$TEMP_DIR/win"

  # 生成一键启动脚本
  echo "@echo off
${PROJECT_NAME}.exe %*" > "$TEMP_DIR/win/${PROJECT_NAME}.bat"

  tar -czf "${OUTPUT_DIR}/${filename}" -C "$TEMP_DIR/win" .
  echo "✅ Built: $filename"
}

# 主入口
VERSION="$1"
ARCH="$2"
TYPE="$3"

case "$TYPE" in
  normal|musl) build_linux "$VERSION" "$ARCH" "$TYPE" ;;
  modern) build_windows "$VERSION" "$ARCH" "$TYPE" ;;
  *) echo "❌ Invalid build type" && exit 1 ;;
esac
