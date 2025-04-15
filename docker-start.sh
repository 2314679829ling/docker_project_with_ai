#!/bin/bash

# 显示帮助信息
show_help() {
  echo "小米实验室招聘系统 Docker启动脚本"
  echo ""
  echo "用法: ./docker-start.sh [选项]"
  echo ""
  echo "选项:"
  echo "  dev          启动开发环境（前端热加载）"
  echo "  prod         启动生产环境"
  echo "  down         停止所有容器"
  echo "  rebuild      重新构建所有镜像"
  echo "  frontend     仅启动前端容器"
  echo "  backend      仅启动后端容器"
  echo "  logs         查看所有容器日志"
  echo "  help         显示此帮助信息"
  echo ""
}

# 检查Docker是否已安装
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
  echo "错误: 请先安装Docker和Docker Compose"
  exit 1
fi

# 根据参数执行不同操作
case "$1" in
  dev)
    echo "启动开发环境..."
    docker-compose up -d frontend-dev backend db
    ;;
  prod)
    echo "启动生产环境..."
    docker-compose --profile prod up -d
    ;;
  down)
    echo "停止所有容器..."
    docker-compose down
    ;;
  rebuild)
    echo "重新构建所有镜像..."
    docker-compose build --no-cache
    ;;
  frontend)
    echo "仅启动前端容器..."
    docker-compose up -d frontend-dev
    ;;
  backend)
    echo "仅启动后端容器..."
    docker-compose up -d backend db
    ;;
  logs)
    echo "查看所有容器日志..."
    docker-compose logs -f
    ;;
  help|*)
    show_help
    ;;
esac 