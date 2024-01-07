# Cert-Manager

Cert Manager will be used to manage certificates both inside and outside the cluster. We need to install it with Helm. Follow the steps below:

```bash
# Fetch your public-facing DNS Servers, Replace DOMAIN with your domain
for item in $(dig cloud.danmanners.com NS +answer +short @8.8.8.8); do
    echo ${item::-1}:53;
done | xargs | sed 's/ /,/g'
# Copy the output and replace the value of `dns01RecursiveNameservers` in `values.yaml`

# Add the Jetstack Helm repository
helm repo add cert-manager https://charts.jetstack.io
# Update your local Helm chart repository cache
helm repo update
# Template out and install the cert-manager Helm chart via pipe to `kubectl apply`
helm template cert-manager cert-manager/cert-manager \
--values values.yaml --version 1.13.3 -n kube-system | \
kubectl apply -f -
```
