provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

resource "vault_generic_secret" "secret" {
  path = "secret/${var.environment}/${var.service}"

  data_json = jsonencode({
    db_user     = var.service
    db_password = uuid()
  })
}

resource "vault_policy" "policy" {
  name = "${var.service}-${var.environment}"

  policy = <<EOT
path "secret/data/${var.environment}/${var.service}" {
  capabilities = ["list", "read"]
}
EOT
}

resource "vault_generic_endpoint" "user" {
  depends_on           = [vault_policy.policy]
  path                 = "auth/userpass/users/${var.service}-${var.environment}"
  ignore_absent_fields = true

  data_json = jsonencode({
    policies = ["${var.service}-${var.environment}"]
    password = "123-${var.service}-${var.environment}"
  })
}

resource "docker_container" "container" {
  image = var.docker_image
  name  = "${var.service}_${var.environment}"

  env = [
    "VAULT_ADDR=${var.vault_address}",
    "VAULT_USERNAME=${var.service}-${var.environment}",
    "VAULT_PASSWORD=123-${var.service}-${var.environment}",
    "ENVIRONMENT=${var.environment}"
  ]

  networks_advanced {
    name = var.network_name
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [vault_generic_endpoint.user]
}
