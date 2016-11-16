#!/bin/bash

if [ -z "${SKIP_CONF_GEN}" ]; then

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
server {
    listen 80 default_server;
    server_name localhost;

    auth_basic "${PROXY_AUTH_TITLE}";
    auth_basic_user_file ${NGINX_PASSWORD_FILE};

    client_max_body_size 100M;

    resolver 127.0.0.1 valid=5s;

    set \$dn "${SERVICE_HOST}";

    location / {
        proxy_pass http://\$dn:${SERVICE_PORT};

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
}
EOL

fi

service dnsmasq restart && echo "Starting nginx..." && exec nginx -g "daemon off;"
