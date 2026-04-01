output "service_url" {
  description = "Cloud Run auto-generated URL (for testing)"
  value       = google_cloud_run_v2_service.proxy.uri
}

output "custom_url" {
  description = "Custom domain URL"
  value       = "https://${var.domain}"
}

output "dashboard_url" {
  description = "LiteLLM admin dashboard"
  value       = "https://${var.domain}/ui"
}

output "cliproxy_service_url" {
  description = "CLIProxyAPI Cloud Run auto-generated URL (for testing)"
  value       = google_cloud_run_v2_service.cliproxy.uri
}

output "cliproxy_custom_url" {
  description = "CLIProxyAPI custom domain URL"
  value       = "https://${var.cliproxy_domain}"
}

output "bucket_name" {
  description = "GCS bucket for LiteLLM config"
  value       = google_storage_bucket.data.name
}

output "gcp_project" {
  description = "GCP project ID"
  value       = var.gcp_project
}

output "gcp_region" {
  description = "GCP region"
  value       = var.gcp_region
}
