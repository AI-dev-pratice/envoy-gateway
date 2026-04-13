apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ${gateway_name}
  namespace: ${gateway_namespace}
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: tls-secret
        namespace: ${gateway_namespace}
    allowedRoutes:
      namespaces:
        from: All
  infrastructure:
    annotations:
      # AWS NLB — replaces Azure internal LB + PLS annotations
      service.beta.kubernetes.io/aws-load-balancer-type: "external"
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
      service.beta.kubernetes.io/aws-load-balancer-subnets: "${subnet_ids}"
      # Optional: static IP (leave empty for auto-assigned)
      %{ if load_balancer_ip != "" ~}
      service.beta.kubernetes.io/aws-load-balancer-eip-allocations: "${load_balancer_ip}"
      %{ endif ~}
      # Tagging for cost allocation
      service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: "env=${env},managed-by=terraform"