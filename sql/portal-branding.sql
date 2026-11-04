-- =============================================================
-- 门户网站品牌化补丁
-- 适用：已经导入过 ry_20260417.sql 的存量数据库
-- 执行一次即可；执行后请退出后台并重新登录
-- =============================================================

USE `ry-vue`;

-- 1. 用户昵称与邮箱
UPDATE sys_user SET nick_name = '管理员',   email = 'admin@lenovo-tech.com' WHERE user_name = 'admin';
UPDATE sys_user SET nick_name = '普通用户', email = 'demo@lenovo-tech.com'  WHERE user_name = 'ry';

-- 2. 部门名称、负责人、邮箱
UPDATE sys_dept SET dept_name = '联想科技' WHERE dept_id = 100;
UPDATE sys_dept SET leader = '管理员' WHERE leader = '若依';
UPDATE sys_dept SET email = 'admin@lenovo-tech.com';

-- 3. 移除“若依官网”菜单及其角色关联
DELETE FROM sys_role_menu WHERE menu_id = 4;
DELETE FROM sys_menu      WHERE menu_id = 4;

-- 4. 替换初始化公告
DELETE FROM sys_notice_read WHERE notice_id IN (1, 2, 3);
DELETE FROM sys_notice      WHERE notice_id IN (1, 2, 3);

INSERT INTO sys_notice (notice_id, notice_title, notice_type, notice_content, status, create_by, create_time)
VALUES
(1, '企业门户网站正式上线', '2', '企业门户网站已完成部署，欢迎使用。', '0', 'admin', NOW()),
(2, '门户网站例行维护通知', '1', '系统将于每周日凌晨 2:00-4:00 进行例行维护，请提前安排工作。', '0', 'admin', NOW()),
(3, '企业门户网站介绍', '1', '企业门户网站提供统一访问入口、业务协同与数据展示能力，欢迎各部门使用。', '0', 'admin', NOW());

-- 5. 说明
-- 昵称缓存在 Redis 的登录 token 中，执行完本脚本后请退出后台重新登录，
-- 或清理 login_tokens:* 后重新登录，右上角才会显示“管理员”。
