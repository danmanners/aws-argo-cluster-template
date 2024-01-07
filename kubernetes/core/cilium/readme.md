# Cilium

Cilium is the CNI we will be using for Kubernetes. We need to install it with Helm, and you can follow the steps below:

```bash
# Add the Jetstack Helm repository
helm repo add cilium https://helm.cilium.io/
# Update your local Helm chart repository cache
helm repo update
# Template out and install the Cilium Helm chart via pipe to `kubectl apply`
helm template cilium cilium/cilium -n kube-system \
--version 1.14.5 --values values.yaml | \
kubectl apply -f -
```
