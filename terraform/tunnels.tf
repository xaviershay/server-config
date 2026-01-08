resource "random_id" "tunnel_secret" {
  byte_length = 64
}

variable "allowed_users" {
  type = list(string)
}

output "cloudflared_tunnel_id" {
  description = "ID of the created tunnel"
  value       = cloudflare_zero_trust_tunnel_cloudflared.auto_tunnel.tunnel_token
  sensitive   = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "Home tunnel"
  secret     = base64sha256(random_id.tunnel_secret.b64_std)
}

resource "cloudflare_record" "http_app" {
  zone_id = module.zone_xaviershay_com.id
  name    = "home"
  content   = "${cloudflare_zero_trust_tunnel_cloudflared.auto_tunnel.cname}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "http_grafana" {
  zone_id = module.zone_xaviershay_com.id
  name    = "grafana"
  content   = "${cloudflare_zero_trust_tunnel_cloudflared.auto_tunnel.cname}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "http_app" {
  zone_id = module.zone_xaviershay_com.id
  name             = "Home"
  domain           = "home.xaviershay.com"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_application" "http_grafana" {
  zone_id = module.zone_xaviershay_com.id
  name             = "Grafana"
  domain           = "grafana.xaviershay.com"
  session_duration = "24h"
}

# Creates the configuration for the tunnel.
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "auto_tunnel" {
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.auto_tunnel.id
  account_id = var.cloudflare_account_id
  config {
   ingress_rule {
     hostname = "${cloudflare_record.http_app.hostname}"
     service  = "http://localhost:80"
     origin_request {
       connect_timeout = "2m0s"
       access {
         required  = true
         team_name = "xaviershay"
         aud_tag   = [cloudflare_zero_trust_access_application.http_app.aud]
       }
     }
   }
   ingress_rule {
     hostname = "${cloudflare_record.http_grafana.hostname}"
     service  = "http://grafana.home:3000"
     origin_request {
       connect_timeout = "2m0s"
       access {
         required  = true
         team_name = "xaviershay"
         aud_tag   = [cloudflare_zero_trust_access_application.http_grafana.aud]
       }
     }
   }
   ingress_rule {
     service  = "http_status:404"
   }
  }
}

# Create an Access Group for the single user
resource "cloudflare_zero_trust_access_group" "home" {
  account_id = var.cloudflare_account_id
  name       = "home"

  include {
    email = var.allowed_users
  }
}

# Create an Access Policy and attach it to the HTTP application
resource "cloudflare_zero_trust_access_policy" "allow_user" {
  account_id     = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.http_app.id
  name           = "Home Access"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_zero_trust_access_group.home.id]
  }
}

# Create an Access Policy and attach it to the HTTP Grafana application
resource "cloudflare_zero_trust_access_policy" "allow_grafana_user" {
  account_id     = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.http_grafana.id
  name           = "Grafana Access"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_zero_trust_access_group.home.id]
  }
}