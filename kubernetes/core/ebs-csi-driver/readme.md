# AWS EBS CSI Driver

The AWS EBS CSI Driver is a Container Storage Interface (CSI) driver that manages the lifecycle of Amazon Elastic Block Store (EBS) volumes for Kubernetes. The driver allows you to mount persistent block storage volumes into your pods. We need to install it with Helm, and you can follow the steps below:

```bash
# Add the CoreDNS Helm repository
helm repo add aws-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
# Update your local Helm chart repository cache
helm repo update
# Template out and install the CoreDNS Helm chart via pipe to `kubectl apply`
helm template ebs aws-ebs-csi-driver/aws-ebs-csi-driver -n kube-system \
--version 2.26.0 --values values.yaml | \
kubectl apply -f -
```

aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver