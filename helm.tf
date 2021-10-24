provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# install monitoring tools
resource "helm_release" "loki_stack" {
  name             = "loki"
  namespace        = "monitoring"
  create_namespace = true
  cleanup_on_fail  = true
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"

  values = [
    file("${path.module}/templates/grafana_helm_values.tpl")
  ]

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "fluent-bit.enabled"
    value = "true"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "grafana.grafana\\.ini.database.host"
    value = module.rds.db_instance_address
  }

  set {
    name  = "grafana.grafana\\.ini.database.password"
    value = random_password.grafana_password.result
  }

  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }

  depends_on = [null_resource.grafana_db_import]

}
