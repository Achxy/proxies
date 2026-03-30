resource "google_cloud_run_v2_service" "proxy" {
  name                = "proxies-llm"
  location            = var.gcp_region
  deletion_protection = false

  template {
    service_account = google_service_account.proxy.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image   = "docker.io/eceasy/cli-proxy-api:latest"
      command = ["./CLIProxyAPI"]
      args    = ["--config", "/data/config.yaml"]

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
        name  = "DEPLOY"
        value = "cloud"
      }

      volume_mounts {
        name       = "proxy-data"
        mount_path = "/data"
      }

      startup_probe {
        tcp_socket {
          port = 8317
        }
        initial_delay_seconds = 10
        period_seconds        = 5
        failure_threshold     = 12
        timeout_seconds       = 3
      }
    }

    volumes {
      name = "proxy-data"
      gcs {
        bucket    = google_storage_bucket.data.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_storage_bucket_object.config,
    google_storage_bucket_iam_member.proxy_data_access,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.proxy.name
  location = google_cloud_run_v2_service.proxy.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
