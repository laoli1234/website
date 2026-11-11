#!/usr/bin/env bash
#
# 构建企业门户网站实验部署包 website-package.zip
#
# 用法：
#   bash deploy/build-package.sh
#   bash deploy/build-package.sh --run-tests
#   bash deploy/build-package.sh --skip-frontend
#   MVN=/opt/apache-maven/bin/mvn bash deploy/build-package.sh
#
# 产物：
#   dist/website-package.zip         上传到 /opt/packages/website-package.zip
#   dist/website-package/            部署包解压后的目录
#
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DEPLOY_DIR/.." && pwd)"
TEMPLATE_DIR="$DEPLOY_DIR/package"
OUTPUT_DIR="$REPO_ROOT/dist"
PACKAGE_DIR="$OUTPUT_DIR/website-package"
PACKAGE_ZIP="$OUTPUT_DIR/website-package.zip"
FRONTEND_DIST="$REPO_ROOT/ruoyi-ui/dist"
FRONTEND_ZIP="$PACKAGE_DIR/website-frontend.zip"
JAR_PATH="$REPO_ROOT/ruoyi-admin/target/website.jar"

MVN="${MVN:-mvn}"
RUN_TESTS=0
SKIP_FRONTEND=0
SKIP_NPM_INSTALL=0

info() { printf '\n==> %s\n' "$1"; }
fail() { printf '\n[FAIL] %s\n' "$1" >&2; exit 1; }

usage() {
  cat <<'EOF'
用法：bash deploy/build-package.sh [选项]

选项：
  --run-tests        运行后端单元测试（默认跳过，与 mvn package -DskipTests 一致）
  --skip-frontend    跳过 npm 构建，直接使用已有的 ruoyi-ui/dist
  --skip-npm-install 跳过 npm install，直接使用已有的 node_modules
  --maven PATH       指定 Maven 可执行文件
  -h, --help         显示本帮助

环境变量：
  MVN                指定 Maven 可执行文件，等价于 --maven
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-tests) RUN_TESTS=1 ;;
    --skip-frontend) SKIP_FRONTEND=1 ;;
    --skip-npm-install) SKIP_NPM_INSTALL=1 ;;
    --maven)
      [[ $# -ge 2 ]] || fail "--maven 需要一个路径"
      MVN="$2"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) fail "未知参数：$1（使用 --help 查看用法）" ;;
  esac
  shift
done

resolve_exec() {
  local name="$1"
  if [[ -x "$name" ]]; then
    printf '%s\n' "$name"
    return 0
  fi
  command -v "$name" 2>/dev/null && return 0
  return 1
}

echo "============================================================"
echo "  企业门户网站部署包构建"
echo "  仓库：$REPO_ROOT"
echo "============================================================"

info "检查构建环境"

command -v java >/dev/null 2>&1 || fail "找不到 java，请安装 JDK 17 并加入 PATH。"
JAVA_VERSION_LINE="$(java -version 2>&1 | head -n 1)"
JAVA_MAJOR="$(printf '%s\n' "$JAVA_VERSION_LINE" | sed -n 's/.*version "\([0-9]*\).*/\1/p')"
if [[ -n "$JAVA_MAJOR" && "$JAVA_MAJOR" -lt 17 ]]; then
  fail "当前 Java 主版本为 $JAVA_MAJOR，需要 JDK 17 或更高版本。"
fi
echo "Java：${JAVA_MAJOR:-未知}（$JAVA_VERSION_LINE）"

MVN_EXE="$(resolve_exec "$MVN")" || fail "找不到 Maven（$MVN）。请安装 Maven 3.8+，或用 MVN=... 指定路径。"
echo "Maven：$MVN_EXE"

if [[ "$SKIP_FRONTEND" -eq 0 ]]; then
  command -v npm >/dev/null 2>&1 || fail "找不到 npm，请安装 Node.js 20 LTS+。"
  echo "npm：$(command -v npm)"
fi

command -v zip >/dev/null 2>&1 || fail "找不到 zip 命令。Linux 请安装 zip；Windows 请改用 build-package.ps1。"

info "1/4 Maven 打包后端"

(
  cd "$REPO_ROOT"
  if [[ "$RUN_TESTS" -eq 1 ]]; then
    "$MVN_EXE" clean package
  else
    "$MVN_EXE" clean package -DskipTests
  fi
) || fail "Maven 构建失败。"

[[ -f "$JAR_PATH" ]] || fail "Maven 构建结束，但找不到 $JAR_PATH。请确认 ruoyi-admin/pom.xml 的 finalName 为 website。"
JAR_SIZE="$(wc -c < "$JAR_PATH" | tr -d ' ')"
[[ "$JAR_SIZE" -gt 1048576 ]] || fail "website.jar 大小异常（$JAR_SIZE 字节），构建可能不完整。"
printf 'website.jar：%s 字节\n' "$JAR_SIZE"

info "2/4 构建前端"

if [[ "$SKIP_FRONTEND" -eq 0 ]]; then
  (
    cd "$REPO_ROOT/ruoyi-ui"
    if [[ "$SKIP_NPM_INSTALL" -eq 0 ]]; then
      # 有锁文件时用 npm ci，确保依赖版本与实验包构建时一致
      if [[ -f "$REPO_ROOT/ruoyi-ui/package-lock.json" ]]; then
        npm ci --no-audit --no-fund
      else
        npm install --no-audit --no-fund
      fi
    fi
    npm run build:prod
  ) || fail "前端构建失败。"
else
  echo "已跳过前端构建（--skip-frontend）。"
fi

[[ -f "$FRONTEND_DIST/index.html" ]] || fail "找不到 $FRONTEND_DIST/index.html，前端构建没有完成。"

info "3/4 组装 website-package 目录"

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
cp -a "$TEMPLATE_DIR/." "$PACKAGE_DIR/"
cp -a "$JAR_PATH" "$PACKAGE_DIR/website.jar"

mkdir -p "$PACKAGE_DIR/sql"
cp -a "$REPO_ROOT/sql/ry_20260417.sql" "$PACKAGE_DIR/sql/"
cp -a "$REPO_ROOT/sql/quartz.sql" "$PACKAGE_DIR/sql/"

# 确保 Linux 脚本和配置是 LF，避免在 openEuler 上出现 \r 错误
normalize_lf() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if command -v perl >/dev/null 2>&1; then
    perl -pi -e 's/\r\n/\n/g' "$file"
  else
    sed -i 's/\r$//' "$file"
  fi
}
normalize_lf "$PACKAGE_DIR/start.sh"
normalize_lf "$PACKAGE_DIR/stop.sh"
normalize_lf "$PACKAGE_DIR/check.sh"
normalize_lf "$PACKAGE_DIR/config/connection.conf"
normalize_lf "$PACKAGE_DIR/config/application.yml"
normalize_lf "$PACKAGE_DIR/config/application-druid.yml"
normalize_lf "$PACKAGE_DIR/systemd/website.service"
normalize_lf "$PACKAGE_DIR/README-部署说明.md"

chmod +x "$PACKAGE_DIR/start.sh" "$PACKAGE_DIR/stop.sh" "$PACKAGE_DIR/check.sh"

info "4/4 生成前端包和部署包"

rm -f "$FRONTEND_ZIP"
(
  cd "$FRONTEND_DIST"
  zip -qrD "$FRONTEND_ZIP" .
)

rm -f "$PACKAGE_ZIP"
(
  cd "$OUTPUT_DIR"
  zip -qrD "$PACKAGE_ZIP" "website-package"
)

REQUIRED_ENTRIES=(
  "website-package/website.jar"
  "website-package/website-frontend.zip"
  "website-package/start.sh"
  "website-package/stop.sh"
  "website-package/check.sh"
  "website-package/config/connection.conf"
  "website-package/config/application.yml"
  "website-package/config/application-druid.yml"
  "website-package/sql/ry_20260417.sql"
  "website-package/sql/quartz.sql"
  "website-package/systemd/website.service"
)
if command -v unzip >/dev/null 2>&1; then
  ZIP_ENTRIES="$(unzip -Z1 "$PACKAGE_ZIP")"
  for required in "${REQUIRED_ENTRIES[@]}"; do
    printf '%s\n' "$ZIP_ENTRIES" | grep -Fxq "$required" \
      || fail "部署包缺少 $required。"
  done
else
  echo "[WARN] 未安装 unzip，跳过压缩包内容校验。"
fi

echo
echo "============================================================"
echo "  打包完成"
echo "  部署包：$PACKAGE_ZIP"
echo "  前端包：$FRONTEND_ZIP"
if command -v sha256sum >/dev/null 2>&1; then
  echo "  SHA256：$(sha256sum "$PACKAGE_ZIP" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  echo "  SHA256：$(shasum -a 256 "$PACKAGE_ZIP" | awk '{print $1}')"
fi
echo
echo "  上传到实验机：/opt/packages/website-package.zip"
echo "  后端安装脚本：deploy/03-backend/01-website-install.sh"
echo "  数据库脚本：  deploy/01-database/05-mysql-init-website-db.sh"
echo "  Nginx 配置：  deploy/nginx/00-upstream.conf、deploy/nginx/portal.conf"
echo "============================================================"
