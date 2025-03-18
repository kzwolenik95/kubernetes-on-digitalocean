terraform {
  backend "kubernetes" {
    secret_suffix = "terraform"
    namespace     = "hashicorp-vault"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
  }
}

provider "vault" {
  address = "http://vault.hashicorp-vault.svc.cluster.local:8200"
  auth_login {
    path = "auth/kubernetes/login"

    parameters = {
      role = "terraform"
      jwt  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
    }
  }
}

resource "vault_mount" "nextcloud_secret_engine" {
  path = "nextcloud"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kubernetes_auth_backend_role" "nextcloud_role" {
  backend                          = "kubernetes"
  role_name                        = "nextcloud"
  bound_service_account_names      = ["nextcloud"]
  bound_service_account_namespaces = ["nextcloud-storage"]
  token_policies                   = ["nextcloud-policy"]
  token_ttl                        = 3600
}

resource "vault_policy" "nextcloud_policy" {
  name = "nextcloud-policy"

  policy = <<-EOT
    path "nextcloud/*" {
      capabilities = ["read"]
    }
    EOT
}
