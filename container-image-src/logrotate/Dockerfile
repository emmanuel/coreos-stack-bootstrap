FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Paul Payne "paul@payne.io"

RUN addgroup syslog
RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
     logrotate \
 && apt-get clean

ADD dist/docker-gen.tar.gz /usr/local/bin
ADD dist/go-cron.tar.gz /usr/local/bin

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
