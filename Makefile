build=build
region=us-west-2

.PHONY: all apply plan

all:

apply: $(build)/terraform.tfstate

plan: $(build)/terraform.tfplan

$(build)/terraform.tfstate: $(build)/terraform.tfplan
	terraform apply -out=$@ $(build)/terraform.tfplan

$(build)/terraform.tfplan: *.tf $(build)/terraform.tfvars $(build)/terraform.tfstate tf_aws_subnet_asg/*.tf | terraform-get
	terraform plan -out=$@ -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate -module-depth=2

$(build)/terraform.tfvars: $(build)/aws.tfvars $(build)/stack.tfvars
	echo "# terraform.tfvars: this file is machine generated. built at $$(date)" > terraform.tfvars
	cat $(build)/aws.tfvars >> $@
	cat $(build)/stack.tfvars >> $@

$(build)/aws.tfvars: $(build)/availability_zones | $(build)
	echo "# aws.tfvars: this file is machine generated. built at $$(date)" > $@
	echo "aws_region = \"$$(cat $(HOME)/.aws/config | grep region | head -1 | cut -f2 -d= | tr -d '[[:space:]]')\"" >> $@
	echo "availability_zones = \"$$(cat $(build)/availability_zones)\"" >> $@

$(build)/stack.tfvars: $(build)/stack_name $(build)/coreos_alpha_ami_id $(build)/etcd_discovery_url | $(build)
	echo "# stack.tfvars: this file is machine generated. built at $$(date)" > $@
	echo "coreos_ami_id = \"$$(cat $(build)/coreos_alpha_ami_id)\"" >> $@
	echo "etcd_discovery_url = \"$$(cat $(build)/etcd_discovery_url)\"" >> $@
	echo "stack_name = \"$$(cat $(build)/stack_name)\"" >> $@

$(build)/coreos_alpha_ami_id: $(build)/coreos_production_ami_all.json | jq
	cat $(build)/coreos_production_ami_all.json | jq -r ".amis | map(select(\"$(region)\" == .name))[0].hvm" > $@

$(build)/availability_zones: $(build)/ec2_availability_zones.json | jq
	cat $(build)/ec2_availability_zones.json | jq -r '.AvailabilityZones | map(select("available" == .State))[].ZoneName' | tr '\n' ',' | sed -e 's/,$$//g' > $@

$(build)/etcd_discovery_url: | $(build) curl
	curl -s https://discovery.etcd.io/new?size=3 > $@

$(build)/coreos_production_ami_all.json: | $(build) curl
	curl -sk https://alpha.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json > $@

$(build)/ec2_availability_zones.json: | $(build) awscli
	aws ec2 describe-availability-zones --region="$(region)" --output="json" > $@

$(build)/stack_name: | $(build)
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | head -c 5 > $@

.PHONY: vpc vpc/state vpc/apply vpc/plan subnet-egress-nat subnet-egress-nat/state subnet-egress-nat/apply subnet-egress-nat/plan subnet-egress-nat/state
vpc: vpc/apply

vpc/apply: vpc/plan
	cd vpc; make apply

vpc/plan: $(build)/vpc.tfplan

$(build)/vpc/terraform.tfplan:
	cd vpc; make plan

subnet-egress-nat: subnet-egress-nat/apply subnet-egress-nat/state

subnet-egress-nat/state: subnet-egress-nat/apply
	cd subnet-egress-nat; make state

subnet-egress-nat/apply: subnet-egress-nat/plan
	cd subnet-egress-nat; make apply

subnet-egress-nat/plan: $(build)/subnet-egress-nat/terraform.tfplan

$(build)/subnet-egress-nat/terraform.tfplan:
	cd subnet-egress-nat; make plan

tf_aws_subnet_asg/*.tf: 
	terraform get

.PHONY: terraform terraform-get awscli aws_config curl jq

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

$(build)/terraform.tfstate:

$(build)/destroy.tfplan: $(build)/terraform.tfstate | terraform
	terraform plan -input=false -destroy -out=$@ -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate 

$(build)/after-destroy.tfstate: $(build)/destroy.tfplan | terraform
	terraform apply -state-out=$@ -var-file=$(build)/terraform.tfvars -state=$(build)/terraform.tfstate $(build)/destroy.tfplan

clean: 
	rm -rf $(build)
