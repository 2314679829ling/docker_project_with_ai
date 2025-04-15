#!/bin/bash
# 小米实验室招聘系统一键安装脚本 (Debian/Ubuntu版)

set -e  # 出错即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   小米实验室招聘系统 - 一键安装脚本   ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# 检查是否为root用户
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}[错误] 请不要使用root用户运行此脚本${NC}"
    echo "请使用普通用户运行，需要时脚本会使用sudo获取权限"
    exit 1
fi

# 检查是否为Debian/Ubuntu系统
if [ ! -f /etc/debian_version ]; then
    echo -e "${YELLOW}[警告] 此脚本针对Debian/Ubuntu系统优化${NC}"
    echo -e "检测到您的系统可能不是Debian/Ubuntu，是否继续？ [y/N]"
    read continue_install
    if [ "$continue_install" != "y" ] && [ "$continue_install" != "Y" ]; then
        echo "安装已取消"
        exit 0
    fi
fi

echo -e "${BLUE}[信息] 更新系统包列表...${NC}"
sudo apt-get update

echo -e "${BLUE}[信息] 安装必要依赖...${NC}"
sudo apt-get install -y curl git wget make

# 检查并安装Docker
if ! command -v docker &> /dev/null; then
    echo -e "${BLUE}[信息] 安装Docker...${NC}"
    sudo apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
    
    # 添加Docker官方GPG密钥
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # 设置稳定版仓库
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # 将当前用户添加到docker组
    sudo usermod -aG docker $USER
    echo -e "${GREEN}[成功] Docker安装完成${NC}"
    echo -e "${YELLOW}[警告] 需要重新登录以应用docker组权限${NC}"
else
    echo -e "${GREEN}[成功] Docker已安装${NC}"
fi

# 检查并安装Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${BLUE}[信息] 安装Docker Compose...${NC}"
    
    # 安装最新版本的Docker Compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo -e "${GREEN}[成功] Docker Compose安装完成${NC}"
else
    echo -e "${GREEN}[成功] Docker Compose已安装${NC}"
fi

# 下载脚本并设置权限
echo -e "${BLUE}[信息] 设置文件权限...${NC}"
chmod +x ./docker-start.sh
chmod +x ./start.sh
chmod +x ./init.sh

# 运行初始化脚本
echo -e "${BLUE}[信息] 运行初始化脚本...${NC}"
./init.sh

echo -e "${GREEN}[成功] 安装完成！${NC}"
echo ""
echo "现在您可以使用以下命令启动系统："
echo "  ./start.sh dev    # 开发模式"
echo "  ./start.sh prod   # 生产模式"
echo ""
echo "首次启动可能需要一些时间来拉取和构建镜像。"
echo -e "${YELLOW}注意：如果您刚刚安装了Docker，请先注销并重新登录，以应用Docker组权限。${NC}" 