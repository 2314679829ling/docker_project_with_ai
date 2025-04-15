@echo off
rem 此脚本使用UTF-8编码保存
chcp 65001 > nul

echo 小米实验室招聘系统 - 项目构建工具
echo ==================================
echo.

echo 此工具将帮助您构建项目，而不是依赖预构建镜像
echo.

if not exist docker-compose.yml (
  echo [错误] 找不到docker-compose.yml文件
  echo 请确保您在项目根目录中运行此脚本
  pause
  exit /b 1
)

echo [步骤1] 检查Docker状态
echo.

docker info > nul 2>&1
if errorlevel 1 (
  echo [错误] Docker未运行或连接失败
  echo 请确保Docker Desktop已经启动
  pause
  exit /b 1
) else (
  echo [成功] Docker正在运行
)

echo.
echo [步骤2] 选择构建方式
echo.

echo 构建选项:
echo  1) 构建所有服务
echo  2) 仅构建后端
echo  3) 仅构建前端
echo  4) 跳过构建，直接启动
echo.

set /p build_choice="请选择 (1-4): "
echo.

if "%build_choice%"=="1" (
  echo 正在构建所有服务...
  docker-compose build
) else if "%build_choice%"=="2" (
  echo 正在构建后端服务...
  docker-compose build backend
) else if "%build_choice%"=="3" (
  echo 正在构建前端服务...
  docker-compose build frontend-dev
) else if "%build_choice%"=="4" (
  echo 跳过构建步骤...
) else (
  echo 无效选择，将构建所有服务...
  docker-compose build
)

echo.
echo [步骤3] 选择启动环境
echo.

echo 启动选项:
echo  1) 开发环境 (热重载)
echo  2) 生产环境
echo  3) 不启动，仅构建
echo.

set /p start_choice="请选择 (1-3): "
echo.

if "%start_choice%"=="1" (
  echo 正在启动开发环境...
  docker-compose up -d frontend-dev backend db
) else if "%start_choice%"=="2" (
  echo 正在启动生产环境...
  docker-compose --profile prod up -d
) else if "%start_choice%"=="3" (
  echo 跳过启动步骤...
) else (
  echo 无效选择，将启动开发环境...
  docker-compose up -d frontend-dev backend db
)

echo.
echo [完成] 操作已执行
echo.
echo 如果您看到类似 "pull access denied" 的错误，请不用担心
echo 这是因为系统尝试拉取不存在的镜像，但会自动回退到本地构建
echo.
echo 常用命令:
echo - 查看日志: docker-compose logs -f
echo - 停止服务: docker-compose down
echo - 重新构建: docker-compose build --no-cache
echo.
echo 服务访问地址:
echo - 开发环境前端: http://localhost:5173
echo - 生产环境前端: http://localhost
echo - 后端API: http://localhost:8000
echo.

pause 