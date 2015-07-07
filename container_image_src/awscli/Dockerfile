FROM nordstrom/python:2.7
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

RUN pip install --upgrade awscli

RUN adduser -S aws
USER aws
RUN mkdir /home/aws/.aws
VOLUME ["/home/aws/.aws"]

ENTRYPOINT ["/usr/bin/aws"]
