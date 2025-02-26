variable "do_token" {
  type      = string
  sensitive = true
}
variable "admin_ip_address" {
  type = string
}
variable "github_repository" {
  type = string
}
variable "github_token" {
  type      = string
  sensitive = true
}
variable "cloudflare_token" {
  type      = string
  sensitive = true
}
