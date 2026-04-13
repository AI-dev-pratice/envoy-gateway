aws_region = "ap-south-1"

env = "production"

names = {
  dev = {
    cluster_name     = "amazon-production-eks-cluster"
    name             = "envoy-gateway-controller"
    gateway_name     = "eks-gw-dev"
    load_balancer_ip = ""   # leave empty — NLB assigns DNS automatically
  }
  production = {
    cluster_name     = "amazon-production-eks-cluster"
    name             = "envoy-gateway-controller"
    gateway_name     = "eks-gw-prod"
    load_balancer_ip = ""   # leave empty — NLB assigns DNS automatically
  }
}

tags = {
  terraform   = "aws-eks"
  environment = "production"
  project     = "amazon"
  managed_by  = "terraform"
  team        = "devops"
}