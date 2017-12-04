FROM nginx:1.13

RUN apt-get update && apt-get install -y apache2-utils dnsmasq && rm -r /var/lib/apt/lists/*

RUN echo "\n\n# Docker extra config \nuser=root\naddn-hosts=/etc/hosts\n" >> /etc/dnsmasq.conf

COPY run.bash /run.bash

EXPOSE 80

CMD ["/bin/bash", "/run.bash"]
