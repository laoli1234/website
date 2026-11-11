# 打包与实验部署资产

本目录把源码构建成《课题4-大型网站》实验手册直接使用的部署包和部署脚本。
打包完成后，实验手册中的路径、文件名、配置读取方式都不需要修改。

## 一、构建环境

| 工具 | 版本 | 用途 |
| --- | --- | --- |
| JDK | 17+ | 编译后端 |
| Maven | 3.8+ | 打包 `website.jar` |
| Node.js | 20 LTS+（建议） | 构建前端 |
| npm | 随 Node.js | 安装前端依赖 |
| zip / Compress-Archive | 系统自带 | 生成 `.zip` |

> 实验虚拟机不需要安装 Maven、Node.js；它们只在**打包机**上使用。
> 部署包交给学生后，学生按 03/04 手册直接解压运行。

## 二、一键打包

### Windows（PowerShell）

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy\build-package.ps1
```

如果 Maven 没有加入 `PATH`，可以显式指定：

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy\build-package.ps1 `
  -Maven "C:\Program Files\JetBrains\IntelliJ IDEA 2025.3.3\plugins\maven\lib\maven3\bin\mvn.cmd"
```

### Linux / macOS / Git Bash

```bash
bash deploy/build-package.sh
```

默认跳过后端测试，与实验手册的 `mvn package -DskipTests` 一致。
需要运行测试或跳过前端重新构建时：

```bash
bash deploy/build-package.sh --run-tests
bash deploy/build-package.sh --skip-frontend
```

PowerShell 对应参数为 `-RunTests`、`-SkipFrontend`、`-SkipNpmInstall`。

> 首次构建需要联网下载 Maven / npm 依赖，时间较长。
> 前端依赖由 `ruoyi-ui/package-lock.json` 锁定，打包脚本会优先执行 `npm ci`；
> 仓库的 `.gitattributes` 固定了前端构建源码的换行符，保证不同平台打出的前端与实验包一致。

## 三、产物

```text
dist/
├── website-package.zip          ← 上传到 /opt/packages/website-package.zip
└── website-package/
    ├── website.jar
    ├── website-frontend.zip
    ├── start.sh
    ├── stop.sh
    ├── check.sh
    ├── config/
    │   ├── connection.conf
    │   ├── application.yml
    │   └── application-druid.yml
    ├── sql/
    │   ├── ry_20260417.sql
    │   └── quartz.sql
    ├── systemd/
    │   └── website.service
    └── README-部署说明.md
```

`website-package.zip` 的顶层目录必须是 `website-package/`，因为实验手册中的
`01-website-install.sh` 和 `05-mysql-init-website-db.sh` 都按这个目录结构查找文件。

## 四、与实验手册的对应关系

| 实验手册中的文件/路径 | 本仓库中的来源 |
| --- | --- |
| `/opt/packages/website-package.zip` | `dist/website-package.zip` |
| 包内 `website.jar` | `ruoyi-admin/target/website.jar`（Maven `finalName`） |
| 包内 `website-frontend.zip` | `ruoyi-ui/dist/` 的内容重新压缩 |
| 包内 `config/connection.conf` | `deploy/package/config/connection.conf` |
| 包内 `config/application.yml` | `deploy/package/config/application.yml` |
| 包内 `config/application-druid.yml` | `deploy/package/config/application-druid.yml` |
| 包内 `start.sh` / `stop.sh` / `check.sh` | `deploy/package/` |
| 包内 `systemd/website.service` | `deploy/package/systemd/website.service` |
| 包内 `sql/*.sql` | 仓库根目录 `sql/` |
| `/opt/packages/03-backend/01-website-install.sh` | `deploy/03-backend/01-website-install.sh` |
| `/opt/packages/01-database/05-mysql-init-website-db.sh` | `deploy/01-database/05-mysql-init-website-db.sh` |
| `/etc/nginx/conf.d/00-upstream.conf` | `deploy/nginx/00-upstream.conf` |
| `/etc/nginx/conf.d/portal.conf` | `deploy/nginx/portal.conf` |
| 单机开发用 Nginx 配置（非实验手册） | `deploy/nginx/single-node/` |

## 五、配置读取方式

部署包内的 `config/application.yml` 和 `config/application-druid.yml` 只定义
数据库和 Redis 的连接字段，值来自环境变量：

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:127.0.0.1}
      ...
```

`systemd/website.service` 通过：

```ini
EnvironmentFile=/opt/website/config/connection.conf
```

把 `connection.conf` 中的 `DB_HOST`、`DB_PASSWORD`、`REDIS_HOST` 等变量注入 Java 进程；
`start.sh` 则用 `set -a; . config/connection.conf; set +a` 达到同样效果。
因此**只改 `connection.conf`**，不要修改两个 Spring 配置文件。

## 六、打包后自检

```bash
unzip -l dist/website-package.zip
unzip -l dist/website-package/website-frontend.zip
sha256sum dist/website-package.zip
```

应至少看到：

```text
website-package/website.jar
website-package/website-frontend.zip
website-package/config/connection.conf
website-package/config/application.yml
website-package/config/application-druid.yml
website-package/sql/ry_20260417.sql
website-package/sql/quartz.sql
website-package/systemd/website.service
```

前端包根目录应直接是 `index.html`、`static/`、`lb-lab.html`、`rewrite-lab.html`，
不能再套一层 `dist/`。

## 七、安全约定

- `deploy/package/config/connection.conf` 只放模板占位，不放真实密码。
- 打包脚本不会读取或写入 `/root/.mysql-website-password`、`/root/.redis-password`；
  这两个密码只在实验机上由学生填写到 `connection.conf`。
- 仓库中的 `application.yml`、`application-druid.yml` 只使用环境变量占位。
- 不要把 `dist/`、`website-package.zip`、`website-frontend.zip` 提交到仓库。
