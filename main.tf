
# Get the AMI in region 1
data "aws_ami" "ubuntu-18_04-region1" {
  provider    = aws.region1
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

# SSH Key : region 1
module "sshkey_aws_region1" {
  source = "./modules/sshkey_aws"
  providers = {
    aws = aws.region1
  }
  name     = "${var.testname}-region1"
  key_path = "~/.ssh/id_rsa.pub"
}

# Network : AWS VPC , region 1
module "vpc_aws_region1" {
  source = "./modules/vpc_aws"
  providers = {
    aws = aws.region1
  }

  vpcCIDRblock    = var.region1_vpcCIDRblock
  subnetCIDRblock = var.region1_subnetCIDRblock

  tag = var.tag
}

# Instance : AWS EC2 , instance 1
module "compute_aws_region1_tfe" {
  source = "./modules/compute_aws"
  providers = {
    aws = aws.region1
  }

  name            = "extvault_upgrade_test_tfe"
  ami             = data.aws_ami.ubuntu-18_04-region1.id
  instance_type   = var.instance_type
  security_groups = [module.vpc_aws_region1.security_group_id]
  subnet_id       = module.vpc_aws_region1.subnet_id
  key_name        = module.sshkey_aws_region1.key_id
  key_path        = "~/.ssh/id_rsa"
}

module "compute_aws_region1_vault" {
  source = "./modules/compute_aws"
  providers = {
    aws = aws.region1
  }

  name            = "extvault_upgrade_test_vault"
  ami             = data.aws_ami.ubuntu-18_04-region1.id
  instance_type   = var.instance_type
  security_groups = [module.vpc_aws_region1.security_group_id]
  subnet_id       = module.vpc_aws_region1.subnet_id
  key_name        = module.sshkey_aws_region1.key_id
  key_path        = "~/.ssh/id_rsa"
}


## DNS & Certs

# Network : DNS CloudFlare
# Note - depends from Load-Balancer and computing 
# resources defined below in the code
module "dns_cloudflare_tfe" {
  source = "./modules/dns_cloudflare"

  host   = var.tfe_name
  domain = var.site_domain
  #  cname_target = module.lb_aws.fqdn
  frontend_ip = module.compute_aws_region1_tfe.public_ip

  //backend_ip = module.compute_gcp.instance_data.public_ip
}

locals {
  vault_host = "${var.tfe_name}-vault"
}

module "dns_cloudflare_vault" {
  source = "./modules/dns_cloudflare"

  host   = local.vault_host
  domain = var.site_domain
  #  cname_target = module.lb_aws.fqdn
  frontend_ip = module.compute_aws_region1_vault.public_ip

  //backend_ip = module.compute_gcp.instance_data.public_ip
}


# Certificate : SSL from Let'sEncrypt
module "sslcert_letsencrypt_tfe" {

  source = "./modules/sslcert_letsencrypt"

  host         = var.tfe_name
  domain       = var.site_domain
  dns_provider = "cloudflare"
}

module "sslcert_letsencrypt_vault" {

  source = "./modules/sslcert_letsencrypt"

  host         = local.vault_host
  domain       = var.site_domain
  dns_provider = "cloudflare"
}

