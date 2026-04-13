data "aws_eks_cluster" "main" {
  name = var.names[var.env].cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = var.names[var.env].cluster_name
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["amazon_${var.env}_vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}