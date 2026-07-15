<#
.SYNOPSIS
HaiTun psi-agent Windows 一键安装脚本
.DESCRIPTION
自动下载、解压、配置环境、创建快捷方式，启动Gateway并输出完整初始化操作流程
安装完成自动打开浏览器，预加载示例工作区，读取系统AI密钥，开箱即用
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
$MinValidZipSize = 10 * 1024 * 1024 # 10MB 最低合法压缩包大小
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
# 1.1 检测系统版本
$OSInfo = [Environment]::OSVersion.Version
if ($OSInfo.Major -lt 10) {
    Write-FailExit "仅支持 Windows 10 / Windows 11 系统，当前系统版本过低"
}
# 1.2 检测执行策略提示（不强制修改，仅提示）
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
# jsDelivr国内镜像替代Github直连Release
$MainDownloadUrl = "https://cdn.jsdelivr.net/gh/$Repo@$Version/$MainZipFileName"

Write-Host "  系统：Windows | 版本：$Version | 下载文件：$MainZipFileName"
Write-Host "正在下载，网络较慢请耐心等待..."
# 新增--max-time 20，20秒无流量自动中断重试，避免无限卡死
curl.exe -L --retry 3 --retry-delay 2 --max-time 20 -o "$MainZipPath" "$MainDownloadUrl"

# 文件完整性校验
if (-not (Test-Path $MainZipPath)) { Write-FailExit "主程序压缩包下载失败" }
$ZipFileSize = (Get-Item $MainZipPath).Length
if ($ZipFileSize -lt $MinValidZipSize) {
    Remove-Item $MainZipPath -Force -ErrorAction SilentlyContinue
    Write-FailExit "下载文件不完整（体积小于10MB），请切换网络重试"
}
Write-Success "主程序包下载完成"

# ==================== 步骤4：解压主程序 + 自动拉取示例Workspace ====================
Write-StepTitle -StepIndex 4 -StepDesc "解压程序并准备示例工作空间"
# 清理旧exe
if (Test-Path $ExeFullPath) { Remove-Item $ExeFullPath -Force }
# 解压主程序
try {
    Expand-Archive -Path $MainZipPath -DestinationPath $BaseInstallDir -Force
}
catch {
    Remove-Item $MainZipPath -Force -ErrorAction SilentlyContinue
    Write-FailExit "主程序解压失败，压缩包损坏，请重新运行脚本"
}
Remove-Item $MainZipPath -Force
# 校验exe是否存在
if (-not (Test-Path $ExeFullPath)) { Write-FailExit "解压后未找到 $ExeName" }

# 下载示例Workspace（同步替换镜像+超时参数）
$ExamplesZipPath = Join-Path $BaseInstallDir $ExamplesZipFileName
$ExamplesDownloadUrl = "https://cdn.jsdelivr.net/gh/$Repo@$Version/$ExamplesZipFileName"
Write-Host "正在拉取官方示例Workspace..."
curl.exe -L --retry 3 --retry-delay 2 --max-time 20 -o "$ExamplesZipPath" "$ExamplesDownloadUrl"
if (Test-Path $ExamplesZipPath) {
    Expand-Archive -Path $ExamplesZipPath -DestinationPath $BaseInstallDir -Force
    Remove-Item $ExamplesZipPath -Force
    Write-Success "示例工作空间 examples/ 已就绪"
    # 持久写入默认工作区环境变量，Web自动加载
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
# 5.1 写入用户PATH，全局调用psi-agent
$UserEnvPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserEnvPath -notmatch [regex]::Escape($BaseInstallDir)) {
    $NewUserPath = "$BaseInstallDir;$UserEnvPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewUserPath, "User")
    Write-Success "已将安装目录加入用户环境变量（新开终端生效）"
}
else {
    Write-Host "PATH已包含安装目录，无需重复添加" -ForegroundColor Yellow
}
# 5.2 创建桌面快捷方式
if (Test-Path $DesktopShortcutPath) { Remove-Item $DesktopShortcutPath -Force }
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DesktopShortcutPath)
$Shortcut.TargetPath = $ExeFullPath
$Shortcut.WorkingDirectory = $BaseInstallDir
$Shortcut.Arguments = "gateway --browser"
$Shortcut.Description = "HaiTun AI Agent Web管理控制台"
$Shortcut.Save()
Write-Success "桌面一键启动快捷方式已创建"

# ==================== 步骤6：启动Gateway + 完整开箱即用指引 ====================
Write-StepTitle -StepIndex 6 -StepDesc "启动Web管理网关，安装完成可直接提问"
Write-Host "  工作目录：$BaseInstallDir"
Write-Host "  默认Agent工作区：$env:PSI_DEFAULT_WORKSPACE"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "安装全部完成！浏览器将自动弹出Web控制台，开箱直接对话" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
Write-Host "【Web端快速流程（无需手动配置工作区）】" -ForegroundColor Cyan
Write-Host "1. 模型自动预填充（系统提前设置PSI_AI_*环境变量则无需手动填Key）"
Write-Host "2. 自动加载examples示例Agent工具集"
Write-Host "3. 新建会话即可输入问题，支持文件上传、代码工具调用、LaTeX渲染"
Write-Host ""
Write-Host "【终端离线对话命令（新开PowerShell直接执行）】" -ForegroundColor Cyan
Write-Host "交互式持续对话：psi-agent channel repl"
Write-Host "单次提问直接返回结果：psi-agent channel cli --message \"你的问题\""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "提示：关闭当前终端窗口会停止Gateway服务；新开终端可直接输入 psi-agent 调用全部命令"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 组装网关启动参数，自动携带系统AI环境变量，Web页面预填模型信息
Set-Location $BaseInstallDir
$gatewayArgs = @("gateway", "--browser")
if ($env:PSI_AI_PROVIDER) { $gatewayArgs += "--provider"; $gatewayArgs += $env:PSI_AI_PROVIDER }
if ($env:PSI_AI_MODEL) { $gatewayArgs += "--model"; $gatewayArgs += $env:PSI_AI_MODEL }
if ($env:PSI_AI_API_KEY) { $gatewayArgs += "--api-key"; $gatewayArgs += $env:PSI_AI_API_KEY }
if ($env:PSI_AI_BASE_URL) { $gatewayArgs += "--base-url"; $gatewayArgs += $env:PSI_AI_BASE_URL }

# 启动网关自动打开浏览器
& $ExeFullPath @gatewayArgs
