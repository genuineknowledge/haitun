#!/bin/bash
set -e

# ===================== 动作1：创建 .haitun 目录 =====================
HAITUN_DIR="$HOME/.haitun"

echo -e "\033[36m=== 步骤1/3：检查 .haitun 目录 ===\033[0m"

if [ ! -d "$HAITUN_DIR" ]; then
    echo "目录不存在，正在创建..."
    mkdir -p "$HAITUN_DIR"
    
    # 如果本地有 psi-agent 的 workspace 模板，复制进去
    WORKSPACE_TEMPLATE="./examples/haitun-workspace"
    if [ -d "$WORKSPACE_TEMPLATE" ]; then
        echo "复制 workspace 模板..."
        cp -r "$WORKSPACE_TEMPLATE/"* "$HAITUN_DIR/"
    fi
else
    echo ".haitun 目录已存在，跳过创建"
fi

# ===================== 动作2：下载对应系统的可执行文件 =====================
echo -e "\n\033[36m=== 步骤2/3：下载 psi-agent ===\033[0m"

# 自动判断系统
OS="$(uname -s)"
case "$OS" in
    Darwin*)
        FILE="psi-agent-pyinstaller-macos-latest"
        ;;
    Linux*)
        FILE="psi-agent-pyinstaller-ubuntu-latest"
        ;;
    *)
        echo "❌ 不支持的系统: $OS"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/genuineknowledge/haitun/releases/download/v1.0.1/$FILE"
BINARY_PATH="$HAITUN_DIR/psi-agent"

echo "检测到系统: $OS"
echo "下载文件: $FILE"
echo "保存到: $BINARY_PATH"
echo "正在下载，请稍候..."

curl -L -o "$BINARY_PATH" "$DOWNLOAD_URL"
chmod +x "$BINARY_PATH"

echo -e "\033[32m下载完成！\033[0m"

# ===================== 动作3：进入目录并运行 =====================
echo -e "\n\033[36m=== 步骤3/3：启动 psi-agent ===\033[0m"

cd "$HAITUN_DIR"
echo "当前目录: $(pwd)"
echo "启动命令: ./psi-agent workspace"

# 运行
./psi-agent workspace
