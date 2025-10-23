terraform {
  required_version = ">= 1.0.7"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
    vault = {
      version = "3.0.1"
    }
  }
}

locals {
  services = ["account", "gateway", "payment"]

  environments = {
    development = {
      vault_address = "http://localhost:8201"
      vault_token   = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
      vault_port    = 8200
      network_name  = "vagrant_development"
    },
    production = {
      vault_address = "http://localhost:8301"
      vault_token   = "083672fc-4471-4ec4-9b59-a285e463a973"
      vault_port    = 8200
      network_name  = "vagrant_production"
    },
    staging = {
      vault_address = "http://localhost:8401"
      vault_token   = "99999999-4471-4ec4-9b59-a285e463a973"
      vault_port    = 8200
      network_name  = "vagrant_staging"
    }
  }
}

module "services_dev" {
  for_each      = toset(local.services)
  source        = "./modules/service"
  service       = each.key
  environment   = "development"
  vault_address = local.environments["development"].vault_address
  vault_token   = local.environments["development"].vault_token
  vault_port    = local.environments["development"].vault_port
  network_name  = local.environments["development"].network_name
  docker_image  = "form3tech-oss/platformtest-${each.key}"
}

module "services_prod" {
  for_each      = toset(local.services)
  source        = "./modules/service"
  service       = each.key
  environment   = "production"
  vault_address = local.environments["production"].vault_address
  vault_token   = local.environments["production"].vault_token
  vault_port    = local.environments["production"].vault_port
  network_name  = local.environments["production"].network_name
  docker_image  = "form3tech-oss/platformtest-${each.key}"
}

module "services_staging" {
  for_each      = toset(local.services)
  source        = "./modules/service"
  service       = each.key
  environment   = "staging"
  vault_address = local.environments["staging"].vault_address
  vault_token   = local.environments["staging"].vault_token
  vault_port    = local.environments["staging"].vault_port
  network_name  = local.environments["staging"].network_name
  docker_image  = "form3tech-oss/platformtest-${each.key}"
}
