terraform {
  backend "kubernetes" {
    secret_suffix = "terraform-init-setup-state"
    namespace     = "default"
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
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "update", "delete", "watch"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["list", "create"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["tfstate-default-terraform"]
    verbs          = ["get", "update", "patch"]
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

resource "vault_kubernetes_auth_backend_config" "terraform-vault-config" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc"
}

resource "vault_policy" "terraform-vault-policy" {
  name = "terraform-vault"

  policy = <<-EOT
    path "*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    path "sys/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    EOT
}

resource "vault_kubernetes_auth_backend_role" "terraform-vault-role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "terraform"
  bound_service_account_names      = [kubernetes_service_account.terraform-vault.metadata.name]
  bound_service_account_namespaces = ["hashicorp-vault"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.terraform-vault-policy.name]
  # audience                         = "vault"
}
