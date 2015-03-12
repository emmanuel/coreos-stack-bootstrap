FROM nordstrom/java-7:u75
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

ADD dist/confluent.apt-key /tmp/
RUN apt-key add /tmp/confluent.apt-key \
 && echo "deb [arch=all] http://packages.confluent.io/deb/1.0 stable main" | \
      tee -a /etc/apt/sources.list.d/confluent.list
