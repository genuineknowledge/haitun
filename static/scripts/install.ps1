# ===================== 动作1：创建 .haitun 目录 =====================
$haitunDir = Join-Path $env:USERPROFILE ".haitun"

Write-Host "=== 步骤1/3：检查 .haitun 目录 ===" -ForegroundColor Cyan

if (-not (Test-Path $haitunDir)) {
    Write-Host "目录不存在，正在创建..."
    New-Item -ItemType Directory -Path $haitunDir -Force | Out-Null
    
    # 如果本地有 psi-agent 的 workspace 模板，复制进去
    $workspaceTemplate = ".\examples\haitun-workspace"
    if (Test-Path $workspaceTemplate) {
        Write-Host "复制 workspace 模板..."
        Copy-Item -Path "$workspaceTemplate\*" -Destination $haitunDir -Recurse -Force
    }
} else {
    Write-Host ".haitun 目录已存在，跳过创建"
}

# ===================== 动作2：下载可执行文件 =====================
Write-Host "`n=== 步骤2/3：下载 psi-agent ===" -ForegroundColor Cyan

$downloadUrl = "https://github.com/genuineknowledge/haitun/releases/download/v1.0.1/psi-agent-pyinstaller-windows-latest"
$exePath = Join-Path $haitunDir "psi-agent.exe"

Write-Host "下载地址: $downloadUrl"
Write-Host "保存到: $exePath"
Write-Host "正在下载，请稍候..."

Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing

Write-Host "下载完成！" -ForegroundColor Green

# ===================== 动作3：进入目录并运行 =====================
Write-Host "`n=== 步骤3/3：启动 psi-agent ===" -ForegroundColor Cyan

Set-Location $haitunDir
Write-Host "当前目录: $(Get-Location)"
Write-Host "启动命令: psi-agent.exe workspace"

# 运行
.\psi-agent.exe workspace
