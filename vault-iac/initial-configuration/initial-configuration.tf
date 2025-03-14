terraform {
  backend "kubernetes" {
    secret_suffix = "terraform-init-setup-state"
    namespace     = "hashicorp-vault"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}
variable "token" {
  type      = string
  sensitive = true
}

provider "vault" {
  address = "http://vault.hashicorp-vault.svc.cluster.local:8200"
  token   = var.token
}

provider "kubernetes" {}

resource "kubernetes_service_account" "terraform-vault" {
  metadata {
    name      = "terraform-vault"
    namespace = "hashicorp-vault"
  }
}

resource "kubernetes_role" "terraform-vault-role" {
  metadata {
    name      = "terraform-vault"
    namespace = "hashicorp-vault"
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["tfstate-default-terraform"]
    verbs          = ["get", "create", "update", "patch"]
  }
}

resource "kubernetes_role_binding" "terraform-vault-rolebinding" {
  metadata {
    name      = "terraform-vault"
    namespace = "hashicorp-vault"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "terraform-vault"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "terraform-vault"
    namespace = "hashicorp-vault"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.default.svc"
  kubernetes_ca_cert = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
  token_reviewer_jwt = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
}
