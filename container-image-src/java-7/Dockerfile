FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# Use Oracle JRE 7
# RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
#  && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
#  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
#  && apt-get update -qy \
#  && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections \
#  && apt-get install -qy --no-install-recommends --no-install-suggests \
#      oracle-java7-installer \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*
# 
# ENV JAVA_HOME /usr/lib/jvm/???


# Just use OpenJDK JRE for now:
RUN apt-get update -qy \
 && apt-get install -qy --no-install-recommends --no-install-suggests \
     openjdk-7-jre-headless \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
