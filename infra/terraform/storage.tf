resource "google_service_account" "proxy" {
  account_id   = "proxies-llm-sa"
  display_name = "LiteLLM proxy Cloud Run service account"

  depends_on = [google_project_service.iam]
}

resource "google_kms_key_ring" "data" {
  name     = "proxies-data"
  location = var.gcp_region

  depends_on = [google_project_service.kms]
}

resource "google_kms_crypto_key" "data" {
  name            = "data-encryption"
  key_ring        = google_kms_key_ring.data.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

data "google_project" "current" {}

resource "google_kms_crypto_key_iam_member" "gcs_service_agent" {
  crypto_key_id = google_kms_crypto_key.data.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "data" {
  name     = "${var.gcp_project}-proxies-data"
  location = var.gcp_region

  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.data.id
  }

  force_destroy = true

  depends_on = [
    google_project_service.storage,
    google_kms_crypto_key_iam_member.gcs_service_agent,
  ]
}

resource "google_storage_bucket_iam_member" "proxy_config_read" {
  bucket = google_storage_bucket.data.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.proxy.email}"
}

resource "google_storage_bucket_object" "config" {
  name    = "litellm_config.yaml"
  bucket  = google_storage_bucket.data.name
  content = file("${path.module}/litellm_config.yaml")
}
