# HTTP auth proxy (nginx based)

    auth-proxy:
      environment:
    #    VIRTUAL_HOST: [...]
    #    LETSENCRYPT_HOST: [...]
    #    LETSENCRYPT_EMAIL: [...]
    
        PROXY_AUTH_USERNAME: [...]
        PROXY_AUTH_PASSWORD: [...]
        PROXY_AUTH_TITLE: "My Place"
    
        SERVICE_HOST: [...] # target hostname
      labels:
        io.rancher.container.pull_image: always
      image: git.webvariants.de:4567/stack/auth-proxy:latest
      log_opt:
        max-file: '2'
        max-size: 64k

