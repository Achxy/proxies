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

variable "database_url" {
  description = "PostgreSQL connection string (Neon). Format: postgresql://user:pass@host/db?sslmode=require"
  type        = string
  sensitive   = true
}

variable "litellm_master_key" {
  description = "LiteLLM admin API key (must start with sk-). Used for API auth and UI login."
  type        = string
  sensitive   = true
}

variable "litellm_salt_key" {
  description = "Encryption salt for credentials stored in the database. Generate with: openssl rand -base64 32. Never rotate — encrypted data becomes unrecoverable."
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "LiteLLM Docker image tag (ghcr.io/berriai/litellm-database)"
  type        = string
  default     = "main-stable"
}

# CLIProxyAPI variables

variable "cliproxy_domain" {
  description = "Custom domain for the CLIProxyAPI service"
  type        = string
  default     = "models.proxies.of.achyuth.dev"
}

variable "cliproxy_image_tag" {
  description = "CLIProxyAPI Docker image tag (eceasy/cli-proxy-api)"
  type        = string
  default     = "v6.9.7"
}

variable "cliproxy_pgstore_dsn" {
  description = "PostgreSQL connection string for CLIProxyAPI persistent storage (OAuth tokens, config). Can share the Neon instance — tables use a LiteLLM-incompatible naming scheme so there are no collisions."
  type        = string
  sensitive   = true
}

variable "cliproxy_management_password" {
  description = "Password for CLIProxyAPI management UI"
  type        = string
  sensitive   = true
}

variable "cliproxy_upstream_key" {
  description = "API key that LiteLLM uses to authenticate to CLIProxyAPI. Must match an entry in CLIProxyAPI's api-keys config."
  type        = string
  sensitive   = true
}
