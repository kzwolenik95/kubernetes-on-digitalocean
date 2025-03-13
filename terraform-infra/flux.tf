resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "clusters/my-cluster"
}

resource "kubernetes_manifest" "flux_kustomization_game_2048" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "game-2048"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      sourceRef = {
        kind = "GitRepository"
        name = "flux-system"
      }
      path    = "./game-2048/kustomize"
      prune   = "true"
      timeout = "1m"
    }
  }
}

resource "kubernetes_manifest" "flux_kustomization_emojivoto" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "emojivoto"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      sourceRef = {
        kind = "GitRepository"
        name = "flux-system"
      }
      path    = "./emojivoto-example/kustomize"
      prune   = "true"
      timeout = "1m"
    }
  }
}

resource "kubernetes_manifest" "flux_kustomization_kube_prometheus" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "kube-prometheus-ingress"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      sourceRef = {
        kind      = "GitRepository"
        name      = "flux-system"
      }
      path    = "./kube-prometheus/manifests"
      prune   = "true"
      timeout = "1m"
    }
  }
}