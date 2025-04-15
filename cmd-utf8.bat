@echo off
rem 设置命令行为UTF-8编码以显示中文

echo 设置命令行为UTF-8编码模式...
chcp 65001 > nul
 
echo.
echo 命令行已设置为UTF-8编码模式！
echo.
echo 现在您可以运行以下命令而不会出现中文乱码：
echo - docker-utf8.bat
echo - docker-fix-all.bat
echo.
echo 推荐使用docker-utf8.bat来操作Docker

cmd /k 