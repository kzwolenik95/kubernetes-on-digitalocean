resource "kubernetes_manifest" "kube_prometheus" {
  manifest = {
    "apiVersion" = "source.toolkit.fluxcd.io/v1"
    "kind"       = "GitRepository"
    "metadata" = {
      "name"      = "kube-prometheus"
      "namespace" = "flux-system"
    }
    "spec" = {
      "ignore"   = <<-EOT
      # exclude all
      /*
      # include deploy dir
      !/manifests
      EOT
      "interval" = "5m"
      "ref" = {
        "branch" = "main"
      }
      "url" = "https://github.com/prometheus-operator/kube-prometheus.git"
    }
  }
}

resource "kubernetes_manifest" "flux_kustomization_kube_prometheus" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "kube-prometheus"
      namespace = "flux-system"
    }
    spec = {
      interval        = "10m"
      sourceRef = {
        kind = "GitRepository"
        name = "kube-prometheus"
      }
      path    = "./manifests"
      prune   = "true"
      timeout = "1m"
    }
  }
}
