resource "kubernetes_manifest" "helmrepository_flux_system_kong" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "HelmRepository"
    metadata = {
      name      = "kong"
      namespace = "flux-system"
    }
    spec = {
      interval = "1h"
      url      = "https://charts.konghq.com"
    }
  }
}

resource "kubernetes_namespace" "kong-system" {
  metadata {
    name = "kong-system"
  }
}

resource "kubernetes_manifest" "helmrelease_kong_system_kong_ingress" {
  manifest = {
    apiVersion = "helm.toolkit.fluxcd.io/v2beta1"
    kind       = "HelmRelease"
    metadata = {
      name      = "kong-ingress"
      namespace = "kong-system"
    }
    spec = {
      chart = {
        spec = {
          chart = "ingress"
          sourceRef = {
            kind      = "HelmRepository"
            name      = "kong"
            namespace = "flux-system"
          }
          version = "*"
        }
      }
      interval = "5m"
      values = {
        controller = {
          replicaCount = 2
        }
        gateway = {
          replicaCount = 2
          certificates = {
            enabled = true
            proxy = {
              enabled       = true
              issuer        = ""
              clusterIssuer = "letsencrypt"
              commonName    = "kzwolenik.com"
              dnsNames = [
                "*.kzwolenik.com",
                "kzwolenik.com"
              ]
            }
            admin = {
              enabled = false
            }
            portal = {
              enabled = false
            }
            cluster = {
              enabled = false
            }
          }
        }
      }
    }
  }
}
