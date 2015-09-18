build := ../build/services
default_tfstate := $(build)/.terraform/terraform.tfstate
region := us-west-2
terraform := terraform
remote_state_s3_key := innovation-platform/dev/services/terraform.tfstate
etcd_cluster_size := 3
ec2_key_name := coreos-beta
ec2_instance_type := t2.medium

include ../Makefile.shared
include ../Makefile.utils

$(build)/terraform.tfplan: $(default_tfstate) $(build)/terraform.tfvars *.tf cloud_config.yaml.tmpl | $(build) .terraform
	$(terraform) plan -state=$(default_tfstate) -var-file=$(build)/terraform.tfvars -module-depth=2 -out=$@

$(build)/terraform.tfvars: ../build/aws.tfvars ../build/stack.tfvars ../build/coreos_alpha_ami_id $(build)/etcd_discovery_url ../build/dns_domain_root | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/aws.tfvars >> $@
	cat ../build/stack.tfvars >> $@
	echo "etcd_discovery_url = \"$$(cat $(build)/etcd_discovery_url)\"" >> $@
	echo "ec2_key_name = \"$(ec2_key_name)\"" >> $@
	echo "ec2_instance_type = \"$(ec2_instance_type)\"" >> $@
	echo "coreos_ami_id = \"$$(cat ../build/coreos_alpha_ami_id)\"" >> $@
	echo "dns_domain_root = \"$$(cat ../build/dns_domain_root)\"" >> $@

$(build)/etcd_discovery_url: | $(build) curl
	curl -s https://discovery.etcd.io/new?size=$(etcd_cluster_size) > $@
