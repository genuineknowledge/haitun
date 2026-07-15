#!/bin/bash
set -euo pipefail

# ====================== 颜色常量 ======================
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
RED='\033[31m'
WHITE='\033[37m'
NC='\033[0m'

# ====================== 全局配置 ======================
HAITUN_DIR="$HOME/.haitun"
VERSION="v1.0.1"
REPO="genuineknowledge/haitun"
BINARY_PATH="$HAITUN_DIR/psi-agent"
EXAMPLES_ZIP="examples-workspace.zip"
MIN_VALID_SIZE=$((10 * 1024 * 1024)) # 10MB
TOTAL_STEP=6

# 工具函数：打印步骤标题
print_step() {
    local idx=$1
    local desc=$2
    echo -e "\n${CYAN}[${idx}/${TOTAL_STEP}] ${desc}${NC}"
}
print_ok() { echo -e "${GREEN}✓ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_err() { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ====================== 头部横幅 ======================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    HaiTun Agent Linux/macOS 一键安装脚本${NC}"
echo -e "${CYAN}========================================${NC}"

# ==================== 步骤1：前置依赖检测 ====================
print_step 1 "前置环境依赖校验"
# 检测 curl
if ! command -v curl &> /dev/null; then
    print_err "未找到 curl，请先安装：
  Ubuntu/Debian: sudo apt install curl
  CentOS/RHEL:   sudo yum install curl
  macOS:         brew install curl"
fi
# 检测 unzip
if ! command -v unzip &> /dev/null; then
    print_err "未找到 unzip，请先安装：
  Ubuntu/Debian: sudo apt install unzip
  CentOS/RHEL:   sudo yum install unzip
  macOS:         brew install unzip"
fi
print_ok "依赖校验全部通过"

# ==================== 步骤2：创建安装目录 ====================
print_step 2 "初始化安装目录"
if [ ! -d "$HAITUN_DIR" ]; then
    mkdir -p "$HAITUN_DIR"
    print_ok "已创建目录: $HAITUN_DIR"
else
    echo -e "${YELLOW}目录已存在，将覆盖更新程序: $HAITUN_DIR${NC}"
fi

# ==================== 步骤3：下载对应系统主程序包（CDN镜像+超时防卡死） ====================
print_step 3 "下载 psi-agent 主程序二进制包"
# 判断系统
OS="$(uname -s)"
case "$OS" in
    Darwin*)
        FILE="psi-agent-pyinstaller-macos-latest.zip"
        ;;
    Linux*)
        FILE="psi-agent-pyinstaller-ubuntu-latest.zip"
        ;;
    *)
        print_err "不支持的操作系统: $OS"
        ;;
esac

# 【核心修改】替换为jsDelivr国内镜像地址，替代原github releases直连
DOWNLOAD_URL="https://cdn.jsdelivr.net/gh/$REPO@$VERSION/$FILE"
ZIP_PATH="$HAITUN_DIR/$FILE"

echo "  系统: $OS"
echo "  版本: $VERSION"
echo "  压缩包: $FILE"
echo "正在下载，网络较慢请耐心等待..."

# 清理旧包
rm -f "$ZIP_PATH"
# 3次重试下载 + 新增20秒超时，卡住自动终止重试
if ! curl -L --retry 3 --retry-delay 2 --max-time 20 --progress-bar -o "$ZIP_PATH" "$DOWNLOAD_URL"; then
    rm -f "$ZIP_PATH"
    print_err "主程序包下载失败，请切换网络重试"
fi

# 校验文件大小
if [[ "$OS" == "Darwin" ]]; then
    FILE_SIZE=$(stat -f%z "$ZIP_PATH")
else
    FILE_SIZE=$(stat -c%s "$ZIP_PATH")
fi
if [ "$FILE_SIZE" -lt "$MIN_VALID_SIZE" ]; then
    rm -f "$ZIP_PATH"
    print_err "下载文件不完整（体积小于10MB），请重新运行脚本"
fi
print_ok "主程序包下载完成"

# ==================== 步骤4：解压程序 + 自动拉取示例Workspace（同步替换镜像+超时） ====================
print_step 4 "解压程序并准备官方示例工作空间"
# 删除旧二进制
rm -f "$BINARY_PATH"
cd "$HAITUN_DIR"
# 解压主程序
if ! unzip -o "$FILE" -d "$HAITUN_DIR" > /dev/null 2>&1; then
    rm -f "$ZIP_PATH"
    print_err "主程序解压失败，压缩包损坏"
fi
rm -f "$ZIP_PATH"

# 赋予可执行权限
if [ -f "$BINARY_PATH" ]; then
    chmod +x "$BINARY_PATH"
else
    print_err "解压后未找到 psi-agent 可执行文件"
fi

# 下载 examples 示例工作区（镜像地址+超时参数）
EXAMPLES_URL="https://cdn.jsdelivr.net/gh/$REPO@$VERSION/$EXAMPLES_ZIP"
EXAMPLES_TMP="$HAITUN_DIR/$EXAMPLES_ZIP"
echo "正在拉取官方示例 workspace..."
if curl -L --retry 2 --retry-delay 2 --max-time 20 -o "$EXAMPLES_TMP" "$EXAMPLES_URL" > /dev/null 2>&1; then
    unzip -o "$EXAMPLES_TMP" -d "$HAITUN_DIR" > /dev/null 2>&1
    rm -f "$EXAMPLES_TMP"
    print_ok "示例工作空间 examples/ 已就绪"
else
    print_warn "示例工作区下载失败，可在Web控制台手动加载目录"
fi
print_ok "程序解压完成"

# ==================== 步骤5：自动配置全局PATH（终端直接调用psi-agent） ====================
print_step 5 "配置全局命令环境变量"
# 自动识别 shell
SHELL_RC=""
if [[ "$SHELL" == *zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "$HAITUN_DIR" "$SHELL_RC"; then
        echo "export PATH=\"$HAITUN_DIR:\$PATH\"" >> "$SHELL_RC"
        print_ok "已将 $HAITUN_DIR 写入 $SHELL_RC，新开终端直接调用 psi-agent"
    else
        echo -e "${YELLOW}PATH已包含安装目录，无需重复写入${NC}"
    fi
else
    print_warn "未识别到 bash/zsh，需手动添加 PATH: export PATH=\"$HAITUN_DIR:\$PATH\""
fi

# ==================== 步骤6：启动Gateway + 完整初始化操作指引（对齐README） ====================
print_step 6 "启动 Web 管理网关 Gateway"
echo "  工作目录: $HAITUN_DIR"
echo "  启动命令: ./psi-agent gateway"
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}安装全部完成！接下来按以下流程操作（参照官方README）${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${CYAN}【从打开网页到输入自定义问题完整流程】${NC}"
echo "1. 绑定大模型（左侧菜单：AI模型管理）"
echo "   · 新建AI实例，选择模型厂商（OpenAI/DeepSeek/通义千问等50+）"
echo "   · 填写模型名称、API Key、中转BaseURL（官方接口留空）"
echo "   · 点击测试连接，提示成功后保存实例"
echo ""
echo "2. 加载Agent工作空间 Workspace"
echo "   · 左侧「工作空间管理」→ 浏览目录"
echo "   · 选中安装目录下 examples 示例文件夹，加载工作空间"
echo ""
echo "3. 创建对话会话"
echo "   · 左侧「会话管理」→ 新建会话"
echo "   · 下拉选择已创建AI实例、加载完成的Workspace"
echo "   · 自定义会话ID（可选），确认创建会话"
echo ""
echo "4. 进入聊天页面，输入自定义问题开始对话"
echo "   · 支持SSE流式输出、Markdown/LaTeX渲染、图片/文件上传"
echo -e "${YELLOW}========================================${NC}"
echo "提示：关闭当前终端窗口会停止Gateway服务；新开终端可直接输入 psi-agent 调用命令"
echo -e "${GREEN}========================================${NC}\n${NC}"

# 切换目录并启动网关
cd "$HAITUN_DIR"
./psi-agent gateway
