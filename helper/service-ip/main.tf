terraform {
  required_providers {
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = "2.25.2"
      configuration_aliases = [kubernetes.cluster01, kubernetes.cluster02]
    }

    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
  }
}

resource "time_sleep" "this" {
  create_duration = "60s"
}

data "kubernetes_service" "service01" {
  provider = kubernetes.cluster01
  metadata {
    name = "hello-hashitalks-svc"
  }
  depends_on = [time_sleep.this]
}

data "kubernetes_service" "service02" {
  provider = kubernetes.cluster02
  metadata {
    name = "hello-hashitalks-svc"
  }
  depends_on = [time_sleep.this]
}

output "service01_ip" {
  value = data.kubernetes_service.service01.status[0].load_balancer[0].ingress[0].ip
}

output "service02_ip" {
  value = data.kubernetes_service.service02.status[0].load_balancer[0].ingress[0].ip
}
