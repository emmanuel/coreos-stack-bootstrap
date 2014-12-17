#!/bin/sh

printf "${ZK_SERVER_NUMBER}\n" > /var/lib/zookeeper/myid
printf "Starting Zookeeper server $(cat /var/lib/zookeeper/myid); release ${ZK_RELEASE}\n"
/opt/local/zookeeper-${ZK_RELEASE}/bin/zkServer.sh start-foreground
