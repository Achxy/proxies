resource "google_cloud_run_v2_service" "proxy" {
  name     = "proxies-llm"
  location = var.gcp_region

  deletion_protection = true

  template {
    service_account = google_service_account.proxy.email

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project}/${google_artifact_registry_repository.ghcr_proxy.repository_id}/berriai/litellm-database:${var.image_tag}"
      args  = ["--config", "/config/litellm_config.yaml", "--port", "4000"]

      ports {
        container_port = 4000
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "2Gi"
        }
      }

      env {
        name  = "LITELLM_MODE"
        value = "PRODUCTION"
      }
      env {
        name  = "LITELLM_LOG"
        value = "ERROR"
      }
      env {
        name  = "STORE_MODEL_IN_DB"
        value = "True"
      }

      # Secrets from Secret Manager
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "LITELLM_MASTER_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.litellm_master_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "LITELLM_SALT_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.litellm_salt_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "CLIPROXY_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.cliproxy_upstream_key.secret_id
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "config"
        mount_path = "/config"
      }

      startup_probe {
        http_get {
          path = "/health/liveliness"
          port = 4000
        }
        initial_delay_seconds = 30
        period_seconds        = 10
        failure_threshold     = 30
        timeout_seconds       = 3
      }
    }

    volumes {
      name = "config"
      secret {
        secret = google_secret_manager_secret.litellm_config.secret_id
        items {
          version = "latest"
          path    = "litellm_config.yaml"
        }
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_secret_manager_secret_version.litellm_config,
    google_secret_manager_secret_version.database_url,
    google_secret_manager_secret_version.litellm_master_key,
    google_secret_manager_secret_version.litellm_salt_key,
    google_secret_manager_secret_iam_member.proxy_config,
    google_secret_manager_secret_iam_member.proxy_database_url,
    google_secret_manager_secret_iam_member.proxy_master_key,
    google_secret_manager_secret_iam_member.proxy_salt_key,
    google_secret_manager_secret_version.cliproxy_upstream_key,
    google_secret_manager_secret_iam_member.proxy_cliproxy_upstream_key,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.proxy.name
  location = google_cloud_run_v2_service.proxy.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
