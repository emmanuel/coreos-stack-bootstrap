#!/bin/bash

alias tfplan='terraform plan --var-file=terraform.tfvars --var-file etcd_discovery_url.tfvars'
alias tfapply='terraform apply --var-file=terraform.tfvars --var-file etcd_discovery_url.tfvars'
alias tfdestroyplan='terraform plan --var-file=terraform.tfvars --var-file etcd_discovery_url.tfvars -destroy --out=destroy.tfplan'
