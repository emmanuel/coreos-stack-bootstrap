# Nordstrom Sandbox Cluster for Rapid Validation, Initialization

Use to initialize and configure our CoreOS cluster.

The cluster runs on AWS EC2 using Cloud Formation. cloud-init includes:
* skydns
* collectd
* cadvisor (containerized)

Fleet is then used to deploy:
* graphite

# Requirements

* URL to a binary of SkyDNS

# Local Setup

* install aws client
* aws client needs to be configured with our lab account params (or better yet, with a delegated user account):

```bash
aws configure
```
* Get AWS ssh private key for the 'coreos-beta' keypair from Paul or Emmanuel, and then ssh-add it. Alternatively, generate your own key pair and upload it to our AWS account (you'll need to refer to this key in the create_stack command below).

# Initializing and configuring the cluster

```bash
aws/create-stack.sh
```

Wait a few minutes, then get a public hostname or ip from one of your new instances from the AWS console. Then set:

```bash
export FLEETCTL_TUNNEL={resolvable address of one of your cloud instances}
aws/launch_units.sh
```

# Handy hints

``` bash
sudo /usr/bin/coreos-cloudinit --from-file /tmp/user-data.yml
```