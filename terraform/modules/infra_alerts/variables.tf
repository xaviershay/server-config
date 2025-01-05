variable "topic_name" {
  description = "SNS topic name to hold alerts"
  type = string
}

variable "phone_number" {
  description = "Phone number to receive SMS notifications"
  type        = string
}
