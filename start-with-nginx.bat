@echo off
rem 此脚本使用UTF-8编码保存
chcp 65001 > nul

echo 小米实验室招聘系统 - 带Nginx代理的启动脚本
echo =======================================
echo.

echo [检查] 确认Docker是否运行...
docker info > nul 2>&1
if %errorlevel% neq 0 (
  echo [错误] Docker未运行，请先启动Docker Desktop
  pause
  exit /b 1
)

echo [检查] 检查是否存在必要文件...
if not exist "nginx/proxy.conf" (
  echo [错误] 找不到nginx/proxy.conf文件
  echo 请确保您已创建所有必要的Nginx配置文件
  pause
  exit /b 1
)

echo [步骤1] 创建nginx目录结构...
if not exist "nginx" mkdir nginx

echo [步骤2] 启动方式选择

echo 请选择启动方式:
echo  1) 开发环境 (前端热重载 + Nginx代理)
echo  2) 生产环境 (Nginx代理生产版前端和后端)
echo  3) 只构建不启动

set /p choice="请选择 (1-3): "

if "%choice%"=="1" (
  echo.
  echo [步骤3] 启动开发环境 (带Nginx代理)...
  
  echo 停止可能运行的容器...
  docker-compose down
  
  echo 构建并启动服务...
  docker-compose up -d nginx frontend-dev backend db
  
  echo.
  echo [成功] 开发环境已启动!
  echo.
  echo 访问地址:
  echo  - 应用前端: http://localhost/
  echo  - 后端API: http://localhost/api/
  echo  - 管理界面: http://localhost/admin/
  echo  - 健康检查: http://localhost/health
  echo.
  echo 查看日志: docker-compose logs -f
) else if "%choice%"=="2" (
  echo.
  echo [步骤3] 启动生产环境 (带Nginx代理)...
  
  echo 停止可能运行的容器...
  docker-compose down
  
  echo 构建并启动生产服务...
  docker-compose --profile prod up -d nginx backend db
  
  echo.
  echo [成功] 生产环境已启动!
  echo.
  echo 访问地址:
  echo  - 应用前端: http://localhost/
  echo  - 后端API: http://localhost/api/
  echo  - 管理界面: http://localhost/admin/
  echo  - 健康检查: http://localhost/health
  echo.
  echo 查看日志: docker-compose logs -f
) else if "%choice%"=="3" (
  echo.
  echo [步骤3] 仅构建镜像...
  
  echo 构建Nginx镜像...
  docker-compose build nginx
  
  echo 构建前端开发镜像...
  docker-compose build frontend-dev
  
  echo 构建前端生产镜像...
  docker-compose build frontend-prod
  
  echo 构建后端镜像...
  docker-compose build backend
  
  echo.
  echo [成功] 所有镜像已构建完成!
  echo 您可以稍后使用此脚本启动服务
) else (
  echo.
  echo [错误] 无效的选择: %choice%
  echo 请输入1、2或3
)

echo.
echo 如需停止服务，请运行: docker-compose down

pause 