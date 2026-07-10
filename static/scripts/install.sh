#!/bin/bash
set -e

GREEN='\033[32m'
CYAN='\033[36m'
NC='\033[0m'

HAITUN_DIR="$HOME/.haitun"
VERSION="v1.0.1"

echo -e "${CYAN}=== HaiTun Agent 安装程序 ===${NC}"

# 步骤1：创建目录
echo -e "\n${CYAN}[1/4] 检查安装目录...${NC}"
if [ ! -d "$HAITUN_DIR" ]; then
    mkdir -p "$HAITUN_DIR"
    echo "已创建目录: $HAITUN_DIR"
else
    echo "目录已存在: $HAITUN_DIR"
fi

# 步骤2：下载 zip 包
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
        echo "不支持的系统: $OS"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/genuineknowledge/haitun/releases/download/$VERSION/$FILE"
ZIP_PATH="$HAITUN_DIR/$FILE"

echo "系统: $OS"
echo "正在下载: $FILE"

curl -L -o "$ZIP_PATH" "$DOWNLOAD_URL"

echo -e "${GREEN}下载完成！${NC}"

# 步骤3：解压
echo -e "\n${CYAN}[3/4] 解压文件...${NC}"
cd "$HAITUN_DIR"
unzip -o "$FILE"
rm "$FILE"  # 删除压缩包
chmod +x psi-agent

echo -e "${GREEN}解压完成！${NC}"

# 步骤4：启动
echo -e "\n${CYAN}[4/4] 启动 psi-agent workspace...${NC}"
./psi-agent workspace
