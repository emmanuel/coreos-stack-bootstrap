output "consul_url" {
  value = "http://${var.stack_name}-consul.cloud.nlab.io/"
}

output "fleet_env" {
  value = "export FLEETCTL_TUNNEL=${var.stack_name}.cloud.nlab.io:2222\nexport FLEETCTL_STRICT_HOST_KEY_CHECKING=false"
}
