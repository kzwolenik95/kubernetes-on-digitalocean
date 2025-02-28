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
      interval = "10m"
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

resource "kubernetes_manifest" "grafana_ingress" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "annotations" = {
        "external-dns.alpha.kubernetes.io/hostname" = "grafana.kzwolenik.com"
      }
      "name" = "grafana-ingress"
    }
    "spec" = {
      "ingressClassName" = "kong"
      "rules" = [
        {
          "host" = "grafana.kzwolenik.com"
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "grafana"
                    "port" = {
                      "number" = 3000
                    }
                  }
                }
                "path"     = "/"
                "pathType" = "ImplementationSpecific"
              },
            ]
          }
        },
      ]
    }
  }
}

# resource "kubernetes_manifest" "kongplugin_ip_restriction" {
#   manifest = {
#     "apiVersion" = "configuration.konghq.com/v1"
#     "config" = {
#       "allow" = [
#         "your.ip.address.here",
#       ]
#     }
#     "kind" = "KongPlugin"
#     "metadata" = {
#       "name" = "grafana-ip-restriction"
#     }
#     "plugin" = "ip-restriction"
#   }
# }
