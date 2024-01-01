# Cert-Manager

Cert Manager will be used to manage certificates both inside and outside the cluster. We need to install it with Helm. Follow the steps below:

```bash
# Add the Jetstack Helm repository
helm repo add cert-manager https://charts.jetstack.io
# Update your local Helm chart repository cache
helm repo update
# Template out and install the cert-manager Helm chart via pipe to `kubectl apply`
helm template cert-manager cert-manager/cert-manager \
--values values.yaml -n kube-system | \
kubectl apply -f -
```
