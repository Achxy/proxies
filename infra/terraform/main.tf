terraform {
  required_version = ">= 1.11.0"

  backend "gcs" {
    # Configured via: terraform init -backend-config=backend.tfbackend
    # See backend.tfbackend.example for the template.
    # The state bucket must exist before running terraform init.
    # Create it with: make bootstrap-state GCP_PROJECT=<your-project-id>
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.25"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

