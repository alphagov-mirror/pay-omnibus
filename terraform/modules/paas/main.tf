data "cloudfoundry_org" "org" {
  name = var.org
}

data "cloudfoundry_space" "space" {
  name = var.space
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_space" "cde_space" {
  name = "${var.space}-cde"
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_domain" "internal" {
  name = "apps.internal"
}

data "cloudfoundry_domain" "external" {
  name = var.external_domain
}

data "cloudfoundry_domain" "paas_external" {
  name = "cloudapps.digital"
}
