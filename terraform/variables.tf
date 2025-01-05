variable "phone_number" {
  description = "Phone number to receive SMS notifications"
  type        = string
  # Format: +1234567890
}

# variable "dnsimple_account_id" {
#   description = "DNSimple Account ID"
#   type = string
# }
# 
# variable "dnsimple_token" {
#   description = "DNSimple API Token"
#   type = string
#   sensitive = true
# }