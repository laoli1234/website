<p align="center">
  <img alt="logo" src="ruoyi-ui/public/favicon.svg" width="72" height="72">
</p>

<h1 align="center">企业门户网站</h1>

<p align="center">
  基于 Spring Boot 3 + Vue 3 的前后端分离企业门户与后台管理系统
</p>

<p align="center">
  <a href="https://github.com/laoli1234/website"><img src="https://img.shields.io/badge/GitHub-website-181717?logo=github" alt="GitHub"></a>
  <img src="https://img.shields.io/badge/Java-17-blue" alt="Java 17">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.5.16-brightgreen" alt="Spring Boot 3.5.16">
  <img src="https://img.shields.io/badge/Vue-3.5-42b883?logo=vue.js" alt="Vue 3">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="MIT License">
</p>

---

> ## ⚠️ 重要说明：本项目基于 RuoYi 改编
>
> 本项目的前后端基础框架、权限体系、代码生成器、系统管理模块等均来自开源项目 **RuoYi-Vue**。
>
> - **RuoYi GitHub 仓库：<https://github.com/yangzongzhuan/RuoYi-Vue>**
> - RuoYi 官方 Gitee 仓库：<https://gitee.com/y_project/RuoYi-Vue>
> - RuoYi 官方文档：<https://doc.ruoyi.vip>
>
> 本项目在 RuoYi-Vue 的基础上增加了企业门户首页、品牌化页面、门户数据库补丁、负载均衡测试页和 Nginx rewrite 演示页，并对配置文件做了脱敏处理。RuoYi 原项目采用 MIT 协议，版权归原作者所有，详见 [LICENSE](LICENSE)。

## 项目简介

企业门户网站是一个面向企业内外的统一访问入口，包含 **前台门户** 与 **后台管理** 两部分：

- **前台门户**：企业形象展示、业务介绍、新闻动态、联系方式等。
- **后台管理**：沿用 RuoYi 的 RBAC 权限体系，提供用户、部门、角色、菜单、字典、参数、公告、日志、定时任务、代码生成和系统监控等能力。
- **运维演示页**：内置负载均衡测试页与 Nginx rewrite 演示页，便于验证多实例与反向代理场景。

> 门户中的企业名称、Logo、新闻、地址、邮箱、备案号等均为 **演示数据**，与任何真实企业无关。正式使用前请替换为自己的品牌与联系方式。

## 功能概览

### 前台门户

| 页面 | 路径 | 说明 |
| --- | --- | --- |
| 门户首页 | `/portal` | 品牌展示、业务板块、新闻动态、关于我们、联系方式 |
| 后台登录 | `/login` | 管理员登录入口 |
| 后台首页 | `/index` | 登录后的管理后台首页 |
| 负载均衡测试 | `/lb-lab.html` | 展示当前响应实例，用于验证 Nginx 多实例负载均衡 |
| Rewrite 演示台 | `/rewrite-lab.html` | Nginx rewrite 规则演示与对照实验 |

### 后台管理

- 用户管理、部门管理、岗位管理、角色管理、菜单管理
- 字典管理、参数管理、通知公告
- 操作日志、登录日志、在线用户
- 定时任务、代码生成、系统接口文档
- 服务监控、缓存监控、连接池监视（Druid 监控台默认关闭）

## 技术栈

| 层次 | 技术 |
| --- | --- |
| 后端 | Java 17、Spring Boot 3.5.16、Spring Security、JWT、MyBatis、Druid、PageHelper |
| 数据库 | MySQL 8.0+ |
| 缓存 | Redis 6.0+ |
| 前端 | Vue 3.5、Vite 6、Element Plus 2.13、Pinia 3、Vue Router 4、Axios |
| 构建 | Maven 3.8+、Node.js 20 LTS（建议） |

## 项目结构

```text
.
├── ruoyi-admin/          # 启动模块：配置、控制器、打包入口（website.jar）
├── ruoyi-common/         # 通用工具、注解、常量、基础实体
├── ruoyi-framework/      # Spring Security、JWT、拦截器、Web 配置
├── ruoyi-generator/      # 代码生成器
├── ruoyi-quartz/         # 定时任务
├── ruoyi-system/         # 系统管理业务与 Mapper
├── ruoyi-ui/             # Vue 3 前端工程
│   ├── public/           # 静态页面（门户演示页、rewrite 演示页等）
│   └── src/              # 前端源码
├── sql/                  # 数据库初始化脚本
├── bin/                  # Windows 构建/运行脚本
├── ry.bat / ry.sh        # 后端启动、停止、重启脚本
└── pom.xml               # Maven 聚合工程
```

## 快速开始

### 1. 环境要求

- JDK 17+
- Maven 3.8+
- MySQL 8.0+
- Redis 6.0+
- Node.js 20 LTS+（前端构建）

### 2. 初始化数据库

先创建数据库（脚本不会自动建库）：

```sql
CREATE DATABASE `ry-vue` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

然后按顺序导入：

```bash
mysql -u root -p ry-vue < sql/ry_20260417.sql
mysql -u root -p ry-vue < sql/quartz.sql
```

> `sql/ry_20260417.sql` 会 **删除并重建** 业务表，请勿在已有生产数据的库上直接执行。
>
> 如果是已经导入过基础脚本的存量库，只需执行 `sql/portal-branding.sql` 更新门户品牌信息。

### 3. 配置环境变量（重要）

仓库中的数据库、Redis、JWT、Druid 配置均使用环境变量占位，**不包含任何真实密码**。启动前请设置：

| 环境变量 | 默认值 | 说明 |
| --- | --- | --- |
| `DB_HOST` | `127.0.0.1` | MySQL 地址 |
| `DB_PORT` | `3306` | MySQL 端口 |
| `DB_NAME` | `ry-vue` | 数据库名 |
| `DB_USER` | `root` | 数据库用户名 |
| `DB_PASSWORD` | 空 | 数据库密码（必须设置） |
| `REDIS_HOST` | `127.0.0.1` | Redis 地址 |
| `REDIS_PORT` | `6379` | Redis 端口 |
| `REDIS_DATABASE` | `0` | Redis 数据库索引 |
| `REDIS_PASSWORD` | 空 | Redis 密码（如未设置密码可留空） |
| `TOKEN_SECRET` | 示例占位值 | JWT 签名密钥，**生产环境必须替换为至少 32 位的随机字符串** |
| `RUOYI_PROFILE` | `./uploadPath` | 文件上传根目录 |
| `SERVER_PORT` | `8080` | 后端 HTTP 端口 |
| `DRUID_STAT_ENABLED` | `false` | 是否启用 Druid 监控台 |
| `DRUID_ALLOW` | `127.0.0.1` | Druid 监控台 IP 白名单 |
| `DRUID_USERNAME` | `ruoyi` | Druid 监控台用户名 |
| `DRUID_PASSWORD` | `change-me` | Druid 监控台密码（启用时必须修改） |
| `REFERER_ALLOWED_DOMAINS` | `localhost,127.0.0.1` | 防盗链允许域名 |

Windows PowerShell 示例：

```powershell
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="3306"
$env:DB_NAME="ry-vue"
$env:DB_USER="root"
$env:DB_PASSWORD="your-db-password"
$env:REDIS_HOST="127.0.0.1"
$env:REDIS_PASSWORD=""
$env:TOKEN_SECRET="replace-with-a-long-random-secret-at-least-32-chars"
$env:RUOYI_PROFILE="./uploadPath"
```

Linux/macOS 示例：

```bash
export DB_HOST=127.0.0.1
export DB_PORT=3306
export DB_NAME=ry-vue
export DB_USER=root
export DB_PASSWORD='your-db-password'
export REDIS_HOST=127.0.0.1
export REDIS_PASSWORD=''
export TOKEN_SECRET='replace-with-a-long-random-secret-at-least-32-chars'
export RUOYI_PROFILE='./uploadPath'
```

> 不要把真实密码写入 `application*.yml`、`.env` 或任何会被提交的文件。建议使用 IDE 运行配置、系统环境变量、Docker Secrets 或配置中心管理。

### 4. 启动后端

方式一：命令行打包运行

```bash
mvn clean package -DskipTests
java -jar ruoyi-admin/target/website.jar
```

方式二：IDE 中运行 `com.ruoyi.RuoYiApplication`。

后端默认地址：<http://localhost:8080>

### 5. 启动前端

```bash
cd ruoyi-ui
npm install
npm run dev
```

开发服务器默认端口为 `80`，访问 <http://localhost>。

生产构建：

```bash
npm run build:prod
```

构建产物位于 `ruoyi-ui/dist/`。

### 6. 访问系统

| 入口 | 地址 |
| --- | --- |
| 前台门户 | <http://localhost/portal> |
| 后台登录 | <http://localhost/login> |
| 后端接口 | <http://localhost:8080> |

**RuoYi 初始账号：**

- 管理员：`admin / admin123`
- 普通用户：`ry / admin123`

> ⚠️ 首次登录后请立即修改 `admin` 密码，并在「系统管理 → 参数管理」中修改 `sys.user.initPassword`（默认 `123456`），避免使用默认凭据上线。

## 配置与安全说明

1. **已脱敏**：数据库地址/账号/密码、Redis 地址/密码、JWT 密钥、Druid 控制台账号密码均通过环境变量占位，仓库中不保存真实值。
2. **Druid 监控台默认关闭**：如确需启用，请设置 `DRUID_STAT_ENABLED=true`，同时修改 `DRUID_USERNAME` / `DRUID_PASSWORD`，并保持 `DRUID_ALLOW` 为可信 IP。
3. **JWT 密钥**：`TOKEN_SECRET` 必须替换为随机长字符串（建议 32 位以上），不要在多个环境复用。
4. **默认密码**：`admin/admin123` 与初始密码 `123456` 仅用于首次初始化，部署后请立即修改。
5. **演示数据**：门户中的企业名称、新闻、地址、邮箱、备案号等均为示例内容，请替换后再对外发布。
6. **生产环境**：建议启用 HTTPS，限制后端与 Redis 的公网访问，并定期备份数据库。

## 与 RuoYi 的关系

本项目保留了 RuoYi-Vue 的核心能力，并做了以下定制：

- 增加企业门户页面（`ruoyi-ui/src/views/portal/index.vue`）与后台首页品牌化。
- 增加门户品牌 SQL 补丁（`sql/portal-branding.sql`）。
- 增加负载均衡测试页（`ruoyi-ui/public/lb-lab.html`）和 Nginx rewrite 演示页（`ruoyi-ui/public/rewrite-lab.html`）。
- 调整登录页、Logo、标题、页脚等品牌信息。
- 将数据库、Redis、JWT、Druid 等敏感配置改为环境变量占位。
- 保留 RuoYi 默认的登录页预填值（`admin/admin123`），便于首次体验；正式部署前请修改默认密码。

再次感谢 RuoYi 作者及所有开源贡献者：

- **RuoYi GitHub：<https://github.com/yangzongzhuan/RuoYi-Vue>**
- **RuoYi Gitee：<https://gitee.com/y_project/RuoYi-Vue>**

## 开源协议

本项目基于 RuoYi-Vue 改编，遵循 [MIT License](LICENSE)。RuoYi 原始版权归原作者所有。
