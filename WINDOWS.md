# Windows 环境下的部署与使用指南

本文档提供了在Windows环境下部署和使用小米实验室招聘系统的详细说明。

## 快速开始

### 如果遇到中文乱码或批处理文件执行问题

如果您在运行`docker-start.bat`时遇到中文乱码或命令无法执行的问题，请先运行修复脚本：

```
fix-encoding.bat
```

这将替换有问题的批处理文件，解决编码问题。

### 启动系统

```
docker-start.bat dev     # 开发环境（前端热更新）
docker-start.bat prod    # 生产环境
```

## 系统要求

- Windows 10/11
- Docker Desktop for Windows
- 至少2GB可用内存
- 至少10GB可用磁盘空间

## 安装步骤

1. 安装Docker Desktop for Windows
   - 下载地址：[https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
   - 安装后重启电脑

2. 确保Docker已启动并运行
   - 打开Docker Desktop应用
   - 确保状态显示为"Docker Desktop running"

3. 运行项目
   ```
   docker-start.bat dev
   ```

## 可用命令

```
docker-start.bat dev       # 启动开发环境
docker-start.bat prod      # 启动生产环境
docker-start.bat down      # 停止所有容器
docker-start.bat rebuild   # 重新构建镜像
docker-start.bat frontend  # 仅启动前端容器
docker-start.bat backend   # 仅启动后端容器
docker-start.bat logs      # 查看日志
```

## 访问地址

- 开发环境前端: http://localhost:5173
- 生产环境前端: http://localhost
- 后端API: http://localhost:8000
- 后端管理界面: http://localhost:8000/admin/

## 常见问题

### Docker Desktop无法启动

确保您：
1. 已安装所有Windows更新
2. 已启用Hyper-V和Windows容器功能
3. 在BIOS中启用了虚拟化

### 端口冲突

如果端口已被占用，可以编辑`docker-compose.yml`文件修改端口映射。

### 文件权限问题

Windows环境下，有时会出现Docker容器写入的文件权限问题。如果碰到此类情况，请尝试：

```
docker-start.bat down
docker volume prune  # 确认删除未使用的卷
docker-start.bat rebuild
docker-start.bat dev
```

### WSL相关问题

如果您使用WSL2后端运行Docker，请确保：
1. 已安装最新版本的WSL2
2. 已分配足够的内存给WSL2 (建议4GB以上)

## 高级配置

### 自定义环境变量

`.env`文件包含所有配置项，可以根据需要修改。

### Docker Desktop资源配置

可以在Docker Desktop的设置中调整分配给Docker的CPU和内存资源。

## 对使用Linux/MacOS的用户

如果您使用Linux或MacOS，请参考[LINUX.md](./LINUX.md)文档。 