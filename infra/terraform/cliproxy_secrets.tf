resource "google_service_account" "cliproxy" {
  account_id   = "proxies-models-sa"
  display_name = "CLIProxyAPI Cloud Run service account"

  depends_on = [google_project_service.iam]
}

resource "google_secret_manager_secret" "cliproxy_management_password" {
  secret_id = "cliproxy-management-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "cliproxy_management_password" {
  secret                 = google_secret_manager_secret.cliproxy_management_password.id
  secret_data_wo         = var.cliproxy_management_password
  secret_data_wo_version = 1
}

resource "google_secret_manager_secret_iam_member" "cliproxy_management_password" {
  secret_id = google_secret_manager_secret.cliproxy_management_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cliproxy.email}"
}

resource "google_secret_manager_secret" "cliproxy_pgstore_dsn" {
  secret_id = "cliproxy-pgstore-dsn"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "cliproxy_pgstore_dsn" {
  secret                 = google_secret_manager_secret.cliproxy_pgstore_dsn.id
  secret_data_wo         = var.cliproxy_pgstore_dsn
  secret_data_wo_version = 1
}

resource "google_secret_manager_secret_iam_member" "cliproxy_pgstore_dsn" {
  secret_id = google_secret_manager_secret.cliproxy_pgstore_dsn.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cliproxy.email}"
}
