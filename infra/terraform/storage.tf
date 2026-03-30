resource "google_service_account" "proxy" {
  account_id   = "proxies-llm-sa"
  display_name = "CLIProxyAPI Cloud Run service account"

  depends_on = [google_project_service.iam]
}

resource "google_storage_bucket" "data" {
  name     = "${var.gcp_project}-proxies-data"
  location = var.gcp_region

  uniform_bucket_level_access = true
  force_destroy               = true

  depends_on = [google_project_service.storage]
}

resource "google_storage_bucket_iam_member" "proxy_data_access" {
  bucket = google_storage_bucket.data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.proxy.email}"
}

data "google_project" "current" {}

resource "google_service_account_iam_member" "cloud_run_token_creator" {
  service_account_id = google_service_account.proxy.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_storage_bucket_object" "config" {
  name   = "config.yaml"
  bucket = google_storage_bucket.data.name
  content = templatefile("${path.module}/config.yaml.tftpl", {
    management_secret = var.management_secret
    api_keys_yaml     = join("\n", [for k in var.api_keys : "  - \"${k}\""])
  })
}

resource "google_storage_bucket_object" "auths_placeholder" {
  name    = "auths/.gitkeep"
  bucket  = google_storage_bucket.data.name
  content = " "
}
