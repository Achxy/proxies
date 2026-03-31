# NOTE: google_cloud_run_domain_mapping is a Preview API (not GA).
# Google explicitly states it is "not production-ready" and not covered by SLAs.
# The GA alternative is a Global External Application Load Balancer with a
# serverless NEG (~6 additional Terraform resources, ~$18/mo minimum cost).
# This setup is working in practice and the Preview API has been stable for years
# with no announced deprecation — the cost/complexity tradeoff favors keeping it.
resource "google_cloud_run_domain_mapping" "proxy" {
  name     = var.domain
  location = var.gcp_region

  metadata {
    namespace = var.gcp_project
  }

  spec {
    route_name = google_cloud_run_v2_service.proxy.name
  }

  depends_on = [google_cloud_run_v2_service.proxy]
}

resource "cloudflare_record" "proxy_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "llm.proxies.of"
  content = "ghs.googlehosted.com"
  type    = "CNAME"
  ttl     = 300
  proxied = false
  comment = "LLM Proxy (Cloud Run) - managed by Terraform"
}
