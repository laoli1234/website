#!/bin/bash
# 停止门户网站后端

APP_HOME=$(cd "$(dirname "$0")" && pwd)
PID_FILE="$APP_HOME/website.pid"

if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    for i in $(seq 1 20); do
      kill -0 "$PID" 2>/dev/null || break
      sleep 0.5
    done
    if kill -0 "$PID" 2>/dev/null; then
      echo "进程未退出，强制结束：$PID"
      kill -9 "$PID" 2>/dev/null
    fi
    echo "后端已停止"
  else
    echo "进程不存在，清理 PID 文件"
  fi
  rm -f "$PID_FILE"
else
  if pgrep -f "$APP_HOME/website.jar" >/dev/null 2>&1; then
    pkill -f "$APP_HOME/website.jar"
    echo "已按 jar 路径停止后端"
  else
    echo "后端未在运行"
  fi
fi
