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

# Local Setup

* install aws client
* aws client needs to be configured with our lab account params (or better yet, with a delegated user account):

```bash
aws configure
```
* Get AWS ssh private key for the 'coreos-beta' keypair from Paul or Emmanuel, and then `ssh-add` it. Alternatively, generate your own key pair and upload it to our AWS account (you'll need to refer to this key in the create_stack command below).

# Initializing and configuring the control cluster

```bash
source aliases.sh
# add your keys to cloud-config.yaml & terraform.tfvars
new_cluster_values
cd control
tfplan
tfapply
```

Wait a few minutes, then get a public hostname or ip from one of your new instances from the AWS console. Then set:

```bash
export FLEETCTL_TUNNEL={resolvable address of one of your cloud instances}
control/launch_units.sh
```

# Initializing "sub" clusters

Similar to the control cluster above, you can bootstrap "sub" clusters _services_ and _deis_. For example:

```bash
cd services
tfplan
tfapply
./launch_units.sh
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

We keep our docker images here:
https://hub.docker.com/account/organizations/nordstrom/
