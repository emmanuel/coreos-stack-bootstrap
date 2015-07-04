build=../build/vpc
region=us-west-2

.PHONY: all apply plan push_state configure_state refresh_state
all:

apply: $(build)/terraform.tfstate push_state

plan: $(build)/terraform.tfplan

push_state: export AWS_DEFAULT_REGION = $(region)
push_state: | configure_state terraform
	cd $(build); terraform remote push

configure_state: export AWS_DEFAULT_REGION = $(region)
configure_state: | terraform
	cd $(build); terraform remote config --backend=s3 --backend-config="bucket=tf-remote-state" --backend-config="key=innovation-platform-dev/vpc/terraform.tfstate"

refresh_state: export AWS_DEFAULT_REGION = $(region)
refresh_state: | terraform
	terraform refresh -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate
	rm $(build)/terraform.tfplan

$(build)/terraform.tfstate: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfstate: $(build)/terraform.tfplan
	terraform apply -state=$@ $(build)/terraform.tfplan

$(build)/terraform.tfplan: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfplan: $(build)/terraform.tfvars *.tf | $(build) .terraform
	terraform plan -state=$(build)/terraform.tfstate -var-file=$(build)/terraform.tfvars -module-depth=2 -out=$@

$(build)/terraform.tfvars: export AWS_DEFAULT_REGION = $(region)
$(build)/terraform.tfvars: ../build/keys.tfvars ../build/availability_zones | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/keys.tfvars >> $@
	echo "availability_zones = \"$$(cat ../build/availability_zones)\"" >> $@

../build/keys.tfvars:
	cd ..; make build/keys.tfvars

../build/availability_zones:
	cd ..; make build/availability_zones

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

$(build)/terraform.tfstate:

$(build)/destroy.tfplan: export AWS_DEFAULT_REGION = $(region)
$(build)/destroy.tfplan: $(build)/terraform.tfstate | terraform
	terraform plan -module-depth=2 -input=false -destroy -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate -out=$@

$(build)/after-destroy.tfstate: export AWS_DEFAULT_REGION = $(region)
$(build)/after-destroy.tfstate: $(build)/destroy.tfplan | terraform
	terraform apply -state-out=$@ $(build)/destroy.tfplan

clean:
	rm -rf $(build)
