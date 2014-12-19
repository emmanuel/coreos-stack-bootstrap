#!/bin/bash

alias tfplan='terraform plan --var-file ../cluster_values.tfvars --var-file=../terraform.global.tfvars --var-file=terraform.local.tfvars'
alias tfapply='terraform apply --var-file ../cluster_values.tfvars --var-file=../terraform.global.tfvars --var-file=terraform.local.tfvars'
alias tfrefresh='terraform refresh --var-file ../cluster_values.tfvars --var-file=../terraform.global.tfvars --var-file=terraform.local.tfvars'
alias tfdestroyplan='terraform plan --var-file ../cluster_values.tfvars --var-file=../terraform.global.tfvars --var-file=terraform.local.tfvars -destroy --out=destroy.tfplan'
