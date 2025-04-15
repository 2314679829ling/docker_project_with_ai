# Resume数据同步修复方案

# 1. 在Resume模型中修复sync_with_profile方法
# backend/resume/models.py 117-119行
"""
原代码:
if updated_fields:
    for field in updated_fields:
        setattr(profile, field, getattr(profile, field))  # 这行有错误
    profile.save(update_fields=updated_fields)
"""

"""
修复代码:
if updated_fields:
    for field in updated_fields:
        setattr(profile, field, getattr(self, field))  # 使用self而不是profile
    profile.save(update_fields=updated_fields)
"""

# 2. 在UserProfile模型中添加save和sync_with_resume方法
# backend/accounts/models.py UserProfile类中添加
"""
def save(self, *args, **kwargs):
    """保存前同步用户数据和简历数据"""
    # 调用父类的保存方法
    super().save(*args, **kwargs)
    
    # 尝试同步更新关联的简历数据
    self.sync_with_resume()

def sync_with_resume(self):
    """将用户资料数据同步到关联的简历中"""
    import logging
    logger = logging.getLogger('resume.api')
    
    try:
        # 导入Resume模型
        from resume.models import Resume
        
        # 检查是否存在关联的Resume
        if hasattr(self.user, 'resume'):
            resume = self.user.resume
            updated_fields = []
            
            # 同步学号
            if self.student_id and (not resume.student_id or resume.student_id != self.student_id):
                resume.student_id = self.student_id
                updated_fields.append('student_id')
            
            # 同步姓名（如果简历名称为空或默认值）
            user_name = self.full_name
            if user_name and user_name != self.user.username and (not resume.name or resume.name.startswith('用户')):
                resume.name = user_name
                updated_fields.append('name')
            
            # 同步头像到照片
            if self.avatar and not resume.photo:
                resume.photo = self.avatar
                updated_fields.append('photo')
            
            # 如果有更新字段，保存简历
            if updated_fields:
                # 避免无限递归，使用update方法
                Resume.objects.filter(id=resume.id).update(**{field: getattr(resume, field) for field in updated_fields})
                logger.info(f"已同步用户资料({self.user.username})到简历: {', '.join(updated_fields)}")
        
        # 如果没有关联的Resume但有学号，尝试查找匹配的简历并关联
        elif self.student_id:
            resume = Resume.objects.filter(student_id=self.student_id, user__isnull=True).first()
            if resume:
                resume.user = self.user
                resume.save(update_fields=['user'])
                logger.info(f"已通过学号({self.student_id})关联简历到用户({self.user.username})")
            else:
                # 如果有足够信息，可以考虑创建新简历
                user_name = self.full_name
                if user_name and user_name != self.user.username and self.student_id:
                    # 创建一个新的简历记录
                    Resume.objects.create(
                        user=self.user,
                        student_id=self.student_id,
                        name=user_name,
                        advantages="",  # 设置默认空值
                        vision=""       # 设置默认空值
                    )
                    logger.info(f"为用户({self.user.username})创建了新简历，学号：{self.student_id}")
    
    except Exception as e:
        logger.error(f"同步用户资料到简历时出错: {str(e)}", exc_info=True)
"""

# 3. 在ResumeSerializer中确保所有Join表单字段都被处理
# 检查序列化器中是否处理了所有Join表单字段，确保没有漏掉字段
"""
字段检查:
- student_id: 被正确处理
- name: 被正确处理
- age: 被提取并同步到UserProfile
- province: 被提取并同步到UserProfile
- email: 被提取并同步到User
- phone: 被提取并同步到UserProfile
- department: 被提取并同步到UserProfile
- gender: 被ResumeSerializer管理并同步
- ethnicity: 被ResumeSerializer管理并同步
- advantages: 保存在Resume中
- vision: 保存在Resume中
- photo: 保存在Resume中，并同步到UserProfile.avatar
- password: 仅用于创建用户，不存储实际密码
""" 