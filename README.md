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
* Get AWS ssh private key for the 'coreos-beta' keypair from Paul or Emmanuel, and then `ssh-add` it. Alternatively, generate your own key pair and upload it to our AWS account (you'll need to refer to this key in the create_stack command below).

# Initializing and configuring the cluster

```bash
cd terraform
source aliases.sh
# add your keys to cloud-config.yaml & terraform.tfvars
new_cluster_values
tfplan
tfapply
```

Wait a few minutes, then get a public hostname or ip from one of your new instances from the AWS console. Then set:

```bash
export FLEETCTL_TUNNEL={resolvable address of one of your cloud instances}
coreos/launch_units.sh
```

# Tests

After starting up the cluster via Terraform, and setting your FLEETCTL_TUNNEL variable, run tests:

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
