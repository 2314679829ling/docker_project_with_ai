@echo off
rem 此脚本使用UTF-8编码保存
chcp 65001 > nul

echo 小米实验室招聘系统 - Nginx代理一键设置工具
echo =========================================
echo.

echo [步骤1] 创建必要的目录结构...

if not exist "nginx" (
  echo 创建nginx目录...
  mkdir nginx
)

echo [步骤2] 创建Nginx配置文件...

echo 创建proxy.conf...
echo server {> nginx\proxy.conf
echo     listen 80;>> nginx\proxy.conf
echo     server_name localhost;>> nginx\proxy.conf
echo.>> nginx\proxy.conf
echo     # 启用gzip压缩提高性能>> nginx\proxy.conf
echo     gzip on;>> nginx\proxy.conf
echo     gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;>> nginx\proxy.conf
echo.>> nginx\proxy.conf
echo     # 前端静态资源>> nginx\proxy.conf
echo     location / {>> nginx\proxy.conf
echo         proxy_pass http://frontend-dev:5173;>> nginx\proxy.conf
echo         proxy_http_version 1.1;>> nginx\proxy.conf
echo         proxy_set_header Upgrade $http_upgrade;>> nginx\proxy.conf
echo         proxy_set_header Connection 'upgrade';>> nginx\proxy.conf
echo         proxy_set_header Host $host;>> nginx\proxy.conf
echo         proxy_cache_bypass $http_upgrade;>> nginx\proxy.conf
echo         proxy_set_header X-Real-IP $remote_addr;>> nginx\proxy.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;>> nginx\proxy.conf
echo         proxy_set_header X-Forwarded-Proto $scheme;>> nginx\proxy.conf
echo     }>> nginx\proxy.conf
echo.>> nginx\proxy.conf
echo     # 后端API请求代理>> nginx\proxy.conf
echo     location /api/ {>> nginx\proxy.conf
echo         proxy_pass http://backend:8000/;>> nginx\proxy.conf
echo         proxy_set_header Host $host;>> nginx\proxy.conf
echo         proxy_set_header X-Real-IP $remote_addr;>> nginx\proxy.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;>> nginx\proxy.conf
echo         proxy_set_header X-Forwarded-Proto $scheme;>> nginx\proxy.conf
echo     }>> nginx\proxy.conf
echo.>> nginx\proxy.conf
echo     # 管理后台请求代理>> nginx\proxy.conf
echo     location /admin/ {>> nginx\proxy.conf
echo         proxy_pass http://backend:8000/admin/;>> nginx\proxy.conf
echo         proxy_set_header Host $host;>> nginx\proxy.conf
echo         proxy_set_header X-Real-IP $remote_addr;>> nginx\proxy.conf
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;>> nginx\proxy.conf
echo         proxy_set_header X-Forwarded-Proto $scheme;>> nginx\proxy.conf
echo     }>> nginx\proxy.conf
echo.>> nginx\proxy.conf
echo     # 健康检查端点>> nginx\proxy.conf
echo     location /health {>> nginx\proxy.conf
echo         access_log off;>> nginx\proxy.conf
echo         return 200 '{"status":"healthy","server":"nginx"}';>> nginx\proxy.conf
echo         add_header Content-Type application/json;>> nginx\proxy.conf
echo     }>> nginx\proxy.conf
echo.>> nginx\proxy.conf
echo     # 配置日志>> nginx\proxy.conf
echo     access_log /var/log/nginx/access.log;>> nginx\proxy.conf
echo     error_log /var/log/nginx/error.log;>> nginx\proxy.conf
echo }>> nginx\proxy.conf

echo 创建Dockerfile...
echo FROM nginx:stable-alpine> nginx\Dockerfile
echo.>> nginx\Dockerfile
echo # 删除默认配置>> nginx\Dockerfile
echo RUN rm /etc/nginx/conf.d/default.conf>> nginx\Dockerfile
echo.>> nginx\Dockerfile
echo # 复制自定义配置>> nginx\Dockerfile
echo COPY proxy.conf /etc/nginx/conf.d/>> nginx\Dockerfile
echo.>> nginx\Dockerfile
echo # 创建日志目录>> nginx\Dockerfile
echo RUN mkdir -p /var/log/nginx>> nginx\Dockerfile
echo.>> nginx\Dockerfile
echo # 暴露端口>> nginx\Dockerfile
echo EXPOSE 80>> nginx\Dockerfile
echo.>> nginx\Dockerfile
echo # 启动nginx>> nginx\Dockerfile
echo CMD ["nginx", "-g", "daemon off;"]>> nginx\Dockerfile

echo [步骤3] 修改docker-compose.yml添加Nginx服务...

if exist docker-compose.yml.bak (
  echo 备份文件已存在，跳过备份步骤...
) else (
  echo 备份当前的docker-compose.yml...
  copy docker-compose.yml docker-compose.yml.bak
)

echo 修改docker-compose.yml...
powershell -Command "(Get-Content docker-compose.yml) -replace 'services:', 'services:`n  nginx:`n    build:`n      context: ./nginx`n      dockerfile: Dockerfile`n    image: recruitapp-nginx`n    container_name: recruitapp-nginx`n    ports:`n      - \"80:80\"`n    depends_on:`n      - frontend-dev`n      - backend`n    networks:`n      - app-network`n    volumes:`n      - ./nginx/proxy.conf:/etc/nginx/conf.d/proxy.conf`n      - nginx-logs:/var/log/nginx`n' | Set-Content docker-compose.yml -Encoding UTF8"

powershell -Command "(Get-Content docker-compose.yml) -replace '  - \"80:80\"', '  - \"8080:80\"'" | Set-Content docker-compose.yml -Encoding UTF8"

powershell -Command "(Get-Content docker-compose.yml) -replace 'volumes:(\s+)mysql-data:(\s+)backend-media:(\s+)backend-static:', 'volumes:$1mysql-data:$2backend-media:$2backend-static:$2nginx-logs:'" | Set-Content docker-compose.yml -Encoding UTF8"

echo [步骤4] 创建启动脚本...
copy start-with-nginx.bat start-nginx.bat > nul

echo.
echo [完成] Nginx代理环境已设置!
echo.
echo 您现在可以运行以下命令启动带Nginx代理的环境:
echo   start-with-nginx.bat
echo.
echo 是否现在就启动环境? (Y/N)
set /p start_now="选择: "

if /i "%start_now%"=="Y" (
  echo.
  echo 启动环境...
  call start-with-nginx.bat
) else (
  echo.
  echo 您可以稍后运行start-with-nginx.bat启动环境
)

pause 