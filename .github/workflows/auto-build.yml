#!/bin/bash
set -euo pipefail

PROJECT_NAME="kiloco"
OUTPUT_DIR="dist"
TEMP_DIR="tmp"
UPSTREAM_REPO="Kilo-Org/kiloco"
UPSTREAM_BASE_URL="https://github.com/${UPSTREAM_REPO}/releases/download"

cleanup() {
  rm -rf "$TEMP_DIR" "$PROJECT_NAME"
}
trap cleanup EXIT

download_file() {
  local url="$1"
  local output="$2"
  echo "Download: $url"
  wget --progress=bar:force:noscroll -t 3 "$url" -O "$output"
}

render_filename() {
  local v="$1" os="$2" type="$3" arch="$4"
  echo "${PROJECT_NAME}-${v}-portable-${os}-${type}-${arch}.tar.gz"
}

build_linux() {
  local version="$1" arch="$2" build_type="$3"
  local libc="glibc"
  [ "$build_type" = "musl" ] && libc="musl"

  local filename=$(render_filename "$version" "linux" "$libc" "$arch")
  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR" "$PROJECT_NAME/bin"

  download_file "${UPSTREAM_BASE_URL}/${version}/${PROJECT_NAME}-linux-${arch}-${libc}.tar.gz" "$TEMP_DIR/pkg.tar.gz"
  tar xf "$TEMP_DIR/pkg.tar.gz" -C "$TEMP_DIR"

  local bin=$(find "$TEMP_DIR" -name "$PROJECT_NAME" -type f | head -n1)
  cp "$bin" "$PROJECT_NAME/bin/"
  chmod +x "$PROJECT_NAME/bin/$PROJECT_NAME"

  tar czf "${OUTPUT_DIR}/${filename}" "$PROJECT_NAME/"
  echo "Built: $filename"
}

build_windows() {
  local version="$1" arch="$2" runtime="$3"
  local filename=$(render_filename "$version" "windows" "$runtime" "$arch")
  mkdir -p "$OUTPUT_DIR" "$TEMP_DIR/win"

  download_file "${UPSTREAM_BASE_URL}/${version}/${PROJECT_NAME}-windows-x64.zip" "$TEMP_DIR/win/pkg.zip"
  unzip -q "$TEMP_DIR/win/pkg.zip" -d "$TEMP_DIR/win"

  echo "@echo off
${PROJECT_NAME}.exe %*" > "$TEMP_DIR/win/${PROJECT_NAME}.bat"

  tar czf "${OUTPUT_DIR}/${filename}" -C "$TEMP_DIR/win" .
  echo "Built: $filename"
}

VERSION="$1"
ARCH="$2"
TYPE="$3"
[ "$ARCH" = "x86_64" ] && ARCH="x64"

case "$TYPE" in
  normal|musl) build_linux "$VERSION" "$ARCH" "$TYPE" ;;
  modern|legacy) build_windows "$VERSION" "$ARCH" "$TYPE" ;;
  *) echo "Invalid type" && exit 1 ;;
esac
