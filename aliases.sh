#!/bin/bash

alias        tfplan='terraform plan --var-file ../cluster_id.tfvars --var-file=../keys.tfvars --var-file=../visible.tfvars'
alias      tfapply='terraform apply --var-file ../cluster_id.tfvars --var-file=../keys.tfvars --var-file=../visible.tfvars'
alias  tfrefresh='terraform refresh --var-file ../cluster_id.tfvars --var-file=../keys.tfvars --var-file=../visible.tfvars'
alias tfdestroyplan='terraform plan --var-file ../cluster_id.tfvars --var-file=../keys.tfvars --var-file=../visible.tfvars -destroy --out=destroy.tfplan'
