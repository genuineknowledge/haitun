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

# ==================== 步骤2：下载（多源自动回退） ====================
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

GITHUB_URL="https://github.com/$REPO/releases/download/$VERSION/$FILE"
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

# 下载源列表（按优先级尝试）
DOWNLOAD_URLS=(
    "https://mirror.ghproxy.com/$GITHUB_URL"
    "https://gh-proxy.com/$GITHUB_URL"
    "$GITHUB_URL"
)

DOWNLOAD_SUCCESS=false

for url in "${DOWNLOAD_URLS[@]}"; do
    echo "尝试下载源: $url"
    
    # 清理旧文件
    rm -f "$ZIP_PATH"
    
    if curl -L --retry 2 --retry-delay 1 --connect-timeout 10 --progress-bar -o "$ZIP_PATH" "$url"; then
        # 校验文件大小
        FILE_SIZE=$(stat -f%z "$ZIP_PATH" 2>/dev/null || stat -c%s "$ZIP_PATH" 2>/dev/null || echo 0)
        MIN_SIZE=$((10 * 1024 * 1024))
        
        if [ "$FILE_SIZE" -ge "$MIN_SIZE" ]; then
            DOWNLOAD_SUCCESS=true
            echo -e "${GREEN}✓ 下载成功${NC}"
            break
        fi
    fi
    
    echo -e "${YELLOW}  该源下载失败，尝试下一个...${NC}"
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo -e "\n${RED}✗ 所有下载源均失败，请检查网络连接${NC}"
    echo "也可以手动下载后放到 $HAITUN_DIR 目录"
    echo "下载地址: $GITHUB_URL"
    rm -f "$ZIP_PATH"
    exit 1
fi

# ==================== 步骤3：解压覆盖 ====================
echo -e "\n${CYAN}[3/4] 解压覆盖...${NC}"

# 先删除旧的可执行文件，确保是全新的
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
