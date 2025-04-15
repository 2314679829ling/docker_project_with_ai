#!/bin/bash
# 小米实验室招聘系统一键启动脚本
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

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    else
        print_success "Docker已安装"
    fi
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_warning "Docker Compose未安装，尝试使用docker compose命令..."
        if ! docker compose version &> /dev/null; then
            print_error "Docker Compose未安装，请先安装Docker Compose"
            exit 1
        else
            print_success "Docker Compose (新版) 已安装"
            DOCKER_COMPOSE="docker compose"
        fi
    else
        print_success "Docker Compose (旧版) 已安装"
        DOCKER_COMPOSE="docker-compose"
    fi
}

# 设置权限
setup_permissions() {
    print_info "设置文件权限..."
    
    # 设置启动脚本可执行权限
    chmod +x ./docker-start.sh
    
    # 设置目录权限
    if [ -d "./backend/media" ]; then
        chmod -R 777 ./backend/media
        print_success "媒体目录权限已设置"
    fi
    
    if [ -d "./backend/static" ]; then
        chmod -R 777 ./backend/static
        print_success "静态文件目录权限已设置"
    fi
}

# 环境变量检查
check_env() {
    print_info "检查环境变量..."
    
    if [ ! -f ".env" ]; then
        print_warning ".env文件不存在，将创建默认配置"
        cp .env.example .env 2>/dev/null || touch .env
        echo "# 数据库配置
MYSQL_ROOT_PASSWORD=password
MYSQL_DATABASE=django_oauth
MYSQL_USER=django
MYSQL_PASSWORD=password

# Django配置
SECRET_KEY=django-insecure-key-for-development-only
DEBUG=True
DB_NAME=django_oauth
DB_USER=root
DB_PASSWORD=password

# 前端配置
VITE_APP_API_URL=http://localhost:8000" > .env
        print_success "已创建默认.env文件"
    else
        print_success ".env文件已存在"
    fi
}

# 启动应用
start_app() {
    print_info "启动应用..."
    
    # 检查是否有参数
    if [ -z "$1" ]; then
        MODE="dev"
        print_info "未指定运行模式，默认使用开发模式"
    else
        MODE="$1"
    fi
    
    # 使用docker-start.sh启动
    ./docker-start.sh $MODE
    
    # 如果是后端或开发模式，进行数据库迁移
    if [ "$MODE" = "backend" ] || [ "$MODE" = "dev" ]; then
        print_info "等待数据库启动..."
        sleep 10
        
        print_info "执行数据库迁移..."
        $DOCKER_COMPOSE exec backend python manage.py migrate || true
        print_success "数据库迁移完成"
    fi
}

# 显示访问信息
show_access_info() {
    print_info "系统启动完成！"
    
    # 显示访问地址
    if [ "$MODE" = "prod" ]; then
        print_success "生产环境已启动"
        echo "  前端访问地址: http://localhost"
    else
        print_success "开发环境已启动"
        echo "  前端访问地址: http://localhost:5173"
    fi
    
    echo "  后端访问地址: http://localhost:8000"
    echo "  后端管理界面: http://localhost:8000/admin/"
    
    echo ""
    echo "可以使用以下命令查看日志："
    echo "  ./docker-start.sh logs"
    echo ""
    echo "可以使用以下命令停止服务："
    echo "  ./docker-start.sh down"
}

# 主函数
main() {
    echo "======================================"
    echo "   小米实验室招聘系统 - 一键启动脚本   "
    echo "======================================"
    echo ""
    
    check_dependencies
    setup_permissions
    check_env
    start_app "$1"
    show_access_info
}

# 执行主函数
main "$1" 