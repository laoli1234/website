#!/bin/bash
# 门户网站后端环境准备脚本
# 功能：安装 JDK 17、解压 website-package.zip、创建运行账号和目录、
#       设置权限、备份连接配置模板。
#       不会自动打开 vi；连接配置由用户按 03-门户网站后端部署配置手册 第三章「手动修改连接配置」。
# 用法：bash /opt/packages/03-backend/01-website-install.sh
# 适用：db-backend-01 / db-backend-02（openEuler 24.03，root 执行）
# 说明：脚本里的 cat > 文件 <<'标记' 或 cat <<'标记' 段落，从 cat 行到单独一行标记结束，
#       整段由脚本自动写入目标文件，不需要手工复制。

set -u

APP_HOME="/opt/website"
APP_ZIP="/opt/packages/website-package.zip"
CONF="$APP_HOME/config/connection.conf"
JAVA_PROFILE="/etc/profile.d/java.sh"

info() { echo; echo "===== $1 ====="; }
fail() { echo "[FAIL] $1"; exit 1; }

# 0. 必须是 root
if [ "$(id -u)" -ne 0 ]; then
  echo "请用 root 执行：sudo bash $0"
  exit 1
fi

echo
echo "============================================================"
echo "  01-website-install.sh 开始执行"
echo "  本脚本将安装 JDK 17、解压 website-package.zip、创建 website"
echo "  运行账号和目录，并准备连接配置文件。"
echo "============================================================"

# 1. 安装 JDK 17
info "1/3 安装 JDK 17"
dnf install -y java-17-openjdk java-17-openjdk-devel || fail "JDK 17 安装失败，检查 DNF 源和网络"

JAVA_BIN=""
for candidate in /usr/lib/jvm/java-17-openjdk/bin/java /usr/lib/jvm/java-17-openjdk-*/bin/java; do
  if [ -x "$candidate" ]; then
    JAVA_BIN="$candidate"
    break
  fi
done
if [ -z "$JAVA_BIN" ]; then
  JAVA_BIN=$(command -v java || true)
fi
[ -n "$JAVA_BIN" ] || fail "安装后找不到 java 命令"
JAVA_PATH=$(dirname "$(dirname "$(readlink -f "$JAVA_BIN")")")
if command -v alternatives >/dev/null 2>&1; then
  alternatives --install /usr/bin/java java "$JAVA_PATH/bin/java" 2000 >/dev/null 2>&1 || true
  alternatives --set java "$JAVA_PATH/bin/java" >/dev/null 2>&1 || true
fi
if [ -f "$JAVA_PROFILE" ]; then
  JAVA_BAK="$JAVA_PROFILE.bak.$(date +%F-%H%M%S)"
  cp -a "$JAVA_PROFILE" "$JAVA_BAK"
  echo "原 java.sh 已备份到 $JAVA_BAK"
fi
cat > "$JAVA_PROFILE" <<EOF
export JAVA_HOME=$JAVA_PATH
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
# shellcheck disable=SC1090
. "$JAVA_PROFILE"
java -version || fail "java -version 执行失败"
echo "JAVA_HOME=$JAVA_HOME"
command -v jps || fail "jps 不存在，JDK 可能没装全"

# 2. 检查并解压部署包
info "2/3 准备 /opt/website"
if ! command -v unzip >/dev/null 2>&1; then
  dnf install -y unzip || fail "unzip 安装失败，请手动执行：dnf install -y unzip"
fi
[ -f "$APP_ZIP" ] || fail "找不到 $APP_ZIP；请确认 website-package.zip 已上传"

if [ ! -f "$APP_HOME/website.jar" ]; then
  if [ -d "$APP_HOME" ]; then
    BACKUP="$APP_HOME.bak.$(date +%F-%H%M%S)"
    mv "$APP_HOME" "$BACKUP"
    echo "旧目录已备份到 $BACKUP"
  fi
  rm -rf /opt/website-package
  UNZIP_RC=0
  unzip -o "$APP_ZIP" -d /opt >/dev/null || UNZIP_RC=$?
  if [ "$UNZIP_RC" -gt 1 ]; then
    fail "解压 $APP_ZIP 失败（unzip 返回 $UNZIP_RC），请检查压缩包是否完整"
  fi
  if [ "$UNZIP_RC" -eq 1 ]; then
    echo "[WARN] 压缩包使用 Windows 反斜杠路径，unzip 已自动转换并继续；下面检查文件是否完整。"
  fi
  mv /opt/website-package "$APP_HOME" || fail "移动 /opt/website-package 到 $APP_HOME 失败"
fi
[ -f "$APP_HOME/website.jar" ] || fail "$APP_HOME/website.jar 不存在，部署包内容不完整"
mkdir -p "$APP_HOME/logs" "$APP_HOME/uploadPath" || fail "创建 logs/uploadPath 目录失败"

# 3. 运行账号、权限和编辑工具
info "3/3 创建运行账号并设置权限"
CREATED_USER=0
if ! id website >/dev/null 2>&1; then
  useradd -r -s /sbin/nologin website || fail "创建 website 用户失败"
  CREATED_USER=1
  echo "已创建 website 用户（回退时可执行 userdel website）"
fi
chown -R website:website "$APP_HOME" || fail "设置 $APP_HOME 属主失败"
chmod +x "$APP_HOME/start.sh" "$APP_HOME/stop.sh" "$APP_HOME/check.sh" || fail "设置脚本可执行权限失败"
ls -lh "$APP_HOME" | sed -n '1,12p'

if ! command -v vi >/dev/null 2>&1; then
  dnf install -y vim-enhanced || fail "vi 安装失败，请手动执行：dnf install -y vim-enhanced"
fi

[ -f "$CONF" ] || fail "找不到 $CONF，部署包不完整"
chown website:website "$CONF" || fail "设置 $CONF 属主失败"
chmod 640 "$CONF" || fail "设置 $CONF 权限失败"
CONF_BAK="$CONF.bak.$(date +%F-%H%M%S)"
cp -a "$CONF" "$CONF_BAK" || fail "备份 $CONF 失败（检查磁盘空间）"
echo "连接配置模板已备份到 $CONF_BAK"

echo
echo "===== 环境准备完成 ====="
echo "本脚本已完成门户网站后端运行环境准备。"
echo "JDK 版本：$(java -version 2>&1 | head -n 1)"
echo "JDK 安装位置：$JAVA_HOME"
echo "网站目录：$APP_HOME"
echo "启动脚本：$APP_HOME/start.sh"
echo "连接配置：$CONF"
echo
echo "连接配置还没有填写，请手动执行："
echo "  vi $CONF"
echo "填好并保存后，执行自检："
echo "  cd $APP_HOME && ./check.sh"
echo "自检通过后，再用 systemd 启动网站服务。"
if [ "$CREATED_USER" -eq 1 ]; then
  echo "提示：本次脚本创建了 website 用户；回退时可执行 userdel website。"
fi
