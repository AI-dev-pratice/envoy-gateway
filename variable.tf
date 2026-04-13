variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "env" {
  type        = string
  description = "Environment — dev or production"
  validation {
    condition     = contains(["dev", "production"], var.env)
    error_message = "Must be 'dev' or 'production'"
  }
}

variable "names" {
  type = map(object({
    cluster_name     = string
    name             = string
    gateway_name     = string
    load_balancer_ip = string   # static IP for NLB (optional, leave "" for auto)
  }))
  default = {
    dev = {
      cluster_name     = "amazon-production-eks-cluster"
      name             = "envoy-gateway-controller"
      gateway_name     = "eks-gw"
      load_balancer_ip = ""
    }
    production = {
      cluster_name     = "amazon-production-eks-cluster"
      name             = "envoy-gateway-controller"
      gateway_name     = "eks-gw"
      load_balancer_ip = ""
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    terraform   = "aws-eks"
    environment = "production"
    managed_by  = "terraform"
  }
}