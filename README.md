# Nova Agent 官网

基于 [Hugo](https://gohugo.io/) 的产品介绍 + 下载落地页，托管在 GitHub Pages，安装包下载指向 GitHub Releases。

## 改内容（最常用）

不用懂 Hugo，改这几个文件就够了：

| 想改什么 | 改这个文件 |
|----------|-----------|
| 品牌名、标语、下载仓库、邮箱 | `hugo.yaml` 里的 `params` |
| 功能亮点卡片 | `data/features.yaml` |
| 使用步骤 | `data/steps.yaml` |
| 常见问题 | `data/faq.yaml` |
| 样式 / 配色 | `assets/css/main.css`（顶部 `:root` 是配色变量）|

## 配置下载按钮

在 `hugo.yaml` 把这三项改成你的真实信息：

```yaml
params:
  github:
    owner: "你的GitHub用户名"
    repo: "你的仓库名"
    assetName: "NovaAgent_Setup.exe"   # 你在 Release 里上传的安装包文件名
```

下载按钮会自动指向：
`https://github.com/<owner>/<repo>/releases/latest/download/<assetName>`
只要每次发布的安装包文件名一致，就永远指向最新版，无需改网页。

## 本地预览

```bash
hugo server
```

打开 http://localhost:1313 ，改文件会自动热刷新。

## 部署到 GitHub Pages

1. 把本目录推到一个 GitHub 仓库
2. 仓库 **Settings → Pages → Build and deployment → Source** 选 **GitHub Actions**
3. 之后每次 push 到 `main`，`.github/workflows/deploy.yml` 会自动构建并发布
4. 把 `hugo.yaml` 的 `baseURL` 改成你的实际站点地址

## 安装包从哪来

安装包由你的程序仓库用 Inno Setup + GitHub Actions 编译，发布到该仓库的 Releases。本网站只负责把下载按钮指过去。
