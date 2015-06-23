region=us-west-2

.PHONY: all

all:
	
.PHONY: apply

apply: build/test.tfplan
	terraform apply build/test.tfplan

.PHONY: plan

plan: build/test.tfplan

build/test.tfplan: *.tf terraform.tfvars tf_aws_asg_elb/*.tf
	terraform plan -out=build/test.tfplan -module-depth=2

terraform.tfvars: build/keys.tfvars build/aws.tfvars build/stack.tfvars
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > terraform.tfvars
	cat build/keys.tfvars >> terraform.tfvars
	cat build/aws.tfvars >> terraform.tfvars
	cat build/stack.tfvars >> terraform.tfvars

build/keys.tfvars: | build
	echo "# keys.tfvars: this file is machine generated. built at $$(date)" > build/keys.tfvars
	echo "aws_region = \"$$(cat $(HOME)/.aws/config | grep region | head -1 | cut -f2 -d= | tr -d '[[:space:]]')\"" >> build/keys.tfvars
	echo "aws_access_key = \"$$(cat $(HOME)/.aws/config | grep aws_access_key | head -1 | cut -f2 -d= | tr -d '[[:space:]]')\"" >> build/keys.tfvars
	echo "aws_secret_key = \"$$(cat $(HOME)/.aws/config | grep aws_secret_access_key | head -1 | cut -f2 -d= | tr -d '[[:space:]]')\"" >> build/keys.tfvars

build/aws.tfvars: build/availability_zones | build
	echo "# aws.tfvars: this file is machine generated. built at $$(date)" > build/aws.tfvars
	echo "availability_zones = \"$$(cat build/availability_zones)\"" >> build/aws.tfvars
	echo "ec2_key_name = \"coreos-beta\"" >> build/aws.tfvars
	echo "ec2_instance_type = \"t2.small\"" >> build/aws.tfvars

build/stack.tfvars: build/stack_name build/coreos_alpha_ami_id build/etcd_discovery_url | build
	echo "# stack.tfvars: this file is machine generated. built at $$(date)" > build/stack.tfvars
	echo "coreos_ami_id = \"$$(cat build/coreos_alpha_ami_id)\"" >> build/stack.tfvars
	echo "etcd_discovery_url = \"$$(cat build/etcd_discovery_url)\"" >> build/stack.tfvars
	echo "stack_name = \"$$(cat build/stack_name)\"" >> build/stack.tfvars

build/coreos_alpha_ami_id: build/coreos_production_ami_all.json | jq
	cat build/coreos_production_ami_all.json | jq -r ".amis | map(select(\"$(region)\" == .name))[0].hvm" > build/coreos_alpha_ami_id

build/availability_zones: build/ec2_availability_zones.json | jq
	cat build/ec2_availability_zones.json | jq -r '.AvailabilityZones | map(select("available" == .State))[].ZoneName' | tr '\n' ',' | sed -e 's/,$$//g' > build/availability_zones

build/etcd_discovery_url: | build curl
	curl -s https://discovery.etcd.io/new?size=3 > build/etcd_discovery_url

build/coreos_production_ami_all.json: | build curl
	curl -sk https://alpha.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json > build/coreos_production_ami_all.json

build/ec2_availability_zones.json: | build awscli
	aws ec2 describe-availability-zones --region="$(region)" --output="json" > build/ec2_availability_zones.json

build/stack_name: | build
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | head -c 5 > build/stack_name

tf_aws_asg_elb/*.tf: 
	terraform get

.PHONY: terraform
.PHONY: terraform-get
.PHONY: awscli
.PHONY: aws_config
.PHONY: curl
.PHONY: jq

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
	rm -f after-destroy.tfstate
	rm -f terraform.tfvars
	rm -f destroy.tfplan
