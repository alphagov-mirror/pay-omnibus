data "cloudfoundry_service" "splunk" {
  name = "splunk"
}

resource "cloudfoundry_service_instance" "splunk_log_service" {
  name         = "splunk-log-service"
  service_plan = data.cloudfoundry_service.splunk.service_plans["unlimited"]
  space        = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_service_instance" "cde_splunk_log_service" {
  name         = "splunk-log-service"
  service_plan = data.cloudfoundry_service.splunk.service_plans["unlimited"]
  space        = data.cloudfoundry_space.cde_space.id
}