FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Paul Payne "paul@payne.io"

WORKDIR /root

RUN apt-get update

RUN \
  apt-get install -y \
    jq \
    python \
    python-pip \
    ruby \

    ruby-bundler
RUN \
  pip install awscli

ADD dist/terraform_0.3.7_linux_amd64.zip /usr/local/bin/
ADD dist/fleetctl /usr/local/bin/

ADD Gemfile* /root/

RUN \
  bundle install

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD spec/ /root/spec/
ADD visible/ /root/visible/
ADD control/ /root/control/
ADD *.tf /root/
ADD Makefile /root/
ADD control-cloud_config.yaml /root/

ENTRYPOINT ["/bin/bash"]
