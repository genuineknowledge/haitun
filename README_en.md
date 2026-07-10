# HaiTun Agent

> [简体中文](README.md)

> 🐬 A local AI agent that turns your goals into completed work.

HaiTun Agent is a general-purpose AI agent developed by [Genuine Knowledge](http://www.genuine-knowledge.com/) and designed to run on your local device. Describe your goal in natural language, and it can help you write code, create designs, prepare reports, analyze information, organize files, clean data, convert formats, and automate repetitive operations.

It is built for people who want AI to execute tasks and deliver usable results, as well as developers who want an open-source agent environment on their own hardware.

## 🐬 Get started

### Windows

Download the Windows installer:

[Download HaiTun Agent for Windows](https://github.com/genuineknowledge/haitun/releases/latest/download/haitun-agent-setup.exe)

HaiTun Agent supports Windows 10 and Windows 11 on x64 systems, with ARM64 compatibility.

Developers can alternatively install the command-line build from PowerShell:

```powershell
irm https://raw.githubusercontent.com/genuineknowledge/haitun/main/static/scripts/install.ps1 | iex
```

After installation, open HaiTun Agent and describe the result you want. For example:

```text
Organize the documents in this folder and group them by project name.
```

```text
Standardize the customer information in this spreadsheet.
```

```text
Prepare a daily report from these materials.
```

### macOS and Linux

A developer build is available through the terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/genuineknowledge/haitun/main/static/scripts/install.sh | bash
```

The installation script launches the web console automatically. To start it again later, run:

```bash
psi-agent gateway
```

Python 3.14 or later is required.

## 🐬 What HaiTun Agent can do

| Scenario | Example tasks |
| --- | --- |
| File organization | Rename, classify, move, and organize project files in batches |
| Data processing | Clean spreadsheets, convert formats, and extract key information |
| Writing and delivery | Prepare daily reports, weekly reports, documentation, and summaries |
| Coding assistance | Inspect projects, modify code, run commands, and organize results |
| Repetitive operations | Execute batches of similar tasks continuously |

## Core capabilities

### Intelligent task automation

HaiTun Agent automates repetitive work such as file organization, data cleaning, format conversion, and batch operations, reducing manual effort.

### Local execution and privacy

The agent runs on your local device. By default, your project data remains on your device and is not uploaded to Genuine Knowledge servers. The code is open source and can be independently audited.

### Reliable multi-step execution

HaiTun Agent supports long-context and multi-step tasks that require continuous execution, inspection, and correction.

### Continuous improvement

HaiTun Agent refines task strategies based on execution feedback and continues to support more personal and team workflows.

## Complete your first task in three steps

1. Download and install HaiTun Agent
2. Describe your goal in natural language
3. Confirm execution and review the result

For example:

```text
Read every meeting note in this folder and create an action-item list organized by project.
```

```text
Convert these Markdown documents to a consistent format and generate a table of contents.
```

```text
Review this project's README and determine whether a new user can get started successfully.
```

## System requirements

### Minimum requirements

| Item | Requirement |
| --- | --- |
| Operating system | Windows 10/11, a mainstream Linux distribution, or macOS 13 or later |
| CPU | 4-core, 64-bit processor |
| Memory | 8 GB RAM |
| Storage | 2 GB of available space |
| GPU | Integrated graphics |
| Network | Stable access to the selected AI provider |

### Recommended configuration

| Item | Recommendation |
| --- | --- |
| Operating system | Windows 11, Ubuntu 24.04 or later, Debian 13 or later, or macOS 14 or later |
| CPU | 6-8 core, 64-bit processor |
| Memory | 16 GB RAM or more |
| Storage | At least 5 GB of available space; SSD recommended |
| Browser | A modern browser with hardware acceleration enabled |
| Network | A stable, low-latency connection |

## Frequently asked questions

### Which operating systems are supported?

A Windows 10/11 installer is available. Developers on macOS and Linux can install the command-line build from the terminal.

### Is an internet connection required?

HaiTun Agent runs locally. Features that use online models or network resources require an internet connection; tasks that rely solely on local capabilities can run offline.

### How is my data handled?

By default, HaiTun Agent keeps project data on your local device and does not upload it to Genuine Knowledge servers. Features that use an online AI provider may send the information required to complete a request to that provider.

### How do I get updates?

New versions are published through GitHub Releases. The Windows download link always points to the latest release.

### Is HaiTun Agent free?

HaiTun Agent is currently available at no charge. Third-party AI providers may charge for model usage. Any changes to HaiTun Agent pricing will be announced on the product website and in this repository.

## Related links

- [Product website](http://www.genuine-knowledge.com/haitun/)
- [Product details](http://www.genuine-knowledge.com/haitun/detail/)
- [Source code](https://github.com/genuineknowledge/psi-agent)
- [Release history](https://github.com/genuineknowledge/haitun/releases)
- [Feedback and suggestions](https://github.com/genuineknowledge/psi-agent/issues)

## License

HaiTun Agent is available under the [MIT License](LICENSE.md).
