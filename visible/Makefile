 build = ../build

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
	  --server-certificate-name "STAR.cloud.nlab.io" \
	  --certificate-body file://$PWD/certificates/STAR_cloud_nlab_io.crt \
	  --certificate-chain file://$PWD/certificates/STAR_cloud_nlab_io_chain.crt \
	  --private-key file://$PWD/certificates/STAR_cloud_nlab_io.key

.PHONY: outputs
outputs: $(build)/keys.tfvars $(build)/visible.tfvars $(build)/visible_elb_hosted_zone_name $(build)/visible_elb_hosted_zone_name_id

$(build)/visible.tfvars: $(build)/aws_vpc_zone_identifier \
	$(build)/aws_route53_zone_id \
	$(build)/aws_iam_server_certificate_arn \
	$(build)/aws_ec2_key_name \
	$(build)/aws_security_group_elb_visible_id \
	$(build)/aws_tag_value_team \
	$(build)/aws_tag_value_cost_center \
	$(build)/aws_iam_instance_profile_control
	echo "aws_vpc_zone_identifier           = \"$$(cat $(build)/aws_vpc_zone_identifier)\"" >> $(build)/visible.tfvars
	echo "aws_route53_zone_id               = \"$$(cat $(build)/aws_route53_zone_id)\"" >> $(build)/visible.tfvars
	echo "aws_iam_server_certificate_arn    = \"$$(cat $(build)/aws_iam_server_certificate_arn)\"" >> $(build)/visible.tfvars
	echo "aws_iam_instance_profile_control  = \"$$(cat $(build)/aws_iam_instance_profile_control)\"" >> $(build)/visible.tfvars
	echo "aws_ec2_key_name                  = \"$$(cat $(build)/aws_ec2_key_name)\"" >> $(build)/visible.tfvars
	echo "aws_security_group_elb_visible_id = \"$$(cat $(build)/aws_security_group_elb_visible_id)\"" >> $(build)/visible.tfvars
	echo "aws_tag_value_team                = \"$$(cat $(build)/aws_tag_value_team)\"" >> $(build)/visible.tfvars
	echo "aws_tag_value_cost_center         = \"$$(cat $(build)/aws_tag_value_cost_center)\"" >> $(build)/visible.tfvars

$(build)/keys.tfvars: $(build)/instance_aws_access_key $(build)/instance_aws_secret_key $(build)/operator_aws_access_key $(build)/operator_aws_secret_key
	echo "aws_access_key          = \"$$(cat $(build)/operator_aws_access_key)\"" >> $(build)/keys.tfvars
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

$(build)/visible_stacks: $(build)/visible_iam_stack_id $(build)/visible_dns_stack_id $(build)/visible_gtin_stack_id
	aws cloudformation describe-stacks > $(build)/visible_stacks

$(build)/visible_iam_stack_id: $(build)/iam_stack_launched
	aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-IAM").StackId' > $(build)/visible_iam_stack_id

$(build)/visible_dns_stack_id: $(build)/dns_stack_launched
	aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-DNS-ELB-S3").StackId' > $(build)/visible_dns_stack_id

$(build)/visible_gtin_stack_id: $(build)/gtin_stack_launched
	aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName == "InnovationPlatform-Visible-GTIN").StackId' > $(build)/visible_gtin_stack_id

$(build)/iam_stack_launched: 
	./launch_iam_stack.sh | jq -r '.StackId' > $(build)/visible_iam_stack_id

$(build)/dns_stack_launched: 
	./launch_dns_stack.sh | jq -r '.StackId' > $(build)/visible_dns_stack_id

$(build)/gtin_stack_launched: 
	./launch_gtin_stack.sh | jq -r '.StackId' > $(build)/visible_gtin_stack_id

$(build)/aws_ec2_key_name: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "StackKeyName").OutputValue' > $(build)/aws_ec2_key_name

$(build)/aws_route53_zone_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "ZoneID").OutputValue' > $(build)/aws_route53_zone_id

$(build)/aws_security_group_elb_visible_id: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBSecurityGroupID").OutputValue' > $(build)/aws_security_group_elb_visible_id

$(build)/aws_iam_server_certificate_arn: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "SSLCertificateARN").OutputValue' > $(build)/aws_iam_server_certificate_arn

$(build)/aws_iam_instance_profile_control: $(build)/visible_stacks
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "IAMInstanceProfileControl").OutputValue' > $(build)/aws_iam_instance_profile_control

$(build)/visible_elb_hosted_zone_name: 
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBHostedZoneName").OutputValue' > $(build)/visible_elb_hosted_zone_name

$(build)/visible_elb_hosted_zone_name_id: 
	cat $(build)/visible_stacks | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "VisibleELBHostedZoneNameID").OutputValue' > $(build)/visible_elb_hosted_zone_name_id

\~/.aws/credentials: 
	aws configure

$(build)/aws_vpc_zone_identifier: 
	echo "vpc-9111f3f4" >> $(build)/aws_vpc_zone_identifier

$(build)/aws_tag_value_team: 
	echo "InnovationPlatform" >> $(build)/aws_tag_value_team

$(build)/aws_tag_value_cost_center: 
	echo "45219" >> $(build)/aws_tag_value_cost_center

.PHONY: clean
clean:
	rm -f $(build)/aws_ec2_key_name
	rm -f $(build)/aws_iam_server_certificate_arn
	rm -f $(build)/aws_route53_zone_id
	rm -f $(build)/aws_security_group_elb_visible_id
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

