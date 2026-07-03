# Haitun Agent 官网

基于 Hugo 构建的产品官方落地页，托管于 GitHub Pages，为 Haitun Agent 本地 AI 助手提供产品介绍、功能说明、配置指引与安装包下载入口。

## 项目简介
Haitun Agent 是一款运行在本地的智能体，致力于自动化处理日常重复性工作，让用户专注于核心事务。本仓库为其官方网站源码，采用静态站点架构，支持明暗双主题切换，响应式适配全终端，部署流程自动化。

## 技术栈
- **站点框架**：Hugo Extended（静态站点生成器）
- **部署方式**：GitHub Actions + GitHub Pages
- **样式方案**：原生 CSS + CSS 变量，支持主题切换
- **内容管理**：YAML 数据驱动，无需修改模板即可更新文案

## 目录结构
haitun/
├── .github/workflows/deploy.yml # 自动部署工作流
├── archetypes/ # 内容模板
├── assets/css/main.css # 全局样式与主题变量
├── data/ # 页面内容数据
│ ├── features.yaml # 核心能力板块
│ ├── steps.yaml # 使用步骤板块
│ ├── faq.yaml # 常见问题板块
│ └── requirements.yaml # 运行配置要求
├── layouts/ # 页面模板
│ └── _default/
│ ├── baseof.html # 全局基础模板
│ └── index.html # 首页模板
├── static/ # 静态资源（图标、Logo）
├── hugo.yaml # 站点全局配置
└── README.md

## 快速开始

### 本地预览
1. 安装 Hugo Extended 版本（建议 v0.163.0 及以上）
2. 克隆仓库到本地
3. 项目根目录执行命令：
   ```bash
   hugo server
4. 浏览器访问 http://localhost:1313/haitun/ 即可预览，修改文件自动热刷新

### 内容修改指南
无需了解 Hugo 语法，修改对应数据文件即可更新页面内容：
需修改内容及对应文件
品牌名称、宣传标语、GitHub 仓库、联系邮箱：hugo.yaml 中 params 字段
核心能力卡片文案与图标：data/features.yaml
使用步骤说明：data/steps.yaml
常见问题与解答：data/faq.yaml
运行配置档位：data/requirements.yaml
主题配色、样式、动效：assets/css/main.css（顶部 :root 为全局颜色变量）

### 下载按钮配置
在 hugo.yaml 的 params.github 中配置以下三项，下载按钮会自动拼接最新版下载地址：
params:
  github:
    owner: "genuineknowledge"     # GitHub 组织/用户名
    repo: "haitun"                # 仓库名称
    assetName: "HaitunAgent_Setup.exe"  # Releases 中安装包的文件名

## 部署说明
本项目通过 GitHub Actions 自动构建并部署到 GitHub Pages：

1. 仓库 Settings → Pages → Build and deployment → Source 选择 GitHub Actions
2. 向 main 分支推送代码后，.github/workflows/deploy.yml 将自动触发构建与部署
3. 部署完成后站点自动更新，可在 Actions 面板查看部署状态与日志
   



## 相关仓库
Haitun Agent 主程序仓库：genuineknowledge/haitun
安装包通过主仓库的 GitHub Actions 编译构建，发布至 Releases

## 许可证
© 2026 合肥真知人工智能应用软件有限公司



