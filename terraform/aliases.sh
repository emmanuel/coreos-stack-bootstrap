#!/bin/bash

alias tfplan='terraform plan --var-file=terraform.tfvars --var-file cluster_values.tfvars'
alias tfapply='terraform apply --var-file=terraform.tfvars --var-file cluster_values.tfvars'
alias tfdestroyplan='terraform plan --var-file=terraform.tfvars --var-file cluster_values.tfvars -destroy --out=destroy.tfplan'
