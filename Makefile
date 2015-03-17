aws_region = "us-west-2"

default: packages

# TODO: make a one-command launch of the whole stack work
# launch: deploy
# 	$$(terraform output fleet_env)
# 	./control/launch_units.sh

deploy: plan keys visible terraform
	terraform apply -input=false --var-file=cluster_id.tfvars --var-file=keys.tfvars --var-file=visible.tfvars < plan

plan: cluster_id keys visible terraform
	terraform plan -input=false -out plan --var-file=cluster_id.tfvars --var-file=keys.tfvars --var-file=visible.tfvars

destroy: keys visible terraform
	terraform destroy -input=false --var-file=cluster_id.tfvars --var-file=keys.tfvars --var-file=visible.tfvars

cluster_id: cluster_id.tfvars

keys: keys.tfvars

visible: visible.tfvars

clean:
	rm -f plan
	rm -f etcd_discovery_url
	rm -f stack_name
	rm -f coreos_ami
	rm -f cluster_id.tfvars

clean-all: destroy clean
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup

cluster_id.tfvars: etcd_discovery_url stack_name coreos_ami
	echo "stack_name = \"$$(cat stack_name)\"" >> cluster_id.tfvars
	echo "etcd_discovery_url = \"$$(cat etcd_discovery_url)\"" >> cluster_id.tfvars
	echo "coreos_ami = \"$$(cat coreos_ami)\"" >> cluster_id.tfvars

keys.tfvars: 
	cd visible; make outputs

visible.tfvars: 
	cd visible; make outputs

stack_name:
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | head -c 5 > stack_name

etcd_discovery_url:
	curl -s https://discovery.etcd.io/new?size=5 > etcd_discovery_url

# CoreOS AMIs are alpha channel, HVM virtualization
coreos_ami: jq
	curl -s https://s3.amazonaws.com/coreos.com/dist/aws/coreos-alpha-hvm.template | jq -r '.Mappings.RegionMap["$(aws_region)"].AMI' > coreos_ami

packages: /usr/local/bin/terraform /usr/local/bin/fleetctl /usr/local/bin/jq

fleetctl: /usr/local/bin/fleetctl

/usr/local/bin/fleetctl:
	brew install fleetctl

terraform: /usr/local/bin/terraform

/usr/local/bin/terraform:
	brew install terraform

jq: /usr/local/bin/jq

/usr/local/bin/jq:
	brew install jq
