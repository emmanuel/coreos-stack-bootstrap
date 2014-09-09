FROM nordstrom/baseimage-ubuntu-core-1404
MAINTAINER Paul Payne "paul@payne.io"

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nginx-light

ADD dist/grafana-1.7.0.tar.gz /
RUN mv /grafana-1.7.0 /grafana
ADD ./config.js /grafana/config.js

ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx/.htpasswd /etc/nginx/.htpasswd

EXPOSE 80

CMD ["/usr/sbin/nginx"]
