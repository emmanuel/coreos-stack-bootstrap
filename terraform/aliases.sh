#!/bin/bash

alias tfplan='terraform plan --var-file=terraform.tfvars --var-file etcd_discovery_url.tfvars --var-file environment.tfvars'
alias tfapply='terraform apply --var-file=terraform.tfvars --var-file etcd_discovery_url.tfvars --var-file environment.tfvars'
alias tfdestroyplan='terraform plan --var-file=terraform.tfvars --var-file etcd_discovery_url.tfvars --var-file environment.tfvars -destroy --out=destroy.tfplan'
