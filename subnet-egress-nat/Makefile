# PATH=$(GOPATH)/bin:$$(PATH)
build := ../build/subnet-egress-nat
default_tfstate := $(build)/.terraform/terraform.tfstate
region := us-west-2
terraform := terraform
ec2_key_name := coreos-beta
ec2_instance_type := t2.micro
remote_state_s3_bucket := tf-remote-state
remote_state_s3_key := innovation-platform/dev/subnet-egress-nat/terraform.tfstate

include ../Makefile.shared # defines vpc_cidr_range
include ../Makefile.utils

$(build)/terraform.tfplan: $(default_tfstate) $(build)/terraform.tfvars *.tf cloud_config.yaml.tmpl | $(build) .terraform
	$(terraform) plan -state=$(default_tfstate) -var-file=$(build)/terraform.tfvars -module-depth=2 -out=$@

$(build)/terraform.tfvars: ../build/aws.tfvars ../build/coreos_stable_ami_id | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/aws.tfvars >> $@
	echo "vpc_cidr_range = \"$(vpc_cidr_range)\"" >> $@
	echo "coreos_ami_id = \"$$(cat ../build/coreos_stable_ami_id)\"" >> $@
	echo "ec2_key_name = \"$(ec2_key_name)\"" >> $@
	echo "ec2_instance_type = \"$(ec2_instance_type)\"" >> $@
