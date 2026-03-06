#!/bin/bash
set -euo pipefail

SERVER_DIR="/home/container"
NGINX_RENDERED_CONF="${SERVER_DIR}/nginx.conf"
NGINX_DIR="${SERVER_DIR}/nginx"

cd "$SERVER_DIR"
echo ">> Server directory: $SERVER_DIR"

mkdir -p \
  "${SERVER_DIR}/www" \
  "${SERVER_DIR}/www/cache" \
  "${SERVER_DIR}/www/config" \
  "$NGINX_DIR"/{tmp,logs,client_body,fastcgi,proxy,uwsgi,scgi}

: "${WEB_PORT:=8080}"
echo ">> Rendering nginx config for WEB_PORT=${WEB_PORT}..."
sed "s/{{WEB_PORT}}/${WEB_PORT}/g" /etc/nginx/template.conf > "${NGINX_RENDERED_CONF}"

PHP_FPM_CONF="${SERVER_DIR}/php-fpm.conf"
PHP_FPM_SOCK="${SERVER_DIR}/php-fpm.sock"

cat > "${PHP_FPM_CONF}" <<EOF
[global]
error_log = /proc/self/fd/2
daemonize = no
pid = ${SERVER_DIR}/php-fpm.pid

[www]
listen = ${PHP_FPM_SOCK}
listen.mode = 0660

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

clear_env = no
EOF

echo ">> Starting PHP-FPM..."
php-fpm8.3 --fpm-config "${PHP_FPM_CONF}" &

if [ -d "${SERVER_DIR}/myaac" ]; then
  cd "${SERVER_DIR}/myaac"
  if [ ! -d vendor ]; then
    echo ">> Installing MyAAC PHP dependencies..."
    php composer.phar install --no-dev --optimize-autoloader 2>/dev/null || true
  fi
  # Write database config from environment so MyAAC uses same DB as TFS server
  if [ -n "${MYSQL_HOST:-}" ]; then
    echo ">> Writing MyAAC config.local.php from environment..."
    cat > config.local.php <<EOPHP
<?php
\$config['database_host'] = getenv('MYSQL_HOST') ?: 'localhost';
\$config['database_port'] = getenv('MYSQL_PORT') ?: '3306';
\$config['database_user'] = getenv('MYSQL_USER') ?: 'root';
\$config['database_password'] = getenv('MYSQL_PASSWORD') ?: '';
\$config['database_name'] = getenv('MYSQL_DATABASE') ?: 'forgottenserver';
EOPHP
  fi
fi

echo ">> Starting nginx..."
nginx -c "${NGINX_RENDERED_CONF}" -p "${SERVER_DIR}"

term_handler() {
  echo ">> Shutting down..."
  nginx -s quit || true
  pkill php-fpm8.3 || true
  exit 0
}
trap term_handler SIGTERM SIGINT

# Keep container running
while true; do sleep 3600; done
