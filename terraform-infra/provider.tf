terraform {
  cloud {
    organization = "kzwolenik95"
    hostname     = "app.terraform.io"

    workspaces {
      name = "kubernetes"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.49.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}

locals {
  kube_config = {
    host                   = digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config.0.cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["kubernetes", "cluster", "kubeconfig", "exec-credential", "--version=v1beta1", "--context=default", digitalocean_kubernetes_cluster.kubernetes_cluster.id]
      command     = "doctl"
    }
  }
}

provider "kubernetes" {
  host                   = local.kube_config.host
  cluster_ca_certificate = local.kube_config.cluster_ca_certificate
  exec {
    api_version = local.kube_config.exec.api_version
    args        = local.kube_config.exec.args
    command     = local.kube_config.exec.command
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "flux" {
  kubernetes = local.kube_config
  git = {
    url = var.github_repository
    http = {
      username = "git" # This can be any string when using a personal access token
      password = var.github_token
    }
  }
}
