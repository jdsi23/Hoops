variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "container_image" {
  description = "ECR image to deploy"
  type        = string
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 8080
}
