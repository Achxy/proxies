variable "gcp_project" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region (must support Cloud Run domain mapping)"
  type        = string
  default     = "us-central1"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions on achyuth.dev"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for achyuth.dev"
  type        = string
}

variable "domain" {
  description = "Custom domain for the proxy service"
  type        = string
  default     = "llm.proxies.of.achyuth.dev"
}

variable "management_secret" {
  description = "Secret key for CLIProxyAPI management dashboard access"
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "CLIProxyAPI Docker image tag to deploy"
  type        = string
  default     = "v6.9.6"
}

