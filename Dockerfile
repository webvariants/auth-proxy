FROM nginx:stable-alpine

RUN apk add --no-cache apache2-utils bash

COPY run.bash /run.bash

EXPOSE 80

CMD ["/bin/bash", "/run.bash"]
