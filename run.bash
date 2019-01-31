#!/bin/bash

if [ -z "${SKIP_CONF_GEN}" ]; then

    if [ -z "${SERVICE_HOST}" ]; then
        echo "Missing SERVICE_HOST"
        exit 0
    fi

    if [ -z "${SERVICE_PORT}" ]; then
        SERVICE_PORT=80
    fi

    if [ -z "${NGINX_CLIENT_MAX_BODY_SIZE}" ]; then
        NGINX_CLIENT_MAX_BODY_SIZE="100M"
    fi
    if [ -z "${NGINX_CLIENT_BODY_TIMEOUT}" ]; then
        NGINX_CLIENT_BODY_TIMEOUT="60s"
    fi

    if [ -z "${NGINX_DNS_IP}" ]; then
        NGINX_DNS_IP="127.0.0.11"
    fi

    if [ -z "${PROXY_AUTH_DISABLE}" ]; then
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

        if [ -z "${PROXY_AUTH_TITLE}" ]; then
            PROXY_AUTH_TITLE="Protected Service"
        fi

        htpasswd -b -c ${NGINX_PASSWORD_FILE} ${PROXY_AUTH_USERNAME} ${PROXY_AUTH_PASSWORD}

        AUTH1="auth_basic \"${PROXY_AUTH_TITLE}\";"
        AUTH2="auth_basic_user_file ${NGINX_PASSWORD_FILE};"
    else
        AUTH1="# auth disabled"
        AUTH2=""
    fi

    cat > /etc/nginx/conf.d/default.conf <<EOL
server {
    listen 80 default_server;
    server_name localhost;

    ${AUTH1}
    ${AUTH2}

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};
    client_body_timeout ${NGINX_CLIENT_BODY_TIMEOUT};

    resolver ${NGINX_DNS_IP} ipv6=off valid=3s;

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

exec nginx -g "daemon off;"
