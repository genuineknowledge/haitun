#!/bin/bash
set -euo pipefail

# ====================== 全局UTF8编码，彻底解决终端&curl乱码 ======================
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export CURL_ENCODING=UTF-8
export CURL_RAW_MODE=1

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
if ! command -v curl &> /dev/null; then
    print_err "未找到 curl，请先安装：
  Ubuntu/Debian: sudo apt install curl
  CentOS/RHEL:   sudo yum install curl
  macOS:         brew install curl"
fi
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

DOWNLOAD_URL="https://cdn.jsdelivr.net/gh/$REPO@$VERSION/$FILE"
ZIP_PATH="$HAITUN_DIR/$FILE"

echo "  系统: $OS"
echo "  版本: $VERSION"
echo "  压缩包: $FILE"
echo "正在下载，网络较慢请耐心等待..."

rm -f "$ZIP_PATH"
if ! curl -L --retry 3 --retry-delay 2 --max-time 20 --progress-bar -o "$ZIP_PATH" "$DOWNLOAD_URL"; then
    rm -f "$ZIP_PATH"
    print_err "主程序包下载失败，请切换网络重试"
fi

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

# ==================== 步骤4：解压程序 + 自动拉取示例Workspace ====================
print_step 4 "解压程序并准备官方示例工作空间"
rm -f "$BINARY_PATH"
cd "$HAITUN_DIR"
if ! unzip -o "$FILE" -d "$HAITUN_DIR" > /dev/null 2>&1; then
    rm -f "$ZIP_PATH"
    print_err "主程序解压失败，压缩包损坏"
fi
rm -f "$ZIP_PATH"

if [ -f "$BINARY_PATH" ]; then
    chmod +x "$BINARY_PATH"
else
    print_err "解压后未找到 psi-agent 可执行文件"
fi

EXAMPLES_URL="https://cdn.jsdelivr.net/gh/$REPO@$VERSION/$EXAMPLES_ZIP"
EXAMPLES_TMP="$HAITUN_DIR/$EXAMPLES_ZIP"
echo "正在拉取官方示例 workspace..."
if curl -L --retry 2 --retry-delay 2 --max-time 20 -o "$EXAMPLES_TMP" "$EXAMPLES_URL" > /dev/null 2>&1; then
    unzip -o "$EXAMPLES_TMP" -d "$HAITUN_DIR" > /dev/null 2>&1
    rm -f "$EXAMPLES_TMP"
    print_ok "示例工作空间 examples/ 已就绪"
    DEFAULT_WORKSPACE="$HAITUN_DIR/examples"
    export PSI_DEFAULT_WORKSPACE="$DEFAULT_WORKSPACE"
    SHELL_RC=""
    if [[ "$SHELL" == *zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ "$SHELL" == *bash ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    if [ -n "$SHELL_RC" ] && ! grep -q "PSI_DEFAULT_WORKSPACE" "$SHELL_RC"; then
        echo "export PSI_DEFAULT_WORKSPACE=\"$DEFAULT_WORKSPACE\"" >> "$SHELL_RC"
        print_ok "已持久配置默认Agent工作空间：$DEFAULT_WORKSPACE"
    fi
else
    print_warn "示例工作区下载失败，可在Web控制台手动加载目录"
fi
print_ok "程序解压完成"

# ==================== 步骤5：自动配置全局PATH（终端直接调用psi-agent） ====================
print_step 5 "配置全局命令环境变量"
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

# ==================== 步骤6：生成config并直接进入REPL对话 ====================
print_step 6 "准备启动终端对话模式"
cd "$HAITUN_DIR"

WORKSPACE="${PSI_DEFAULT_WORKSPACE:-.}"
CONFIG_FILE="$HAITUN_DIR/config.yml"

# 生成config.yml，缺失的AI参数直接注释掉
cat > "$CONFIG_FILE" << EOF
- type: ai
  session_socket: ./ai.sock
  provider: ${PSI_AI_PROVIDER:-}
  model: ${PSI_AI_MODEL:-}
  api_key: ${PSI_AI_API_KEY:-}
  base_url: ${PSI_AI_BASE_URL:-}
- type: session
  workspace: $WORKSPACE
  channel_socket: ./channel.sock
  ai_socket: ./ai.sock
- type: channel
  name: repl
  session_socket: ./channel.sock
EOF

# 将空值替换为注释
if [[ -z "${PSI_AI_PROVIDER:-}" ]]; then
    sed -i.bak 's/^  provider: \s*$/  # provider:/' "$CONFIG_FILE"
fi
if [[ -z "${PSI_AI_MODEL:-}" ]]; then
    sed -i.bak 's/^  model: \s*$/  # model:/' "$CONFIG_FILE"
fi
if [[ -z "${PSI_AI_API_KEY:-}" ]]; then
    sed -i.bak 's/^  api_key: \s*$/  # api_key:/' "$CONFIG_FILE"
fi
if [[ -z "${PSI_AI_BASE_URL:-}" ]]; then
    sed -i.bak 's/^  base_url: \s*$/  # base_url:/' "$CONFIG_FILE"
fi
rm -f "$CONFIG_FILE.bak"

echo "  工作目录: $HAITUN_DIR"
echo "  默认Agent工作区: $WORKSPACE"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}安装全部完成！正在进入终端对话模式${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${CYAN}【使用方法】${NC}"
echo "1. 输入问题后按 Alt+Enter 发送（或 Escape 再按 Enter）"
echo "2. Ctrl+D 退出对话"
echo "3. 想用 Web 控制台：新开终端执行 psi-agent gateway --browser"
echo -e "${YELLOW}========================================${NC}"
echo ""

# 启动对话
./psi-agent run "$CONFIG_FILE"
