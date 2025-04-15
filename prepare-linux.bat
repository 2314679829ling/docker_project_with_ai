@echo off
echo 正在准备Linux脚本，设置Unix行尾格式...

REM 检测Windows环境中的Unix工具
where dos2unix >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 未安装dos2unix工具，跳过行尾转换...
) else (
    echo 转换脚本到Unix格式...
    dos2unix.exe docker-start.sh
    dos2unix.exe start.sh 
    dos2unix.exe init.sh
    dos2unix.exe install.sh
)

REM 在Docker环境中，这些脚本将被正确执行
echo.
echo 转换完成！当在Linux或Docker中运行这些脚本时，需要确保它们有执行权限。
echo.
echo 在Linux/WSL环境下，请运行:
echo   chmod +x *.sh
echo.
echo 要在Windows下直接使用Docker，请运行以下命令:
echo   docker-start.bat dev    # 开发环境
echo   docker-start.bat prod   # 生产环境
echo.
echo 如果您使用WSL，请在WSL中运行:
echo   ./start.sh dev          # 开发环境
echo   ./start.sh prod         # 生产环境
echo.

pause 