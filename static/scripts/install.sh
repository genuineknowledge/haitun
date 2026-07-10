#!/bin/bash
set -e

# 颜色定义
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

# 配置项
HAITUN_DIR="$HOME/.haitun"
VERSION="v1.0.1"
REPO="genuineknowledge/haitun"
BINARY_PATH="$HAITUN_DIR/psi-agent"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    HaiTun Agent 一键安装脚本${NC}"
echo -e "${CYAN}========================================${NC}"

# ==================== 步骤1：检查目录 ====================
echo -e "\n${CYAN}[1/4] 检查安装目录...${NC}"

if [ ! -d "$HAITUN_DIR" ]; then
    mkdir -p "$HAITUN_DIR"
    echo -e "${GREEN}✓ 已创建目录: $HAITUN_DIR${NC}"
else
    echo -e "${YELLOW}目录已存在: $HAITUN_DIR${NC}"
fi

# ==================== 步骤2：下载 ====================
echo -e "\n${CYAN}[2/4] 下载 psi-agent...${NC}"

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
        echo -e "${RED}✗ 不支持的操作系统: $OS${NC}"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$FILE"
ZIP_PATH="$HAITUN_DIR/$FILE"

echo "  系统: $OS"
echo "  版本: $VERSION"
echo "  文件: $FILE"
echo ""

# 检查依赖
if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ 未找到 curl 命令${NC}"
    echo "请先安装 curl:"
    echo "  Ubuntu/Debian: sudo apt install curl"
    echo "  CentOS/RHEL:   sudo yum install curl"
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo -e "${RED}✗ 未找到 unzip 命令${NC}"
    echo "请先安装 unzip:"
    echo "  Ubuntu/Debian: sudo apt install unzip"
    echo "  CentOS/RHEL:   sudo yum install unzip"
    exit 1
fi

echo "正在下载，请稍候..."

# 清理旧文件
rm -f "$ZIP_PATH"

# 下载，自动重试 3 次
if ! curl -L --retry 3 --retry-delay 2 --progress-bar -o "$ZIP_PATH" "$DOWNLOAD_URL"; then
    echo -e "\n${RED}✗ 下载失败，请检查网络连接${NC}"
    rm -f "$ZIP_PATH"
    exit 1
fi

# 校验文件大小
FILE_SIZE=$(stat -f%z "$ZIP_PATH" 2>/dev/null || stat -c%s "$ZIP_PATH" 2>/dev/null || echo 0)
MIN_SIZE=$((10 * 1024 * 1024))

if [ "$FILE_SIZE" -lt "$MIN_SIZE" ]; then
    echo -e "${RED}✗ 下载文件异常（太小），请重新运行${NC}"
    rm -f "$ZIP_PATH"
    exit 1
fi

echo -e "${GREEN}✓ 下载完成${NC}"

# ==================== 步骤3：解压覆盖 ====================
echo -e "\n${CYAN}[3/4] 解压覆盖...${NC}"

# 先删除旧的可执行文件
rm -f "$BINARY_PATH"

cd "$HAITUN_DIR"

if ! unzip -o "$FILE" -d "$HAITUN_DIR" > /dev/null 2>&1; then
    echo -e "${RED}✗ 解压失败，文件可能损坏，请重新运行脚本${NC}"
    rm -f "$ZIP_PATH"
    exit 1
fi

# 清理压缩包
rm -f "$ZIP_PATH"

# 加执行权限
if [ -f "$BINARY_PATH" ]; then
    chmod +x "$BINARY_PATH"
    echo -e "${GREEN}✓ 解压完成${NC}"
else
    echo -e "${RED}✗ 解压后未找到 psi-agent 文件${NC}"
    exit 1
fi

# ==================== 步骤4：启动 Gateway ====================
echo -e "\n${CYAN}[4/4] 启动 Gateway 服务...${NC}"
echo "  工作目录: $HAITUN_DIR"
echo "  启动命令: ./psi-agent gateway"
echo -e "\n${GREEN}========================================${NC}"

cd "$HAITUN_DIR"
./psi-agent gateway
