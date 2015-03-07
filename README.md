# Nordstrom Sandbox Cluster for Rapid Validation, Initialization

Use to initialize and configure our CoreOS cluster. The control cluster as well as other "sub" clusters.

The cluster runs on AWS EC2 using Cloud Formation. cloud-init includes:

* docker (configure containers for local SkyDNS server)
* etcd
* fleet

For the control cluster, fleet is then used to deploy:

* logspout: log collection from all containers, forwards to syslog-gollector
* syslog-gollector: syslog server on each host, forwards to kafka
* registrator: automated DNS registrations based on container metadata
* skydns: local DNS server backed by etcd
* influxdb: time-series database, mainly used for metrics
* sysinfo_influxdb: collects metrics via CloudFoundry's sigar, sends to influxdb
* cadvisor: collects metrics about all running containers, sends to influxdb
* zookeeper: distributed consistent key/value datastore, used by several others
* kafka: high-volume distributed publish/subscribe message queue, uses zookeeper
* elasticsearch: distributed, lucene-based search, used for log aggregation
* logstash: log processing worker. reads from kafka & indexes into elasticsearch

# Initializing and configuring the control cluster

```bash
make deploy
$(terraform output fleet_env)
./control/launch_units.sh
```

# Tests

After starting up the control cluster via Terraform, and setting your FLEETCTL_TUNNEL variable, run tests:

To install rspec:
```bash
bundle install
```

To run tests:
```
rspec -f d
```


# Handy hints

You can test some changes to your cloud without needing to destroy and re-create. SCP your file to a host and:

``` bash
sudo /usr/bin/coreos-cloudinit --from-file /tmp/user-data.yml
```

Most of our docker images are here:
https://hub.docker.com/account/organizations/nordstrom/
