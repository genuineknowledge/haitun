<#
.SYNOPSIS
HaiTun psi-agent Windows 一键安装脚本
.DESCRIPTION
自动下载、解压、配置环境、创建快捷方式，安装完成后直接进入 REPL 对话模式
#>
# ========== 全局强制UTF8编码，根治所有终端&curl子进程乱码 ==========
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding
# curl子进程强制UTF8输出，进度条无乱码
$env:CURL_ENCODING = "UTF-8"
$env:CURL_RAW_MODE = "1"

# 全局错误捕获
$ErrorActionPreference = "Stop"

# ====================== 全局配置区（仅此处修改版本/仓库） ======================
$Version = "v1.0.1"
$Repo = "genuineknowledge/haitun"
$BaseInstallDir = Join-Path $env:USERPROFILE ".haitun"
$ExeName = "psi-agent.exe"
$ExeFullPath = Join-Path $BaseInstallDir $ExeName
$DesktopShortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) "HaiTun Gateway.lnk"
$MainZipFileName = "psi-agent-pyinstaller-windows-latest.zip"
$ExamplesZipFileName = "examples-workspace.zip"
$MinValidZipSize = 10 * 1024 * 1024 # 10MB
$TotalStepCount = 6
# ==============================================================================

# 工具函数：统一打印步骤标题
function Write-StepTitle {
    param(
        [int]$StepIndex,
        [string]$StepDesc
    )
    Write-Host "`n[$StepIndex/$TotalStepCount] $StepDesc" -ForegroundColor Cyan
}

# 工具函数：打印成功标记
function Write-Success {
    param([string]$Msg)
    Write-Host "✓ $Msg" -ForegroundColor Green
}

# 工具函数：打印失败并退出
function Write-FailExit {
    param([string]$Msg)
    Write-Host "✗ $Msg" -ForegroundColor Red
    exit 1
}

# 头部横幅
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    HaiTun Agent Windows 一键安装程序" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ==================== 步骤1：前置环境检测 ====================
Write-StepTitle -StepIndex 1 -StepDesc "前置环境校验"
$OSInfo = [Environment]::OSVersion.Version
if ($OSInfo.Major -lt 10) {
    Write-FailExit "仅支持 Windows 10 / Windows 11 系统，当前系统版本过低"
}
$execPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($execPolicy -in "Restricted", "AllSigned") {
    Write-Host "⚠ 提示：PowerShell执行策略受限，若脚本运行失败请执行：" -ForegroundColor Yellow
    Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
}
Write-Success "系统环境校验通过"

# ==================== 步骤2：创建安装目录 ====================
Write-StepTitle -StepIndex 2 -StepDesc "初始化安装目录"
if (-not (Test-Path $BaseInstallDir)) {
    New-Item -ItemType Directory -Path $BaseInstallDir -Force | Out-Null
    Write-Success "已创建安装目录：$BaseInstallDir"
}
else {
    Write-Host "目录已存在，将覆盖更新程序：$BaseInstallDir" -ForegroundColor Yellow
}

# ==================== 步骤3：下载并校验主程序包（国内CDN镜像+超时防卡死） ====================
Write-StepTitle -StepIndex 3 -StepDesc "下载 psi-agent 主程序"
$MainZipPath = Join-Path $BaseInstallDir $MainZipFileName
$MainDownloadUrl = "https://cdn.jsdelivr.net/gh/$Repo@$Version/$MainZipFileName"

Write-Host "  系统：Windows | 版本：$Version | 下载文件：$MainZipFileName"
Write-Host "正在下载，网络较慢请耐心等待..."
curl.exe -L --retry 3 --retry-delay 2 --max-time 20 -o "$MainZipPath" "$MainDownloadUrl"

if (-not (Test-Path $MainZipPath)) { Write-FailExit "主程序压缩包下载失败" }
$ZipFileSize = (Get-Item $MainZipPath).Length
if ($ZipFileSize -lt $MinValidZipSize) {
    Remove-Item $MainZipPath -Force -ErrorAction SilentlyContinue
    Write-FailExit "下载文件不完整（体积小于10MB），请切换网络重试"
}
Write-Success "主程序包下载完成"

# ==================== 步骤4：解压主程序 + 自动拉取示例Workspace ====================
Write-StepTitle -StepIndex 4 -StepDesc "解压程序并准备示例工作空间"
if (Test-Path $ExeFullPath) { Remove-Item $ExeFullPath -Force }
try {
    Expand-Archive -Path $MainZipPath -DestinationPath $BaseInstallDir -Force
}
catch {
    Remove-Item $MainZipPath -Force -ErrorAction SilentlyContinue
    Write-FailExit "主程序解压失败，压缩包损坏，请重新运行脚本"
}
Remove-Item $MainZipPath -Force
if (-not (Test-Path $ExeFullPath)) { Write-FailExit "解压后未找到 $ExeName" }

$ExamplesZipPath = Join-Path $BaseInstallDir $ExamplesZipFileName
$ExamplesDownloadUrl = "https://cdn.jsdelivr.net/gh/$Repo@$Version/$ExamplesZipFileName"
Write-Host "正在拉取官方示例Workspace..."
curl.exe -L --retry 3 --retry-delay 2 --max-time 20 -o "$ExamplesZipPath" "$ExamplesDownloadUrl"
if (Test-Path $ExamplesZipPath) {
    Expand-Archive -Path $ExamplesZipPath -DestinationPath $BaseInstallDir -Force
    Remove-Item $ExamplesZipPath -Force
    Write-Success "示例工作空间 examples/ 已就绪"
    $DefaultWorkspace = Join-Path $BaseInstallDir "examples"
    $env:PSI_DEFAULT_WORKSPACE = $DefaultWorkspace
    [Environment]::SetEnvironmentVariable("PSI_DEFAULT_WORKSPACE", $DefaultWorkspace, "User")
    Write-Success "已配置默认Agent工作空间：$DefaultWorkspace"
}
else {
    Write-Host "⚠ 示例工作区下载失败，可在Web控制台手动加载目录" -ForegroundColor Yellow
}
Write-Success "程序解压完成"

# ==================== 步骤5：配置全局PATH + 桌面快捷方式 ====================
Write-StepTitle -StepIndex 5 -StepDesc "配置全局命令与桌面快捷启动"
$UserEnvPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserEnvPath -notmatch [regex]::Escape($BaseInstallDir)) {
    $NewUserPath = "$BaseInstallDir;$UserEnvPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewUserPath, "User")
    Write-Success "已将安装目录加入用户环境变量（新开终端生效）"
}
else {
    Write-Host "PATH已包含安装目录，无需重复添加" -ForegroundColor Yellow
}
if (Test-Path $DesktopShortcutPath) { Remove-Item $DesktopShortcutPath -Force }
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DesktopShortcutPath)
$Shortcut.TargetPath = $ExeFullPath
$Shortcut.WorkingDirectory = $BaseInstallDir
$Shortcut.Arguments = "gateway --browser"
$Shortcut.Description = "HaiTun AI Agent Web管理控制台"
$Shortcut.Save()
Write-Success "桌面一键启动Web控制台快捷方式已创建"

# ==================== 步骤6：生成config并直接进入REPL对话 ====================
Write-StepTitle -StepIndex 6 -StepDesc "准备启动终端对话模式"
Set-Location $BaseInstallDir

# 生成config.yml
$configPath = Join-Path $BaseInstallDir "config.yml"
$workspace = if ($env:PSI_DEFAULT_WORKSPACE) { $env:PSI_DEFAULT_WORKSPACE } else { "." }

$configContent = @"
- type: ai
  session_socket: ./ai.sock
  provider: $($env:PSI_AI_PROVIDER)
  model: $($env:PSI_AI_MODEL)
  api_key: $($env:PSI_AI_API_KEY)
  base_url: $($env:PSI_AI_BASE_URL)
- type: session
  workspace: $workspace
  channel_socket: ./channel.sock
  ai_socket: ./ai.sock
- type: channel
  name: repl
  session_socket: ./channel.sock
"@

# 将空字符串的值替换为注释行，保持YAML合法（空字符串会导致解析错误）
$configContent = $configContent -replace 'provider: \s*$', '# provider:'
$configContent = $configContent -replace 'model: \s*$', '# model:'
$configContent = $configContent -replace 'api_key: \s*$', '# api_key:'
$configContent = $configContent -replace 'base_url: \s*$', '# base_url:'

Set-Content -Path $configPath -Value $configContent -Encoding UTF8

Write-Host "  工作目录：$BaseInstallDir"
Write-Host "  默认Agent工作区：$workspace"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "安装全部完成！正在进入终端对话模式" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
Write-Host "【使用方法】" -ForegroundColor Cyan
Write-Host "1. 输入问题后按 Alt+Enter 发送（或 Escape 再按 Enter）"
Write-Host "2. Ctrl+D 退出对话"
Write-Host "3. 想用 Web 控制台：新开终端执行 psi-agent gateway --browser"
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# 启动 psi-agent run config.yml
& $ExeFullPath run $configPath
