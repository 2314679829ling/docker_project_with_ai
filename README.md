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

# 邮件系统重构文档

## 重构概述

邮件系统重构的主要目标是消除系统中的冗余代码，统一邮件发送接口，提高系统维护性。重构工作主要集中在以下几个方面：

1. 删除过时的邮件发送接口
2. 统一使用 `email_service` 作为邮件发送的入口
3. 确保验证码系统使用统一的生成和验证方法
4. 保留必要的工具函数，如 `mask_email`

## 修改的文件

1. **email_utils.py**
   - 删除了过时的 `send_email` 和 `send_verification_email` 函数
   - 删除了过时的 `generate_verification_code` 函数
   - 只保留 `mask_email` 函数用于邮箱脱敏

2. **verification_utils.py**
   - 更新导入，使用 `email_service` 代替旧的函数
   - 使用 `email_service.verification_manager._generate_numeric_code()` 生成验证码
   - 使用 `email_service.send_verification_email()` 发送验证码邮件

3. **queue_utils.py**
   - 更新导入，使用 `email_service` 代替旧的函数
   - 使用 `email_service.verification_manager._generate_numeric_code()` 生成验证码
   - 使用 `email_service.send_verification_email()` 发送验证码邮件

4. **queue_adapter.py**
   - 更新所有 `enqueue_email` 方法，使用 `email_service.send_email()` 发送邮件

5. **redis_code.py**
   - 更新验证码邮件发送代码，使用 `email_service.send_verification_email()` 发送邮件
   - 修复变量名一致性问题 (`send_success` 改为 `success`)

## 邮件系统架构

重构后的邮件系统架构如下：

1. **核心组件**:
   - `email_service`: 统一的邮件服务入口，提供 `send_email` 和 `send_verification_email` 方法
   - `verification_manager`: 负责验证码的生成和验证
   - `EmailTemplateLoader`: 处理邮件模板的加载和渲染

2. **发送流程**:
   ```
   应用调用 -> email_service -> 队列适配器 -> 邮件发送
                                           -> 数据库记录
   ```

3. **其他工具**:
   - `mask_email`: 对邮箱进行脱敏处理，用于日志和显示

## 后续优化建议

1. 进一步整合队列系统，统一使用一种队列实现方式
2. 考虑移除 `redis_code.py` 中的冗余验证码处理代码
3. 整合 `verification_utils.py` 和 `verification_manager.py` 中的验证码处理逻辑
4. 将邮件模板从代码中分离，统一使用文件模板 