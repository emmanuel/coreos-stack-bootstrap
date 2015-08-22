build := ../build/bastion
default_tfstate := $(build)/.terraform/terraform.tfstate
region := us-west-2
terraform := terraform
remote_state_s3_key := innovation-platform/dev/bastion/terraform.tfstate
ec2_key_name := coreos-beta
ec2_instance_type := t2.micro

include ../Makefile.shared
include ../Makefile.utils

$(build)/terraform.tfplan: $(default_tfstate) $(build)/terraform.tfvars *.tf cloud_config.yaml.tmpl | $(build) .terraform
	$(terraform) plan -state=$(default_tfstate) -var-file=$(build)/terraform.tfvars -module-depth=2 -out=$@

$(build)/terraform.tfvars: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfvars: ../build/aws.tfvars ../build/stack.tfvars ../build/coreos_stable_ami_id ../build/dns_domain_root | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/aws.tfvars >> $@
	cat ../build/stack.tfvars >> $@
	echo "coreos_ami_id = \"$$(cat ../build/coreos_stable_ami_id)\"" >> $@
	echo "ec2_key_name = \"$(ec2_key_name)\"" >> $@
	echo "ec2_instance_type = \"$(ec2_instance_type)\"" >> $@
	echo "ssh_dns_name = \"$$(cat ../build/stack_name)-ssh.$$(cat ../build/dns_domain_root)\"" >> $@
