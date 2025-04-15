# Linux 环境下的部署与使用指南

本文档提供了在Linux环境下部署和使用小米实验室招聘系统的详细说明。

## 快速开始

### 方法一：一键安装（推荐）

对于Debian/Ubuntu系统，可以使用一键安装脚本：

```bash
# 下载代码
git clone <仓库地址> recruitapp
cd recruitapp

# 设置脚本执行权限
chmod +x install.sh

# 运行安装脚本
./install.sh
```

### 方法二：手动安装

1. 确保已安装Docker和Docker Compose
2. 克隆代码仓库并进入项目目录
3. 设置脚本执行权限并运行初始化脚本

```bash
# 下载代码
git clone <仓库地址> recruitapp
cd recruitapp

# 设置脚本执行权限
chmod +x init.sh
chmod +x start.sh
chmod +x docker-start.sh

# 运行初始化脚本
./init.sh
```

## 系统要求

- Linux 操作系统 (推荐Debian/Ubuntu)
- 至少2GB内存
- 至少10GB可用磁盘空间
- Docker & Docker Compose
- 用户在Docker组中 (无需使用sudo运行Docker)

## 可用脚本说明

本项目提供了以下脚本，方便您在Linux环境下操作：

### install.sh

一键安装脚本，专为Debian/Ubuntu系统优化：
- 检查系统环境
- 安装Docker和Docker Compose
- 初始化环境变量和用户权限
- 构建必要的Docker镜像

### init.sh

系统初始化脚本：
- 检查系统架构和要求
- 检查并安装Docker和Docker Compose（如需要）
- 设置文件权限
- 创建环境变量文件（生成安全的随机密码）
- 构建Docker镜像

### start.sh

简化的启动脚本：
- 检查依赖是否已安装
- 设置必要的文件权限
- 启动Docker容器
- 执行数据库迁移
- 显示访问链接

用法：
```bash
./start.sh [dev|prod]
```

### docker-start.sh

Docker操作脚本：
```bash
./docker-start.sh dev       # 启动开发环境
./docker-start.sh prod      # 启动生产环境
./docker-start.sh down      # 停止所有容器
./docker-start.sh rebuild   # 重新构建镜像
./docker-start.sh frontend  # 仅启动前端
./docker-start.sh backend   # 仅启动后端
./docker-start.sh logs      # 查看日志
```

## 环境变量配置

`.env`文件包含所有配置项：

```
# 数据库配置
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
VITE_APP_API_URL=http://localhost:8000
```

## 访问地址

- 开发环境前端: http://localhost:5173
- 生产环境前端: http://localhost
- 后端API: http://localhost:8000
- 后端管理界面: http://localhost:8000/admin/

## 常见问题

### 权限错误

如果看到权限相关错误，请确保：

```bash
# 为脚本添加执行权限
chmod +x *.sh

# 确保当前用户在docker组中
sudo usermod -aG docker $USER
# 然后注销并重新登录
```

### 端口冲突

如果端口已被占用，可以在`docker-compose.yml`中修改映射端口。

### 数据库连接问题

检查`.env`文件中的数据库配置是否正确。

## 备份与恢复

### 备份数据

```bash
# 备份数据库
docker-compose exec db mysqldump -u root -p django_oauth > backup.sql

# 备份媒体文件
tar -czvf media_backup.tar.gz ./backend/media
```

### 恢复数据

```bash
# 恢复数据库
cat backup.sql | docker-compose exec -T db mysql -u root -p django_oauth

# 恢复媒体文件
tar -xzvf media_backup.tar.gz -C ./
```

## 生产环境注意事项

对于生产环境部署，您应该：

1. 修改`.env`文件中的所有默认密码
2. 确保设置`DEBUG=False`
3. 考虑使用更安全的`SECRET_KEY`
4. 配置HTTPS
5. 启用生产环境设置 