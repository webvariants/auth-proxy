# HTTP auth proxy (nginx based)

    auth-proxy:
      environment:
        PROXY_AUTH_USERNAME: [...]
        PROXY_AUTH_PASSWORD: [...]
        PROXY_AUTH_TITLE: "My Place"
        # PROXY_AUTH_DISABLE: 1

        SERVICE_HOST: [...] # target service name
        SERVICE_PORT: 80

        NGINX_CLIENT_MAX_BODY_SIZE: "100M"
        NGINX_CLIENT_BODY_TIMEOUT: "60s"
      image: webvariants/auth-proxy:latest
      log_opt:
        max-file: '2'
        max-size: 64k
