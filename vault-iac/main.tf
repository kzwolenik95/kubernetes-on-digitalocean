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

resource "vault_kubernetes_auth_backend_role" "webapp" {
  backend                          = "kubernetes"
  role_name                        = "webapp"
  bound_service_account_names      = ["vault-auth"]
  bound_service_account_namespaces = ["default"]
  token_policies                   = ["demo-policy"]
  token_ttl                        = 259200 # 72 hours in seconds
}

resource "vault_policy" "demo_policy" {
  name = "demo-policy"

  policy = <<-EOT
    path "demo-app/*" {
      capabilities = ["read"]
    }
    EOT
}

resource "vault_mount" "demo_app" {
  path = "demo-app"
  type = "kv"
  options = {
    version = "2"
  }
}

