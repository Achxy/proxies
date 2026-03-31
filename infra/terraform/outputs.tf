output "service_url" {
  description = "Cloud Run auto-generated URL (for testing)"
  value       = google_cloud_run_v2_service.proxy.uri
}

output "custom_url" {
  description = "Custom domain URL"
  value       = "https://${var.domain}"
}

output "dashboard_url" {
  description = "Management dashboard URL"
  value       = "https://${var.domain}/management.html"
}

output "bucket_name" {
  description = "GCS bucket for persistent auth token storage"
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
