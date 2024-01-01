# ExternalDNS

[ExternalDNS](https://github.com/kubernetes-sigs/external-dns) is a Kubernetes addon that allows you to manage externally facing DNS records for service in your Kubernetes cluster. We need to install it with Helm, and you can follow the steps below:

```bash
# Add the Kubernetes SIGS Helm repository
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
# Update your local Helm chart repository cache
helm repo update
# Template out and install the ExternalDNS Helm chart via pipe to `kubectl apply`
helm template external-dns external-dns/external-dns \
-n kube-system --version 1.13.1 --values values.yaml | \
kubectl apply -f -
```
