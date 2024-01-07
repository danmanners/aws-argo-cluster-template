# NGINX Ingress Controller

[NGINX Ingress](https://kubernetes.github.io/ingress-nginx/) is the Ingress controller that will be used by Kubernetes. We need to install it with Helm, and you can follow the steps below:

```bash
# Add the CoreDNS Helm repository
helm repo add nginx https://kubernetes.github.io/ingress-nginx
# Update your local Helm chart repository cache
helm repo update
# Template out and install the CoreDNS Helm chart via pipe to `kubectl apply`
helm template nginx nginx/ingress-nginx -n kube-system \
--version 4.9.0 --values values.yaml | \
kubectl apply -f -
```
