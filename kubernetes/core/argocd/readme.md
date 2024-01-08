# Argo CD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. This will be utilized in the cluster to manage and maintain the state of the cluster.

```bash
# Create the namespace in the cluster
kubectl apply -f namespace.yaml

# Add the Argo Project Helm repository
helm repo add argoproj https://argoproj.github.io/argo-helm
# Update your local Helm chart repository cache
helm repo update
# Template out and install the Argo CD Helm chart via pipe to `kubectl apply`
helm template argo-cd argoproj/argo-cd \
--version 5.51.2 --values values.yaml -n kube-system | \
kubectl apply -f -
```
