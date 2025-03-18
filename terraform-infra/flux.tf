resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "clusters/my-cluster"
}

resource "kubernetes_manifest" "flux_kustomizations" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "flux_kustomizations"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      sourceRef = {
        kind = "GitRepository"
        name = "flux-system"
      }
      path    = "./flux"
      prune   = "true"
      timeout = "1m"
    }
  }
}
