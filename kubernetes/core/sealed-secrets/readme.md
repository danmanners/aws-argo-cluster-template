# Bitnami Seal Secrets

[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) is a Kubernetes Custom Resource Definition Controller which allows you to store and manage secrets in Git repositories while still being able to use them in your cluster. This will be utilized in the cluster to manage and maintain the state of the cluster. We will install the controller in the cluster and then use the `kubeseal` CLI to encrypt secrets and store them in the repository.

```bash
# Apply the namespace to the cluster
kubectl create ns sealed-secrets

# Add the Bitnami Sealed Secrets Helm repository
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
# Update your local Helm chart repository cache
helm repo update
# Template out and install the Sealed Secret Helm chart via pipe to `kubectl apply`
helm template sealed-secrets sealed-secrets/sealed-secrets
-n sealed-secrets --version 2.14.1 --values values.yaml | \
kubectl apply -f -
```
