# Kilo Portable

> 非官方 Kilo 便携版（Portable）自动构建仓库

本项目每天（或每半小时）自动从 [Kilo 官方 Release](https://github.com/Kilo-Org/kilocode/releases) 拉取最新版本，重新打包为纯 `.tar.gz` 格式的便携版，方便解压即用，无需安装 Node.js 等运行时环境。

## ✨ 特点

- **自包含**：所有构建包均已内嵌运行环境，开箱即用
- **全平台覆盖**：支持 Linux (x64/arm64, glibc/musl/baseline)、Windows (x64/arm64) 和 macOS (x64/arm64)
- **自动同步**：每隔半小时检查官方更新，发现新版本自动构建发布
- **纯净便携**：直接下载 `.tar.gz`，解压即可在终端中使用 `kilo`

## 📦 下载

请前往本仓库的 [Releases 页面](../../releases) 下载对应你操作系统的压缩包。

## 🚀 使用

1. 下载对应你操作系统和架构的 `kilo-portable-*.tar.gz`
2. 解压：
   ```bash
   tar -xzf kilo-portable-vX.Y.Z-linux-x64.tar.gz
