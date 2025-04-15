#!/usr/bin/env python
"""
端口冲突检测和修复脚本
此脚本用于检测和解决Docker容器的端口冲突问题
"""

import os
import sys
import socket
import re
import subprocess
import platform
from pathlib import Path
import yaml
import shutil

def check_port_in_use(port):
    """检查端口是否被占用"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            return s.connect_ex(('localhost', port)) == 0
    except:
        return False

def find_process_using_port(port):
    """查找使用指定端口的进程"""
    if platform.system() == "Windows":
        try:
            result = subprocess.check_output(f'netstat -ano | findstr ":{port}"', shell=True).decode()
            if not result:
                return None
            
            for line in result.split('\n'):
                if 'LISTENING' in line:
                    parts = line.strip().split()
                    if len(parts) >= 5:
                        pid = parts[-1]
                        try:
                            process_info = subprocess.check_output(f'tasklist /fi "pid eq {pid}"', shell=True).decode()
                            return {'pid': pid, 'info': process_info}
                        except:
                            return {'pid': pid, 'info': 'Unknown'}
            return None
        except:
            return None
    else:
        try:
            result = subprocess.check_output(f'lsof -i :{port} -P -n | grep LISTEN', shell=True).decode()
            if not result:
                return None
            
            parts = result.split()
            if len(parts) >= 2:
                process = parts[0]
                pid = parts[1]
                return {'pid': pid, 'info': process}
            return None
        except:
            return None

def find_docker_compose_file():
    """查找docker-compose.yml文件"""
    possible_paths = [
        Path("docker-compose.yml"),
        Path("./docker-compose.yml"),
        Path("../docker-compose.yml")
    ]
    
    for path in possible_paths:
        if path.exists():
            return path
    
    return None

def backup_file(file_path):
    """备份文件"""
    backup_path = f"{file_path}.bak"
    try:
        shutil.copy2(file_path, backup_path)
        print(f"[完成] 已备份原始文件至 {backup_path}")
        return True
    except Exception as e:
        print(f"[警告] 无法创建备份: {e}")
        return False

def modify_port_in_compose(file_path, service_name, old_port, new_port):
    """修改docker-compose.yml中的端口映射"""
    try:
        # 读取文件内容
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查是否包含旧端口的映射格式
        old_port_patterns = [
            f'"{old_port}:{old_port}"',
            f"'{old_port}:{old_port}'",
            f"{old_port}:{old_port}"
        ]
        
        new_port_str = f'"{new_port}:{old_port}"'
        replaced = False
        
        for pattern in old_port_patterns:
            if pattern in content:
                content = content.replace(pattern, new_port_str)
                replaced = True
        
        if not replaced:
            # 使用正则表达式查找更复杂的端口映射
            pattern = rf'ports:.*?-\s*["\']*{old_port}:{old_port}["\']*'
            replacement = f'ports:\\n      - "{new_port}:{old_port}"'
            content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        
        # 写入修改后的内容
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return True
    except Exception as e:
        print(f"[错误] 修改端口映射失败: {e}")
        return False

def main():
    """主函数"""
    print("端口冲突检测和修复工具")
    print("===================")
    print()
    
    # 检查常见冲突端口
    conflict_ports = []
    common_ports = {
        3306: "MySQL",
        5173: "前端开发服务",
        8000: "后端API服务",
        80: "前端生产服务"
    }
    
    print("[步骤1] 检测端口冲突")
    print("----------------")
    
    for port, service in common_ports.items():
        if check_port_in_use(port):
            process_info = find_process_using_port(port)
            conflict_ports.append({
                'port': port,
                'service': service,
                'process': process_info
            })
            print(f"[发现冲突] 端口 {port} ({service}) 已被占用")
            if process_info:
                print(f"  - 进程ID: {process_info['pid']}")
                print(f"  - 进程信息: {process_info['info']}")
        else:
            print(f"[正常] 端口 {port} ({service}) 可用")
    
    if not conflict_ports:
        print("\n没有发现端口冲突！项目应该可以正常启动。")
        return 0
    
    print("\n[步骤2] 解决端口冲突")
    print("----------------")
    
    # 查找docker-compose.yml文件
    compose_file = find_docker_compose_file()
    if not compose_file:
        print("[错误] 找不到docker-compose.yml文件")
        print("请确保您在项目根目录下运行此脚本")
        return 1
    
    print(f"[找到] {compose_file}")
    
    # 备份文件
    backup_file(compose_file)
    
    # 处理每个冲突端口
    for conflict in conflict_ports:
        port = conflict['port']
        service = conflict['service']
        
        print(f"\n处理端口冲突: {port} ({service})")
        print(f"  1) 修改Docker端口映射")
        print(f"  2) 尝试停止占用端口的进程")
        print(f"  3) 跳过此端口")
        
        choice = input("请选择解决方案 (1-3): ")
        
        if choice == "1":
            new_port = input(f"请输入新的端口号 (默认: {port+1}): ")
            if not new_port:
                new_port = port + 1
            else:
                new_port = int(new_port)
            
            # 确保新端口未被占用
            while check_port_in_use(new_port):
                print(f"[警告] 端口 {new_port} 也被占用")
                new_port += 1
                print(f"尝试使用端口: {new_port}")
            
            # 修改docker-compose.yml
            service_name = "db" if port == 3306 else "frontend-dev" if port == 5173 else "backend"
            if modify_port_in_compose(compose_file, service_name, port, new_port):
                print(f"[完成] 已将 {service} 端口从 {port} 修改为 {new_port}")
            
        elif choice == "2":
            if conflict['process']:
                pid = conflict['process']['pid']
                if platform.system() == "Windows":
                    try:
                        subprocess.run(f"taskkill /F /PID {pid}", shell=True)
                        print(f"[完成] 已终止进程 {pid}")
                    except Exception as e:
                        print(f"[错误] 无法终止进程: {e}")
                else:
                    try:
                        subprocess.run(f"kill -9 {pid}", shell=True)
                        print(f"[完成] 已终止进程 {pid}")
                    except Exception as e:
                        print(f"[错误] 无法终止进程: {e}")
            else:
                print("[错误] 无法获取进程信息")
        
        elif choice == "3":
            print(f"[跳过] 保持端口 {port} 不变")
        
        else:
            print(f"[跳过] 无效选择")
    
    print("\n[步骤3] 应用更改")
    print("----------------")
    
    restart = input("是否重启Docker容器以应用更改? (Y/N): ")
    if restart.lower() == 'y':
        try:
            print("停止所有容器...")
            subprocess.run("docker-compose down", shell=True)
            
            print("启动修改后的容器...")
            subprocess.run("docker-compose up -d", shell=True)
            
            print("[完成] 容器已重启")
        except Exception as e:
            print(f"[错误] 重启容器失败: {e}")
    
    print("\n[完成] 端口冲突修复工具执行完毕")
    print("如果问题仍然存在，您可能需要手动修改docker-compose.yml文件")

if __name__ == "__main__":
    sys.exit(main()) 