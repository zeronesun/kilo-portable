### ✅ 文件 1：`README.md`

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Kilo Portable</h3>
  <p align="center">
    自动同步官方最新版本 · 开箱即用的便携版 Kilo
    <br />
    <a href="https://github.com/zeronesun/kilo-portable/releases"><strong>📦 前往下载 »</strong></a>
    <br />
    <br />
    <a href="https://github.com/zeronesun/kilo-portable/issues">报告 Bug</a>
    ·
    <a href="https://github.com/Kilo-Org/kilocode">官方 Kilo 项目</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>目录</summary>
  <ol>
    <li><a href="#项目简介">项目简介</a></li>
    <li><a href="#覆盖平台">覆盖平台</a></li>
    <li><a href="#快速开始">快速开始</a></li>
    <li><a href="#自动同步">自动同步</a></li>
    <li><a href="#从源码构建">从源码构建</a></li>
    <li><a href="#致谢">致谢</a></li>
    <li><a href="#许可证">许可证</a></li>
  </ol>
</details>

---

## 项目简介

本项目每小时自动检测 [Kilo 官方 Release](https://github.com/Kilo-Org/kilocode/releases) 的最新版本（含预发布版），下载官方已编译好的二进制包，重新打包为标准的 `.tar.gz` 便携版。所有构建产物均**自包含运行环境**，无需额外安装 Node.js 或 Bun，解压后即可直接在终端中使用。

> **为什么选择便携版？**  
> - 不需要系统级安装，不污染系统环境  
> - 可以放在 U 盘、移动硬盘或任意目录，随时运行  
> - 方便多版本共存和快速切换

---

## 覆盖平台

| 操作系统 | 架构 | 变体 / 说明 |
| :--- | :--- | :--- |
| Linux | x64 | `normal` (glibc) / `musl` / `baseline` (兼容旧CPU) / `baseline-musl` |
| Linux | arm64 | `normal` (glibc) / `musl` |
| Windows | x64 | `modern` (新硬件) / `legacy` (baseline) |
| Windows | arm64 | `modern` |
| macOS | arm64 | `modern` (Apple Silicon) |
| macOS | x64 | `modern` (Intel) |

> 所有组合均由官方 Release 资产直接映射，确保 100% 一致性。

---

## 快速开始

1. 从 [Releases 页面](https://github.com/zeronesun/kilo-portable/releases) 下载适合你系统的压缩包，例如：
   ```
   kilocode-portable-v7.3.8-linux-x64.tar.gz
   ```
2. 解压：
   ```bash
   tar -xzf kilocode-portable-v7.3.8-linux-x64.tar.gz
   ```
3. 进入目录并运行：
   ```bash
   cd kilocode-portable-v7.3.8-linux-x64
   ./kilo
   ```
   对于 Windows 用户，直接运行解压后的 `.exe` 文件即可。

---

## 自动同步

本项目使用 GitHub Actions 实现完全自动化：

- **触发方式**  
  - 定时触发：每半小时执行一次（`*/30 * * * *`）  
  - 手动触发：支持 `workflow_dispatch`，可在 Actions 页面一键运行

- **流程说明**  
  1. 获取 Kilo 官方最新版本号（包含 Pre-release）  
  2. 根据矩阵同时构建 Linux / Windows / macOS 全部分版  
  3. 所有构建产物上传为 Artifact  
  4. 合并产物，创建或更新 Release，自动上传所有便携版包

- **发布策略**  
  每次构建成功后，会生成一个新的 Release（如 `v7.3.8-portable`），旧版本会被覆盖更新，确保 Release 页面始终保持最新。

---

## 从源码构建

如果你希望自行构建，可以 Fork 本仓库并使用 GitHub Actions 运行，或本地执行构建脚本。

**前提条件**  
- Linux / macOS / Windows (Git Bash)  
- 已安装 `curl`, `jq`, `tar`, `unzip`（Linux 可用 `apt install`, macOS 用 `brew install`）

**本地构建步骤**  
```bash
git clone https://github.com/zeronesun/kilo-portable.git
cd kilo-portable
chmod +x build/build.sh

# 手动指定版本、操作系统、架构和变体
./build/build.sh v7.3.8 linux x64 normal
```

构建成功后，产物会生成在 `dist/` 目录下。

---

## 致谢

- [Kilo](https://github.com/Kilo-Org/kilocode) - 优秀的 AI 编码助手，本项目的上游项目
- [opencode-portable](https://github.com/zeronesun/opencode-portable) - 提供了便携版自动化构建的思路与模板
- 所有为开源工具贡献代码的开发者们

---

## 许可证

本项目中的工作流文件、构建脚本等原创代码采用 **MIT License** 发布。  
通过本仓库下载的 Kilo 便携版包基于官方构建，其版权和许可证遵循 [Kilo 官方协议](https://github.com/Kilo-Org/kilocode/blob/main/LICENSE)。


