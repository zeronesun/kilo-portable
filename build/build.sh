#!/bin/bash
set -euo pipefail

# 🔥 全部修正为 kilocode
PROJECT_NAME="kilocode"
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
  echo "Download: $url"
  wget -q --tries=3 "$url" -O "$output"
}

# Linux 构建
build_linux() {
  local version="$1" arch="$2" build_type="$3"
  local libc="glibc"
  [ "$build_type" = "musl" ] && libc="musl"

  suffix=""
  [ "$libc" = "musl" ] && suffix="-musl"
  pkg_name="${PROJECT_NAME}-linux-${arch}${suffix}.tar.gz"
  filename="${PROJECT_NAME}-${version}-portable-linux-${libc}-${arch}.tar.gz"

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR" "$PROJECT_NAME/bin"
  download_file "${UPSTREAM_BASE_URL}/${version}/${pkg_name}" "$TEMP_DIR/pkg.tar.gz"
  tar xf "$TEMP_DIR/pkg.tar.gz" -C "$TEMP_DIR"

  bin=$(find "$TEMP_DIR" -name "$PROJECT_NAME" -type f | head -n 1)
  cp "$bin" "$PROJECT_NAME/bin/"
  chmod +x "$PROJECT_NAME/bin/$PROJECT_NAME"

  tar czf "${OUTPUT_DIR}/${filename}" "$PROJECT_NAME/"
  echo "✅ Built: $filename"
}

# Windows 构建
build_windows() {
  local version="$1" arch="$2" runtime="$3"
  filename="${PROJECT_NAME}-${version}-portable-windows-${runtime}-${arch}.tar.gz"
  pkg_name="${PROJECT_NAME}-windows-x64.zip"

  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR/win"
  download_file "${UPSTREAM_BASE_URL}/${version}/${pkg_name}" "$TEMP_DIR/win/pkg.zip"
  unzip -q "$TEMP_DIR/win/pkg.zip" -d "$TEMP_DIR/win"

  echo "@echo off
${PROJECT_NAME}.exe %*" > "$TEMP_DIR/win/${PROJECT_NAME}.bat"

  tar czf "${OUTPUT_DIR}/${filename}" -C "$TEMP_DIR/win" .
  echo "✅ Built: $filename"
}

VERSION="$1"
ARCH="$2"
TYPE="$3"

case "$TYPE" in
  normal|musl) build_linux "$VERSION" "$ARCH" "$TYPE" ;;
  modern) build_windows "$VERSION" "$ARCH" "$TYPE" ;;
  *) exit 1 ;;
esac
