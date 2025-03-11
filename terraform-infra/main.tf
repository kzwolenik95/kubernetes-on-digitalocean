resource "digitalocean_project" "kubernetes" {
  name        = "kubernetes"
  description = "A project to deploy kubernetes."
  purpose     = "kubernetes"
  environment = "Development"

  resources = [digitalocean_kubernetes_cluster.kubernetes_cluster.urn]
}

resource "digitalocean_kubernetes_cluster" "kubernetes_cluster" {
  name   = "k8s-cluster"
  region = "fra1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.32.1-do.0"


  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 2
    tags       = ["k8s-cluster-firewall"]
  }
}

resource "digitalocean_firewall" "cluster_firewall" {
  depends_on = [digitalocean_kubernetes_cluster.kubernetes_cluster]
  name       = "k8s-cluster-firewall"
  tags       = ["k8s-cluster-firewall"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.admin_ip_address]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = [var.admin_ip_address]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "all"
    source_addresses = [var.admin_ip_address]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_container_registry" "container_registry" {
  name                   = "kubernetes-kzwolenik95"
  subscription_tier_slug = "starter"
  region                 = "fra1"
}
