@echo off
rem 此脚本使用UTF-8编码保存
chcp 65001 > nul

echo 小米实验室招聘系统 - 阿里云镜像仓库工具
echo =======================================
echo.

set REGISTRY=crpi-c1xccf2ja35k2iok.cn-wulanchabu.personal.cr.aliyuncs.com
set VPC_REGISTRY=crpi-c1xccf2ja35k2iok-vpc.cn-wulanchabu.personal.cr.aliyuncs.com
set NAMESPACE=docker_image_yyh
set REPOSITORY=selfdocker
set USERNAME=aliyun6437728208

echo 阿里云镜像仓库信息：
echo - 公网地址: %REGISTRY%/%NAMESPACE%/%REPOSITORY%
echo - VPC地址: %VPC_REGISTRY%/%NAMESPACE%/%REPOSITORY%
echo - 用户名: %USERNAME%
echo.

echo 功能选项:
echo  1) 登录到阿里云镜像仓库
echo  2) 构建并推送后端镜像
echo  3) 构建并推送前端镜像
echo  4) 拉取已存在的镜像
echo  5) 使用阿里云镜像运行项目
echo  0) 退出
echo.

set /p option="请选择功能 (0-5): "
echo.

if "%option%"=="0" (
  echo 退出工具...
  exit /b 0
)

if "%option%"=="1" (
  call :docker_login
  pause
  exit /b 0
)

if "%option%"=="2" (
  call :push_backend_image
  pause
  exit /b 0
)

if "%option%"=="3" (
  call :push_frontend_image
  pause
  exit /b 0
)

if "%option%"=="4" (
  call :pull_image
  pause
  exit /b 0
)

if "%option%"=="5" (
  call :run_with_aliyun_images
  pause
  exit /b 0
)

echo 无效选项，请重新运行脚本选择有效功能。
pause
exit /b 1

:docker_login
echo [步骤] 登录到阿里云镜像仓库
echo.
echo 请在弹出提示中输入您的阿里云容器镜像服务密码
docker login --username=%USERNAME% %REGISTRY%
if errorlevel 1 (
  echo [错误] 登录失败，请检查用户名和密码
) else (
  echo [成功] 登录成功
)
exit /b 0

:push_backend_image
echo [步骤] 构建并推送后端镜像
echo.

echo 请输入版本号(默认为latest):
set /p version=
if "%version%"=="" set version=latest

echo 1) 构建后端镜像...
docker-compose build backend

echo 2) 标记后端镜像...
for /f "tokens=3" %%i in ('docker images ^| findstr recruitapp-backend') do (
  set IMAGE_ID=%%i
  goto :tag_backend
)

:tag_backend
echo 使用镜像ID: %IMAGE_ID%
docker tag %IMAGE_ID% %REGISTRY%/%NAMESPACE%/%REPOSITORY%:backend-%version%

echo 3) 推送镜像到阿里云...
docker push %REGISTRY%/%NAMESPACE%/%REPOSITORY%:backend-%version%

if errorlevel 1 (
  echo [错误] 推送失败，请确保已登录到阿里云镜像仓库
) else (
  echo [成功] 后端镜像已推送到: %REGISTRY%/%NAMESPACE%/%REPOSITORY%:backend-%version%
)
exit /b 0

:push_frontend_image
echo [步骤] 构建并推送前端镜像
echo.

echo 请输入版本号(默认为latest):
set /p version=
if "%version%"=="" set version=latest

echo 1) 构建前端镜像...
docker-compose build frontend-dev

echo 2) 标记前端镜像...
for /f "tokens=3" %%i in ('docker images ^| findstr recruitapp-frontend-dev') do (
  set IMAGE_ID=%%i
  goto :tag_frontend
)

:tag_frontend
echo 使用镜像ID: %IMAGE_ID%
docker tag %IMAGE_ID% %REGISTRY%/%NAMESPACE%/%REPOSITORY%:frontend-%version%

echo 3) 推送镜像到阿里云...
docker push %REGISTRY%/%NAMESPACE%/%REPOSITORY%:frontend-%version%

if errorlevel 1 (
  echo [错误] 推送失败，请确保已登录到阿里云镜像仓库
) else (
  echo [成功] 前端镜像已推送到: %REGISTRY%/%NAMESPACE%/%REPOSITORY%:frontend-%version%
)
exit /b 0

:pull_image
echo [步骤] 从阿里云拉取镜像
echo.

echo 可用镜像类型:
echo  1) 后端镜像
echo  2) 前端镜像
echo  3) 自定义镜像
echo.

set /p image_type="请选择要拉取的镜像类型 (1-3): "
echo.

if "%image_type%"=="1" (
  echo 请输入版本号(默认为latest):
  set /p version=
  if "%version%"=="" set version=latest
  
  echo 拉取后端镜像 backend-%version%...
  docker pull %REGISTRY%/%NAMESPACE%/%REPOSITORY%:backend-%version%
) else if "%image_type%"=="2" (
  echo 请输入版本号(默认为latest):
  set /p version=
  if "%version%"=="" set version=latest
  
  echo 拉取前端镜像 frontend-%version%...
  docker pull %REGISTRY%/%NAMESPACE%/%REPOSITORY%:frontend-%version%
) else if "%image_type%"=="3" (
  echo 请输入完整的镜像标签:
  set /p custom_tag=
  
  if "%custom_tag%"=="" (
    echo [错误] 镜像标签不能为空
    exit /b 1
  )
  
  echo 拉取自定义镜像 %custom_tag%...
  docker pull %REGISTRY%/%NAMESPACE%/%REPOSITORY%:%custom_tag%
) else (
  echo 无效选项
  exit /b 1
)

if errorlevel 1 (
  echo [错误] 拉取失败，请确保镜像存在且已登录到阿里云镜像仓库
) else (
  echo [成功] 镜像拉取成功
)
exit /b 0

:run_with_aliyun_images
echo [步骤] 使用阿里云镜像运行项目
echo.

echo 请输入后端版本号(默认为latest):
set /p backend_version=
if "%backend_version%"=="" set backend_version=latest

echo 请输入前端版本号(默认为latest):
set /p frontend_version=
if "%frontend_version%"=="" set frontend_version=latest

echo 创建临时docker-compose.aliyun.yml文件...

(
echo version: "3.8"
echo.
echo services:
echo   frontend-dev:
echo     image: %REGISTRY%/%NAMESPACE%/%REPOSITORY%:frontend-%frontend_version%
echo     container_name: recruitapp-frontend-dev
echo     ports:
echo       - "5173:5173"
echo     environment:
echo       - NODE_ENV=development
echo       - VITE_APP_API_URL=http://localhost:8000
echo     depends_on:
echo       - backend
echo     networks:
echo       - app-network
echo.
echo   backend:
echo     image: %REGISTRY%/%NAMESPACE%/%REPOSITORY%:backend-%backend_version%
echo     container_name: recruitapp-backend
echo     restart: always
echo     ports:
echo       - "8000:8000"
echo     volumes:
echo       - backend-media:/app/media
echo       - backend-static:/app/static
echo     environment:
echo       - DEBUG=True
echo       - DJANGO_SETTINGS_MODULE=core.settings
echo       - DB_ENGINE=django.db.backends.mysql
echo       - DB_NAME=django_oauth
echo       - DB_USER=root
echo       - DB_PASSWORD=password
echo       - DB_HOST=db
echo       - DB_PORT=3306
echo     depends_on:
echo       - db
echo     networks:
echo       - app-network
echo.
echo   db:
echo     image: mysql:8.0
echo     container_name: recruitapp-db
echo     restart: always
echo     ports:
echo       - "3306:3306"
echo     volumes:
echo       - mysql-data:/var/lib/mysql
echo     environment:
echo       - MYSQL_ROOT_PASSWORD=password
echo       - MYSQL_DATABASE=django_oauth
echo     networks:
echo       - app-network
echo.
echo networks:
echo   app-network:
echo     driver: bridge
echo.
echo volumes:
echo   mysql-data:
echo   backend-media:
echo   backend-static:
) > docker-compose.aliyun.yml

echo 使用阿里云镜像启动服务...
docker-compose -f docker-compose.aliyun.yml up -d

if errorlevel 1 (
  echo [错误] 启动失败，请确保镜像存在且已登录到阿里云镜像仓库
) else (
  echo [成功] 使用阿里云镜像启动服务成功
  echo.
  echo 服务访问地址:
  echo - 前端: http://localhost:5173
  echo - 后端: http://localhost:8000
)
exit /b 0 