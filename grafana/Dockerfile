FROM nordstrom/baseimage-ubuntu-core-1404
MAINTAINER Paul Payne "paul@payne.io"

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nginx-light

ADD dist/grafana-1.7.0.tar.gz /
RUN mv /grafana-1.7.0 /grafana

ADD nginx/.htpasswd /etc/nginx/.htpasswd
ADD conf/nginx.conf /etc/nginx/
ADD conf/config.js /grafana/

EXPOSE 80

CMD ["/usr/sbin/nginx"]
