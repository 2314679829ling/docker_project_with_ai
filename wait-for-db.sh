#!/bin/bash
# 等待MySQL数据库可用的脚本

set -e

host="$1"
shift
cmd="$@"

echo "等待MySQL数据库 ($host) 启动..."
until mysqladmin ping -h "$host" --silent; do
  >&2 echo "MySQL数据库仍在启动中 - 等待..."
  sleep 2
done

>&2 echo "MySQL数据库已准备就绪！"
exec $cmd 