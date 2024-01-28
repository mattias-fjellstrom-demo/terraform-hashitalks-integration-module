terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

variable "fqdn" {
  type = string
}

variable "trigger" {
  type = string
}

resource "time_sleep" "sleep" {
  triggers = {
    trigger = var.trigger
  }
  create_duration = "60s"
}

data "http" "tm" {
  depends_on = [time_sleep.sleep]
  url        = "http://${var.fqdn}"
}

output "response" {
  value = data.http.tm.response_body
}
