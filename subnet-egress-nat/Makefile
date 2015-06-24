region=us-west-2

.PHONY: all
all:
	
.PHONY: apply
apply: ../build/subnet-egress-nat.tfplan
	terraform apply ../build/subnet-egress-nat.tfplan

.PHONY: plan
plan: ../build/subnet-egress-nat.tfplan

.PHONY: pushsstate
push_state: | configure_state terraform
	terraform remote push

.PHONY: configure_state
configure_state: | terraform
	terraform remote config --backend=s3 --backend-config="bucket=tf-remote-state" --backend-config="key=innovation-platform-prod/subnet-egress-nat.tfstate"

../build/subnet-egress-nat.tfplan: terraform.tfvars *.tf ../tf_aws_asg_elb/*.tf | build
	terraform plan -out=../build/subnet-egress-nat.tfplan -module-depth=2

terraform.tfvars: ../build/keys.tfvars ../build/aws.tfvars ../build/stack.tfvars ../build/availability_zones
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > terraform.tfvars
	cat ../build/keys.tfvars >> terraform.tfvars
	cat ../build/aws.tfvars >> terraform.tfvars
	# cat ../build/stack.tfvars >> terraform.tfvars
	echo "availability_zones = \"$$(cat ../build/availability_zones)\"" >> terraform.tfvars

../build/keys.tfvars:
	cd ..; make build/keys.tfvars

../build/aws.tfvars:
	cd ..; make build/aws.tfvars

../build/stack.tfvars:
	cd ..; make build/stack.tfvars

../build/availability_zones:
	cd ..; make build/availability_zones

../tf_aws_asg_elb/*.tf: 
	terraform get

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

build:
	mkdir -p build

.PHONY: destroy
destroy: after-destroy.tfstate

.PHONY: destroy_plan
destroy_plan: destroy.tfplan

terraform.tfstate:

destroy.tfplan: terraform.tfstate | terraform
	terraform plan -input=false -destroy -out=destroy.tfplan

after-destroy.tfstate: destroy.tfplan | terraform
	terraform apply -state-out=after-destroy.tfstate destroy.tfplan

clean:
	rm -rf build
	rm -f terraform.tfstate
