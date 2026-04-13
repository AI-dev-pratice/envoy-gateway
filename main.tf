##############################################
# Namespace
##############################################

resource "kubernetes_namespace_v1" "main" {
  metadata {
    name = var.names[var.env].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

##############################################
# Gateway API CRDs (same as Azure version)
##############################################

data "http" "gateway_api" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml"
}

data "kubectl_file_documents" "gateway_api" {
  content = data.http.gateway_api.response_body
}

resource "kubectl_manifest" "gateway_api" {
  for_each  = data.kubectl_file_documents.gateway_api.manifests
  yaml_body = each.value
}

##############################################
# Envoy Gateway Helm Release
# Same chart as Azure, values differ for AWS
##############################################

resource "helm_release" "envoy_gateway" {
  name             = "eg"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = "1.7.1"
  namespace        = kubernetes_namespace_v1.main.metadata[0].name
  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  timeout = 600

  depends_on = [
    kubernetes_namespace_v1.main,
    kubectl_manifest.gateway_api
  ]
}

##############################################
# GatewayClass (identical to Azure version)
##############################################

resource "kubectl_manifest" "gatewayclass" {
  yaml_body  = file("${path.module}/k8s-manifests/gateway-class.yaml")
  depends_on = [helm_release.envoy_gateway]
}

##############################################
# Gateway resource — AWS NLB annotations
# replaces Azure PLS + internal LB annotations
##############################################

resource "kubectl_manifest" "k8s_gw" {
  yaml_body = templatefile("${path.module}/k8s-manifests/k8s-gw.yaml.tpl", {
    gateway_name      = var.names[var.env].gateway_name
    gateway_namespace = kubernetes_namespace_v1.main.metadata[0].name
    load_balancer_ip  = var.names[var.env].load_balancer_ip
    # Pass public subnet IDs for NLB placement
    subnet_ids = join(",", data.aws_subnets.public.ids)
    env        = var.env
  })

  depends_on = [
    kubectl_manifest.gatewayclass,
    kubectl_manifest.gateway_api,
    helm_release.envoy_gateway
  ]
}