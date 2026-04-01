resource "google_cloud_run_domain_mapping" "cliproxy" {
  name     = var.cliproxy_domain
  location = var.gcp_region

  metadata {
    namespace = var.gcp_project
  }

  spec {
    route_name = google_cloud_run_v2_service.cliproxy.name
  }

  depends_on = [google_cloud_run_v2_service.cliproxy]
}

resource "cloudflare_record" "cliproxy_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "models.proxies.of"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 300
  proxied = false
  comment = "CLIProxyAPI (Cloud Run) - managed by Terraform"
}
