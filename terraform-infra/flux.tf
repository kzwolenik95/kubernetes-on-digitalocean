resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "clusters/my-cluster"
}

resource "kubernetes_manifest" "flux_kustomization" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind = "Kustomization"
    metadata = {
      name = "game-2048"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      targetNamespace = "game-2048"
      sourceRef = {
        kind = "GitRepository"
        name = "flux-system"
      }
      path = "./game-2048/kustomize"
      prune = "true"
      timeout = "1m"
    }
  }
}
