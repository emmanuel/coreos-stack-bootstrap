build := ../build/vpc
default_tfstate := $(build)/.terraform/terraform.tfstate
region := us-west-2
terraform := terraform
remote_state_s3_key := innovation-platform/dev/vpc/terraform.tfstate
vpc_name := innovation-platform-vpc-dev
vpc_private_subnets := 172.33.1.0/24,172.33.2.0/24,172.33.3.0/24
vpc_public_subnets := 172.33.101.0/24,172.33.102.0/24,172.33.103.0/24
vpc_public_subnets := 172.33.101.0/24,172.33.102.0/24,172.33.103.0/24

include ../Makefile.shared # defines vpc_cidr_range
include ../Makefile.utils

$(build)/terraform.tfplan: $(default_tfstate) $(build)/terraform.tfvars *.tf | $(build) .terraform
	terraform plan -out=$@ -var-file=$(build)/terraform.tfvars -state=$(default_tfstate) -module-depth=2

$(build)/terraform.tfvars: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfvars: ../build/aws.tfvars ../build/stack_name ../build/dns_domain_root | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/aws.tfvars >> $@
	echo "vpc_name = \"$(vpc_name)\"" >> $@
	echo "vpc_cidr_range = \"$(vpc_cidr_range)\"" >> $@
	echo "vpc_private_subnets = \"$(vpc_private_subnets)\"" >> $@
	echo "vpc_public_subnets = \"$(vpc_public_subnets)\"" >> $@
	echo "ssh_dns_name = \"$$(cat ../build/stack_name)-ssh.$$(cat ../build/dns_domain_root)\"" >> $@
