resource "google_service_account" "proxy" {
  account_id   = "proxies-llm-sa"
  display_name = "CLIProxyAPI Cloud Run service account"

  depends_on = [google_project_service.iam]
}

resource "google_storage_bucket" "data" {
  name     = "${var.gcp_project}-proxies-data"
  location = var.gcp_region

  uniform_bucket_level_access = true

  # force_destroy = true allows terraform destroy to wipe the bucket.
  # Acceptable here because the bucket only holds auth tokens and an empty
  # placeholder file — both reproducible or re-creatable via the dashboard.
  # Do NOT use force_destroy on a Terraform state bucket.
  force_destroy = true

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

resource "google_storage_bucket_object" "auths_placeholder" {
  name    = "auths/.gitkeep"
  bucket  = google_storage_bucket.data.name
  content = " "
}

# Config is stored in Secret Manager and mounted into the container at runtime.
# secret_data_wo is a write-only attribute (Terraform >= 1.11) — the rendered
# config.yaml (including management_secret) never enters Terraform state.
resource "google_secret_manager_secret" "app_config" {
  secret_id = "proxies-llm-config"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "app_config" {
  secret = google_secret_manager_secret.app_config.id

  secret_data_wo = templatefile("${path.module}/config.yaml.tftpl", {
    management_secret = var.management_secret
  })

  # Increment var.config_version in terraform.tfvars to push a new secret
  # version on the next apply (e.g., after rotating management_secret).
  secret_data_wo_version = var.config_version
}

resource "google_secret_manager_secret_iam_member" "proxy_secret_accessor" {
  secret_id = google_secret_manager_secret.app_config.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.proxy.email}"
}
