<#
.SYNOPSIS
HaiTun psi-agent Windows 一键安装脚本
.DESCRIPTION
自动下载、解压、配置环境、创建快捷方式，启动Gateway并输出完整初始化操作流程
#>
# 全局编码强制修复，解决终端中文乱码（新增）
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding = $OutputEncoding

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

# ==================== 步骤3：下载并校验主程序包（替换jsDelivr镜像+超时防卡死） ====================
Write-StepTitle -StepIndex 3 -StepDesc "下载 psi-agent 主程序"
$MainZipPath = Join-Path $BaseInstallDir $MainZipFileName
# 国内CDN镜像加速Release，替代原github直连
$MainDownloadUrl = "https://cdn.jsdelivr.net/gh/$Repo@$Version/$MainZipFileName"

Write-Host "  系统：Windows | 版本：$Version | 下载文件：$MainZipFileName"
Write-Host "正在下载，网络较慢请耐心等待..."
# 新增--max-time 20，20秒无流量自动重试，解决下载卡死
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

# 下载示例Workspace（镜像+超时参数同步修改）
$ExamplesZipPath = Join-Path $BaseInstallDir $ExamplesZipFileName
$ExamplesDownloadUrl = "https://cdn.jsdelivr.net/gh/$Repo@$Version/$ExamplesZipFileName"
Write-Host "正在拉取官方示例Workspace..."
curl.exe -L --retry 3 --retry-delay 2 --max-time 20 -o "$ExamplesZipPath" "$ExamplesDownloadUrl"
if (Test-Path $ExamplesZipPath) {
    Expand-Archive -Path $ExamplesZipPath -DestinationPath $BaseInstallDir -Force
    Remove-Item $ExamplesZipPath -Force
    Write-Success "示例工作空间 examples/ 已就绪"
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

# ==================== 步骤6：启动Gateway + 完整初始化操作指引 ====================
Write-StepTitle -StepIndex 6 -StepDesc "启动Web管理网关，启动前操作指引"
Write-Host "  工作目录：$BaseInstallDir"
Write-Host "  启动命令：$ExeName gateway --browser"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "安装全部完成！浏览器将自动弹出Web控制台" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
Write-Host "【从打开网页 → 输入提问 完整标准流程（参照README）】" -ForegroundColor Cyan
Write-Host "1. 绑定大模型（左侧菜单：AI模型管理）"
Write-Host "   · 新建AI实例，选择模型厂商"
Write-Host "   · 填写模型名称、API Key、中转BaseURL（官方接口留空）"
Write-Host "   · 点击测试连接，提示成功后保存实例"
Write-Host ""
Write-Host "2. 加载Agent工作空间 Workspace"
Write-Host "   · 左侧「工作空间管理」→ 浏览目录"
Write-Host "   · 选中安装目录下 examples 示例文件夹，加载工作空间"
Write-Host ""
Write-Host "3. 创建对话会话"
Write-Host "   · 左侧「会话管理」→ 新建会话"
Write-Host "   · 下拉选择已创建AI实例、加载完成的Workspace"
Write-Host "   · 自定义会话ID（可选），确认创建会话"
Write-Host ""
Write-Host "4. 进入聊天页面，输入自定义问题开始对话"
Write-Host "   · 支持SSE流式输出、Markdown/LaTeX渲染、图片/文件上传"
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "提示：关闭当前终端窗口会停止Gateway服务；新开终端可直接输入 psi-agent 调用命令"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 切换目录并启动网关，自动打开浏览器
Set-Location $BaseInstallDir
& $ExeFullPath gateway --browser
