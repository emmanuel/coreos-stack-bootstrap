FROM emmanuel/baseimage-ubuntu-core-1404:0.0.1
MAINTAINER Emmanuel Gomez "emmanuel@gomez.io"

RUN DEBIAN_FRONTENT=noninteractive apt-get install -y \
  --no-install-recommends --no-install-suggests \
  collectd-core
RUN adduser --system --group --no-create-home collectd

ADD conf/collectd.conf /etc/collectd/collectd.conf.tmpl
ADD bin/collectd-wrapper /bin/collectd-wrapper
RUN chown -R collectd:collectd /etc/collectd

CMD ["/bin/collectd-wrapper"]
