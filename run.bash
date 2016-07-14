#!/bin/bash

NGINX_PASSWORD_FILE=/etc/nginx/service.pwd

if [ -z "${NGINX_PASSWORD_FILE}" ]; then
    exit 0
fi

if [ -z "${PROXY_AUTH_USERNAME}" ]; then
    echo "Missing PROXY_AUTH_USERNAME"
    exit 0
fi

if [ -z "${PROXY_AUTH_PASSWORD}" ]; then
    echo "Missing PROXY_AUTH_PASSWORD"
    exit 0
fi

if [ -z "${SERVICE_HOST}" ]; then
    echo "Missing SERVICE_HOST"
    exit 0
fi

if [ -z "${SERVICE_PORT}" ]; then
    SERVICE_PORT=80
fi

if [ -z "${PROXY_AUTH_TITLE}" ]; then
    PROXY_AUTH_TITLE="Protected Service"
fi

htpasswd -b -c ${NGINX_PASSWORD_FILE} ${PROXY_AUTH_USERNAME} ${PROXY_AUTH_PASSWORD}

cat > /etc/nginx/conf.d/default.conf <<EOL
upstream service {
    server ${SERVICE_HOST}:${SERVICE_PORT};
}

server {
    listen 80 default_server;
    server_name localhost;

    auth_basic "${PROXY_AUTH_TITLE}";
    auth_basic_user_file ${NGINX_PASSWORD_FILE};

    location / {
        proxy_pass http://service;

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
}
EOL

echo "Starting nginx..."

nginx -g "daemon off;"
