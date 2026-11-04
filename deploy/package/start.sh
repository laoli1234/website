#!/bin/bash
# 启动门户网站后端
# 只需修改 config/connection.conf，然后执行 ./start.sh

set -e

APP_HOME=$(cd "$(dirname "$0")" && pwd)
JAR="$APP_HOME/website.jar"
PID_FILE="$APP_HOME/website.pid"
LOG_FILE="$APP_HOME/logs/console.log"
CONF="$APP_HOME/config/connection.conf"

[ -f "$JAR" ] || { echo "错误：找不到 $JAR"; exit 1; }
command -v java >/dev/null 2>&1 || { echo "错误：未安装 JDK，请先安装 JDK 17"; exit 1; }

# 读取数据库与 Redis 连接信息
if [ -f "$CONF" ]; then
  set -a
  . "$CONF"
  set +a
else
  echo "错误：找不到 $CONF"
  exit 1
fi

mkdir -p "$APP_HOME/logs" "$APP_HOME/uploadPath"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "后端已在运行，PID=$(cat "$PID_FILE")"
  exit 0
fi

cd "$APP_HOME"
nohup java -Xms256m -Xmx512m -Duser.timezone=Asia/Shanghai \
  -DLOG_PATH="$APP_HOME/logs" \
  -Druoyi.profile="$APP_HOME/uploadPath" \
  -jar "$JAR" \
  --spring.config.additional-location=optional:file:"$APP_HOME/config/" \
  --server.forward-headers-strategy=framework \
  >> "$LOG_FILE" 2>&1 &

echo $! > "$PID_FILE"
echo "后端启动中，PID=$(cat "$PID_FILE")"
echo "日志：$LOG_FILE"
echo "等待约 30 秒后执行：curl http://127.0.0.1:8080/lb/info"
