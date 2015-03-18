aws_region = us-west-2
build = build

# TODO: make a one-command launch of the whole stack work
# launch: deploy
# 	$$(terraform output fleet_env)
# 	./control/launch_units.sh

$(build)/plan: $(build)/cluster_id.tfvars $(build)/keys.tfvars $(build)/visible.tfvars
	terraform plan -input=false -out $(build)/plan --var-file=$(build)/cluster_id.tfvars --var-file=$(build)/keys.tfvars --var-file=$(build)/visible.tfvars

.PHONY: deploy
deploy: $(build)/plan $(build)/keys.tfvars $(build)/visible.tfvars
	terraform apply -input=false --var-file=$(build)/cluster_id.tfvars --var-file=$(build)/keys.tfvars --var-file=$(build)/visible.tfvars < $(build)/plan

.PHONY: destroy
destroy: $(build)/keys.tfvars $(build)/visible.tfvars 
	terraform destroy -input=false --var-file=$(build)/cluster_id.tfvars --var-file=$(build)/keys.tfvars --var-file=$(build)/visible.tfvars
	rm -f $(build)/terraform.tfstate
	rm -f $(build)/terraform.tfstate.backup

$(build)/cluster_id.tfvars: $(build)/etcd_discovery_url $(build)/stack_name $(build)/coreos_ami
	echo "stack_name = \"$$(cat $(build)/stack_name)\"" >> $(build)/cluster_id.tfvars
	echo "etcd_discovery_url = \"$$(cat $(build)/etcd_discovery_url)\"" >> $(build)/cluster_id.tfvars
	echo "coreos_ami = \"$$(cat $(build)/coreos_ami)\"" >> $(build)/cluster_id.tfvars

$(build)/keys.tfvars: 
	cd visible; make outputs

$(build)/visible.tfvars: 
	cd visible; make outputs

$(build)/stack_name:
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | head -c 5 > $(build)/stack_name

$(build)/etcd_discovery_url: $(build)
	curl -s https://discovery.etcd.io/new?size=5 > $(build)/etcd_discovery_url

# CoreOS AMIs are alpha channel, HVM virtualization
$(build)/coreos_ami: 
	curl -s https://s3.amazonaws.com/coreos.com/dist/aws/coreos-alpha-hvm.template | jq -r '.Mappings.RegionMap["$(aws_region)"].AMI' > $(build)/coreos_ami

$(build):
	mkdir -p $(build)

.PHONY: clean
clean:
	rm -Rf $(build)

