# PATH=$(GOPATH)/bin:$$(PATH)
build=../build/subnet-egress-nat
region=us-west-2
terraform=terraform

.PHONY: all apply plan push_state configure_state
all:

apply: $(build)/terraform.tfstate

plan: $(build)/terraform.tfplan

push_state: | configure_state terraform
	$(terraform) remote push

configure_state: | terraform
	$(terraform) remote config --backend=s3 --backend-config="bucket=tf-remote-state" --backend-config="key=innovation-platform-dev/subnet-egress-nat/terraform.tfstate"

$(build)/terraform.tfstate: $(build)/terraform.tfplan | $(build)
	$(terraform) apply -state-out=$@ $(build)/terraform.tfplan

$(build)/terraform.tfplan: $(build)/terraform.tfvars *.tf *.tmpl ../tf_aws_subnet_asg/*.tf | terraform-get
	$(terraform) plan -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate -module-depth=2 -out=$@

$(build)/terraform.tfvars: ../build/keys.tfvars ../build/aws.tfvars ../build/stack.tfvars ../build/availability_zones | $(build)
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > $@
	cat ../build/keys.tfvars >> $@
	cat ../build/aws.tfvars >> $@
	cat ../build/stack.tfvars >> $@

../build/keys.tfvars:
	cd ..; make build/keys.tfvars

../build/aws.tfvars:
	cd ..; make build/aws.tfvars

../build/stack.tfvars:
	cd ..; make build/stack.tfvars

../build/availability_zones:
	cd ..; make build/availability_zones

../tf_aws_subnet_asg/*.tf: 
	$(terraform) get

terraform: /usr/local/bin/terraform
terraform-get: .terraform
awscli: /usr/local/bin/aws
curl: /usr/bin/curl
jq: /usr/local/bin/jq

.terraform: | terraform
	$(terraform) get

$$(GOPATH)/bin/terraform:
	go get github.com/hashicorp/terraform

/usr/local/bin/terraform:
	brew install terraform

/usr/local/bin/aws:
	brew install awscli

/usr/local/bin/jq:
	brew install jq

$(build):
	mkdir -p $@

.PHONY: destroy destroy_plan
destroy: $(build)/after-destroy.tfstate

destroy_plan: $(build)/destroy.tfplan

$(build)/terraform.tfstate:

$(build)/destroy.tfplan: $(build)/terraform.tfstate | terraform
	terraform plan -input=false -destroy -out=$@ -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate

$(build)/after-destroy.tfstate: $(build)/destroy.tfplan | terraform
	terraform apply -state-out=$@ -state=$(build)/terraform.tfstate $(build)/destroy.tfplan

clean:
	rm -rf $(build)
