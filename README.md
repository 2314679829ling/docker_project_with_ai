# 小米实验室招聘系统

这是小米实验室的招聘管理系统，包含前后端完整代码。系统支持申请者提交简历、查看申请状态，管理员审核申请，并集成了Coze AI智能助手提供咨询服务。系统采用多种登录认证方式和全面的唯一性校验，确保数据安全和可靠性。

## 系统架构

项目采用前后端分离架构：

- **前端**：Vue 3 + TypeScript + Element Plus
- **后端**：Django + Django REST Framework + MySQL
- **AI集成**：Coze AI聊天机器人

## 主要功能

### 用户端
- 申请者信息提交
- 照片上传
- 用户注册与验证码验证
- 多种登录方式（用户名/邮箱/学号/手机号）
- 申请状态查看
- 与AI助手对话咨询

### 管理端
- 申请审核管理
- 用户管理
- 令牌管理
- AI助手配置

## 项目结构

```
project/
├── backend/                # Django后端
│   ├── accounts/           # 用户认证模块
│   ├── resume/             # 简历管理模块
│   ├── core/               # 核心功能模块
│   ├── oauth/              # OAuth认证模块
│   └── README.md           # 后端文档
│
├── frontend/               # Vue 3前端
│   ├── src/                # 源代码
│   │   ├── components/     # 组件
│   │   ├── services/       # API服务
│   │   ├── views/          # 页面
│   │   └── router/         # 路由
│   └── README.md           # 前端文档
│
└── README.md               # 项目总体文档
```

## 技术特点

1. **多种登录方式**：支持用户名、邮箱、学号、手机号多种登录方式
2. **验证码注册**：邮箱验证码注册流程，确保用户邮箱真实有效
3. **强大的唯一性校验**：学号、用户名、邮箱、手机号的唯一性验证
4. **令牌认证**：实现长期令牌认证，便于用户免密访问
5. **AI集成**：无缝集成Coze AI，实现智能问答
6. **自动状态管理**：
   - user_token过期时退出登录
   - 详细的错误处理和状态提示

## 快速开始

### 后端部署

1. 进入后端目录
   ```bash
   cd backend
   ```

2. 安装依赖
   ```bash
   pip install -r requirements.txt
   ```

3. 配置环境变量
   参考后端README.md中的配置说明

4. 运行数据库迁移
   ```bash
   python manage.py migrate
   ```

5. 创建超级用户
   ```bash
   python manage.py createsuperuser
   ```

6. 启动服务器
   ```bash
   python manage.py runserver 8000
   ```

### 前端部署

1. 进入前端目录
   ```bash
   cd frontend
   ```

2. 安装依赖
   ```bash
   npm install
   # 或
   yarn install
   ```

3. 启动开发服务器
   ```bash
   npm run dev
   # 或
   yarn dev
   ```

4. 生产环境构建
   ```bash
   npm run build
   # 或
   yarn build
   ```

## 接口文档

详细的API接口文档：
- [后端API文档](backend/README.md#API接口文档) - 包含完整的API列表及请求/响应格式
- [前端服务集成](frontend/README.md#API集成) - 包含前端如何调用API的示例代码

### 核心API概览

#### 用户认证相关
- 注册: `/api/accounts/register/`
- 验证码注册: `/api/accounts/verify_and_register/`
- 登录: `/api/accounts/login/`
- 验证码登录: `/api/accounts/email_login/`
- 退出登录: `/api/accounts/logout/`

#### 简历管理相关
- 提交简历: `/api/resume/apply/`
- 获取简历: `/api/resume/get/`
- 获取状态: `/api/accounts/resume_status/`

详细的请求和响应格式请参考[后端API文档](backend/README.md#API接口文档)。

## 开发者

- 小米实验室团队

## 许可证

MIT License 