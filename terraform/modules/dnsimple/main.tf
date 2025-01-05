terraform {
  required_providers {
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "~> 1.0"
    }
  }
}

provider "dnsimple" {
  token   = var.dnsimple_token
  account = var.dnsimple_account_id
}

variable "dnsimple_token" {
  type      = string
  sensitive = true
}

variable "dnsimple_account_id" {
  type = string
}


# Zone: dbisyourfriend.com
resource "dnsimple_zone_record" "dbisyourfriend_com_mx_apex" {
  zone_name = "dbisyourfriend.com"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "dbisyourfriend_com_mx_apex_2" {
  zone_name = "dbisyourfriend.com"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "dbisyourfriend_com_cname_mail" {
  zone_name = "dbisyourfriend.com"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_spf_apex" {
  zone_name = "dbisyourfriend.com"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_txt_apex" {
  zone_name = "dbisyourfriend.com"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_alias_apex" {
  zone_name = "dbisyourfriend.com"
  name   = ""
  type   = "ALIAS"
  value  = "d23w87a8fjkh8y.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_txt_apex_2" {
  zone_name = "dbisyourfriend.com"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for d23w87a8fjkh8y.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_cname_www" {
  zone_name = "dbisyourfriend.com"
  name   = "www"
  type   = "CNAME"
  value  = "d23w87a8fjkh8y.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_cname__686c207ceecb58e351890902a01bea15" {
  zone_name = "dbisyourfriend.com"
  name   = "_686c207ceecb58e351890902a01bea15"
  type   = "CNAME"
  value  = "_4390ceafbeef5760cf5fa67a94de2970.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "dbisyourfriend_com_cname__d592b7af147a78767a0deccd6dc196ec_www" {
  zone_name = "dbisyourfriend.com"
  name   = "_d592b7af147a78767a0deccd6dc196ec.www"
  type   = "CNAME"
  value  = "_084bfef37b01306cc5874e6417dcf249.acm-validations.aws"
  ttl    = 3600
}


# Zone: eventhandapp.com
resource "dnsimple_zone_record" "eventhandapp_com_alias_apex" {
  zone_name = "eventhandapp.com"
  name   = ""
  type   = "ALIAS"
  value  = "eventhandapp.com.herokudns.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_txt_apex" {
  zone_name = "eventhandapp.com"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for eventhandapp.com.herokudns.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_www" {
  zone_name = "eventhandapp.com"
  name   = "www"
  type   = "CNAME"
  value  = "www.eventhandapp.com.herokudns.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_mx_apex" {
  zone_name = "eventhandapp.com"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "eventhandapp_com_mx_apex_2" {
  zone_name = "eventhandapp.com"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_mail" {
  zone_name = "eventhandapp.com"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_spf_apex" {
  zone_name = "eventhandapp.com"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_txt_apex_2" {
  zone_name = "eventhandapp.com"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_em6257" {
  zone_name = "eventhandapp.com"
  name   = "em6257"
  type   = "CNAME"
  value  = "u61799.wl050.sendgrid.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_s1__domainkey" {
  zone_name = "eventhandapp.com"
  name   = "s1._domainkey"
  type   = "CNAME"
  value  = "s1.domainkey.u61799.wl050.sendgrid.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_s2__domainkey" {
  zone_name = "eventhandapp.com"
  name   = "s2._domainkey"
  type   = "CNAME"
  value  = "s2.domainkey.u61799.wl050.sendgrid.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_url4584" {
  zone_name = "eventhandapp.com"
  name   = "url4584"
  type   = "CNAME"
  value  = "sendgrid.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "eventhandapp_com_cname_61799" {
  zone_name = "eventhandapp.com"
  name   = "61799"
  type   = "CNAME"
  value  = "sendgrid.net"
  ttl    = 3600
}


# Zone: lindylog.net
resource "dnsimple_zone_record" "lindylog_net_mx_apex" {
  zone_name = "lindylog.net"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "lindylog_net_mx_apex_2" {
  zone_name = "lindylog.net"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "lindylog_net_cname_mail" {
  zone_name = "lindylog.net"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "lindylog_net_spf_apex" {
  zone_name = "lindylog.net"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "lindylog_net_txt_apex" {
  zone_name = "lindylog.net"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "lindylog_net_alias_apex" {
  zone_name = "lindylog.net"
  name   = ""
  type   = "ALIAS"
  value  = "lindylog-cedar.herokuapp.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "lindylog_net_txt_apex_2" {
  zone_name = "lindylog.net"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for lindylog-cedar.herokuapp.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "lindylog_net_cname_www" {
  zone_name = "lindylog.net"
  name   = "www"
  type   = "CNAME"
  value  = "lindylog-cedar.herokuapp.com"
  ttl    = 3600
}


# Zone: outage.party
resource "dnsimple_zone_record" "outage_party_alias_apex" {
  zone_name = "outage.party"
  name   = ""
  type   = "ALIAS"
  value  = "dgl6xuan41dnf.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "outage_party_txt_apex" {
  zone_name = "outage.party"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for dgl6xuan41dnf.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "outage_party_cname__14676a8005ace4350280bac364b8bd63" {
  zone_name = "outage.party"
  name   = "_14676a8005ace4350280bac364b8bd63"
  type   = "CNAME"
  value  = "_4db2b193bba02d27e49884aa702c1b2b.acm-validations.aws"
  ttl    = 60
}


# Zone: rhnh.net
resource "dnsimple_zone_record" "rhnh_net_alias_apex" {
  zone_name = "rhnh.net"
  name   = ""
  type   = "ALIAS"
  value  = "d2llx8i3cqnxcv.cloudfront.net"
  ttl    = 60
}

resource "dnsimple_zone_record" "rhnh_net_txt_apex" {
  zone_name = "rhnh.net"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for d2llx8i3cqnxcv.cloudfront.net"
  ttl    = 60
}

resource "dnsimple_zone_record" "rhnh_net_cname_www" {
  zone_name = "rhnh.net"
  name   = "www"
  type   = "CNAME"
  value  = "d2llx8i3cqnxcv.cloudfront.net"
  ttl    = 60
}

resource "dnsimple_zone_record" "rhnh_net_mx_apex" {
  zone_name = "rhnh.net"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "rhnh_net_mx_apex_2" {
  zone_name = "rhnh.net"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "rhnh_net_cname_mail" {
  zone_name = "rhnh.net"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "rhnh_net_spf_apex" {
  zone_name = "rhnh.net"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "rhnh_net_txt_apex_2" {
  zone_name = "rhnh.net"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "rhnh_net_cname__6fbbb34e0e725355318436e3bd72fa9b" {
  zone_name = "rhnh.net"
  name   = "_6fbbb34e0e725355318436e3bd72fa9b"
  type   = "CNAME"
  value  = "_9d77ba460d7c845571962859ee6bd2e1.bcnrdwzwjt.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "rhnh_net_cname__6dce3b8af42b389d093d894bfa9894f3_www" {
  zone_name = "rhnh.net"
  name   = "_6dce3b8af42b389d093d894bfa9894f3.www"
  type   = "CNAME"
  value  = "_cefd391ccc9fd074e24ad3783dd54387.bcnrdwzwjt.acm-validations.aws"
  ttl    = 3600
}


# Zone: tenarms.net
resource "dnsimple_zone_record" "tenarms_net_a_www" {
  zone_name = "tenarms.net"
  name   = "www"
  type   = "A"
  value  = "54.200.171.68"
  ttl    = 3600
}

resource "dnsimple_zone_record" "tenarms_net_mx_apex" {
  zone_name = "tenarms.net"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "tenarms_net_mx_apex_2" {
  zone_name = "tenarms.net"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "tenarms_net_cname_mail" {
  zone_name = "tenarms.net"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "tenarms_net_spf_apex" {
  zone_name = "tenarms.net"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "tenarms_net_txt_apex" {
  zone_name = "tenarms.net"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}


# Zone: two-shay.com
resource "dnsimple_zone_record" "two_shay_com_mx_apex" {
  zone_name = "two-shay.com"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "two_shay_com_mx_apex_2" {
  zone_name = "two-shay.com"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "two_shay_com_cname_mail" {
  zone_name = "two-shay.com"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_spf_apex" {
  zone_name = "two-shay.com"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_txt_apex" {
  zone_name = "two-shay.com"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_alias_apex" {
  zone_name = "two-shay.com"
  name   = ""
  type   = "ALIAS"
  value  = "d2g9bhuyjuqorw.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_txt_apex_2" {
  zone_name = "two-shay.com"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for d2g9bhuyjuqorw.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_cname_www" {
  zone_name = "two-shay.com"
  name   = "www"
  type   = "CNAME"
  value  = "d2g9bhuyjuqorw.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_cname__ea532065614f7b3177376e68336d1217" {
  zone_name = "two-shay.com"
  name   = "_ea532065614f7b3177376e68336d1217"
  type   = "CNAME"
  value  = "_f4b9c7a02b4c901c40106f15f09c1266.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "two_shay_com_cname__f4d03e78248ba1c6ed721a29777fc69f_www" {
  zone_name = "two-shay.com"
  name   = "_f4d03e78248ba1c6ed721a29777fc69f.www"
  type   = "CNAME"
  value  = "_cde2787ce4a62d629fe476dc56791c7b.acm-validations.aws"
  ttl    = 3600
}


# Zone: veganmelbourne.com.au
resource "dnsimple_zone_record" "veganmelbourne_com_au_alias_apex" {
  zone_name = "veganmelbourne.com.au"
  name   = ""
  type   = "ALIAS"
  value  = "dwbz3y17dkc09.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_txt_apex" {
  zone_name = "veganmelbourne.com.au"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for dwbz3y17dkc09.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_cname_www" {
  zone_name = "veganmelbourne.com.au"
  name   = "www"
  type   = "CNAME"
  value  = "dwbz3y17dkc09.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_mx_apex" {
  zone_name = "veganmelbourne.com.au"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_mx_apex_2" {
  zone_name = "veganmelbourne.com.au"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_cname_mail" {
  zone_name = "veganmelbourne.com.au"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_spf_apex" {
  zone_name = "veganmelbourne.com.au"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_txt_apex_2" {
  zone_name = "veganmelbourne.com.au"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_cname__233f42ee4d779e3103e3b58cf9090b5c" {
  zone_name = "veganmelbourne.com.au"
  name   = "_233f42ee4d779e3103e3b58cf9090b5c"
  type   = "CNAME"
  value  = "_3e0aa1c74941880fb1e93aa83dcf5503.djqtsrsxkq.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "veganmelbourne_com_au_cname__6b4dfc4925c45aebdb7cf9d9af47de54_www" {
  zone_name = "veganmelbourne.com.au"
  name   = "_6b4dfc4925c45aebdb7cf9d9af47de54.www"
  type   = "CNAME"
  value  = "_bb1cc0fbea68ebdd0b0edf8aefa6226b.djqtsrsxkq.acm-validations.aws"
  ttl    = 3600
}


# Zone: vegan-month.com
resource "dnsimple_zone_record" "vegan_month_com_alias_apex" {
  zone_name = "vegan-month.com"
  name   = ""
  type   = "ALIAS"
  value  = "vegan-month.herokuapp.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "vegan_month_com_txt_apex" {
  zone_name = "vegan-month.com"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for vegan-month.herokuapp.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "vegan_month_com_cname_www" {
  zone_name = "vegan-month.com"
  name   = "www"
  type   = "CNAME"
  value  = "vegan-month.herokuapp.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "vegan_month_com_mx_apex" {
  zone_name = "vegan-month.com"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "vegan_month_com_mx_apex_2" {
  zone_name = "vegan-month.com"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "vegan_month_com_cname_mail" {
  zone_name = "vegan-month.com"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "vegan_month_com_spf_apex" {
  zone_name = "vegan-month.com"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "vegan_month_com_txt_apex_2" {
  zone_name = "vegan-month.com"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}


# Zone: xaviershay.com
resource "dnsimple_zone_record" "xaviershay_com_alias_apex" {
  zone_name = "xaviershay.com"
  name   = ""
  type   = "ALIAS"
  value  = "d35moas0x4pv9r.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_txt_apex" {
  zone_name = "xaviershay.com"
  name   = ""
  type   = "TXT"
  value  = "ALIAS for d35moas0x4pv9r.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_www" {
  zone_name = "xaviershay.com"
  name   = "www"
  type   = "CNAME"
  value  = "d35moas0x4pv9r.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_mx_apex" {
  zone_name = "xaviershay.com"
  name   = ""
  type   = "MX"
  value  = "in1-smtp.messagingengine.com"
  ttl    = 3600
  priority = 10
}

resource "dnsimple_zone_record" "xaviershay_com_mx_apex_2" {
  zone_name = "xaviershay.com"
  name   = ""
  type   = "MX"
  value  = "in2-smtp.messagingengine.com"
  ttl    = 3600
  priority = 20
}

resource "dnsimple_zone_record" "xaviershay_com_cname_mail" {
  zone_name = "xaviershay.com"
  name   = "mail"
  type   = "CNAME"
  value  = "www.fastmail.fm"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_spf_apex" {
  zone_name = "xaviershay.com"
  name   = ""
  type   = "SPF"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_txt_apex_2" {
  zone_name = "xaviershay.com"
  name   = ""
  type   = "TXT"
  value  = "v=spf1 include:spf.messagingengine.com ~all"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_blog" {
  zone_name = "xaviershay.com"
  name   = "blog"
  type   = "CNAME"
  value  = "d2puzksnnvzvkd.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_sheets" {
  zone_name = "xaviershay.com"
  name   = "sheets"
  type   = "CNAME"
  value  = "d1ydiph2rmtzld.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname__059c6b2c4cb9015569fdb4601549e52a_peakyfinders" {
  zone_name = "xaviershay.com"
  name   = "_059c6b2c4cb9015569fdb4601549e52a.peakyfinders"
  type   = "CNAME"
  value  = "_d3e1a3e4eb35faf927fca6e00882d30f.vybhcgkthd.acm-validations.aws"
  ttl    = 60
}

resource "dnsimple_zone_record" "xaviershay_com_cname_peakyfinders" {
  zone_name = "xaviershay.com"
  name   = "peakyfinders"
  type   = "CNAME"
  value  = "d1g86hcaqn89ou.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_fm1__domainkey" {
  zone_name = "xaviershay.com"
  name   = "fm1._domainkey"
  type   = "CNAME"
  value  = "fm1.xaviershay.com.dkim.fmhosted.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_fm2__domainkey" {
  zone_name = "xaviershay.com"
  name   = "fm2._domainkey"
  type   = "CNAME"
  value  = "fm2.xaviershay.com.dkim.fmhosted.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_fm3__domainkey" {
  zone_name = "xaviershay.com"
  name   = "fm3._domainkey"
  type   = "CNAME"
  value  = "fm3.xaviershay.com.dkim.fmhosted.com"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname__07c0bd879c92f3a19555d9b816d7b3bb_sheets" {
  zone_name = "xaviershay.com"
  name   = "_07c0bd879c92f3a19555d9b816d7b3bb.sheets"
  type   = "CNAME"
  value  = "_f5acc99c93c3df36dcd8c1902eb43010.duyqrilejt.acm-validations.aws"
  ttl    = 600
}

resource "dnsimple_zone_record" "xaviershay_com_cname__913843815ffdf2bee3b5e1ee35832a01_mapshot" {
  zone_name = "xaviershay.com"
  name   = "_913843815ffdf2bee3b5e1ee35832a01.mapshot"
  type   = "CNAME"
  value  = "_df09426a22343f2a35f0c6c6fab1a02a.fcgjwsnkyp.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname_mapshot" {
  zone_name = "xaviershay.com"
  name   = "mapshot"
  type   = "CNAME"
  value  = "d16m1c5goj0iug.cloudfront.net"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname__d362f15cc49c75c96c711e89f52c0b3e_blog" {
  zone_name = "xaviershay.com"
  name   = "_d362f15cc49c75c96c711e89f52c0b3e.blog"
  type   = "CNAME"
  value  = "_8b9a3692fc06098d884b7f83c2bbf398.djqtsrsxkq.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname__89089d7b424247383c3db6c8becf388a" {
  zone_name = "xaviershay.com"
  name   = "_89089d7b424247383c3db6c8becf388a"
  type   = "CNAME"
  value  = "_107a4aba2373ccd033997a450d0d9c96.djqtsrsxkq.acm-validations.aws"
  ttl    = 3600
}

resource "dnsimple_zone_record" "xaviershay_com_cname__8e3a6eaeb7b4d6ba08d5acae9fd76799_www" {
  zone_name = "xaviershay.com"
  name   = "_8e3a6eaeb7b4d6ba08d5acae9fd76799.www"
  type   = "CNAME"
  value  = "_d0c015e30056fbdb2e638ef032fd6b1e.djqtsrsxkq.acm-validations.aws"
  ttl    = 3600
}
