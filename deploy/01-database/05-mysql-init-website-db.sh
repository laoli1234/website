#!/usr/bin/env bash
#
# 05-mysql-init-website-db.sh
# 在主库创建业务库 ry-vue、导入网站 SQL、创建 website 业务账号。
# 只在 db-backend-01 执行。
#
# 密码自动生成（20 位强密码，含大小写字母、数字和特殊字符），保存在 /root/.mysql-website-password（仅 root 可读）。
# 如果密码文件已存在，脚本会复用它，并把数据库里的密码同步成该值。
# 脚本结束时会显示：业务库名、账号、密码，请妥善保存。

set -euo pipefail

ROOT_PW_FILE="/root/.mysql-root-password"
PACKAGE="/opt/packages/website-package.zip"
SQL_DIR="/opt/website-package/sql"
DB_NAME="ry-vue"
WEB_USER="website"
WEB_HOST="192.168.11.%"
WEB_PW_FILE="/root/.mysql-website-password"

info()  { printf '\033[1;32m[INFO]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

[ "$(id -u)" -eq 0 ] || { error "请使用 root 用户执行本脚本。"; exit 1; }
[ -f "$ROOT_PW_FILE" ] || { error "找不到 $ROOT_PW_FILE，请先执行 01-mysql-install.sh。"; exit 1; }
[ -f "$PACKAGE" ] || { error "找不到 $PACKAGE，请先上传 website-package.zip。"; exit 1; }
ROOT_PW="$(cat "$ROOT_PW_FILE")"
mysql -u root -p"$ROOT_PW" -e "SELECT 1;" >/dev/null 2>&1 || { error "无法用 root 登录 MySQL，请检查 $ROOT_PW_FILE 和 mysqld 状态。"; exit 1; }

gen_password() {
  local pw n
  while :; do
    pw="$(head -c 256 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9@%+=:.,_-')"
    pw="${pw:0:20}"
    if [[ ${#pw} -eq 20 && "$pw" == *[A-Z]* && "$pw" == *[a-z]* && "$pw" == *[0-9]* && "$pw" == *[@%+=:.,_-]* ]]; then
      n=0
      while [[ "${pw:0:1}" != [A-Za-z0-9] && "$n" -lt 20 ]]; do
        pw="${pw:1}${pw:0:1}"
        n=$((n + 1))
      done
      break
    fi
  done
  printf '%s\n' "$pw"
}

echo
echo "============================================================"
echo "  05-mysql-init-website-db.sh 开始执行"
echo "  本脚本将创建业务库 $DB_NAME、导入网站 SQL，并创建 $WEB_USER 业务账号。"
echo "============================================================"

if [ ! -f "$SQL_DIR/ry_20260417.sql" ] || [ ! -f "$SQL_DIR/quartz.sql" ]; then
  info "解压 website-package.zip 到 /opt ..."
  rm -rf /opt/website-package
  UNZIP_RC=0
  unzip -o "$PACKAGE" -d /opt >/dev/null || UNZIP_RC=$?
  if [ "$UNZIP_RC" -gt 1 ]; then
    error "解压 website-package.zip 失败（unzip 返回 $UNZIP_RC），请检查压缩包是否完整。"
    exit 1
  fi
  if [ "$UNZIP_RC" -eq 1 ]; then
    info "unzip 返回警告（压缩包使用 Windows 反斜杠路径），已继续，下面检查文件是否完整。"
  fi
fi
[ -f "$SQL_DIR/ry_20260417.sql" ] || { error "找不到 $SQL_DIR/ry_20260417.sql。请确认压缩包内的目录结构是 website-package/sql/..."; exit 1; }
[ -f "$SQL_DIR/quartz.sql" ] || { error "找不到 $SQL_DIR/quartz.sql。请确认压缩包内的目录结构是 website-package/sql/..."; exit 1; }

TABLE_COUNT="$(mysql -u root -p"$ROOT_PW" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" 2>/dev/null || echo 0)"
if [ "${TABLE_COUNT:-0}" != "0" ]; then
  error "数据库 $DB_NAME 已有 $TABLE_COUNT 张表，为避免覆盖，脚本退出。"
  error "如果要重新初始化，请先按本脚本的回退说明清空数据库，再重跑本脚本。"
  exit 1
fi

if [ -f "$WEB_PW_FILE" ]; then
  WEB_PW="$(cat "$WEB_PW_FILE")"
  [ -n "$WEB_PW" ] || { error "密码文件 $WEB_PW_FILE 为空，请删除后重跑本脚本。"; exit 1; }
  info "检测到已保存的 website 密码，直接复用。"
else
  WEB_PW="$(gen_password)"
  umask 077
  printf '%s\n' "$WEB_PW" > "$WEB_PW_FILE"
  info "已生成新的 website 密码。"
fi
chmod 600 "$WEB_PW_FILE" 2>/dev/null || true

info "创建数据库 $DB_NAME ..."
if ! mysql -u root -p"$ROOT_PW" -e "
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;"; then
  error "创建数据库 $DB_NAME 失败，请检查上面的 MySQL 错误信息。"
  exit 1
fi

info "导入 ry_20260417.sql ..."
mysql -u root -p"$ROOT_PW" "$DB_NAME" < "$SQL_DIR/ry_20260417.sql"

info "导入 quartz.sql ..."
mysql -u root -p"$ROOT_PW" "$DB_NAME" < "$SQL_DIR/quartz.sql"

info "创建业务账号 $WEB_USER ..."
if ! mysql -u root -p"$ROOT_PW" -e "
CREATE USER IF NOT EXISTS '$WEB_USER'@'$WEB_HOST' IDENTIFIED BY '$WEB_PW';
ALTER USER '$WEB_USER'@'$WEB_HOST' IDENTIFIED BY '$WEB_PW';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX,
      CREATE TEMPORARY TABLES, LOCK TABLES
  ON \`$DB_NAME\`.* TO '$WEB_USER'@'$WEB_HOST';
FLUSH PRIVILEGES;"; then
  error "创建业务账号 $WEB_USER 失败。常见原因：密码不符合 MySQL 密码策略。"
  exit 1
fi

info "验证表和账号 ..."
COUNT="$(mysql -u root -p"$ROOT_PW" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" 2>/dev/null)"
echo "表数量：$COUNT"
mysql -u root -p"$ROOT_PW" -N -e "SELECT user_name, nick_name FROM \`$DB_NAME\`.sys_user LIMIT 3;" 2>/dev/null

if [ "$COUNT" != "31" ]; then
  error "表数量是 $COUNT，不是预期的 31。导入可能不完整，请按本脚本的回退说明处理后重跑。"
  exit 1
fi

info "用业务账号从本机测试 ..."
SELF_TEST_OK=1
mysql -h 192.168.11.11 -u "$WEB_USER" -p"$WEB_PW" -N -e "SELECT COUNT(*) FROM \`$DB_NAME\`.sys_user;" 2>/dev/null || SELF_TEST_OK=0

echo
echo "============================================================"
echo "  业务库初始化完成"
echo "  数据库：$DB_NAME"
echo "  账号：$WEB_USER"
echo "  允许来源：$WEB_HOST"
echo "  密码：$WEB_PW"
echo "  密码文件：$WEB_PW_FILE（仅 root 可读）"
echo
echo "  MySQL 版本：$(mysqld --version 2>/dev/null | head -n 1 || true)"
echo "  安装位置：$(command -v mysqld 2>/dev/null || echo /usr/sbin/mysqld)"
echo "  数据目录：/var/lib/mysql"
echo
echo "  请务必妥善保存该密码！配置后端连接时要填写它。"
echo "============================================================"

if [ "$SELF_TEST_OK" -ne 1 ]; then
  error "业务账号连接测试失败，请检查 GRANT、3306 监听和密码。"
  exit 1
fi
