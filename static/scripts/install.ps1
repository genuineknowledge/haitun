$ErrorActionPreference = "Stop"

# 配置项
$Version = "v1.0.1"
$Repo = "genuineknowledge/haitun"
$haitunDir = Join-Path $env:USERPROFILE ".haitun"
$exePath = Join-Path $haitunDir "psi-agent.exe"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    HaiTun Agent 一键安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ==================== 步骤1：检查目录 ====================
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
Write-Host ""
Write-Host "正在下载，请稍候..."

curl.exe -L --retry 3 --retry-delay 2 -o "$zipPath" "$downloadUrl"

# 校验文件大小
if (Test-Path $zipPath) {
    $fileSize = (Get-Item $zipPath).Length
    if ($fileSize -lt 10MB) {
        Write-Host "✗ 下载文件异常（太小），请检查网络后重试" -ForegroundColor Red
        Remove-Item $zipPath -Force
        exit 1
    }
} else {
    Write-Host "✗ 下载失败" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 下载完成" -ForegroundColor Green

# ==================== 步骤3：解压覆盖 ====================
Write-Host "`n[3/4] 解压覆盖..." -ForegroundColor Cyan

# 先删除旧的可执行文件
if (Test-Path $exePath) {
    Remove-Item $exePath -Force
}

try {
    Expand-Archive -Path $zipPath -DestinationPath $haitunDir -Force
} catch {
    Write-Host "✗ 解压失败，文件可能损坏，请重新运行脚本" -ForegroundColor Red
    Remove-Item $zipPath -Force
    exit 1
}

Remove-Item $zipPath -Force

if (Test-Path $exePath) {
    Write-Host "✓ 解压完成" -ForegroundColor Green
} else {
    Write-Host "✗ 解压后未找到 psi-agent 文件" -ForegroundColor Red
    exit 1
}

# ==================== 步骤4：启动 Gateway ====================
Write-Host "`n[4/4] 启动 Gateway 服务..." -ForegroundColor Cyan
Write-Host "  工作目录: $haitunDir"
Write-Host "  启动命令: psi-agent.exe gateway"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green

Set-Location $haitunDir
& $exePath gateway
