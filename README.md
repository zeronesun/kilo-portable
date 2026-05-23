<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Kilo Portable</h3>
  <p align="center">
    基于官方 Kilo 便携版自动构建项目 · 运行时内置，开箱即用，全平台覆盖
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
    <li><a href="#特性">特性</a></li>
    <li><a href="#覆盖平台">覆盖平台</a></li>
    <li><a href="#快速开始">快速开始</a></li>
    <li><a href="#自动同步">自动同步</a></li>
    <li><a href="#从源码构建">从源码构建</a></li>
    <li><a href="#致谢">致谢</a></li>
    <li><a href="#star-history">Star History</a></li>
    <li><a href="#许可证">许可证</a></li>
  </ol>
</details>

---

## 项目简介

项目自动检测 [Kilo 官方 Release](https://github.com/Kilo-Org/kilocode/releases) 的最新版本（含预发布版），下载官方已编译好的二进制包，重新打包为标准的 `.tar.gz` 便携版。所有构建产物均**自包含运行环境**，无需额外安装 Node.js 或 Bun，解压后即可直接在终端中使用。

> **为什么选择便携版？**  
> - 不需要系统级安装，不污染系统环境  
> - 可以放在 U 盘、移动硬盘或任意目录，随时运行  
> - 方便多版本共存和快速切换

---

## 特性

- **开箱即用**：已内置 Node.js 运行时，无需预先安装任何依赖，解压后直接在终端运行。
- **全平台覆盖**：支持 Linux、Windows、macOS 三大平台，涵盖 x64/arm64、glibc/musl、现代/旧款 CPU 等多种变体。
- **自动同步**：通过 GitHub Actions 每 30 分钟检测官方最新 Release（含 Pre-release），一旦更新立即构建并发布。
- **纯净打包**：仅重新封装为标准的 `.tar.gz` 格式，不修改程序本身，保留官方全部功能。
- **轻量便携**：单个压缩包，可放在任意目录，随时使用。

---

## 覆盖平台

| 操作系统 | 架构 | 变体 / 说明 |
| :--- | :--- | :--- |
| Linux | x86_64 | `normal` (glibc) / `musl` / `baseline` (兼容旧CPU) / `baseline-musl` |
| Linux | arm64 | `normal` (glibc) / `musl` |
| Windows | x64 | `modern` (新硬件) / `legacy` (baseline) |
| Windows | arm64 | `modern` |
| macOS | arm64 | `modern` (Apple Silicon) |
| macOS | x64 | `modern` (Intel) |

> 所有组合均由官方 Release 资产直接映射，确保 100% 一致性。

### 下载文件名对照

前往 [Releases 页面](https://github.com/zeronesun/kilo-portable/releases) 下载对应你系统的压缩包，文件名示例如下：

| 平台 | 架构 | 变体 | 文件名示例 |
|------|------|------|------------|
| Linux | x86_64 | normal | `kilocode-portable-vX.Y.Z-linux-x86_64-normal.tar.gz` |
| Linux | x86_64 | musl | `kilocode-portable-vX.Y.Z-linux-x86_64-musl.tar.gz` |
| Linux | x86_64 | baseline | `kilocode-portable-vX.Y.Z-linux-x86_64-baseline.tar.gz` |
| Linux | x86_64 | baseline-musl | `kilocode-portable-vX.Y.Z-linux-x86_64-baseline-musl.tar.gz` |
| Linux | arm64 | normal | `kilocode-portable-vX.Y.Z-linux-arm64-normal.tar.gz` |
| Linux | arm64 | musl | `kilocode-portable-vX.Y.Z-linux-arm64-musl.tar.gz` |
| Windows | x64 | modern | `kilocode-portable-vX.Y.Z-windows-x64-modern.tar.gz` |
| Windows | x64 | legacy | `kilocode-portable-vX.Y.Z-windows-x64-legacy.tar.gz` |
| Windows | arm64 | modern | `kilocode-portable-vX.Y.Z-windows-arm64-modern.tar.gz` |
| macOS | arm64 | modern | `kilocode-portable-vX.Y.Z-darwin-arm64-modern.tar.gz` |
| macOS | x64 | modern | `kilocode-portable-vX.Y.Z-darwin-x64-modern.tar.gz` |

> **注意**：  
> - `normal` = 现代 CPU（支持 AVX），`legacy` / `baseline` = 旧款 CPU（不支持 AVX）  
> - `musl` = 适用于 Alpine Linux 等 musl libc 环境

---

## 快速开始

1. 从 [Releases 页面](https://github.com/zeronesun/kilo-portable/releases) 下载适合你系统的压缩包，例如 `kilocode-portable-vX.Y.Z-linux-x86_64.tar.gz`。
2. 解压：
   ```bash
   tar -xzf kilocode-portable-vX.Y.Z-linux-x86_64.tar.gz
   ```
3. 进入目录并运行：
   ```bash
   cd kilocode-portable-vX.Y.Z-linux-x86_64
   ./kilo
   ```
4. （可选）将目录加入 `PATH` 或创建符号链接以便全局调用。

> 对于 Windows 用户，直接运行解压后的 `.exe` 文件即可。

---

## 自动同步

本项目使用 GitHub Actions 实现完全自动化：

- **触发方式**  
  - 定时触发：每 30 分钟执行一次（`*/30 * * * *`）  
  - 手动触发：支持 `workflow_dispatch`，可在 Actions 页面一键运行

- **流程说明**  
  1. 调用 GitHub API 获取 `Kilo-Org/kilocode` 的最新版本号（包含 Pre-release）。  
  2. 根据矩阵配置下载对应平台的官方二进制包。  
  3. 解包后重新打包为统一的 `.tar.gz`。  
  4. 将产物上传为 Artifact，合并后发布为 GitHub Release。

- **发布策略**  
  每次构建成功后，会生成一个新的 Release（如 `vX.Y.Z-portable`），旧版本会被覆盖更新，确保 Release 页面始终保持最新。

你可以在仓库根目录的 `.github/workflows/auto-build.yml` 中查看并修改定时设置。

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
./build/build.sh v7.3.8 linux x86_64 normal
```

构建成功后，产物会生成在 `dist/` 目录下。

---

## 致谢

- [Kilo](https://github.com/Kilo-Org/kilocode) - 出色的 AI 编码助手，本项目的上游项目
- [opencode-portable](https://github.com/zeronesun/opencode-portable) - 为本项目提供了便携版自动化构建的思路与模板
- 所有为开源工具贡献代码的开发者们

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=zeronesun/kilo-portable&type=Date)](https://star-history.com/#zeronesun/kilo-portable&Date)

---

## 许可证

本项目中的工作流文件、构建脚本等原创代码采用 **MIT License** 发布。  
通过本仓库下载的 Kilo 便携版包基于官方构建，其版权和许可证遵循 [Kilo 官方协议](https://github.com/Kilo-Org/kilocode/blob/main/LICENSE)。

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/zeronesun/kilo-portable.svg?style=for-the-badge
[contributors-url]: https://github.com/zeronesun/kilo-portable/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/zeronesun/kilo-portable.svg?style=for-the-badge
[forks-url]: https://github.com/zeronesun/kilo-portable/network/members
[stars-shield]: https://img.shields.io/github/stars/zeronesun/kilo-portable.svg?style=for-the-badge
[stars-url]: https://github.com/zeronesun/kilo-portable/stargazers
[issues-shield]: https://img.shields.io/github/issues/zeronesun/kilo-portable.svg?style=for-the-badge
[issues-url]: https://github.com/zeronesun/kilo-portable/issues
[license-shield]: https://img.shields.io/github/license/zeronesun/kilo-portable.svg?style=for-the-badge
[license-url]: https://github.com/zeronesun/kilo-portable/blob/master/LICENSE
