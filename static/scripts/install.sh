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

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    HaiTun Agent 一键安装脚本${NC}"
echo -e "${CYAN}========================================${NC}"

# ==================== 步骤1：创建目录 ====================
echo -e "\n${CYAN}[1/4] 检查安装目录...${NC}"

if [ ! -d "$HAITUN_DIR" ]; then
    mkdir -p "$HAITUN_DIR"
    echo -e "${GREEN}✓ 已创建目录: $HAITUN_DIR${NC}"
else
    echo -e "${YELLOW}目录已存在: $HAITUN_DIR${NC}"
fi

# ==================== 步骤2：判断系统并下载 ====================
echo -e "\n${CYAN}[2/4] 下载 psi-agent...${NC}"

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

# 检查 curl 是否存在
if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ 未找到 curl 命令，请先安装 curl${NC}"
    exit 1
fi

echo "正在下载，请稍候..."
curl -L --progress-bar -o "$ZIP_PATH" "$DOWNLOAD_URL"

if [ ! -f "$ZIP_PATH" ]; then
    echo -e "${RED}✗ 下载失败${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 下载完成${NC}"

# ==================== 步骤3：解压 ====================
echo -e "\n${CYAN}[3/4] 解压文件...${NC}"

cd "$HAITUN_DIR"

# 检查 unzip 是否存在
if ! command -v unzip &> /dev/null; then
    echo -e "${RED}✗ 未找到 unzip 命令，请先安装 unzip${NC}"
    exit 1
fi

unzip -o "$FILE" -d "$HAITUN_DIR" > /dev/null 2>&1

# 删除压缩包
rm -f "$ZIP_PATH"

# 给可执行文件加权限
if [ -f "$HAITUN_DIR/psi-agent" ]; then
    chmod +x "$HAITUN_DIR/psi-agent"
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
