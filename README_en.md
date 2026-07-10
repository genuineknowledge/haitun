# HaiTun Agent

> [简体中文](README.md)

> 🐬 A local AI agent for communication, execution, and delivery—starting from your goals.

HaiTun Agent is an all-scenario local AI agent created by Genuine Knowledge. Simply describe your goal in natural language, and it can help you write code, create designs, prepare reports, perform analysis, organize files, clean data, convert formats, and handle batch operations.

It is designed for users who want to hand tasks directly to AI, as well as developers who want to use open-source agent capabilities on their local devices.

## 🐬 Get Started

### Windows

Windows users can download the installer directly:

[Download for Windows](https://github.com/genuineknowledge/haitun/releases/latest/download/haitun-agent-setup.exe)

Supports Windows 10 / 11 x64 and is compatible with ARM64.

After installation, open HaiTun Agent and describe what you want to accomplish in natural language. For example:

```text
Organize the documents in this folder and group them by project name.
```

```text
Clean the customer information in this spreadsheet and standardize its format.
```

```text
Write a daily report based on these materials.
```

### macOS / Linux

macOS and Linux users can install the developer version from the terminal:

```bash
uv tool install psi-agent
```

After installation, start the web management console:

```bash
psi-agent gateway
```

Python 3.14+ is required.

## 🐬 What HaiTun Agent Can Do

| Scenario | Tasks you can give HaiTun Agent |
| --- | --- |
| File organization | Rename, classify, move, and organize project files in batches |
| Data processing | Clean spreadsheets, convert formats, and extract key information |
| Writing and delivery | Create daily reports, weekly reports, documentation, and summaries |
| Coding assistance | Inspect projects, modify code, run commands, and organize results |
| Repetitive operations | Delegate batches of similar tasks for continuous execution |

## Core Capabilities

### Intelligent Task Automation

HaiTun Agent can automate repetitive work such as file organization, data cleaning, format conversion, and batch operations, reducing manual effort.

### Local Operation, Privacy First

The agent runs on your local device. By default, your data remains on your device and is not uploaded to our servers. The code is open source and can be audited independently.

### Reliable Long-Running Tasks

HaiTun Agent supports long-context and multi-step tasks, making it suitable for workflows that require continuous execution, inspection, and correction.

### Continuous Improvement

HaiTun Agent improves task strategies based on execution feedback and continues to support more personal and team workflows.

## Complete a Task in Three Steps

1. Download and install HaiTun Agent
2. Describe your goal in natural language
3. Confirm execution and review the final result

For example:

```text
Read all meeting notes in this folder and create a project-based action-item list.
```

```text
Convert these Markdown documents to a consistent format and generate a table of contents.
```

```text
Review this project's README and tell me whether a new user can get started successfully.
```

## System Requirements

### Minimum Requirements

| Item | Requirement |
| --- | --- |
| Operating system | Windows 10/11, a mainstream Linux distribution, or macOS 13+ |
| CPU | 4-core 64-bit processor |
| Memory | 8 GB RAM |
| Storage | 2 GB of available space |
| GPU | Integrated graphics are sufficient |
| Network | Stable access to your selected AI provider |

### Recommended Requirements

| Item | Recommendation |
| --- | --- |
| Operating system | Windows 11, Ubuntu 24.04+/Debian 13+, or macOS 14+ |
| CPU | 6-8 core 64-bit processor |
| Memory | 16 GB RAM or more |
| Storage | At least 5 GB of available space; SSD recommended |
| Browser | A modern browser with hardware acceleration enabled |
| Network | A stable, low-latency connection |

## Frequently Asked Questions

### Which operating systems are supported?

A Windows 10/11 installer is currently available. macOS and Linux users can use the developer version through the GitHub repository.

### Is an internet connection required?

HaiTun Agent itself runs locally. Features that call online models or network resources require an internet connection; other local capabilities can run offline.

### Is my data safe?

By default, your data remains on your local device and is not uploaded to our servers.

### How do I get updates?

New versions are published through GitHub Releases. The download button points to the latest version, which you can download and reinstall.

### Is HaiTun Agent free?

HaiTun Agent is currently available free of charge. Any changes will be announced on the product page and in the GitHub repository.

## Related Links

- [Product Home](http://www.genuine-knowledge.com/haitun/)
- [Product Details](http://www.genuine-knowledge.com/haitun/detail/)
- [GitHub Repository](https://github.com/genuineknowledge/psi-agent)
- [Release History](https://github.com/genuineknowledge/psi-agent/releases)
- [Feedback and Suggestions](https://github.com/genuineknowledge/psi-agent/issues)

## License

MIT License. See [LICENSE](LICENSE.md) for details.
