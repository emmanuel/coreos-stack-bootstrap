FROM nordstrom/baseimage-ubuntu:14.04.2
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

ADD conf/config.yml /config.yml
ADD dist/registry /registry

CMD ["/registry", "/config.yml"]
