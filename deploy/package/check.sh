#!/bin/bash
# 部署前环境自检
# 用法：./check.sh
#
# 本脚本按 config/connection.conf 的实际值检查：
#   1. DB_HOST / REDIS_HOST 是否是本实验规定的地址
#   2. 用 DB_USER / DB_PASSWORD 真正登录 MySQL
#   3. 用 REDIS_PASSWORD 真正登录 Redis 并执行 PING

APP_HOME=$(cd "$(dirname "$0")" && pwd)
CONF="$APP_HOME/config/connection.conf"

# 本实验固定连接地址；如果实验网段改了，这里也要改
EXPECTED_DB_HOST="192.168.11.11"
EXPECTED_REDIS_HOST="192.168.11.12"

if [ -f "$CONF" ]; then
  set -a
  . "$CONF"
  set +a
fi

MYSQL_HOST=${DB_HOST:-127.0.0.1}
MYSQL_PORT=${DB_PORT:-3306}
MYSQL_DB=${DB_NAME:-ry-vue}
MYSQL_USER=${DB_USER:-website}
REDIS_HOST=${REDIS_HOST:-127.0.0.1}
REDIS_PORT=${REDIS_PORT:-6379}

PASS=0
FAIL=0

ok()  { echo "[ OK ] $1"; PASS=$((PASS+1)); }
bad() { echo "[FAIL] $1"; FAIL=$((FAIL+1)); }

port_open() {
  timeout 2 bash -c "</dev/tcp/$1/$2" >/dev/null 2>&1
}

# 不依赖 redis-cli：直接用 Redis RESP 协议做 AUTH + PING
redis_ping() {
  local host="$1" port="$2" pass="${3:-}"
  REDIS_PASS="$pass" timeout 3 bash -c '
    host=$1
    port=$2
    exec 3<>"/dev/tcp/$host/$port" || exit 1
    if [ -n "${REDIS_PASS:-}" ]; then
      printf "*2\r\n\$4\r\nAUTH\r\n\$%s\r\n%s\r\n" "${#REDIS_PASS}" "$REDIS_PASS" >&3
      IFS= read -r -t 2 line <&3 || exit 1
      case "$line" in
        +OK*) ;;
        *) exit 1 ;;
      esac
    fi
    printf "*1\r\n\$4\r\nPING\r\n" >&3
    IFS= read -r -t 2 line <&3 || exit 1
    case "$line" in
      +PONG*) exit 0 ;;
      *) exit 1 ;;
    esac
  ' _ "$host" "$port"
}

echo "===== 门户网站部署自检 ====="
echo

# 1. Java
if command -v java >/dev/null 2>&1; then
  JAVA_MAJOR=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)
  if [ "$JAVA_MAJOR" = "17" ]; then
    ok "JDK 版本 17"
  else
    bad "JDK 版本为 ${JAVA_MAJOR:-未知}，需要 JDK 17"
  fi
else
  bad "未找到 java 命令，请安装 JDK 17"
fi

# 2. 文件
[ -f "$APP_HOME/website.jar" ] && ok "website.jar 存在" || bad "缺少 website.jar"
[ -f "$CONF" ] && ok "config/connection.conf 存在" || bad "缺少 config/connection.conf"
[ -f "$APP_HOME/config/application.yml" ] && ok "config/application.yml 存在" || bad "缺少 config/application.yml"
[ -f "$APP_HOME/config/application-druid.yml" ] && ok "config/application-druid.yml 存在" || bad "缺少 config/application-druid.yml"

# 3. 连接配置
echo
echo "MySQL：$MYSQL_HOST:$MYSQL_PORT  库：$MYSQL_DB  用户：$MYSQL_USER"
echo "Redis：$REDIS_HOST:$REDIS_PORT"

if [ "$MYSQL_HOST" = "$EXPECTED_DB_HOST" ]; then
  ok "DB_HOST 是 $EXPECTED_DB_HOST"
else
  bad "DB_HOST 是 ${MYSQL_HOST:-空}，必须改成 $EXPECTED_DB_HOST（不能留 127.0.0.1）"
fi

if [ "$REDIS_HOST" = "$EXPECTED_REDIS_HOST" ]; then
  ok "REDIS_HOST 是 $EXPECTED_REDIS_HOST"
else
  bad "REDIS_HOST 是 ${REDIS_HOST:-空}，必须改成 $EXPECTED_REDIS_HOST（不能留 127.0.0.1）"
fi

if [ -f "$CONF" ] && grep -q "你的数据库密码" "$CONF"; then
  bad "DB_PASSWORD 仍然填写的是占位密码"
elif [ -z "${DB_PASSWORD:-}" ]; then
  bad "DB_PASSWORD 为空，请填写数据库密码"
else
  ok "DB_PASSWORD 已填写"
fi

if [ -z "${REDIS_PASSWORD:-}" ]; then
  echo "[WARN] REDIS_PASSWORD 为空；如果 Redis 没有密码可忽略，有密码时必须填写"
else
  ok "REDIS_PASSWORD 已填写"
fi

# 4. MySQL：先测端口，再用配置里的账号密码真正登录
if port_open "$MYSQL_HOST" "$MYSQL_PORT"; then
  ok "MySQL 端口可连接（$MYSQL_HOST:$MYSQL_PORT）"
else
  bad "MySQL 端口连接失败（$MYSQL_HOST:$MYSQL_PORT）"
fi

if command -v mysql >/dev/null 2>&1; then
  if MYSQL_PWD="${DB_PASSWORD:-}" mysql --connect-timeout=3 \
      -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" \
      -N -e "SELECT 1" "$MYSQL_DB" >/dev/null 2>&1; then
    ok "MySQL 登录成功（$MYSQL_USER@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB）"
  else
    bad "MySQL 登录失败（$MYSQL_USER@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB），检查 DB_PASSWORD/DB_USER/DB_NAME"
  fi
else
  echo "[WARN] 未安装 mysql 客户端，跳过 MySQL 登录检查"
fi

# 5. Redis：先测端口，再用配置里的密码真正登录并 PING
if port_open "$REDIS_HOST" "$REDIS_PORT"; then
  ok "Redis 端口可连接（$REDIS_HOST:$REDIS_PORT）"
else
  bad "Redis 端口连接失败（$REDIS_HOST:$REDIS_PORT）"
fi

if redis_ping "$REDIS_HOST" "$REDIS_PORT" "${REDIS_PASSWORD:-}"; then
  ok "Redis 登录成功（$REDIS_HOST:$REDIS_PORT）"
else
  bad "Redis 登录失败（$REDIS_HOST:$REDIS_PORT），检查 REDIS_PASSWORD"
fi

# 6. 8080
if port_open 127.0.0.1 8080; then
  echo "[WARN] 8080 已有服务在监听，可能后端已经启动，或端口被占用"
else
  ok "8080 空闲"
fi

# 7. 目录
mkdir -p "$APP_HOME/logs" "$APP_HOME/uploadPath"
[ -w "$APP_HOME/logs" ] && ok "日志目录可写（$APP_HOME/logs）" || bad "日志目录不可写"
[ -w "$APP_HOME/uploadPath" ] && ok "上传目录可写（$APP_HOME/uploadPath）" || bad "上传目录不可写"

# 8. Nginx（前端可能与后端不在同一台，缺失只提示）
if command -v nginx >/dev/null 2>&1; then
  ok "Nginx 已安装"
else
  echo "[WARN] 本机未安装 Nginx；如果前端由另一台服务器提供可忽略"
fi

echo
echo "===== 结果：通过 $PASS 项，失败 $FAIL 项 ====="
[ "$FAIL" -eq 0 ] || exit 1
