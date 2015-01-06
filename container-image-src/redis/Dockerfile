FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez <emmanuel.gomez@nordstrom.com>

RUN echo "deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu trusty main" \
    | tee -a /etc/apt/sources.list.d/chris-lea_redis-server.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12 \
 && apt-get update -qy \
 && apt-get install -qy --no-install-recommends --no-install-suggests \
     redis-server \
 && apt-get clean -qy \
 && rm -rf /var/lib/apt/lists/*

ADD conf/redis.conf /etc/redis/

ENTRYPOINT ["/usr/bin/redis-server", "/etc/redis/redis.conf"]
