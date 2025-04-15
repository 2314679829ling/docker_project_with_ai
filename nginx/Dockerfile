FROM nginx:stable-alpine

# 删除默认配置
RUN rm /etc/nginx/conf.d/default.conf

# 复制自定义配置
COPY proxy.conf /etc/nginx/conf.d/

# 创建日志目录
RUN mkdir -p /var/log/nginx

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
