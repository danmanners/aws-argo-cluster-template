# CoreDNS

[CoreDNS](https://coredns.io/) is the DNS server that will be used by Kubernetes. We need to install it with Helm, and you can follow the steps below:

```bash
# Add the CoreDNS Helm repository
helm repo add dns https://coredns.github.io/helm
# Update your local Helm chart repository cache
helm repo update
# Template out and install the CoreDNS Helm chart via pipe to `kubectl apply`
helm template coredns coredns/coredns -n kube-system \
--version 1.28.1 --values values.yaml | \
kubectl apply -f -
```
