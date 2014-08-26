# Nordstrom Sandbox Cluster for Rapid Validation, Initialization

Use to initialize and configure our CoreOS cluster.

The cluster runs on AWS EC2 using Cloud Formation. cloud-init includes:
* skydns
* collectd
* cadvisor (containerized)

Fleet is then used to deploy:
* graphite

# Requirements

URL to a binary of SkyDNS

# Initializing and configuring the cluster

```bash
aws/creeate-stack.sh
```

Wait a few minutes, then:

```bash
aws/launch_units.sh
```

# Handy hints

``` bash
sudo /usr/bin/coreos-cloudinit --from-file /tmp/user-data.yml
```