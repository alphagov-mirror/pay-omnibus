locals {
  low_pass_values = zipmap(keys(data.pass_password.secret), values(data.pass_password.secret).*.password)
}

provider "pass" {
  store_dir = "../../../pay-low-pass"
  refresh_store = false
}

data "pass_password" "secret" {
  for_each = var.pay_low_pass_secrets
  path = each.value
}

