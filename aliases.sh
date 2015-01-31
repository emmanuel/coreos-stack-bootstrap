#!/bin/bash

alias tfplan='terraform plan --var-file ../cluster_id.tfvars --var-file=../keys.tfvars'
alias tfapply='terraform apply --var-file ../cluster_id.tfvars --var-file=../keys.tfvars'
alias tfrefresh='terraform refresh --var-file ../cluster_id.tfvars --var-file=../keys.tfvars'
alias tfdestroyplan='terraform plan --var-file ../cluster_id.tfvars --var-file=../keys.tfvars -destroy --out=destroy.tfplan'
