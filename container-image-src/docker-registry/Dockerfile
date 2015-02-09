FROM nordstrom/python:2.7
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"
# copied from: https://github.com/docker/docker-registry/blob/master/Dockerfile
RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
      build-essential \
      swig \
      python-dev \
      python-rsa \
      libssl-dev \
      liblzma-dev \
      libevent1-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY dist/docker-registry /docker-registry
COPY dist/docker-registry/config/boto.cfg /etc/boto.cfg

# Install core
RUN pip install /docker-registry/depends/docker-registry-core
# Install registry
RUN pip install file:///docker-registry#egg=docker-registry[bugsnag,newrelic,cors]
RUN patch \
   $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
 < /docker-registry/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /docker-registry/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 5000

CMD ["docker-registry"]
