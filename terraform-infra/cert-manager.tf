resource "kubernetes_manifest" "helmrepository_flux_system_cert_manager" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "HelmRepository"
    metadata = {
      name      = "jetstack"
      namespace = "flux-system"
    }
    spec = {
      interval = "1h"
      url      = "https://charts.jetstack.io"
    }
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_manifest" "helmrelease_cert_manager" {
  manifest = {
    apiVersion = "helm.toolkit.fluxcd.io/v2beta1"
    kind       = "HelmRelease"
    metadata = {
      name      = "cert-manager"
      namespace = "cert-manager"
    }
    spec = {
      chart = {
        spec = {
          chart = "cert-manager"
          sourceRef = {
            kind      = "HelmRepository"
            name      = "jetstack"
            namespace = "flux-system"
          }
          version = "*"
        }
      }
      interval = "5m"
      values = {
        crds = {
          enabled = true
        }
      }
    }
  }
}

resource "kubernetes_secret" "cloudflare_api_token_cert_manager" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }
  data = {
    api-token = var.cloudflare_token
  }
  type = "Opaque"
}

resource "kubernetes_manifest" "clusterissuer_letsencrypt_dns" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    "kind"     = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        email = "kzwolenik95@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-key"
        }
        server = "https://acme-v02.api.letsencrypt.org/directory"
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token"
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}
