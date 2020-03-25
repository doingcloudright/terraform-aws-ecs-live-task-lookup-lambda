variable "create" {
  type = bool
  default = true
}

variable "name" {
  type = string
}

# container_name sets the name of the container where we lookup the container_image
variable "tags" {
  type    = map
  default = {}
}

# container_name sets the name of the container where we lookup the container_image
variable "lambda_runtime" {
  type    = string
  default = "nodejs12.x"
}
