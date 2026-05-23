#!/bin/bash
set -euo pipefail

PROJECT_NAME="kilo"
OUTPUT_DIR="dist"
TEMP_DIR="tmp"
UPSTREAM_REPO="Kilo‑Org/kilocode"
UPSTREAM_BASE_URL="https://github.com/${UPSTREAM_REPO}/releases/download"

cleanup() { rm -rf "$TEMP_DIR" "$PROJECT_NAME"; }
trap cleanup EXIT

download_file() {
  local url="$1" output="$2"
  echo "🔻 Download: $url"
  wget --progress=bar:force:noscroll -t 3 "$url" -O "$output"
}

# 统一输出文件名（和 opencode‑portable 格式完全一致）
render_filename() {
  local ver="$1" os="$2" arch="$3" typ="$4"
  echo "${PROJECT_NAME}-${ver}-portable-${os}-${arch}-${typ}.tar.gz"
}

# --------------------------
# 1. Linux 构建（精准匹配官方文件名）
# --------------------------
build_linux() {
  local ver="$1" arch="$2" typ="$3"
  local pkg_suffix=""
  case "$typ" in
    normal) pkg_suffix="" ;;
    musl) pkg_suffix="-musl" ;;
    baseline) pkg_suffix="-baseline" ;;
    baseline‑musl) pkg_suffix="-baseline‑musl" ;;
  esac
  local pkg_name="${PROJECT_NAME}-linux-${arch}${pkg_suffix}.tar.gz"
  local out_name=$(render_filename "$ver" "linux" "$arch" "$typ")

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR" "$PROJECT_NAME/bin"
  download_file "${UPSTREAM_BASE_URL}/${ver}/${pkg_name}" "$TEMP_DIR/pkg.tar.gz"
  tar xf "$TEMP_DIR/pkg.tar.gz" -C "$TEMP_DIR"

  local bin=$(find "$TEMP_DIR" -name "$PROJECT_NAME" -type f | head -n1)
  cp "$bin" "$PROJECT_NAME/bin/"
  chmod +x "$PROJECT_NAME/bin/$PROJECT_NAME"

  tar czf "${OUTPUT_DIR}/${out_name}" "$PROJECT_NAME/"
  echo "✅ Linux Built: $out_name"
}

# --------------------------
# 2. Windows 构建
# --------------------------
build_windows() {
  local ver="$1" arch="$2" typ="$3"
  local pkg_suffix=""
  [ "$typ" = "baseline" ] && pkg_suffix="-baseline"
  local pkg_name="${PROJECT_NAME}-windows-${arch}${pkg_suffix}.zip"
  local out_name=$(render_filename "$ver" "windows" "$arch" "$typ")

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR/win"
  download_file "${UPSTREAM_BASE_URL}/${ver}/${pkg_name}" "$TEMP_DIR/win/pkg.zip"
  unzip -q "$TEMP_DIR/win/pkg.zip" -d "$TEMP_DIR/win"

  echo "@echo off
${PROJECT_NAME}.exe %*" > "$TEMP_DIR/win/${PROJECT_NAME}.bat"

  tar czf "${OUTPUT_DIR}/${out_name}" -C "$TEMP_DIR/win" .
  echo "✅ Windows Built: $out_name"
}

# --------------------------
# 3. macOS 构建
# --------------------------
build_darwin() {
  local ver="$1" arch="$2" typ="$3"
  local pkg_suffix=""
  [ "$typ" = "baseline" ] && pkg_suffix="-baseline"
  local pkg_name="${PROJECT_NAME}-darwin-${arch}${pkg_suffix}.zip"
  local out_name=$(render_filename "$ver" "darwin" "$arch" "$typ")

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR/darwin"
  download_file "${UPSTREAM_BASE_URL}/${ver}/${pkg_name}" "$TEMP_DIR/darwin/pkg.zip"
  unzip -q "$TEMP_DIR/darwin/pkg.zip" -d "$TEMP_DIR/darwin"

  tar czf "${OUTPUT_DIR}/${out_name}" -C "$TEMP_DIR/darwin" .
  echo "✅ macOS Built: $out_name"
}

# --------------------------
# 4. VSIX 构建（精准匹配所有8个VSIX）
# --------------------------
build_vscode() {
  local ver="$1" arch="$2" typ="$3"
  local pkg_name="${PROJECT_NAME}-vscode-${typ}-${arch}.vsix"
  local out_name=$(render_filename "$ver" "vscode" "$arch" "$typ")

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR/vsix"
  download_file "${UPSTREAM_BASE_URL}/${ver}/${pkg_name}" "$TEMP_DIR/vsix/${pkg_name}"

  tar czf "${OUTPUT_DIR}/${out_name}" -C "$TEMP_DIR/vsix" "${pkg_name}"
  echo "✅ VSIX Built: $out_name"
}

# --------------------------
# 主入口
# --------------------------
VERSION="$1"
OS="$2"
ARCH="$3"
TYPE="$4"

case "$OS" in
  linux) build_linux "$VERSION" "$ARCH" "$TYPE" ;;
  windows) build_windows "$VERSION" "$ARCH" "$TYPE" ;;
  darwin) build_darwin "$VERSION" "$ARCH" "$TYPE" ;;
  vscode) build_vscode "$VERSION" "$ARCH" "$TYPE" ;;
  *) echo "❌ Invalid OS" && exit 1 ;;
esac
