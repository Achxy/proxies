resource "google_secret_manager_secret" "litellm_config" {
  secret_id = "litellm-config"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "litellm_config" {
  secret      = google_secret_manager_secret.litellm_config.id
  secret_data = file("${path.module}/litellm_config.yaml")
}

resource "google_secret_manager_secret_iam_member" "proxy_config" {
  secret_id = google_secret_manager_secret.litellm_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.proxy.email}"
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = "litellm-database-url"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "database_url" {
  secret                 = google_secret_manager_secret.database_url.id
  secret_data_wo         = var.database_url
  secret_data_wo_version = 1
}

resource "google_secret_manager_secret_iam_member" "proxy_database_url" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.proxy.email}"
}

resource "google_secret_manager_secret" "litellm_master_key" {
  secret_id = "litellm-master-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "litellm_master_key" {
  secret                 = google_secret_manager_secret.litellm_master_key.id
  secret_data_wo         = var.litellm_master_key
  secret_data_wo_version = 1
}

resource "google_secret_manager_secret_iam_member" "proxy_master_key" {
  secret_id = google_secret_manager_secret.litellm_master_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.proxy.email}"
}

resource "google_secret_manager_secret" "litellm_salt_key" {
  secret_id = "litellm-salt-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "litellm_salt_key" {
  secret                 = google_secret_manager_secret.litellm_salt_key.id
  secret_data_wo         = var.litellm_salt_key
  secret_data_wo_version = 1
}

resource "google_secret_manager_secret_iam_member" "proxy_salt_key" {
  secret_id = google_secret_manager_secret.litellm_salt_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.proxy.email}"
}

# CLIProxyAPI upstream API key (used by LiteLLM to call CLIProxyAPI)
resource "google_secret_manager_secret" "cliproxy_upstream_key" {
  secret_id = "cliproxy-upstream-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "cliproxy_upstream_key" {
  secret                 = google_secret_manager_secret.cliproxy_upstream_key.id
  secret_data_wo         = var.cliproxy_upstream_key
  secret_data_wo_version = 1
}

resource "google_secret_manager_secret_iam_member" "proxy_cliproxy_upstream_key" {
  secret_id = google_secret_manager_secret.cliproxy_upstream_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.proxy.email}"
}
