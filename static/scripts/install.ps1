$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# GitHub Release 下载地址
$BaseUrl = "https://github.com/genuineknowledge/haitun/releases/latest/download"
$WindowsPackage = "haitun-agent-setup.exe"
$TemplatePackage = "workspace-template.zip"
$InstallDir = Join-Path $env:USERPROFILE ".haitun"

Write-Host "=== HaiTun Agent 一键安装脚本 ===" -ForegroundColor Cyan

# 初始化工作目录
if (-not (Test-Path $InstallDir)) {
    Write-Host "首次安装，创建工作目录: $InstallDir"
    New-Item -ItemType Directory -Path $InstallDir | Out-Null

    Write-Host "正在下载工作空间模板..."
    $TemplateUrl = "$BaseUrl/$TemplatePackage"
    $TempTemplate = Join-Path $env:TEMP "haitun-workspace-template.zip"
    try {
        Invoke-WebRequest -Uri $TemplateUrl -OutFile $TempTemplate -UseBasicParsing
        Expand-Archive -Path $TempTemplate -DestinationPath $InstallDir -Force
        Remove-Item $TempTemplate -Force
    }
    catch {
        Write-Host "警告：模板下载失败，将使用空目录" -ForegroundColor Yellow
    }
}
else {
    Write-Host "已存在 .haitun 目录，仅更新程序文件"
}

# 下载Windows安装包
Write-Host "正在下载 Windows 安装包..."
$PackageUrl = "$BaseUrl/$WindowsPackage"
$ExeSavePath = Join-Path $InstallDir "haitun-agent-setup.exe"
try {
    Invoke-WebRequest -Uri $PackageUrl -OutFile $ExeSavePath -UseBasicParsing
    Write-Host "安装包下载完成" -ForegroundColor Green
}
catch {
    Write-Host "安装包下载失败，请检查网络" -ForegroundColor Red
    exit 1
}

# 启动安装程序
Write-Host "启动 HaiTun 安装向导"
Set-Location $InstallDir
Start-Process ".\haitun-agent-setup.exe"
Write-Host "安装窗口已弹出，请完成向导安装" -ForegroundColor Green
