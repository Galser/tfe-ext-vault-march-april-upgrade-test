output "compute_aws_region1_tfe" {
  value = module.compute_aws_region1_tfe.public_ip
}

output "compute_aws_region1_vault" {
  value = module.compute_aws_region1_vault.public_ip
}

output "fqdn-hosts" {
  value = {
    tfe-host   = "${var.tfe_name}.${var.site_domain}"
    vault-host = "${local.vault_host}.${var.site_domain}"
  }
}