resource "kubernetes_manifest" "helmrepository_flux_system_external_dns" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "HelmRepository"
    metadata = {
      name      = "external-dns"
      namespace = "flux-system"
    }
    spec = {
      interval = "1h"
      url      = "https://kubernetes-sigs.github.io/external-dns/"
    }
  }
}

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "cloudflare-api-token_external_dns" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "external-dns"
  }
  data = {
    apiKey = var.cloudflare_token
  }
  type = "Opaque"
}

resource "kubernetes_manifest" "helmrelease_external_dns" {
  manifest = {
    apiVersion = "helm.toolkit.fluxcd.io/v2beta1"
    kind       = "HelmRelease"
    metadata = {
      name      = "external-dns"
      namespace = "external-dns"
    }
    spec = {
      chart = {
        spec = {
          chart = "external-dns"
          sourceRef = {
            kind      = "HelmRepository"
            name      = "external-dns"
            namespace = "flux-system"
          }
          version = "1.5.0"
        }
      }
      interval = "5m"
      values = {
        provider = "cloudflare"
        env = [
          {
            name = "CF_API_TOKEN"
            valueFrom = {
              secretKeyRef = {
                name = "cloudflare-api-token"
                key  = "apiKey"
              }
            }
          }
        ]
      }
    }
  }
}
