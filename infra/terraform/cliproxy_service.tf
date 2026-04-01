resource "google_cloud_run_v2_service" "cliproxy" {
  name     = "proxies-models"
  location = var.gcp_region

  deletion_protection = true

  template {
    service_account = google_service_account.cliproxy.email

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project}/${google_artifact_registry_repository.dockerhub_proxy.repository_id}/eceasy/cli-proxy-api:${var.cliproxy_image_tag}"

      ports {
        container_port = 8317
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "TZ"
        value = "UTC"
      }

      env {
        name = "MANAGEMENT_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.cliproxy_management_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "PGSTORE_DSN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.cliproxy_pgstore_dsn.secret_id
            version = "latest"
          }
        }
      }

      startup_probe {
        tcp_socket {
          port = 8317
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 10
        timeout_seconds       = 3
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_secret_manager_secret_version.cliproxy_management_password,
    google_secret_manager_secret_version.cliproxy_pgstore_dsn,
    google_secret_manager_secret_iam_member.cliproxy_management_password,
    google_secret_manager_secret_iam_member.cliproxy_pgstore_dsn,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "cliproxy_public" {
  name     = google_cloud_run_v2_service.cliproxy.name
  location = google_cloud_run_v2_service.cliproxy.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
