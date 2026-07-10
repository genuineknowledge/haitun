$ErrorActionPreference = "Stop"

# 配置项
$Version = "v1.0.1"
$Repo = "genuineknowledge/haitun"
$haitunDir = Join-Path $env:USERPROFILE ".haitun"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    HaiTun Agent 一键安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ==================== 步骤1：创建目录 ====================
Write-Host "`n[1/4] 检查安装目录..." -ForegroundColor Cyan

if (-not (Test-Path $haitunDir)) {
    New-Item -ItemType Directory -Path $haitunDir -Force | Out-Null
    Write-Host "✓ 已创建目录: $haitunDir" -ForegroundColor Green
} else {
    Write-Host "目录已存在: $haitunDir" -ForegroundColor Yellow
}

# ==================== 步骤2：下载 ====================
Write-Host "`n[2/4] 下载 psi-agent..." -ForegroundColor Cyan

$file = "psi-agent-pyinstaller-windows-latest.zip"
$downloadUrl = "https://github.com/$Repo/releases/download/$Version/$file"
$zipPath = Join-Path $haitunDir $file

Write-Host "  系统: Windows"
Write-Host "  版本: $Version"
Write-Host "  文件: $file"
Write-Host "  地址: $downloadUrl"
Write-Host ""
Write-Host "正在下载，请稍候..."

Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

if (-not (Test-Path $zipPath)) {
    Write-Host "✗ 下载失败" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 下载完成" -ForegroundColor Green

# ==================== 步骤3：解压 ====================
Write-Host "`n[3/4] 解压文件..." -ForegroundColor Cyan

Expand-Archive -Path $zipPath -DestinationPath $haitunDir -Force

# 删除压缩包
Remove-Item $zipPath -Force

# 检查可执行文件
$exePath = Join-Path $haitunDir "psi-agent.exe"
if (-not (Test-Path $exePath)) {
    $exePath = Join-Path $haitunDir "psi-agent"
}

if (Test-Path $exePath) {
    Write-Host "✓ 解压完成" -ForegroundColor Green
} else {
    Write-Host "✗ 解压后未找到 psi-agent 文件" -ForegroundColor Red
    exit 1
}

# ==================== 步骤4：启动 ====================
Write-Host "`n[4/4] 启动 psi-agent workspace..." -ForegroundColor Cyan
Write-Host "  工作目录: $haitunDir"
Write-Host "  启动命令: psi-agent.exe workspace"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green

Set-Location $haitunDir
& $exePath workspace
