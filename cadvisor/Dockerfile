FROM nordstrom/baseimage-ubuntu-core-1404
MAINTAINER Emmanuel Gomez "emmanuel@gomez.io"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dnsutils --no-install-recommends --no-install-suggests

ADD dist/cadvisor /usr/bin/cadvisor
ADD bin/cadvisor.sh /bin

EXPOSE 8080

CMD ["/bin/cadvisor.sh"]
