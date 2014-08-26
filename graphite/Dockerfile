FROM emmanuel/baseimage-ubuntu-core-1404:0.0.1
MAINTAINER Emmanuel Gomez "emmanuel@gomez.io"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  --no-install-suggests --no-install-recommends \
  graphite-carbon

ADD conf/coreos-carbon.conf          /etc/carbon/carbon.conf
ADD conf/coreos-storage-schemas.conf /etc/carbon/storage-schemas.conf
ADD start-carbon.sh /bin/start-carbon.sh

CMD ["start-carbon.sh"]
