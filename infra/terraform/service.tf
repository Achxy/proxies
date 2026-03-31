resource "google_cloud_run_v2_service" "proxy" {
  name     = "proxies-llm"
  location = var.gcp_region

  # deletion_protection = true prevents accidental destruction via terraform destroy
  # or direct API calls. To destroy this service intentionally:
  #   1. Temporarily set deletion_protection = false in this file
  #   2. terraform apply -target=google_cloud_run_v2_service.proxy
  #   3. terraform destroy
  #   4. Revert (or leave it, since the resource is gone)
  deletion_protection = true

  template {
    service_account = google_service_account.proxy.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image   = "docker.io/eceasy/cli-proxy-api:${var.image_tag}"
      command = ["./CLIProxyAPI"]
      args    = ["--config", "/config/config.yaml"]

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

      # GCS FUSE: persistent auth token storage at /data/auths
      volume_mounts {
        name       = "proxy-data"
        mount_path = "/data"
      }

      # Secret Manager: config.yaml mounted as a file at /config/config.yaml
      volume_mounts {
        name       = "app-config"
        mount_path = "/config"
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

    volumes {
      name = "app-config"
      secret {
        secret = google_secret_manager_secret.app_config.secret_id
        items {
          version = "latest"
          path    = "config.yaml"
        }
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_storage_bucket_iam_member.proxy_data_access,
    google_secret_manager_secret_iam_member.proxy_secret_accessor,
    google_secret_manager_secret_version.app_config,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.proxy.name
  location = google_cloud_run_v2_service.proxy.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
