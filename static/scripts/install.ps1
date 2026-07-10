$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ====================== 配置项 ======================
# GitHub Release 最新版永久下载前缀
$BaseUrl = "https://github.com/genuineknowledge/haitun/releases/latest/download"
# Release 中的文件名（必须和你上传的完全一致）
$WindowsPackage = "haitun-agent-setup.exe"
$TemplatePackage = "workspace-template.zip"
# 用户本地安装目录
$InstallDir = Join-Path $env:USERPROFILE ".haitun"
# ===================================================

Write-Host "=== HaiTun Agent 一键安装脚本 ===" -ForegroundColor Cyan

# 1. 检查并创建工作目录
if (-not (Test-Path $InstallDir)) {
    Write-Host "首次安装，正在创建工作目录: $InstallDir"
    New-Item -ItemType Directory -Path $InstallDir | Out-Null

    # 下载工作空间模板
    Write-Host "正在初始化工作空间模板..."
    $TemplateUrl = "$BaseUrl/$TemplatePackage"
    $TempTemplate = Join-Path $env:TEMP "haitun-workspace-template.zip"
    
    try {
        Invoke-WebRequest -Uri $TemplateUrl -OutFile $TempTemplate -UseBasicParsing
        Expand-Archive -Path $TempTemplate -DestinationPath $InstallDir -Force
        Remove-Item $TempTemplate -Force
    }
    catch {
        Write-Host "警告：工作空间模板下载失败，将创建空目录" -ForegroundColor Yellow
    }
}
else {
    Write-Host "检测到已存在 .haitun 目录，保留原有数据，仅更新程序"
}

# 2. 下载Windows安装包
Write-Host "正在下载 Windows 版安装包..."
$PackageUrl = "$BaseUrl/$WindowsPackage"
$ExeSavePath = Join-Path $InstallDir "haitun-agent-setup.exe"

try {
    Invoke-WebRequest -Uri $PackageUrl -OutFile $ExeSavePath -UseBasicParsing
    Write-Host "安装包下载完成" -ForegroundColor Green
}
catch {
    Write-Host "下载失败，请检查网络连接" -ForegroundColor Red
    exit 1
}

# 3. 进入目录并启动安装向导
Write-Host "正在启动 HaiTun Agent 安装向导..."
Set-Location $InstallDir
Start-Process ".\haitun-agent-setup.exe"

Write-Host "安装流程已启动，请按向导完成安装" -ForegroundColor Green