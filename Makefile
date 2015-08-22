build=build
region=us-west-2
dns_domain_root := cloud.nlab.io

include Makefile.utils

.PHONY: all apply plan
.PHONY: vpc bastion subnet-egress-nat services

all:

apply: vpc bastion subnet-egress-nat services

vpc bastion subnet-egress-nat services:
	cd $@; make apply

$(build)/aws.tfvars: $(build)/availability_zones $(build)/aws_account_id $(build)/aws_region $(build)/route53_zone_id | $(build)
	echo "# aws.tfvars: this file is machine generated. built at $$(date)" > $@
	@echo "aws_account_id = \"$$(cat $(build)/aws_account_id)\"" >> $@
	@echo "aws_region = \"$$(cat $(build)/aws_region)\"" >> $@
	@echo "availability_zones = \"$$(cat $(build)/availability_zones)\"" >> $@
	@echo "route53_zone_id = \"$$(cat $(build)/route53_zone_id)\"" >> $@

$(build)/stack.tfvars: $(build)/stack_name | $(build)
	echo "# stack.tfvars: this file is machine generated. built at $$(date)" > $@
	@echo "stack_name = \"$$(cat $(build)/stack_name)\"" >> $@

$(build)/coreos_stable_ami_id: | jq
	curl -sk https://stable.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json | jq -r ".amis | map(select(\"$(region)\" == .name))[0].hvm" > $@

$(build)/coreos_beta_ami_id: | jq
	curl -sk https://beta.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json | jq -r ".amis | map(select(\"$(region)\" == .name))[0].hvm" > $@

$(build)/coreos_alpha_ami_id: | jq
	curl -sk https://alpha.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json | jq -r ".amis | map(select(\"$(region)\" == .name))[0].hvm" > $@

$(build)/aws_region: 
	grep region $(HOME)/.aws/config | head -1 | cut -f2 -d= | tr -d '[[:space:]]' > $@

$(build)/aws_account_id: | awscli jq
	aws iam get-user | jq -r .User.Arn | cut -d: -f5 > $@

$(build)/ec2_availability_zones.json: | $(build) awscli
	aws ec2 describe-availability-zones --region="$(region)" --output="json" > $@

$(build)/availability_zones: $(build)/ec2_availability_zones.json | jq
	cat $(build)/ec2_availability_zones.json | jq -r '.AvailabilityZones | map(select("available" == .State))[].ZoneName' | tr '\n' ',' | sed -e 's/,$$//g' > $@

$(build)/stack_name: | $(build)
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | head -c 5 > $@

$(build)/dns_domain_root: | $(build)
	echo $(dns_domain_root) > $@

$(build)/route53_zone_id: | $(build)
	# .HostedZones[].Id looks like "/hostedzone/ZM70TX7ZBX2O0"
	aws route53 list-hosted-zones | jq -r '.HostedZones | map(select(.Name == "$(dns_domain_root)."))[0].Id' | cut -d/ -f3 > $@

clean: 
	rm -rf $(build)
