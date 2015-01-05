FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Paul Payne "paul@payne.io"

# install curl & syslog
RUN addgroup syslog \
 && apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
   curl \
   logrotate \
 && apt-get clean

# install docker-gen
RUN curl -sL https://github.com/jwilder/docker-gen/releases/download/0.3.2/docker-gen-linux-amd64-0.3.2.tar.gz \
    | tar -xz -C /usr/local/bin

# install go-cron
RUN curl -sL https://github.com/michaloo/go-cron/releases/download/v0.0.2/go-cron.tar.gz \
    | tar -x -C /usr/local/bin


# copy project files
ADD . /app
WORKDIR /app

# clear logrotate ubuntu installation and modify logrotate script
# add docker-gen execution and enable debug mode
RUN rm /etc/logrotate.d/* && \
    sed -i \
    -e 's/^\/usr\/sbin\/logrotate.*/\/usr\/sbin\/logrotate \-v \/etc\/logrotate.conf/' \
    -e '/\#\!\/bin\/sh/a /usr/local/bin/docker-gen /root/logrotate.tmpl /etc/logrotate.d/docker' \
    /etc/cron.daily/logrotate

# set default configuration
ENV DOCKER_HOST unix:///var/run/docker.sock
ENV DOCKER_DIR /var/lib/docker/
ENV GOCRON_SCHEDULER 0 0 * * * *

ENV LOGROTATE_MODE daily
ENV LOGROTATE_ROTATE 3
ENV LOGROTATE_SIZE 512M

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/app/start" ]
