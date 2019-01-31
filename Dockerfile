FROM nginx:mainline

RUN apt-get update && apt-get install -y apache2-utils && rm -r /var/lib/apt/lists/*

COPY run.bash /run.bash

EXPOSE 80

CMD ["/bin/bash", "/run.bash"]
