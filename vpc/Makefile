build=../build/vpc
region=us-west-2
default_tfstate=$(build)/.terraform/terraform.tfstate

.PHONY: all apply plan push_state configure_state refresh_state
all:

apply: export AWS_DEFAULT_REGION = $(region)
apply: plan
	terraform apply -state=$(default_tfstate) $(build)/terraform.tfplan && rm $(build)/terraform.tfplan
	mv .terraform/terraform.tfstate $(default_tfstate)

plan: configure_state $(build)/terraform.tfplan

push_state: export AWS_DEFAULT_REGION = $(region)
push_state: | terraform
	cd $(build); terraform remote push

configure_state: $(default_tfstate) | terraform

$(build)/.terraform/terraform.tfstate: export AWS_DEFAULT_REGION = $(region)
$(build)/.terraform/terraform.tfstate: | $(build) terraform
	cd $(build); terraform remote config --backend=s3 --backend-config="bucket=tf-remote-state" --backend-config="key=innovation-platform-dev/vpc/terraform.tfstate"

refresh_state: export AWS_DEFAULT_REGION = $(region)
refresh_state: $(default_tfstate) | terraform
	terraform refresh -var-file=$(build)/terraform.tfvars -state=$(default_tfstate) && rm $(build)/terraform.tfplan

# $(build)/terraform.tfstate: export AWS_DEFAULT_REGION = $(region)
# $(build)/terraform.tfstate: $(build)/terraform.tfplan
# 	terraform apply -state=$@ $(build)/terraform.tfplan && rm $(build)/terraform.tfplan

$(build)/terraform.tfplan: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfplan: $(default_tfstate) $(build)/terraform.tfvars *.tf ../tf_aws_vpc/*.tf | $(build) .terraform
	terraform plan -state=$(default_tfstate) -var-file=$(build)/terraform.tfvars -module-depth=2 -out=$@

$(build)/terraform.tfvars: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfvars: ../build/aws.tfvars | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/aws.tfvars >> $@

../build/aws.tfvars:
	cd ..; make build/aws.tfvars

terraform: /usr/local/bin/terraform
terraform-get: .terraform
awscli: /usr/local/bin/aws
curl: /usr/bin/curl
jq: /usr/local/bin/jq

.terraform: | terraform
	terraform get

/usr/local/bin/terraform:
	brew install terraform

/usr/local/bin/aws:
	brew install awscli

/usr/local/bin/jq:
	brew install jq

$(build):
	mkdir -p $(build)

.PHONY: destroy destroy_plan
destroy: $(build)/after-destroy.tfstate

destroy_plan: $(build)/destroy.tfplan

$(build)/destroy.tfplan: export AWS_DEFAULT_REGION = $(region)
$(build)/destroy.tfplan: $(default_tfstate) | terraform
	terraform plan -module-depth=2 -input=false -destroy -var-file=$(build)/terraform.tfvars -state=$(default_tfstate) -out=$@

$(build)/after-destroy.tfstate: export AWS_DEFAULT_REGION = $(region)
$(build)/after-destroy.tfstate: $(build)/destroy.tfplan | terraform
	terraform apply -state-out=$@ $(build)/destroy.tfplan
	mv .terraform/terraform.tfstate $(default_tfstate)
	make push_state

clean:
	rm -rf $(build)
