Configuring AWS to tell us when things happen to our instances
--------------------------------------------------------------

The basic plan is as follows: the auto-scaling group will send notifications
to an AWS Simple Notification Service (SNS) topic when instances are launched or
terminated. The SNS topic will have an SQS queue as a subscriber. Then, we'll
configure our service to pull messages off the SQS queue and do something
appropriate (like remove the instance from the etcd quorum).

To get there, I did the following setup. All of these steps were done manually 
outside of Terraform, since Terraform doesn't support SNS or SQS (yet). 
Thankfully, these steps only have to be done once (not once per cluster). More
details at the official docs:
http://docs.aws.amazon.com/sns/latest/dg/SendMessageToSQS.html

Highlights: 

1. Create an SNS topic (copy its ARN)
2. Create an SQS queue (copy its ARN)
3. Create a permission on the SQS queue for the SNS topic to enqueue messages
4. Create an SNS topic subscription targeting the SQS queue

My plan is to build a small go program that will listen for messages on the SQS
queue and take appropriate corrective/maintenance action (e.g., remove a
terminated instance from the etcd members list).
