variable "bucket_name" {
  description = "The name of the bucket"
  type = string
}

variable "group_name" {
  description = "Name of an IAM group that will have write access to bucket"
  type = string
}
