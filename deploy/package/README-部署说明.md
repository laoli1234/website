# 门户网站部署手册

> 环境：一台 Linux 虚拟机（openEuler / CentOS / Ubuntu）
> 部署前需要准备：JDK 17、MySQL 8、Redis、Nginx
> 部署方式：前端、后端、MySQL、Redis 都在同一台机器

---

## 一、包内文件

```
website-package
├── website.jar                 后端程序
├── website-frontend.zip        前端页面（解压后根目录是 index.html）
├── start.sh                    启动后端
├── stop.sh                     停止后端
├── check.sh                    部署前自检
├── config
│   ├── connection.conf         唯一需要修改的文件
│   ├── application.yml         已写好，不用改
│   └── application-druid.yml   已写好，不用改
├── sql
│   ├── ry_20260417.sql
│   └── quartz.sql
├── systemd
│   └── website.service
└── README-部署说明.md
```

部署后：

| 路径 | 用途 |
| --- | --- |
| `/opt/website` | 后端、配置、日志、上传文件 |
| `/opt/website/logs` | 后端日志（自动创建） |
| `/opt/website/uploadPath` | 上传文件（自动创建） |
| `/opt/website-ui` | 前端页面 |

---

## 二、安装依赖

openEuler / CentOS：

```bash
sudo dnf install -y java-17-openjdk java-17-openjdk-devel mysql-server mysql redis nginx unzip
sudo systemctl enable --now mysqld redis nginx
java -version    # 需要 17.x
```

Ubuntu / Debian：

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk mysql-server mysql-client redis-server nginx unzip
```

---

## 三、把包放到 /opt/website

进入解压后的包目录（能看到 `website.jar`、`config`、`sql`），执行：

```bash
sudo mkdir -p /opt/website
sudo cp -r . /opt/website/
cd /opt/website
chmod +x start.sh stop.sh check.sh
```

---

## 四、初始化数据库

```bash
mysql -u root -p
```

执行（密码换成自己的）：

```sql
CREATE DATABASE IF NOT EXISTS `ry-vue`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER 'website'@'%' IDENTIFIED BY '你的数据库密码';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX,
      CREATE TEMPORARY TABLES, LOCK TABLES
  ON `ry-vue`.* TO 'website'@'%';
FLUSH PRIVILEGES;
EXIT;
```

导入脚本，顺序不能反：

```bash
mysql -u root -p 'ry-vue' < /opt/website/sql/ry_20260417.sql
mysql -u root -p 'ry-vue' < /opt/website/sql/quartz.sql
```

验证（应输出 31）：

```bash
mysql -u root -p -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='ry-vue';"
```

---

## 五、只改一个文件

编辑 `config/connection.conf`，填数据库和 Redis 信息：

```ini
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=ry-vue
DB_USER=website
DB_PASSWORD=你的数据库密码

REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=
```

- 数据库/Redis 不在本机时改对应 HOST。
- Redis 没有密码时 `REDIS_PASSWORD=` 留空。
- 密码含空格时用单引号包起来，例如 `DB_PASSWORD='abc 123'`。
- 实例标识自动取「主机名:端口」（如 `db-backend-01:8080`），不需要配置。
- `config/application.yml` 和 `application-druid.yml` **不需要修改**，它们会自动读取这个文件。

---

## 六、自检并启动

```bash
cd /opt/website
./check.sh
```

全部 `OK` 后：

```bash
./start.sh
```

等待约 30 秒，验证：

```bash
curl http://127.0.0.1:8080/lb/info
# 期望：{"instanceId":"db-backend-01:8080", ...}（第二台为 db-backend-02:8080）

curl -s -X POST http://127.0.0.1:8080/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'
# 期望：{"code":200,"msg":"操作成功","token":"..."}
```

停止：

```bash
./stop.sh
```

日志（自动生成，不需要配置）：

```bash
tail -f /opt/website/logs/sys-info.log
tail -f /opt/website/logs/sys-error.log
tail -f /opt/website/logs/console.log
```

---

## 七、部署前端

```bash
sudo mkdir -p /opt/website-ui
sudo unzip /opt/website/website-frontend.zip -d /opt/website-ui
ls /opt/website-ui     # 应看到 index.html、static

# openEuler / CentOS
sudo chown -R nginx:nginx /opt/website-ui
sudo chmod -R 755 /opt/website-ui

# Ubuntu 使用 www-data
# sudo chown -R www-data:www-data /opt/website-ui
```

---

## 八、前端访问配置（Nginx 由部署环境统一配置）

本部署包**不提供 Nginx 配置文件**，Nginx 由部署环境统一配置。前端解压到 `/opt/website-ui` 后，Nginx 需要满足以下三点：

```nginx
root /opt/website-ui;
index index.html;

location / {
    try_files $uri $uri/ /index.html;
}

location ^~ /prod-api/ {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location ^~ /profile/ {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $http_host;
}
```

配置完成后由环境维护人员执行：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

放行端口与 SELinux：

```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
sudo setsebool -P httpd_can_network_connect 1
```

---

## 九、访问验证

| 地址 | 期望 |
| --- | --- |
| `http://服务器IP/portal` | 门户首页 |
| `http://服务器IP/login` | 后台登录（无验证码） |
| `http://服务器IP/rewrite-lab.html` | rewrite 演示台 |
| `http://服务器IP/lb-lab.html` | 后端实例信息 |

账号：`admin` / `admin123`，登录后请修改密码。

---

## 十、使用 systemd 托管（可选）

```bash
sudo useradd -r -s /sbin/nologin website 2>/dev/null || true
sudo mkdir -p /opt/website/logs /opt/website/uploadPath
sudo chown -R website:website /opt/website

sudo cp /opt/website/systemd/website.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now website
sudo systemctl status website --no-pager
```

使用 systemd 后不要再执行 `./start.sh`，二者只能选一个。

---

## 十一、常见问题

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `check.sh` 提示数据库密码是占位符 | 没改 `connection.conf` | 填写 `DB_PASSWORD` |
| 启动报 `Access denied for user 'website'` | 账号、密码或授权不对 | 重新执行建用户和 GRANT |
| 启动报 `Unknown database 'ry-vue'` | 没有建库 | 按第四节建库 |
| Redis 报 `NOAUTH` | Redis 有密码但没填 | 填写 `REDIS_PASSWORD` |
| 后端启动失败 | 看日志定位 | `cat /opt/website/logs/console.log` |
| 登录接口 404 | Nginx 没代理 `/prod-api/` | 检查环境提供的 Nginx 配置 |
| 页面 502 | 后端没启动或 8080 不通 | `curl 127.0.0.1:8080/lb/info` |
| 刷新页面 404 | 缺少 history 回退 | 确认 `try_files $uri $uri/ /index.html;` |
| 上传头像失败 | 上传目录无权限 | `mkdir -p /opt/website/uploadPath` 并授权 |
| 8080 被占用 | 重复启动 | 先 `./stop.sh`，再 `ss -lntp \| grep 8080` |
| 中文乱码 | 数据库不是 utf8mb4 | 按第三节建库 |

---

## 十二、验收清单

- [ ] `./check.sh` 全部 OK
- [ ] `curl /lb/info` 返回「主机名:端口」，两台不同
- [ ] `curl /login` 能拿到 token
- [ ] `/portal`、`/login` 页面正常
- [ ] 登录后能进入首页、用户管理
- [ ] 上传头像或附件成功
- [ ] 80、8080 端口监听正常
- [ ] 已修改 admin 默认密码
