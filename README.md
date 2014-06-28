# CoreOS cloud-init for SkyDNS on EC2

Configuration files to get SkyDNS installed & running on CoreOS hosts (not in a container). 

This is a CoreOS cloud init user data YAML file, and a correspondingly updated AWS CloudFormation JSON file. 

# Requirements

URL to a binary of SkyDNS

# Handy hints

``` bash
sudo /usr/bin/coreos-cloudinit --from-file /tmp/user-data.yml
```