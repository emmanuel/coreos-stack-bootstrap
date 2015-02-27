default: packages

deploy: plan terraform
	terraform apply -input=false --var-file cluster_id.tfvars --var-file=keys.tfvars --var-file=visible.tfvars < plan

plan: cluster_id terraform
	terraform plan -input=false -out plan --var-file cluster_id.tfvars --var-file=keys.tfvars --var-file=visible.tfvars

cluster_id: cluster_id.tfvars

cluster_id.tfvars: etcd_discovery_url stack_name
	echo "stack_name = \"`cat stack_name`\"" >> cluster_id.tfvars
	echo "etcd_discovery_url = \"`cat etcd_discovery_url`\"" >> cluster_id.tfvars

stack_name:
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | head -c 5 > stack_name

etcd_discovery_url:
	curl -s https://discovery.etcd.io/new?size=5 > etcd_discovery_url

destroy: terraform
	terraform destroy -input=false

clean:
	rm -f plan
	rm -f etcd_discovery_url
	rm -f stack_name
	rm -f cluster_id.tfvars

clean-all: destroy clean
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup

packages: /usr/local/bin/fleetctl /usr/local/bin/terraform

fleetctl: /usr/local/bin/fleetctl

/usr/local/bin/fleetctl:
	brew install fleetctl

terraform: /usr/local/bin/terraform

/usr/local/bin/terraform:
	brew install terraform