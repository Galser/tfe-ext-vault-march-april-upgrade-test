variable "region1" {
  default = "eu-west-1"
}

variable "region1_vpcCIDRblock" {
  default = "10.1.0.0/16"
}

variable "region1_subnetCIDRblock" {
  default = "10.1.0.0/24"
}

variable "ubuntu_account_number" {
  default = "099720109477"
}

variable "testname" {
  default = "agtest"
}

variable "site_domain" {
  type    = string
  default = "guselietov.com"
}

variable "tfe_name" {
  type    = string
  default = "tfe-ext-vault"
}

variable "tag" {
  default = "guselietov_test_3"
}

variable "instance_type" {
  default = "m5.large"
}