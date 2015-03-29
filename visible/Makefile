build = ../build
aws_vpc_zone_identifier = vpc-9111f3f4
aws_tag_value_team = InnovationPlatform
aws_tag_value_cost_center = 45219
stack_name_visible_iam = Innovation-Platform-Visible-IAM
stack_name_visible_dns = Innovation-Platform-Visible-DNS-ELB-S3
stack_name_visible_gtin = Innovation-Platform-Visible-DNS-GTIN
aws_server_certificate_visible_tls_name = STAR.cloud.nlab.io

# TODO: make a one-command launch of the whole stack work
# launch: deploy
# 	$$(terraform output fleet_env)
# 	./control/launch_units.sh

# TODO: make this conditional
.PHONY: deploy
deploy: $(build)/visible_stacks

# TODO: make this conditional
.PHONY: upload-certificates
upload-certificates: certificates/STAR_cloud_nlab_io.key certificates/STAR_cloud_nlab_io.crt certificates/STAR_cloud_nlab_io_chain.crt
	aws iam upload-server-certificate \
	  --path "/tls/" \
	  --server-certificate-name "$(aws_server_certificate_visible_tls_name)" \
	  --certificate-body file://$$(PWD)/certificates/STAR_cloud_nlab_io.crt \
	  --certificate-chain file://$$(PWD)/certificates/STAR_cloud_nlab_io_chain.crt \
	  --private-key file://$$(PWD)/certificates/STAR_cloud_nlab_io.key

.PHONY: outputs
outputs: $(build)/keys.tfvars $(build)/visible.tfvars $(build)/visible_elb_hosted_zone_name $(build)/visible_elb_hosted_zone_name_id

$(build)/visible.tfvars: $(build)/aws_vpc_zone_identifier $(build)/aws_route53_zone_id $(build)/aws_iam_server_certificate_arn $(build)/aws_iam_instance_profile_control $(build)/aws_ec2_key_name $(build)/aws_security_group_visible_elb_sg_id $(build)/aws_tag_value_team $(build)/aws_tag_value_cost_center
	echo "aws_vpc_zone_identifier              = \"$$(cat $(build)/aws_vpc_zone_identifier)\"" > $(build)/visible.tfvars
	echo "aws_route53_zone_id                  = \"$$(cat $(build)/aws_route53_zone_id)\"" >> $(build)/visible.tfvars
	echo "aws_iam_server_certificate_arn       = \"$$(cat $(build)/aws_iam_server_certificate_arn)\"" >> $(build)/visible.tfvars
	echo "aws_iam_instance_profile_control     = \"$$(cat $(build)/aws_iam_instance_profile_control)\"" >> $(build)/visible.tfvars
	echo "aws_ec2_key_name                     = \"$$(cat $(build)/aws_ec2_key_name)\"" >> $(build)/visible.tfvars
	echo "aws_security_group_visible_elb_sg_id = \"$$(cat $(build)/aws_security_group_visible_elb_sg_id)\"" >> $(build)/visible.tfvars
	echo "aws_tag_value_team                   = \"$$(cat $(build)/aws_tag_value_team)\"" >> $(build)/visible.tfvars
	echo "aws_tag_value_cost_center            = \"$$(cat $(build)/aws_tag_value_cost_center)\"" >> $(build)/visible.tfvars

$(build)/keys.tfvars: $(build)/instance_aws_access_key $(build)/instance_aws_secret_key $(build)/operator_aws_access_key $(build)/operator_aws_secret_key
	echo "aws_access_key          = \"$$(cat $(build)/operator_aws_access_key)\"" > $(build)/keys.tfvars
	echo "aws_secret_key          = \"$$(cat $(build)/operator_aws_secret_key)\"" >> $(build)/keys.tfvars
	echo "instance_aws_access_key = \"$$(cat $(build)/instance_aws_access_key)\"" >> $(build)/keys.tfvars
	echo "instance_aws_secret_key = \"$$(cat $(build)/instance_aws_secret_key)\"" >> $(build)/keys.tfvars

$(build)/operator_aws_access_key: ~/.aws/credentials
	cat ~/.aws/credentials | grep -v '^#' | grep 'aws_access_key_id' | head -1 | cut -d'=' -f 2 | sed -E -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$$//' > $(build)/operator_aws_access_key

$(build)/operator_aws_secret_key: ~/.aws/credentials
	cat ~/.aws/credentials | grep -v '^#' | grep 'aws_secret_access_key' | head -1 | cut -d'=' -f2 | sed -E -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$$//' > $(build)/operator_aws_secret_key

$(build)/instance_aws_access_key: $(build)/visible_stacks 
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMUserControlFauxInstanceProfileAccessKey").OutputValue' > $(build)/instance_aws_access_key

$(build)/instance_aws_secret_key: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMUserControlFauxInstanceProfileSecretKey").OutputValue' > $(build)/instance_aws_secret_key

$(build)/visible_iam_stack_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-IAM").StackId' > $(build)/visible_iam_stack_id

$(build)/visible_dns_stack_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-DNS-ELB-S3").StackId' > $(build)/visible_dns_stack_id

$(build)/visible_gtin_stack_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-GTIN").StackId' > $(build)/visible_gtin_stack_id

$(build)/visible_stacks: $(build)/stack_launched_iam $(build)/stack_launched_dns $(build)/stack_launched_gtin
	aws cloudformation describe-stacks > $(build)/visible_stacks

$(build)/stack_launched_iam: 
	touch $(build)/stack_launched_iam
	aws cloudformation create-stack \
	  --stack-name $(stack_name_visible_iam) \
	  --template-body file://$$(PWD)/iam.json \
	  --capabilities CAPABILITY_IAM \
	  --tags \
	    Key=Team,Value=$(aws_tag_value_team) \
	    Key=CostCenter,Value=$(aws_tag_value_cost_center) \
	  --parameters \
	    "ParameterKey=readableS3BucketsGlob,ParameterValue=innovation-platform-*" \
	    "ParameterKey=dockerRegistryS3BucketName,ParameterValue=internal-docker-registry" \
	    "ParameterKey=registerableLoadBalancersPath,ParameterValue=loadbalancer/*" \
	    "ParameterKey=readableDynamoDBTablesPath,ParameterValue=table/*"

$(build)/stack_launched_dns: 
	touch $(build)/stack_launched_dns
	aws cloudformation create-stack \
	  --stack-name $(stack_name_visible_dns) \
	  --template-body file://$$(PWD)/dns.json \
	  --tags \
	    Key=Team,Value=$(aws_tag_value_team) \
	    Key=CostCenter,Value=$(aws_tag_value_cost_center) \
	  --parameters \
	    "ParameterKey=zoneDNSRoot,ParameterValue=cloud.nlab.io,UsePreviousValue=false" \
	    "ParameterKey=keyName,ParameterValue=coreos-beta,UsePreviousValue=false" \
	    "ParameterKey=sslCertificateIAMPath,ParameterValue=/tls/$(aws_server_certificate_visible_tls_name),UsePreviousValue=false" \
	    "ParameterKey=dockerRegistryBucketName,ParameterValue=docker-registry,UsePreviousValue=false"

$(build)/stack_launched_gtin: $(build)/visible_elb_hosted_zone_name $(build)/visible_elb_hosted_zone_name_id
	touch $(build)/stack_launched_gtin
	aws cloudformation create-stack \
	  --stack-name $(stack_name_visible_gtin) \
	  --template-body file://$$(PWD)/gtin.json \
	  --tags \
	    Key=Team,Value=$(aws_tag_value_team) \
	    Key=CostCenter,Value=$(aws_tag_value_cost_center) \
	  --parameters \
	    "ParameterKey=zoneDNSRoot,ParameterValue=cloud.nlab.io,UsePreviousValue=false" \
	    "ParameterKey=visibleELBHostedZoneName,ParameterValue=$$(cat visible_elb_hosted_zone_name),UsePreviousValue=false" \
	    "ParameterKey=visibleELBHostedZoneNameID,ParameterValue=$$(cat visible_elb_hosted_zone_name_id),UsePreviousValue=false"

$(build)/stack_updated_iam: iam.json
	touch $(build)/stack_updated_iam
	aws cloudformation update-stack \
	  --stack-name $(stack_name_visible_iam) \
	  --template-body file://$$(PWD)/iam.json \
	  --no-use-previous-template \
	  --capabilities CAPABILITY_IAM \
	  --parameters \
	    "ParameterKey=readableS3BucketsGlob,UsePreviousValue=true" \
	    "ParameterKey=dockerRegistryS3BucketName,UsePreviousValue=true" \
	    "ParameterKey=registerableLoadBalancersPath,UsePreviousValue=true" \
	    "ParameterKey=readableDynamoDBTablesPath,UsePreviousValue=true"

$(build)/stack_updated_dns: dns.json
	touch $(build)/stack_updated_dns
	aws cloudformation update-stack \
	  --stack-name $(stack_name_visible_dns) \
	  --template-body file://$$(PWD)/dns.json \
	  --no-use-previous-template \
	  --parameters \
	    "ParameterKey=zoneDNSRoot,UsePreviousValue=true" \
	    "ParameterKey=keyName,UsePreviousValue=true" \
	    "ParameterKey=sslCertificateIAMPath,UsePreviousValue=true" \
	    "ParameterKey=dockerRegistryBucketName,UsePreviousValue=true"

$(build)/stack_updated_gtin: gtin.json
	touch $(build)/stack_updated_gtin
	aws cloudformation update-stack \
	  --stack-name $(stack_name_visible_gtin) \
	  --template-body file://$$(PWD)/gtin.json \
	  --no-use-previous-template \
	  --parameters \
	    "ParameterKey=zoneDNSRoot,UsePreviousValue=true" \
	    "ParameterKey=visibleELBHostedZoneName,UsePreviousValue=true" \
	    "ParameterKey=visibleELBHostedZoneNameID,UsePreviousValue=true"

$(build)/aws_ec2_key_name: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "StackKeyName").OutputValue' > $(build)/aws_ec2_key_name

$(build)/aws_route53_zone_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "ZoneID").OutputValue' > $(build)/aws_route53_zone_id

$(build)/aws_security_group_visible_elb_sg_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBSecurityGroupID").OutputValue' > $(build)/aws_security_group_visible_elb_sg_id

$(build)/aws_iam_server_certificate_arn: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "SSLCertificateARN").OutputValue' > $(build)/aws_iam_server_certificate_arn

$(build)/aws_iam_instance_profile_control: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMInstanceProfileControlName").OutputValue' > $(build)/aws_iam_instance_profile_control

$(build)/visible_elb_hosted_zone_name: 
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBHostedZoneName").OutputValue' > $(build)/visible_elb_hosted_zone_name

$(build)/visible_elb_hosted_zone_name_id: 
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBHostedZoneNameID").OutputValue' > $(build)/visible_elb_hosted_zone_name_id

~/.aws/credentials: 
	aws configure

$(build)/aws_vpc_zone_identifier: 
	echo "$(aws_vpc_zone_identifier)" > $(build)/aws_vpc_zone_identifier

$(build)/aws_tag_value_team: 
	echo "$(aws_tag_value_team)" > $(build)/aws_tag_value_team

$(build)/aws_tag_value_cost_center: 
	echo "$(aws_tag_value_cost_center)" > $(build)/aws_tag_value_cost_center

$(build)/stack_name_visible_iam: 
	echo "$(stack_name_visible_iam)" > $(build)/stack_name_visible_iam

$(build)/stack_name_visible_dns: 
	echo "$(stack_name_visible_dns)" > $(build)/stack_name_visible_dns

.PHONY: clean
clean:
	rm -f $(build)/aws_ec2_key_name
	rm -f $(build)/aws_iam_server_certificate_arn
	rm -f $(build)/aws_route53_zone_id
	rm -f $(build)/aws_security_group_visible_elb_sg_id
	rm -f $(build)/aws_tag_value_cost_center
	rm -f $(build)/aws_tag_value_team
	rm -f $(build)/aws_vpc_zone_identifier
	rm -f $(build)/visible_stacks
	rm -f $(build)/visible_iam_stack_id
	rm -f $(build)/visible_dns_stack_id
	rm -f $(build)/operator_aws_access_key
	rm -f $(build)/operator_aws_secret_key
	rm -f $(build)/instance_aws_access_key
	rm -f $(build)/instance_aws_secret_key
	rm -f $(build)/visible_elb_hosted_zone_name
	rm -f $(build)/visible_elb_hosted_zone_name_id

.PHONY: clean-outputs
clean-outputs: 
	rm -f $(build)/keys.tfvars
	rm -f $(build)/visible.tfvars

