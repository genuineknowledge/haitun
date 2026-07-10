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

# ==================== 步骤2：下载（多源自动回退） ====================
Write-Host "`n[2/4] 下载 psi-agent..." -ForegroundColor Cyan

$file = "psi-agent-pyinstaller-windows-latest.zip"
$githubUrl = "https://github.com/$Repo/releases/download/$Version/$file"
$zipPath = Join-Path $haitunDir $file

Write-Host "  系统: Windows"
Write-Host "  版本: $Version"
Write-Host "  文件: $file"
Write-Host ""

# 下载源列表（按优先级尝试）
$downloadUrls = @(
    "https://mirror.ghproxy.com/$githubUrl",
    "https://gh-proxy.com/$githubUrl",
    $githubUrl
)

$downloadSuccess = $false

foreach ($url in $downloadUrls) {
    Write-Host "尝试下载源: $url"
    
    # 清理旧文件
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }

    try {
        curl.exe -L --retry 2 --retry-delay 1 --connect-timeout 10 -o "$zipPath" "$url"
        
        # 校验文件大小
        if (Test-Path $zipPath) {
            $fileSize = (Get-Item $zipPath).Length
            if ($fileSize -gt 10MB) {
                $downloadSuccess = $true
                Write-Host "✓ 下载成功" -ForegroundColor Green
                break
            }
        }
    } catch {
        # 继续试下一个
    }
    
    Write-Host "  该源下载失败，尝试下一个..." -ForegroundColor Yellow
}

if (-not $downloadSuccess) {
    Write-Host "`n✗ 所有下载源均失败，请检查网络连接" -ForegroundColor Red
    Write-Host "也可以手动下载后放到 $haitunDir 目录"
    Write-Host "下载地址: $githubUrl"
    exit 1
}

# ==================== 步骤3：解压覆盖 ====================
Write-Host "`n[3/4] 解压覆盖..." -ForegroundColor Cyan

# 先删除旧的可执行文件，确保是全新的
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
