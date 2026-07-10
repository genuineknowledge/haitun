# HaiTun Agent

> [English](README_en.md)

> 🐬 本地 AI 智能体。交流、执行、交付，从你的目标开始。

HaiTun Agent 是真知出品的全场景本地 AI 智能体。你只需要用自然语言说明目标，它可以帮你处理写代码、做设计、写报告、做分析、整理文件、清洗数据、转换格式和批量操作等任务。

它适合希望“直接把任务交给 AI 执行”的用户，也适合想在本地设备上使用开源智能体能力的开发者。

## 🐬 立即开始

### Windows 用户

Windows 用户可以直接下载安装包：

[下载 Windows 版](https://github.com/genuineknowledge/haitun/releases/latest/download/haitun-agent-setup.exe)

支持 Windows 10 / 11 x64，兼容 ARM64。

当然也可以通过终端安装开发者版本：

```bash
irm https://raw.githubusercontent.com/genuineknowledge/haitun/main/static/scripts/install.ps1 | iex
```

安装后打开 HaiTun Agent，用自然语言告诉它你想完成什么，例如：

```text
帮我整理这个文件夹里的资料，并按项目名称分类。
```

```text
帮我把这份表格里的客户信息清洗成统一格式。
```

```text
帮我根据这些材料写一份日报。
```

### macOS / Linux 用户

macOS 和 Linux 用户可以通过终端安装开发者版本：

```bash
curl -fsSL https://raw.githubusercontent.com/genuineknowledge/haitun/main/static/scripts/install.sh | bash
```

安装完成后会自启动 Web 管理面板，下次自己启动可以输入：

```bash
psi-agent gateway
```

需要 Python 3.14+。

## 🐬 HaiTun Agent 能帮你做什么

| 场景 | 可以交给 HaiTun Agent 的任务 |
| --- | --- |
| 文件整理 | 批量重命名、分类、移动、整理项目资料 |
| 数据处理 | 清洗表格、转换格式、提取关键信息 |
| 写作交付 | 写日报、周报、说明文档、总结材料 |
| 代码辅助 | 查看项目、修改代码、运行命令、整理结果 |
| 重复操作 | 把一批相似任务交给智能体连续执行 |

## 核心能力

### 智能任务自动化

HaiTun Agent 可以自动完成文件整理、数据清洗、格式转换、批量操作等重复性工作，减少手动处理流程。

### 本地运行，隐私优先

智能体在本地设备运行。数据默认保留在你的设备本地，不会上传到我们的服务器。代码开源，可以自行审计。

### 长程任务稳定执行

支持长上下文和多步骤复杂任务，适合处理需要连续执行、检查和修正的工作流。

### 持续迭代

HaiTun Agent 会基于执行反馈优化任务策略，并持续适配更多个人和团队工作流。

## 三步完成一个任务

1. 下载并安装 HaiTun Agent
2. 用自然语言描述你想完成的任务
3. 确认执行，查看最终结果

例如：

```text
请读取这个文件夹里的所有会议纪要，整理成一份按项目分类的待办清单。
```

```text
请把这些 Markdown 文档转换成统一格式，并生成目录。
```

```text
请检查这个代码项目的 README，告诉我新用户是否能顺利跑起来。
```

## 运行配置要求

### 最低配置

| 项目 | 要求 |
| --- | --- |
| 操作系统 | Windows 10/11、主流 Linux 发行版、macOS 13+ |
| CPU | 4 核 64 位处理器 |
| 内存 | 8GB RAM |
| 存储空间 | 2GB 可用空间 |
| 显卡 | 集成显卡即可 |
| 网络 | 可稳定访问所选 AI provider |

### 推荐配置

| 项目 | 建议 |
| --- | --- |
| 操作系统 | Windows 11、Ubuntu 24.04+/Debian 13+、macOS 14+ |
| CPU | 6-8 核 64 位处理器 |
| 内存 | 16GB RAM 或更高 |
| 存储空间 | 5GB 以上可用空间，建议 SSD |
| 浏览器 | 推荐现代浏览器并开启硬件加速 |
| 网络 | 低延迟、稳定的网络连接 |

## 常见问题

### 支持哪些操作系统？

目前提供 Windows 10/11 安装包。macOS 和 Linux 用户可以通过 GitHub 仓库使用开发者版本。

### 需要联网吗？

HaiTun Agent 本身在本地运行。部分需要调用在线模型或网络资源的功能会使用网络，其余本地能力可离线运行。

### 我的数据安全吗？

数据默认保留在你的设备本地，不会上传到我们的服务器。

### 如何获取更新？

新版本会发布到 GitHub Releases。下载按钮会指向最新版本，重新下载安装即可。

### 收费吗？

当前免费提供。如有变化，会在产品页和 GitHub 仓库说明。

## 相关链接

- [产品主页](http://www.genuine-knowledge.com/haitun/)
- [产品详情](http://www.genuine-knowledge.com/haitun/detail/)
- [GitHub 仓库](https://github.com/genuineknowledge/psi-agent)
- [历史版本](https://github.com/genuineknowledge/psi-agent/releases)
- [反馈与建议](https://github.com/genuineknowledge/psi-agent/issues)

## 许可

MIT License. 详见 [LICENSE](LICENSE.md)。
