OS := $(shell uname -s)
ifeq ($(OS),Darwin)
	include ./Makefile.Darwin
endif
ifeq ($(OS),Linux)
	include ./Makefile.Linux
endif

default: packages

# TODO: make a one-command launch of the whole stack work
# launch: deploy
# 	$$(terraform output fleet_env)
# 	./control/launch_units.sh

# TODO: make this conditional
deploy: visible_stacks

# TODO: make this conditional
upload-certificate: awscli certificates
	aws iam upload-server-certificate \
	  --path "/tls/" \
	  --server-certificate-name "STAR.cloud.nlab.io" \
	  --certificate-body file://$PWD/certificates/STAR_cloud_nlab_io.crt \
	  --certificate-chain file://$PWD/certificates/STAR_cloud_nlab_io_chain.crt \
	  --private-key file://$PWD/certificates/STAR_cloud_nlab_io.key

certificates: certificates/STAR_cloud_nlab_io.key certificates/STAR_cloud_nlab_io.crt certificates/STAR_cloud_nlab_io_chain.crt

destroy: 
	# terraform destroy -input=false --var-file cluster_id.tfvars --var-file=keys.tfvars --var-file=visible.tfvars

.PHONY: outputs
outputs: keys.tfvars visible.tfvars

.PHONY: clean
clean:
	rm -f aws_ec2_key_name
	rm -f aws_iam_server_certificate_arn
	rm -f aws_route53_zone_id
	rm -f aws_security_group_elb_visible_id
	rm -f aws_tag_value_cost_center
	rm -f aws_tag_value_team
	rm -f aws_vpc_zone_identifier
	rm -f visible_stacks
	rm -f visible_iam_stack_id
	rm -f visible_dns_stack_id
	rm -f operator_aws_access_key
	rm -f operator_aws_secret_key
	rm -f instance_aws_access_key
	rm -f instance_aws_secret_key
	rm -f visible_elb_hosted_zone_name
	rm -f visible_elb_hosted_zone_name_id

.PHONY: clean-outputs
clean-outputs: 
	rm -f ../keys.tfvars
	rm -f ../visible.tfvars

visible.tfvars: ../visible.tfvars visible_elb_hosted_zone_name visible_elb_hosted_zone_name_id

keys.tfvars: ../keys.tfvars

../visible.tfvars: aws_vpc_zone_identifier aws_route53_zone_id aws_iam_server_certificate_arn aws_ec2_key_name aws_security_group_elb_visible_id aws_tag_value_team aws_tag_value_cost_center
	echo "aws_vpc_zone_identifier              = \"$$(cat aws_vpc_zone_identifier)\"" >> ../visible.tfvars
	echo "aws_route53_zone_id    = \"$$(cat aws_route53_zone_id)\"" >> ../visible.tfvars
	echo "aws_iam_server_certificate_arn       = \"$$(cat aws_iam_server_certificate_arn)\"" >> ../visible.tfvars
	echo "aws_ec2_key_name                     = \"$$(cat aws_ec2_key_name)\"" >> ../visible.tfvars
	echo "aws_security_group_elb_visible_id    = \"$$(cat aws_security_group_elb_visible_id)\"" >> ../visible.tfvars
	echo "aws_tag_value_team                   = \"$$(cat aws_tag_value_team)\"" >> ../visible.tfvars
	echo "aws_tag_value_cost_center            = \"$$(cat aws_tag_value_cost_center)\"" >> ../visible.tfvars
	echo "aws_iam_instance_profile_control  = \"$$(cat aws_iam_instance_profile_control)\"" >> ../visible.tfvars

../keys.tfvars: instance_aws_access_key instance_aws_secret_key operator_aws_access_key operator_aws_secret_key
	echo "aws_access_key          = \"$$(cat operator_aws_access_key)\"" >> ../keys.tfvars
	echo "aws_secret_key          = \"$$(cat operator_aws_secret_key)\"" >> ../keys.tfvars
	echo "instance_aws_access_key = \"$$(cat instance_aws_access_key)\"" >> ../keys.tfvars
	echo "instance_aws_secret_key = \"$$(cat instance_aws_secret_key)\"" >> ../keys.tfvars

operator_aws_access_key: aws/credentials
	cat ~/.aws/credentials | grep -v '^#' | grep 'aws_access_key_id' | head -1 | cut -d'=' -f 2 | sed -E -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$$//' > operator_aws_access_key

operator_aws_secret_key: aws/credentials
	cat ~/.aws/credentials | grep -v '^#' | grep 'aws_secret_access_key' | head -1 | cut -d'=' -f2 | sed -E -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$$//' > operator_aws_secret_key

instance_aws_access_key: visible_stacks jq
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMUserControlFauxInstanceProfileAccessKey").OutputValue' > instance_aws_access_key

instance_aws_secret_key: visible_stacks jq
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMUserControlFauxInstanceProfileSecretKey").OutputValue' > instance_aws_secret_key

visible_stacks: visible_iam_stack_id visible_dns_stack_id
	aws cloudformation describe-stacks > visible_stacks

visible_iam_stack_id: 
	aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-IAM").StackId' > visible_iam_stack_id

visible_dns_stack_id: 
	aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-DNS-ELB-S3").StackId' > visible_dns_stack_id

launch/visible_stacks: launch/iam_stack launch/dns_stack

launch/iam_stack: 
	./launch_iam_stack.sh | jq -r '.StackId' > visible_iam_stack_id

launch/dns_stack: 
	./launch_dns_stack.sh | jq -r '.StackId' > visible_dns_stack_id

launch/gtin_stack: 
	./launch_gtin_stack.sh | jq -r '.StackId' > visible_gtin_stack_id

aws_ec2_key_name: visible_stacks
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "StackKeyName").OutputValue' > aws_ec2_key_name

aws_route53_zone_id: visible_stacks
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "ZoneID").OutputValue' > aws_route53_zone_id

aws_security_group_elb_visible_id: visible_stacks
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBSecurityGroupID").OutputValue' > aws_security_group_elb_visible_id

aws_iam_server_certificate_arn: visible_stacks
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "SSLCertificateARN").OutputValue' > aws_iam_server_certificate_arn

aws_iam_instance_profile_control: visible_stacks
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMInstanceProfileControl").OutputValue' > aws_iam_instance_profile_control

visible_elb_hosted_zone_name: 
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBHostedZoneName").OutputValue' > visible_elb_hosted_zone_name

visible_elb_hosted_zone_name_id: 
	cat visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBHostedZoneNameID").OutputValue' > visible_elb_hosted_zone_name_id

aws/credentials: ~/.aws/credentials

\~/.aws/credentials: awscli
	aws configure

packages: /usr/local/bin/aws /usr/local/bin/jq

aws_vpc_zone_identifier: 
	echo "vpc-9111f3f4" >> aws_vpc_zone_identifier

aws_tag_value_team: 
	echo "InnovationPlatform" >> aws_tag_value_team

aws_tag_value_cost_center: 
	echo "45219" >> aws_tag_value_cost_center
