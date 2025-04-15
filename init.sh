#!/bin/bash
# 小米实验室招聘系统初始化脚本
# 适用于Linux环境

set -e  # 出错即退出

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查系统架构
check_arch() {
    print_info "检查系统架构..."
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        print_success "系统架构: x86_64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        print_success "系统架构: ARM64"
    else
        print_warning "未知系统架构: $ARCH，可能有兼容性问题"
    fi
}

# 检查系统要求
check_system() {
    print_info "检查系统要求..."
    
    # 检查Linux发行版
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_info "Linux发行版: $NAME $VERSION_ID"
    else
        print_warning "无法确定Linux发行版"
    fi
    
    # 检查内存
    MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$MEM_TOTAL" -lt 2048 ]; then
        print_warning "系统内存小于2GB，可能会影响性能"
    else
        print_success "系统内存: ${MEM_TOTAL}MB"
    fi
    
    # 检查磁盘空间
    DISK_FREE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$DISK_FREE" -lt 10 ]; then
        print_warning "系统磁盘空间小于10GB，可能不足"
    else
        print_success "可用磁盘空间: ${DISK_FREE}GB"
    fi
}

# 安装依赖
install_dependencies() {
    print_info "检查并安装依赖..."
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        print_warning "Docker未安装，尝试安装Docker..."
        
        # 判断发行版并安装Docker
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            
            case "$ID" in
                debian|ubuntu)
                    print_info "检测到Debian/Ubuntu系统，使用apt安装Docker..."
                    sudo apt-get update
                    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                    curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$ID $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    sudo apt-get update
                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                    ;;
                centos|rhel)
                    print_info "检测到CentOS/RHEL系统，使用yum安装Docker..."
                    sudo yum install -y yum-utils
                    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                    sudo yum install -y docker-ce docker-ce-cli containerd.io
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    ;;
                fedora)
                    print_info "检测到Fedora系统，使用dnf安装Docker..."
                    sudo dnf -y install dnf-plugins-core
                    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                    sudo dnf install -y docker-ce docker-ce-cli containerd.io
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    ;;
                *)
                    print_error "不支持的Linux发行版，请手动安装Docker: https://docs.docker.com/engine/install/"
                    exit 1
                    ;;
            esac
            
            # 添加当前用户到docker组
            sudo usermod -aG docker $USER
            print_warning "需要重新登录以应用docker组权限"
            print_success "Docker安装完成"
        else
            print_error "无法确定Linux发行版，请手动安装Docker: https://docs.docker.com/engine/install/"
            exit 1
        fi
    else
        print_success "Docker已安装"
    fi
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_warning "Docker Compose未安装，尝试安装Docker Compose..."
        
        # 安装Docker Compose
        COMPOSE_VERSION="v2.23.3"
        
        if [ "$(uname -m)" = "x86_64" ]; then
            sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            print_success "Docker Compose安装完成"
        else
            print_warning "非x86_64架构，使用Docker Compose插件安装方式"
            mkdir -p ~/.docker/cli-plugins/
            curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ~/.docker/cli-plugins/docker-compose
            chmod +x ~/.docker/cli-plugins/docker-compose
            print_success "Docker Compose插件安装完成"
        fi
    else
        print_success "Docker Compose已安装"
    fi
}

# 设置文件权限
setup_permissions() {
    print_info "设置文件权限..."
    
    # 设置脚本可执行
    chmod +x ./docker-start.sh
    chmod +x ./start.sh
    
    # 创建目录确保存在
    mkdir -p ./backend/media
    mkdir -p ./backend/static
    mkdir -p ./frontend/dist
    
    # 设置权限
    chmod -R 777 ./backend/media
    chmod -R 777 ./backend/static
    
    print_success "文件权限设置完成"
}

# 创建环境变量文件
create_env_file() {
    print_info "创建环境变量文件..."
    
    if [ -f ".env" ]; then
        print_warning "发现已存在的.env文件，是否覆盖？[y/N] "
        read OVERWRITE
        if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
            print_info "保留原有.env文件"
            return
        fi
    fi
    
    # 生成随机密码和密钥
    DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()-_=+' | fold -w 50 | head -n 1)
    
    # 创建.env文件
    cat > .env << EOL
# 数据库配置
MYSQL_ROOT_PASSWORD=${ROOT_PASSWORD}
MYSQL_DATABASE=django_oauth
MYSQL_USER=django
MYSQL_PASSWORD=${DB_PASSWORD}

# Django配置
SECRET_KEY=${SECRET_KEY}
DEBUG=True
DB_NAME=django_oauth
DB_USER=root
DB_PASSWORD=${ROOT_PASSWORD}

# 前端配置
VITE_APP_API_URL=http://localhost:8000
EOL
    
    print_success ".env文件创建成功，已生成随机密码和密钥"
}

# 构建镜像
build_images() {
    print_info "构建Docker镜像..."
    
    # 如果是首次运行，构建所有镜像
    if [ "$DOCKER_COMPOSE" = "docker-compose" ]; then
        docker-compose build
    else
        docker compose build
    fi
    
    print_success "Docker镜像构建完成"
}

# 完成安装
finish_setup() {
    print_success "系统初始化完成！"
    print_info "现在可以使用以下命令启动系统："
    echo ""
    echo "  ./start.sh dev    # 开发模式，前端热加载"
    echo "  ./start.sh prod   # 生产模式，优化性能"
    echo ""
    print_warning "注意：首次启动时，Docker会拉取镜像，这可能需要一些时间。"
    print_warning "如果您修改了.env文件，请重新构建镜像：./docker-start.sh rebuild"
}

# 主函数
main() {
    echo "======================================"
    echo "   小米实验室招聘系统 - 初始化脚本   "
    echo "======================================"
    echo ""
    
    check_arch
    check_system
    install_dependencies
    setup_permissions
    create_env_file
    build_images
    finish_setup
}

# 执行主函数
main 