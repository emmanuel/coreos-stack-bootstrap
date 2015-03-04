FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ENV VULCAND_RELEASE=0.8.0-beta.2
ADD dist/vulcand-v$VULCAND_RELEASE-linux-amd64/vulcand /usr/bin/
ADD dist/vulcand-v$VULCAND_RELEASE-linux-amd64/vctl    /usr/bin/
ADD dist/vulcand-v$VULCAND_RELEASE-linux-amd64/vbundle /usr/bin/
